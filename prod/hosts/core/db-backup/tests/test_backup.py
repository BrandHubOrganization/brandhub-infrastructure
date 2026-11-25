import subprocess
import threading
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from backup.app import create_app
from backup.dumpers import SkipDump
from backup.runner import BackupRunner, BusyError


def write_file(name: str, size: int = 10):
    def dumper(work: Path, ts: str):
        path = work / f"{name}-{ts}.bin"
        path.write_bytes(b"x" * size)
        return [path]
    return dumper


def skip(work, ts):
    raise SkipDump("MONGO_URI is not set")


# Built at runtime so secret scanners do not flag a fake credential in source.
FAKE_URI = "mongodb://user:" + "hunter2" + "@host/db"


def fail(work, ts):
    raise subprocess.CalledProcessError(1, ["mongodump"], stderr=f"auth failed for {FAKE_URI}".encode())


@pytest.fixture
def uploads():
    return []


def make_runner(tmp_path, uploads, **dumpers):
    return BackupRunner(tmp_path / "state.json", lambda path, key: uploads.append(key), dumpers)


def test_success_records_size_and_prefixed_keys(tmp_path, uploads):
    runner = make_runner(tmp_path, uploads, postgres=write_file("brandhub", 42))
    status = runner.run(["postgres"], trigger="manual")
    entry = status["databases"]["postgres"]
    assert entry["status"] == "success"
    assert entry["size_bytes"] == 42
    assert uploads and all(k.startswith("postgres/brandhub-") for k in uploads)
    assert entry["last_success"]["size_bytes"] == 42


def test_skipped_and_failed_are_reported_without_secrets(tmp_path, uploads):
    runner = make_runner(tmp_path, uploads, mongo=skip, neo4j=fail)
    status = runner.run(["mongo", "neo4j"], trigger="schedule")
    assert status["databases"]["mongo"]["status"] == "skipped"
    failed = status["databases"]["neo4j"]
    assert failed["status"] == "failed"
    assert "hunter2" not in failed["error"] and "***@" in failed["error"]
    assert uploads == []


def test_failure_keeps_previous_success(tmp_path, uploads):
    calls = iter([write_file("redis"), fail])
    runner = make_runner(tmp_path, uploads, redis=lambda w, t: next(calls)(w, t))
    runner.run(["redis"], "manual")
    entry = runner.run(["redis"], "manual")["databases"]["redis"]
    assert entry["status"] == "failed"
    assert entry["last_success"]["size_bytes"] == 10


def test_only_selected_databases_run(tmp_path, uploads):
    runner = make_runner(tmp_path, uploads, postgres=write_file("pg"), redis=write_file("redis"))
    status = runner.run(["redis"], "manual")
    assert status["databases"]["postgres"] is None
    assert status["databases"]["redis"]["status"] == "success"


def test_rejects_unknown_db_and_concurrent_run(tmp_path, uploads):
    gate = threading.Event()

    def slow(work, ts):
        gate.wait(5)
        return write_file("pg")(work, ts)

    runner = make_runner(tmp_path, uploads, postgres=slow)
    with pytest.raises(ValueError):
        runner.validate(["oracle"])
    runner.start(["postgres"], "manual")
    with pytest.raises(BusyError):
        runner.run(["postgres"], "manual")
    gate.set()


def test_restart_marks_running_entries_interrupted(tmp_path, uploads):
    state = tmp_path / "state.json"
    state.write_text('{"postgres": {"status": "running", "started_at": "x"}}')
    runner = BackupRunner(state, lambda p, k: None, {"postgres": write_file("pg")})
    entry = runner.status()["databases"]["postgres"]
    assert entry["status"] == "failed" and entry["error"] == "Interrupted by restart"


def test_api_requires_token_and_validates(tmp_path, uploads):
    runner = make_runner(tmp_path, uploads, postgres=write_file("pg"))
    client = TestClient(create_app(runner, token="t0ken", schedule=False))
    assert client.get("/status").status_code == 401
    assert client.get("/status", headers={"X-Backup-Token": "nope"}).status_code == 401
    ok = client.get("/status", headers={"X-Backup-Token": "t0ken"})
    assert ok.status_code == 200 and ok.json()["schedule"] == "00:00"
    bad = client.post("/run", json={"dbs": ["oracle"]}, headers={"X-Backup-Token": "t0ken"})
    assert bad.status_code == 400
    started = client.post("/run", json={"dbs": ["postgres"]}, headers={"X-Backup-Token": "t0ken"})
    assert started.status_code == 202


def test_uploads_are_tagged_for_daily_expiry(monkeypatch, tmp_path):
    import backup.app as app_module

    calls = []

    class FakeS3:
        def upload_file(self, filename, bucket, key, ExtraArgs=None):
            calls.append((bucket, key, ExtraArgs))

    monkeypatch.setattr(app_module.boto3, "client", lambda *a, **k: FakeS3())
    app_module.s3_uploader("bkt", "ap-southeast-1")(tmp_path / "x.dump", "postgres/x.dump")
    assert calls == [("bkt", "postgres/x.dump",
                      {"ServerSideEncryption": "AES256", "Tagging": "retention=daily"})]


