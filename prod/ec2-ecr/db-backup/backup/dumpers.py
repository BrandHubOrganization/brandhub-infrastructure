"""One dump function per database. Each writes files into `work` and returns them.

A dumper raises SkipDump when the database is not configured on this host, so a
missing Mongo/Neo4j URI is reported as "skipped" instead of a failure.
"""
import gzip
import json
import os
import subprocess
import tarfile
from pathlib import Path
from typing import Callable


class SkipDump(Exception):
    pass


Dumper = Callable[[Path, str], list[Path]]


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
