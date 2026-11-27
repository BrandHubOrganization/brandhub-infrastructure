"""Runs the selected dumpers/restorers one at a time, syncs with S3, and records 30-day history.

Status, 30-day size delta history, and restore metadata are stored in state.json
on the container volume.
"""
import json
import logging
import re
import shutil
import subprocess
import tempfile
import threading
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Callable
from zoneinfo import ZoneInfo

from .dumpers import DUMPERS, RESTORERS, Dumper, Restorer, SkipDump

UploadFn = Callable[[Path, str], None]
DownloadFn = Callable[[str, Path], None]
ListHistoryFn = Callable[[list[str]], dict[str, list[dict]]]
_SECRET = re.compile(r"(\w+://)[^@\s/]*@")
log = logging.getLogger("db-backup")

RETENTION_DAYS = 30
LOCAL_TZ = ZoneInfo("Asia/Ho_Chi_Minh")


class BusyError(Exception):
    pass


def _now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _local_date(iso_ts: str | None = None) -> str:
    if iso_ts:
        dt = datetime.fromisoformat(iso_ts)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(LOCAL_TZ).strftime("%Y-%m-%d")
    return datetime.now(LOCAL_TZ).strftime("%Y-%m-%d")


def _error_text(exc: Exception) -> str:
    text = str(exc)
    if isinstance(exc, subprocess.CalledProcessError) and exc.stderr:
        text = exc.stderr.decode(errors="replace").strip().splitlines()[-1] if exc.stderr.strip() else text
    return _SECRET.sub(r"\1***@", text)[:500]


def _update_history(previous_history: list[dict] | None, snap: dict) -> tuple[list[dict], int]:
    """Upsert snapshot by date, retain 30 days, and compute per-day & 30-day byte deltas."""
    by_date: dict[str, dict] = {}
    cutoff = (datetime.now(LOCAL_TZ).date() - timedelta(days=RETENTION_DAYS - 1)).strftime("%Y-%m-%d")
    for item in previous_history or []:
        d = item.get("date")
        if d and d >= cutoff:
            by_date[d] = dict(item)
    by_date[snap["date"]] = dict(snap)

    ordered = sorted(by_date.values(), key=lambda x: x["date"], reverse=True)[:RETENTION_DAYS]
    for idx, item in enumerate(ordered):
        if idx + 1 < len(ordered):
            item["delta_bytes"] = int(item.get("size_bytes") or 0) - int(ordered[idx + 1].get("size_bytes") or 0)
        else:
            item["delta_bytes"] = 0

    monthly_delta = (
        int(ordered[0].get("size_bytes") or 0) - int(ordered[-1].get("size_bytes") or 0)
        if len(ordered) >= 2
        else 0
    )
    return ordered, monthly_delta