def test_history_keeps_30_days_and_computes_deltas(tmp_path):
    from datetime import datetime, timedelta
    from zoneinfo import ZoneInfo
    from backup.runner import _update_history

    today = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).date()
    d_old_expired = (today - timedelta(days=35)).strftime("%Y-%m-%d")
    d1 = (today - timedelta(days=5)).strftime("%Y-%m-%d")
    d2 = (today - timedelta(days=1)).strftime("%Y-%m-%d")
    d3 = today.strftime("%Y-%m-%d")

    existing = [
        {"date": d_old_expired, "size_bytes": 100, "keys": ["postgres/old.dump"]},
        {"date": d1, "size_bytes": 1000, "keys": ["postgres/d1.dump"]},
        {"date": d2, "size_bytes": 1500, "keys": ["postgres/d2.dump"]},
    ]
    history, monthly_delta = _update_history(
        existing,
        {"date": d3, "finished_at": "2026-11-23T00:00:00+00:00", "size_bytes": 1200, "keys": ["postgres/d3.dump"]},
    )

    assert [h["date"] for h in history] == [d3, d2, d1]
    assert history[0]["delta_bytes"] == -300
    assert history[1]["delta_bytes"] == 500
    assert history[2]["delta_bytes"] == 0
    assert monthly_delta == 200


def test_restore_downloads_snapshot_and_records_last_restore(tmp_path):
    import json
    from datetime import datetime
    from zoneinfo import ZoneInfo

    snap_date = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).strftime("%Y-%m-%d")
    stored: dict[str, bytes] = {}
    restored_payloads: list[bytes] = []

    def upload(path: Path, key: str):
        stored[key] = path.read_bytes()

    def download(key: str, dest: Path):
        dest.write_bytes(stored[key])

    def dumper(work: Path, ts: str):
        p = work / f"brandhub-{ts}.dump"
        p.write_bytes(b"backup-v1")
        return [p]

    def restorer(files: list[Path]):
        restored_payloads.append(files[0].read_bytes())

    runner = BackupRunner(
        tmp_path / "state.json",
        upload,
        dumpers={"postgres": dumper},
        download=download,
        restorers={"postgres": restorer},
    )
    status = runner.run(["postgres"], "manual")
    assert status["retention_days"] == 30
    assert len(status["databases"]["postgres"]["history"]) == 1

    restored_status = runner.restore(["postgres"], snap_date)
    pg = restored_status["databases"]["postgres"]
    assert pg["status"] == "success"
    assert pg["action"] == "restore"
    assert pg["last_restore"]["date"] == snap_date
    assert restored_payloads == [b"backup-v1"]
    assert len(pg["history"]) == 1

    client = TestClient(create_app(runner, token="t0ken", schedule=False))
    bad_date = client.post("/restore", json={"dbs": ["postgres"], "date": "1999-01-01"}, headers={"X-Backup-Token": "t0ken"})
    assert bad_date.status_code == 400
    ok = client.post("/restore", json={"dbs": ["postgres"], "date": snap_date}, headers={"X-Backup-Token": "t0ken"})
    assert ok.status_code == 202


def test_sync_s3_history_backfills_multiday_snapshots_and_enables_restore(tmp_path):
    from datetime import datetime, timedelta
    from zoneinfo import ZoneInfo

    today = datetime.now(ZoneInfo("Asia/Ho_Chi_Minh")).date()
    d_old = (today - timedelta(days=2)).strftime("%Y-%m-%d")
    d_new = today.strftime("%Y-%m-%d")

    restored_keys: list[str] = []

    def list_history(dbs: list[str]) -> dict[str, list[dict]]:
        return {
            "postgres": [
                {
                    "date": d_new,
                    "finished_at": f"{d_new}T00:00:00+00:00",
                    "size_bytes": 2500,
                    "keys": ["postgres/brandhub-new.dump"],
                },
                {
                    "date": d_old,
                    "finished_at": f"{d_old}T00:00:00+00:00",
                    "size_bytes": 2000,
                    "keys": ["postgres/brandhub-old.dump"],
                },
            ]
        }

    runner = BackupRunner(
        tmp_path / "state.json",
        lambda p, k: None,
        dumpers={"postgres": write_file("pg")},
        download=lambda key, dest: restored_keys.append(key) or dest.write_bytes(b"dump"),
        restorers={"postgres": lambda files: None},
        list_history=list_history,
    )
    status = runner.status()
    pg = status["databases"]["postgres"]
    assert pg["status"] == "success"
    assert [h["date"] for h in pg["history"]] == [d_new, d_old]
    assert pg["history"][0]["delta_bytes"] == 500
    assert pg["history"][1]["delta_bytes"] == 0
    assert pg["monthly_delta_bytes"] == 500

    runner.restore(["postgres"], d_old)
    assert restored_keys == ["postgres/brandhub-old.dump"]


