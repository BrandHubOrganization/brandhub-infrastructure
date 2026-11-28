"""Internal API for the db-backup container (not published outside the compose network).

GET  /status                         last result & 30-day history per database
POST /run {"dbs": []}                start a backup of the selected databases
POST /restore {"dbs": [], "date": ""} start a point-in-time restore from S3
GET  /health                         liveness, no token
"""
import hmac
import logging
import os
import re
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

import boto3
from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel

from .runner import BackupRunner, BusyError, RETENTION_DAYS

log = logging.getLogger("db-backup")
TIMEZONE = "Asia/Ho_Chi_Minh"
LOCAL_TZ = ZoneInfo(TIMEZONE)
_TS_RE = re.compile(r"-(\d{8}T\d{6}Z)\.")
# The bucket lifecycle expires only objects with this tag after db_backup_retention_days (30d).
UPLOAD_ARGS = {"ServerSideEncryption": "AES256", "Tagging": "retention=daily"}


def s3_uploader(bucket: str, region: str):
    client = boto3.client("s3", region_name=region)

    def upload(path: Path, key: str) -> None:
        client.upload_file(str(path), bucket, key, ExtraArgs=UPLOAD_ARGS)

    return upload


def s3_downloader(bucket: str, region: str):
    client = boto3.client("s3", region_name=region)

    def download(key: str, dest: Path) -> None:
        client.download_file(bucket, key, str(dest))

    return download


def s3_history_lister(bucket: str, region: str):
    client = boto3.client("s3", region_name=region)

    def list_history(dbs: list[str]) -> dict[str, list[dict]]:
        cutoff = (datetime.now(LOCAL_TZ).date() - timedelta(days=RETENTION_DAYS - 1)).strftime("%Y-%m-%d")
        paginator = client.get_paginator("list_objects_v2")
        result: dict[str, list[dict]] = {}
        for db in dbs:
            by_date: dict[str, dict] = {}
            try:
                for page in paginator.paginate(Bucket=bucket, Prefix=f"{db}/"):
                    for obj in page.get("Contents") or []:
                        key = obj.get("Key") or ""
                        if not key or key.endswith("/") or "before-restore" in key:
                            continue
                        match = _TS_RE.search(key)
                        if match:
                            dt = datetime.strptime(match.group(1), "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc)
                        else:
                            dt = obj.get("LastModified")
                            if not isinstance(dt, datetime):
                                continue
                            if dt.tzinfo is None:
                                dt = dt.replace(tzinfo=timezone.utc)
                        date_str = dt.astimezone(LOCAL_TZ).strftime("%Y-%m-%d")
                        if date_str < cutoff:
                            continue
                        iso_ts = dt.astimezone(timezone.utc).isoformat(timespec="seconds")
                        size = int(obj.get("Size") or 0)
                        slot = by_date.get(date_str)
                        if slot is None:
                            by_date[date_str] = {
                                "date": date_str,
                                "finished_at": iso_ts,
                                "size_bytes": size,
                                "keys": [key],
                            }
                        else:
                            slot["size_bytes"] += size
                            slot["keys"].append(key)
                            if iso_ts > slot["finished_at"]:
                                slot["finished_at"] = iso_ts
            except Exception as exc:  # noqa: BLE001
                log.warning("Failed to list S3 backups for %s: %s", db, exc)
                continue
            ordered = sorted(by_date.values(), key=lambda x: x["date"], reverse=True)[:RETENTION_DAYS]
            for idx, item in enumerate(ordered):
                if idx + 1 < len(ordered):
                    item["delta_bytes"] = int(item["size_bytes"]) - int(ordered[idx + 1]["size_bytes"])
                else:
                    item["delta_bytes"] = 0
            result[db] = ordered
        return result

    return list_history


def create_app(runner: BackupRunner | None = None, token: str | None = None, schedule: bool = True) -> FastAPI:
    token = token if token is not None else os.environ.get("BACKUP_TOKEN", "")
    if not token:
        raise RuntimeError("BACKUP_TOKEN is required")
    bucket = os.environ.get("BACKUP_BUCKET", "")
    region = os.environ.get("AWS_REGION", "ap-southeast-1")
    runner = runner or BackupRunner(
        Path(os.environ.get("BACKUP_STATE_FILE", "/var/lib/db-backup/state.json")),
        s3_uploader(bucket, region),
        download=s3_downloader(bucket, region),
        list_history=s3_history_lister(bucket, region) if bucket else None,
    )

    def nightly() -> None:
        try:
            runner.run(runner.databases, trigger="schedule")
        except BusyError:
            log.warning("nightly backup skipped: a run is in progress")

    @asynccontextmanager
    async def lifespan(_: FastAPI):
        scheduler = None
        if schedule:
            scheduler = BackgroundScheduler(timezone=TIMEZONE)
            scheduler.add_job(nightly, "cron", hour=0, minute=0, misfire_grace_time=3600, coalesce=True)
            scheduler.start()
        yield
        if scheduler:
            scheduler.shutdown(wait=False)

    app = FastAPI(title="db-backup", lifespan=lifespan, docs_url=None, redoc_url=None, openapi_url=None)

    def authorize(x_backup_token: str = Header(default="")) -> None:
        if not hmac.compare_digest(x_backup_token.encode(), token.encode()):
            raise HTTPException(status_code=401, detail="Invalid backup token")

    class RunRequest(BaseModel):
        dbs: list[str]

    class RestoreRequest(BaseModel):
        dbs: list[str]
        date: str

    @app.get("/health")
    def health() -> dict:
        return {"status": "ok"}

    @app.get("/status", dependencies=[Depends(authorize)])
    def status() -> dict:
        return {"timezone": TIMEZONE, "schedule": "00:00", **runner.status()}

    @app.post("/run", status_code=202, dependencies=[Depends(authorize)])
    def run(body: RunRequest) -> dict:
        try:
            runner.start(body.dbs, trigger="manual")
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except BusyError as exc:
            raise HTTPException(status_code=409, detail=str(exc)) from exc
        return runner.status()

    @app.post("/restore", status_code=202, dependencies=[Depends(authorize)])
    def restore(body: RestoreRequest) -> dict:
        try:
            runner.start_restore(body.dbs, body.date, trigger="restore")
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except BusyError as exc:
            raise HTTPException(status_code=409, detail=str(exc)) from exc
        return runner.status()

    return app
