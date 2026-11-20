# db-backup (DB dumps → S3)

Replaces the old `pg-backup` systemd job. Runs on the core EC2 as the `db-backup` service in `core.compose.json`.

- Schedule: 00:00 Asia/Ho_Chi_Minh every day (APScheduler inside the container), all five databases one after another.
- Target: `s3://brandhub-db-backup-prd-134875421878/<db>/`, SSE-S3. Each dump is tagged `retention=daily` and expires after 1 day (`db_backup_retention_days`), so only the latest copy stays. Files without that tag (older dumps already in the bucket) are never expired.
- The EC2 role can only `PutObject` under `postgres/ redis/ chroma/ mongo/ neo4j/`; it cannot list, read or delete dumps. Restore with an admin AWS identity.
- Admin → Recovery shows the last result per DB and can start "Backup now" for selected DBs through business-service (`/api/v1/admin/backups`).
- A DB whose env is missing is reported as `skipped`, not failed.

| DB | Source | File |
| :--- | :--- | :--- |
| postgres | `postgres` container | `postgres/<db>-<ts>.dump` (`pg_dump -Fc`, checked with `pg_restore -l`) + `postgres/globals-<ts>.sql.gz` (no role passwords) |
| redis | `redis` container | `redis/redis-<ts>.rdb.gz` |
| chroma | `brandhub-chroma-data` volume, mounted read-only | `chroma/chroma-<ts>.tar.gz` |
| mongo | `MONGO_URI` (external) | `mongo/mongo-<ts>.archive.gz` (`mongodump --archive --gzip`) |
| neo4j | `NEO4J_URI` (Aura) | `neo4j/neo4j-<ts>.jsonl.gz` (one JSON line per node, then per relationship) |

## Setup on core

`~/brandhub/ecr/env/db-backup.env` (0600):

```
PGUSER=<POSTGRES_USER from postgres.env>
PGPASSWORD=<POSTGRES_PASSWORD>
PGDATABASE=<POSTGRES_DB>
REDIS_PASSWORD=<from redis.env>
MONGO_URI=<external Mongo URI>
NEO4J_URI=<neo4j+s://...>
NEO4J_USERNAME=<user>
NEO4J_PASSWORD=<password>
BACKUP_TOKEN=<random, same value as BACKUP_TOKEN in business-service.env>
```

Add to `env/business-service.env`: `BACKUP_SERVICE_URL=http://db-backup:8090` and the same `BACKUP_TOKEN`.

Set `DB_BACKUP_IMAGE` in `~/brandhub/ecr/.env` (tag printed by the "DB Backup Image" workflow), then:

```bash
docker compose -f core.compose.json up -d db-backup
sudo systemctl disable --now brandhub-pg-backup.timer   # old job, if still installed
```

Run now: Admin → Recovery → "Backup now", or from the host
`docker exec brandhub-db-backup python -c "from backup.app import *; import os; from pathlib import Path; from backup.runner import BackupRunner; BackupRunner(Path('/var/lib/db-backup/state.json'), s3_uploader(os.environ['BACKUP_BUCKET'], 'ap-southeast-1')).run(['postgres'], 'manual')"`.
State: `docker exec brandhub-db-backup cat /var/lib/db-backup/state.json`.

## Restore (admin AWS identity, maintenance window)

```bash
B=s3://brandhub-db-backup-prd-134875421878
# postgres: restore into a new DB, check it, then swap (stop Business/Publisher first)
aws s3 cp $B/postgres/brandhub-<ts>.dump /var/tmp/restore.dump
docker exec -i brandhub-postgres sh -c 'createdb -U "$POSTGRES_USER" brandhub_restore && pg_restore -U "$POSTGRES_USER" -d brandhub_restore --no-owner' < /var/tmp/restore.dump
# redis: stop redis, replace dump, start (appendonly must be off for the first start, then rewrite AOF)
aws s3 cp $B/redis/redis-<ts>.rdb.gz - | gunzip > /var/tmp/dump.rdb
# chroma: stop chromadb, extract into the brandhub-chroma-data volume
aws s3 cp $B/chroma/chroma-<ts>.tar.gz /var/tmp/chroma.tar.gz
# mongo
aws s3 cp $B/mongo/mongo-<ts>.archive.gz /var/tmp/mongo.archive.gz && mongorestore --uri="$MONGO_URI" --archive=/var/tmp/mongo.archive.gz --gzip
# neo4j: JSONL export; re-create nodes by label/properties, then relationships by start/end id
```

Remove files in `/var/tmp` afterwards.

## Tests

```bash
python -m venv .venv && .venv/bin/pip install -r requirements-dev.txt && .venv/bin/python -m pytest -q
```
