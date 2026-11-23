"""One dump function per database. Each writes files into `work` and returns them.

A dumper raises SkipDump when the database is not configured on this host, so a
missing Mongo/Neo4j URI is reported as "skipped" instead of a failure.
"""
import gzip
import json
import os
import shutil
import subprocess
import tarfile
from pathlib import Path
from typing import Callable


class SkipDump(Exception):
    pass


Dumper = Callable[[Path, str], list[Path]]
Restorer = Callable[[list[Path]], None]


def _env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise SkipDump(f"{name} is not set")
    return value


def _run(cmd: list[str], out: Path, env: dict | None = None) -> None:
    with open(out, "wb") as fh:
        subprocess.run(cmd, stdout=fh, stderr=subprocess.PIPE, check=True, env=env, timeout=3600)


def dump_postgres(work: Path, ts: str) -> list[Path]:
    db = _env("PGDATABASE")
    _env("PGHOST")
    dump = work / f"{db}-{ts}.dump"
    _run(["pg_dump", "-Fc", "-Z", "6", "-d", db], dump)
    subprocess.run(["pg_restore", "-l", str(dump)], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                   check=True, timeout=600)
    globals_sql = work / f"globals-{ts}.sql"
    _run(["pg_dumpall", "--globals-only", "--no-role-passwords"], globals_sql)
    return [dump, _gzip(globals_sql)]


def dump_redis(work: Path, ts: str) -> list[Path]:
    host = _env("REDIS_HOST")
    env = {**os.environ, "REDISCLI_AUTH": os.environ.get("REDIS_PASSWORD", "")}
    rdb = work / f"redis-{ts}.rdb"
    subprocess.run(["redis-cli", "-h", host, "-p", os.environ.get("REDIS_PORT", "6379"), "--rdb", str(rdb)],
                   stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, check=True, env=env, timeout=1800)
    return [_gzip(rdb)]


def dump_chroma(work: Path, ts: str) -> list[Path]:
    src = Path(_env("CHROMA_DATA_DIR"))
    if not src.is_dir():
        raise FileNotFoundError(f"{src} is not mounted")
    out = work / f"chroma-{ts}.tar.gz"
    with tarfile.open(out, "w:gz") as tar:
        tar.add(src, arcname="chroma")
    return [out]


def dump_mongo(work: Path, ts: str) -> list[Path]:
    uri = _env("MONGO_URI")
    out = work / f"mongo-{ts}.archive.gz"
    subprocess.run(["mongodump", f"--uri={uri}", f"--archive={out}", "--gzip", "--quiet"],
                   stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, check=True, timeout=3600)
    return [out]


def dump_neo4j(work: Path, ts: str) -> list[Path]:
    """Neo4j Aura does not allow neo4j-admin dump, so export the graph as JSONL over bolt."""
    from neo4j import GraphDatabase

    uri = _env("NEO4J_URI")
    auth = (os.environ.get("NEO4J_USERNAME", "neo4j"), _env("NEO4J_PASSWORD"))
    out = work / f"neo4j-{ts}.jsonl.gz"
    queries = {
        "node": "MATCH (n) RETURN elementId(n) AS id, labels(n) AS labels, properties(n) AS props",
        "rel": "MATCH (a)-[r]->(b) RETURN elementId(r) AS id, type(r) AS type, elementId(a) AS start, "
               "elementId(b) AS end, properties(r) AS props",
    }
    with GraphDatabase.driver(uri, auth=auth) as driver, gzip.open(out, "wt", encoding="utf-8") as fh:
        db = os.environ.get("NEO4J_DATABASE") or None
        with driver.session(database=db) as session:
            for kind, query in queries.items():
                for record in session.run(query):
                    fh.write(json.dumps({"kind": kind, **record.data()}, default=str, ensure_ascii=False) + "\n")
    return [out]


def _gzip(path: Path) -> Path:
    out = path.with_name(path.name + ".gz")
    with open(path, "rb") as src, gzip.open(out, "wb") as dst:
        while chunk := src.read(1 << 20):
            dst.write(chunk)
    path.unlink()
    return out


DUMPERS: dict[str, Dumper] = {
    "postgres": dump_postgres,
    "mongo": dump_mongo,
    "redis": dump_redis,
    "chroma": dump_chroma,
    "neo4j": dump_neo4j,
}