class BackupRunner:
    def __init__(
        self,
        state_file: Path,
        upload: UploadFn,
        dumpers: dict[str, Dumper] | None = None,
        download: DownloadFn | None = None,
        restorers: dict[str, Restorer] | None = None,
        list_history: ListHistoryFn | None = None,
    ):
        self.state_file = state_file
        self.upload = upload
        self.download = download
        self.dumpers = dumpers or DUMPERS
        self.restorers = restorers or RESTORERS
        self.list_history = list_history
        self._lock = threading.Lock()
        self._state_lock = threading.Lock()
        self._last_s3_sync: float | None = None
        self._mark_interrupted()

    def _mark_interrupted(self) -> None:
        """A container restart mid-run leaves queued/running entries behind; report them as failed."""
        for db, entry in self._read().items():
            if entry and entry.get("status") in ("queued", "running"):
                self._set(db, {**entry, "status": "failed", "error": "Interrupted by restart", "finished_at": _now()})

    @property
    def databases(self) -> list[str]:
        return list(self.dumpers)

    def _sync_s3_history(self, force: bool = False) -> None:
        if self.list_history is None:
            return
        now_ts = time.monotonic()
        if not force and self._last_s3_sync is not None and now_ts - self._last_s3_sync < 60:
            return
        try:
            discovered = self.list_history(list(self.dumpers))
        except Exception as exc:  # noqa: BLE001
            log.warning("S3 backup discovery skipped: %s", exc)
            return
        self._last_s3_sync = time.monotonic()
        if not any(discovered.values()):
            return
        cutoff = (datetime.now(LOCAL_TZ).date() - timedelta(days=RETENTION_DAYS - 1)).strftime("%Y-%m-%d")
        with self._state_lock:
            state = self._read()
            changed = False
            for db, s3_history in discovered.items():
                if not s3_history:
                    continue
                entry = dict(state.get(db) or {})
                by_date: dict[str, dict] = {}
                for item in entry.get("history") or []:
                    d = item.get("date")
                    if d and d >= cutoff:
                        by_date[d] = dict(item)
                for snap in s3_history:
                    d = snap.get("date")
                    if d and d >= cutoff:
                        by_date[d] = dict(snap)
                if not by_date:
                    continue
                ordered = sorted(by_date.values(), key=lambda x: x["date"], reverse=True)[:RETENTION_DAYS]
                for idx, item in enumerate(ordered):
                    if idx + 1 < len(ordered):
                        item["delta_bytes"] = int(item.get("size_bytes") or 0) - int(ordered[idx + 1].get("size_bytes") or 0)
                    else:
                        item["delta_bytes"] = 0
                monthly_delta = (
                    int(ordered[0].get("size_bytes") or 0) - int(ordered[-1].get("size_bytes") or 0)
                    if len(ordered) >= 2
                    else 0
                )
                latest = ordered[0]
                if entry.get("status") not in ("queued", "running"):
                    if not entry.get("status"):
                        entry["status"] = "success"
                        entry["action"] = "backup"
                    entry["finished_at"] = entry.get("finished_at") or latest.get("finished_at")
                    if entry.get("size_bytes") is None:
                        entry["size_bytes"] = latest.get("size_bytes")
                entry["last_success"] = {
                    "finished_at": latest.get("finished_at"),
                    "size_bytes": latest.get("size_bytes"),
                    "keys": latest.get("keys") or [],
                }
                entry["history"] = ordered
                entry["monthly_delta_bytes"] = monthly_delta
                state[db] = entry
                changed = True
            if changed:
                self.state_file.parent.mkdir(parents=True, exist_ok=True)
                tmp = self.state_file.with_suffix(".tmp")
                tmp.write_text(json.dumps(state, indent=2), encoding="utf-8")
                tmp.replace(self.state_file)

    def status(self) -> dict:
        self._sync_s3_history()
        with self._state_lock:
            state = self._read()
        return {
            "running": self._lock.locked(),
            "retention_days": RETENTION_DAYS,
            "databases": {db: state.get(db) for db in self.dumpers},
        }

    def validate(self, dbs: list[str]) -> list[str]:
        unknown = [db for db in dbs if db not in self.dumpers]
        if unknown or not dbs:
            raise ValueError(f"Unknown or empty database list: {unknown or dbs}")
        return list(dict.fromkeys(dbs))

    def start(self, dbs: list[str], trigger: str) -> None:
        """Run backup in a background thread; raises BusyError if a run is in progress."""
        dbs = self.validate(dbs)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup or restore is already running")
        for db in dbs:
            self._set(db, {"status": "queued", "action": "backup", "trigger": trigger, "queued_at": _now()})
        threading.Thread(target=self._run_locked, args=(dbs, trigger), daemon=True).start()

    def run(self, dbs: list[str], trigger: str) -> dict:
        """Run backup synchronously (scheduler, tests)."""
        dbs = self.validate(dbs)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup or restore is already running")
        self._run_locked(dbs, trigger)
        return self.status()

    def _find_snapshot(self, db: str, date: str) -> dict | None:
        state = self._read()
        entry = state.get(db) or {}
        for item in entry.get("history") or []:
            if item.get("date") == date and item.get("keys"):
                return item
        last_success = entry.get("last_success") or {}
        if last_success.get("finished_at") and _local_date(last_success["finished_at"]) == date and last_success.get("keys"):
            return last_success
        return None

    def validate_restore(self, dbs: list[str], date: str) -> list[tuple[str, dict]]:
        dbs = self.validate(dbs)
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", date or ""):
            raise ValueError(f"Invalid restore date: {date}")
        if self.download is None:
            raise ValueError("Restore downloader is not configured")
        resolved: list[tuple[str, dict]] = []
        missing = False
        with self._state_lock:
            for db in dbs:
                if db not in self.restorers:
                    raise ValueError(f"No restorer configured for {db}")
                snap = self._find_snapshot(db, date)
                if snap is None:
                    missing = True
                    break
                resolved.append((db, snap))
        if missing:
            self._sync_s3_history(force=True)
            resolved = []
            with self._state_lock:
                for db in dbs:
                    snap = self._find_snapshot(db, date)
                    if snap is None:
                        raise ValueError(f"No backup snapshot found for {db} on {date}")
                    resolved.append((db, snap))
        return resolved

    def start_restore(self, dbs: list[str], date: str, trigger: str = "restore") -> None:
        """Run point-in-time restore in a background thread."""
        resolved = self.validate_restore(dbs, date)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup or restore is already running")
        for db, _ in resolved:
            self._set(
                db,
                {
                    "status": "queued",
                    "action": "restore",
                    "restore_date": date,
                    "trigger": trigger,
                    "queued_at": _now(),
                },
            )
        threading.Thread(target=self._restore_locked, args=(resolved, date, trigger), daemon=True).start()

    def restore(self, dbs: list[str], date: str, trigger: str = "restore") -> dict:
        """Run point-in-time restore synchronously (tests)."""
        resolved = self.validate_restore(dbs, date)
        if not self._lock.acquire(blocking=False):
            raise BusyError("A backup or restore is already running")
        self._restore_locked(resolved, date, trigger)
        return self.status()

    def _run_locked(self, dbs: list[str], trigger: str) -> None:
        try:
            for db in dbs:
                self._run_one(db, trigger)
        finally:
            self._lock.release()

    def _run_one(self, db: str, trigger: str) -> None:
        entry = {"status": "running", "action": "backup", "trigger": trigger, "started_at": _now()}
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

    def _restore_locked(self, resolved: list[tuple[str, dict]], date: str, trigger: str) -> None:
        try:
            for db, snap in resolved:
                self._restore_one(db, snap, date, trigger)
        finally:
            self._lock.release()

    def _restore_one(self, db: str, snap: dict, date: str, trigger: str) -> None:
        entry = {
            "status": "running",
            "action": "restore",
            "restore_date": date,
            "trigger": trigger,
            "started_at": _now(),
        }
        self._set(db, entry)
        work = Path(tempfile.mkdtemp(prefix=f"restore-{db}-"))
        try:
            local_files: list[Path] = []
            for key in snap.get("keys") or []:
                dest = work / Path(key).name
                self.download(key, dest)  # type: ignore[misc]
                local_files.append(dest)
            self.restorers[db](local_files)
            entry.update(status="success", size_bytes=snap.get("size_bytes"))
        except SkipDump as exc:
            entry.update(status="skipped", error=str(exc))
        except Exception as exc:  # noqa: BLE001
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
            prev_history = previous.get("history") or []
            prev_monthly_delta = previous.get("monthly_delta_bytes", 0)
            prev_last_success = previous.get("last_success")
            prev_last_restore = previous.get("last_restore")

            action = entry.get("action", "backup")
            if entry["status"] == "success" and action == "backup":
                finished_at = entry.get("finished_at") or _now()
                snap = {
                    "date": _local_date(finished_at),
                    "finished_at": finished_at,
                    "size_bytes": int(entry.get("size_bytes") or 0),
                    "keys": entry.get("keys") or [],
                }
                history, monthly_delta = _update_history(prev_history, snap)
                entry = {
                    **entry,
                    "last_success": {k: entry.get(k) for k in ("finished_at", "size_bytes", "keys")},
                    "last_restore": prev_last_restore,
                    "history": history,
                    "monthly_delta_bytes": monthly_delta,
                }
            elif entry["status"] == "success" and action == "restore":
                entry = {
                    **entry,
                    "last_success": prev_last_success,
                    "last_restore": {
                        "date": entry.get("restore_date"),
                        "finished_at": entry.get("finished_at"),
                        "size_bytes": entry.get("size_bytes"),
                    },
                    "history": prev_history,
                    "monthly_delta_bytes": prev_monthly_delta,
                }
            else:
                entry = {
                    **entry,
                    "last_success": prev_last_success,
                    "last_restore": prev_last_restore,
                    "history": prev_history,
                    "monthly_delta_bytes": prev_monthly_delta,
                }

            state[db] = entry
            self.state_file.parent.mkdir(parents=True, exist_ok=True)
            tmp = self.state_file.with_suffix(".tmp")
            tmp.write_text(json.dumps(state, indent=2), encoding="utf-8")
            tmp.replace(self.state_file)
