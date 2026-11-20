"""Runs the selected dumpers one at a time, uploads to S3 and records per-DB state.

The EC2 role can only PutObject, so the status shown in Admin comes from the
state file on the container volume, never from listing the bucket.
"""
import json
import re
import shutil
import subprocess
import tempfile
import threading
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable

from .dumpers import DUMPERS, Dumper, SkipDump

Uploader = Callable[[Path, str], None]
_SECRET = re.compile(r"(\w+://)[^@\s/]*@")


class BusyError(Exception):
    pass


def _now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _error_text(exc: Exception) -> str:
    text = str(exc)
    if isinstance(exc, subprocess.CalledProcessError) and exc.stderr:
        text = exc.stderr.decode(errors="replace").strip().splitlines()[-1] if exc.stderr.strip() else text
    return _SECRET.sub(r"\1***@", text)[:500]


class BackupRunner:
    def __init__(self, state_file: Path, upload: Uploader, dumpers: dict[str, Dumper] | None = None):
        self.state_file = state_file
        self.upload = upload
        self.dumpers = dumpers or DUMPERS
        self._lock = threading.Lock()
        self._state_lock = threading.Lock()
        self._mark_interrupted()

    def _mark_interrupted(self) -> None:
        """A container restart mid-run leaves queued/running entries behind; report them as failed."""
        for db, entry in self._read().items():
            if entry and entry.get("status") in ("queued", "running"):
                self._set(db, {**entry, "status": "failed", "error": "Interrupted by restart", "finished_at": _now()})

    @property
    def databases(self) -> list[str]:
        return list(self.dumpers)

    def status(self) -> dict:
        with self._state_lock:
            state = self._read()
        return {"running": self._lock.locked(), "databases": {db: state.get(db) for db in self.dumpers}}

    def validate(self, dbs: list[str]) -> list[str]:
        unknown = [db for db in dbs if db not in self.dumpers]
        if unknown or not dbs:
            raise ValueError(f"Unknown or empty database list: {unknown or dbs}")
        return list(dict.fromkeys(dbs))

    def start(self, dbs: list[str], trigger: str) -> None:
        """Run in a background thread; raises BusyError if a run is in progress."""
        dbs = self.validate(dbs)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup is already running")
        for db in dbs:
            self._set(db, {"status": "queued", "trigger": trigger, "queued_at": _now()})
        threading.Thread(target=self._run_locked, args=(dbs, trigger), daemon=True).start()

    def run(self, dbs: list[str], trigger: str) -> dict:
        """Run synchronously (scheduler, tests)."""
        dbs = self.validate(dbs)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup is already running")
        self._run_locked(dbs, trigger)
        return self.status()

    def _run_locked(self, dbs: list[str], trigger: str) -> None:
        try:
            for db in dbs:
                self._run_one(db, trigger)
        finally:
            self._lock.release()

    def _run_one(self, db: str, trigger: str) -> None:
        entry = {"status": "running", "trigger": trigger, "started_at": _now()}
        self._set(db, entry)
        ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        work = Path(tempfile.mkdtemp(prefix=f"backup-{db}-"))
        try:
            files = self.dumpers[db](work, ts)
            keys = []
            for path in files:
                key = f"{db}/{path.name}"
                self.upload(path, key)
                keys.append(key)
            entry.update(status="success", size_bytes=sum(p.stat().st_size for p in files), keys=keys)
        except SkipDump as exc:
            entry.update(status="skipped", error=str(exc))
        except Exception as exc:  # noqa: BLE001 - every failure is reported per DB
            entry.update(status="failed", error=_error_text(exc))
        finally:
            shutil.rmtree(work, ignore_errors=True)
        entry["finished_at"] = _now()
        self._set(db, entry)

    def _read(self) -> dict:
        try:
            return json.loads(self.state_file.read_text(encoding="utf-8"))
        except (FileNotFoundError, json.JSONDecodeError):
            return {}

    def _set(self, db: str, entry: dict) -> None:
        with self._state_lock:
            state = self._read()
            previous = state.get(db) or {}
            # Keep the last finished result visible while a new run is queued/running.
            if entry["status"] in ("queued", "running"):
                entry = {**entry, "last_success": previous.get("last_success")}
            elif entry["status"] == "success":
                entry = {**entry, "last_success": {k: entry.get(k) for k in ("finished_at", "size_bytes", "keys")}}
            else:
                entry = {**entry, "last_success": previous.get("last_success")}
            state[db] = entry
            self.state_file.parent.mkdir(parents=True, exist_ok=True)
            tmp = self.state_file.with_suffix(".tmp")
            tmp.write_text(json.dumps(state, indent=2), encoding="utf-8")
            tmp.replace(self.state_file)