def restore_postgres(files: list[Path]) -> None:
    """Restore a PostgreSQL custom-format dump with --clean --if-exists."""
    db = _env("PGDATABASE")
    _env("PGHOST")
    dump = next((f for f in files if f.name.endswith(".dump")), None)
    if dump is None:
        raise FileNotFoundError("PostgreSQL .dump file missing from backup snapshot")
    subprocess.run(
        ["pg_restore", "--clean", "--if-exists", "--no-owner", "-d", db, str(dump)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        check=True,
        timeout=3600,
    )


def restore_mongo(files: list[Path]) -> None:
    """Restore MongoDB archive with --drop to roll back to snapshot."""
    uri = _env("MONGO_URI")
    archive = next((f for f in files if f.name.endswith(".archive.gz")), None)
    if archive is None:
        raise FileNotFoundError("MongoDB .archive.gz file missing from backup snapshot")
    subprocess.run(
        ["mongorestore", f"--uri={uri}", f"--archive={archive}", "--gzip", "--drop", "--quiet"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        check=True,
        timeout=3600,
    )


def restore_redis(files: list[Path]) -> None:
    """Restore Redis keys from a JSONL dump or report unsupported RDB over remote TCP."""
    host = _env("REDIS_HOST")
    port = int(os.environ.get("REDIS_PORT", "6379"))
    password = os.environ.get("REDIS_PASSWORD", "") or None
    jsonl = next((f for f in files if f.name.endswith(".jsonl.gz")), None)
    if jsonl is not None:
        import redis as redis_lib

        client = redis_lib.Redis(host=host, port=port, password=password, decode_responses=False, socket_timeout=15)
        client.flushall()
        with gzip.open(jsonl, "rt", encoding="utf-8") as fh:
            for line in fh:
                if not line.strip():
                    continue
                rec = json.loads(line)
                pttl = max(0, int(rec.get("pttl") or 0))
                client.restore(rec["key"], pttl, bytes.fromhex(rec["dump_hex"]), replace=True)
        return

    rdb = next((f for f in files if f.name.endswith(".rdb.gz")), None)
    if rdb is None:
        raise FileNotFoundError("Redis snapshot file missing from backup snapshot")
    # If REDIS_DATA_DIR is mounted (optional), write dump.rdb and trigger restart/shutdown;
    # otherwise flush and inform caller if RDB-level restore requires container restart.
    data_dir = os.environ.get("REDIS_DATA_DIR", "").strip()
    if data_dir:
        target = Path(data_dir) / "dump.rdb"
        with gzip.open(rdb, "rb") as src, open(target, "wb") as dst:
            shutil.copyfileobj(src, dst)
        return
    raise SkipDump("Redis RDB restore requires REDIS_DATA_DIR mount or JSONL snapshot")


def restore_chroma(files: list[Path]) -> None:
    """Clear and extract ChromaDB tar.gz snapshot into CHROMA_DATA_DIR."""
    src_dir = Path(_env("CHROMA_DATA_DIR"))
    archive = next((f for f in files if f.name.endswith(".tar.gz")), None)
    if archive is None:
        raise FileNotFoundError("ChromaDB .tar.gz file missing from backup snapshot")
    if not src_dir.is_dir():
        raise FileNotFoundError(f"{src_dir} is not mounted")
    for item in src_dir.iterdir():
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()
    with tarfile.open(archive, "r:gz") as tar:
        members = []
        for m in tar.getmembers():
            # Strip leading 'chroma/' prefix if archived via tar.add(src, arcname='chroma')
            if m.name == "chroma":
                continue
            if m.name.startswith("chroma/"):
                m.name = m.name[len("chroma/"):]
            if m.name and not m.name.startswith("/") and ".." not in Path(m.name).parts:
                members.append(m)
        tar.extractall(src_dir, members=members)


def restore_neo4j(files: list[Path]) -> None:
    """Clear Neo4j graph and recreate nodes and relationships from JSONL snapshot."""
    from neo4j import GraphDatabase

    uri = _env("NEO4J_URI")
    auth = (os.environ.get("NEO4J_USERNAME", "neo4j"), _env("NEO4J_PASSWORD"))
    jsonl = next((f for f in files if f.name.endswith(".jsonl.gz")), None)
    if jsonl is None:
        raise FileNotFoundError("Neo4j .jsonl.gz file missing from backup snapshot")

    nodes: list[dict] = []
    rels: list[dict] = []
    with gzip.open(jsonl, "rt", encoding="utf-8") as fh:
        for line in fh:
            if not line.strip():
                continue
            rec = json.loads(line)
            if rec.get("kind") == "node":
                nodes.append(rec)
            elif rec.get("kind") == "rel":
                rels.append(rec)

    with GraphDatabase.driver(uri, auth=auth) as driver:
        db = os.environ.get("NEO4J_DATABASE") or None
        with driver.session(database=db) as session:
            session.run("MATCH (n) DETACH DELETE n")
            id_map: dict[str, int] = {}
            for node in nodes:
                labels = [lbl for lbl in (node.get("labels") or []) if lbl.isidentifier()]
                label_clause = "".join(f":{lbl}" for lbl in labels)
                rec = session.run(
                    f"CREATE (n{label_clause} $props) RETURN id(n) AS nid",
                    props=node.get("props") or {},
                ).single()
                if rec is not None and node.get("id") is not None:
                    id_map[str(node["id"])] = rec["nid"]
            for rel in rels:
                start_id = id_map.get(str(rel.get("start")))
                end_id = id_map.get(str(rel.get("end")))
                rel_type = rel.get("type") or "RELATED"
                if start_id is None or end_id is None or not rel_type.replace("_", "").isalnum():
                    continue
                session.run(
                    f"MATCH (a), (b) WHERE id(a) = $start AND id(b) = $end "
                    f"CREATE (a)-[r:{rel_type} $props]->(b)",
                    start=start_id,
                    end=end_id,
                    props=rel.get("props") or {},
                )


RESTORERS: dict[str, Restorer] = {
    "postgres": restore_postgres,
    "mongo": restore_mongo,
    "redis": restore_redis,
    "chroma": restore_chroma,
    "neo4j": restore_neo4j,
}
