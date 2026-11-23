"""Internal API for the db-backup container (not published outside the compose network).

GET  /status                         last result & 30-day history per database
POST /run {"dbs": []}                start a backup of the selected databases
POST /restore {"dbs": [], "date": ""} start a point-in-time restore from S3
GET  /health                         liveness, no token
"""
import hmac
import logging
import os
from contextlib import asynccontextmanager
from pathlib import Path

import boto3
from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel

from .runner import BackupRunner, BusyError

log = logging.getLogger("db-backup")
TIMEZONE = "Asia/Ho_Chi_Minh"
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
