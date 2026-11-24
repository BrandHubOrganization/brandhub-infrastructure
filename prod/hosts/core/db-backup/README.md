# `db-backup` (Daily DB Dumps & Point-in-Time Restore → S3)

- Back to [All Hosts](../../README.md) · [Production Hub](../../../README.md)
- CI Workflow: [`.github/workflows/prod-db-backup-image.yml`](../../../../.github/workflows/prod-db-backup-image.yml)
- S3 & IAM Terraform: [`prod/terraform/03-backend/backup.tf`](../../../terraform/03-backend/backup.tf)

Runs on `brandhub-core-services` (`172.31.24.149`) as the `db-backup` container in [`../core.compose.json`](../core.compose.json).

---

## Behavior & S3 Retention

- **Schedule**: `00:00 Asia/Ho_Chi_Minh` daily via APScheduler inside the container, dumping all five databases sequentially.
- **Target**: `s3://brandhub-db-backup-prd-134875421878/<db>/` with `AES256` server-side encryption.
- **Retention**: Each dump is tagged `retention=daily` and expires after **30 days** (`db_backup_retention_days = 30`). Untagged baseline snapshots in the bucket are kept indefinitely.
- **IAM Permissions (`brandhub-ec2-ecr-pull`)**: `s3:ListBucket` on the backup bucket plus `s3:PutObject`, `s3:PutObjectTagging`, and `s3:GetObject` under `postgres/*`, `redis/*`, `chroma/*`, `mongo/*`, and `neo4j/*` (enabling both automated dumps and point-in-time `POST /restore`, without `s3:DeleteObject`).
- **Graceful skip**: Any database whose connection env var is omitted is recorded as `skipped` rather than failing the run.

| DB | Source | S3 Object Key(s) |
| :--- | :--- | :--- |
| `postgres` | `postgres` container | `postgres/<db>-<ts>.dump` (`pg_dump -Fc`, verified via `pg_restore -l`) + `postgres/globals-<ts>.sql.gz` (no role passwords) |
| `redis` | `redis` container | `redis/redis-<ts>.rdb.gz` (restore supports `.jsonl.gz` via `redis-py` or `.rdb.gz` when `REDIS_DATA_DIR` is mounted) |
| `chroma` | `brandhub-chroma-data` volume mounted **read-write** at `/chroma` | `chroma/chroma-<ts>.tar.gz` |
| `mongo` | `MONGO_URI` (MongoDB Atlas) | `mongo/mongo-<ts>.archive.gz` (`mongodump --archive --gzip`) |
| `neo4j` | `NEO4J_URI` (Neo4j Aura) | `neo4j/neo4j-<ts>.jsonl.gz` (nodes + relationships exported over Bolt) |

---

## Internal HTTP API (`http://db-backup:8090`)

Not published outside `brandhub-network`. All endpoints except `/health` require `X-Backup-Token: <BACKUP_TOKEN>` (called by `brandhub-business-service` for the `Admin` Recovery UI at `/api/v1/admin/backups`):

| Endpoint | Description |
| :--- | :--- |
| `GET /health` | Liveness check (no token required) |
| `GET /status` | Latest run status & 30-day history per database |
| `POST /run` | `{"dbs": ["postgres", ...]}` — Trigger immediate on-demand backup (`202 Accepted`) |
| `POST /restore` | `{"dbs": ["postgres", ...], "date": "YYYY-MM-DD"}` — Download snapshot from S3 and run point-in-time restore (`202 Accepted`) |

---

## Setup on `brandhub-core-services`

Create `~/brandhub/ecr/env/db-backup.env` (`chmod 600`):

```dotenv
PGUSER=<POSTGRES_USER from postgres.env>
PGPASSWORD=<POSTGRES_PASSWORD>
PGDATABASE=<POSTGRES_DB>
REDIS_PASSWORD=<from redis.env>
MONGO_URI=<MongoDB Atlas URI>
NEO4J_URI=<neo4j+s://...>
NEO4J_USERNAME=<user>
NEO4J_PASSWORD=<password>
BACKUP_TOKEN=<random secret matching BACKUP_TOKEN in business-service.env>
```

Set `BACKUP_SERVICE_URL=http://db-backup:8090` and the matching `BACKUP_TOKEN` in `env/business-service.env`, set `DB_BACKUP_IMAGE` in `~/brandhub/ecr/.env` (printed by the [`prod-db-backup-image.yml`](../../../../.github/workflows/prod-db-backup-image.yml) workflow), and start:

```bash
docker compose -f core.compose.json up -d db-backup
```

Inspect state on host: `docker exec brandhub-db-backup cat /var/lib/db-backup/state.json`.

---

## Manual CLI Restore Fallback (Maintenance Window)

In addition to `POST /restore` from the `Admin` Recovery panel, operators can manually pull and restore dumps during a maintenance window:

```bash
B=s3://brandhub-db-backup-prd-134875421878
# postgres: restore into a staging DB or clean swap (stop business/publisher first)
aws s3 cp "$B/postgres/brandhub-<ts>.dump" /var/tmp/restore.dump
docker exec -i brandhub-postgres sh -c 'createdb -U "$POSTGRES_USER" brandhub_restore && pg_restore -U "$POSTGRES_USER" -d brandhub_restore --no-owner' < /var/tmp/restore.dump

# mongo
aws s3 cp "$B/mongo/mongo-<ts>.archive.gz" /var/tmp/mongo.archive.gz && mongorestore --uri="$MONGO_URI" --archive=/var/tmp/mongo.archive.gz --gzip --drop
```

Remove temporary files under `/var/tmp` immediately after verification.

---

## Unit Tests

```bash
python -m pip install -r requirements-dev.txt
python -m pytest -q
```
