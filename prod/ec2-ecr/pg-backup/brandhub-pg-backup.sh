#!/bin/bash
# Daily Postgres backup: pg_dump (custom format) + globals -> S3. Installed at
# /usr/local/bin/brandhub-pg-backup.sh on the service EC2, run by brandhub-pg-backup.timer.
set -euo pipefail

BUCKET="${BACKUP_BUCKET:-brandhub-db-backup-prd-821014378805}"
CONTAINER="${PG_CONTAINER:-brandhub-postgres}"
REGION="${AWS_REGION:-ap-southeast-1}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
WORK="$(mktemp -d /var/tmp/pg-backup.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
umask 077

DB_USER="$(docker exec "$CONTAINER" printenv POSTGRES_USER)"
DB_NAME="$(docker exec "$CONTAINER" printenv POSTGRES_DB)"

docker exec "$CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" -Fc -Z 6 > "$WORK/db.dump"
docker exec "$CONTAINER" pg_dumpall -U "$DB_USER" --globals-only --no-role-passwords | gzip -9 > "$WORK/globals.sql.gz"

# Verify the archive is readable before uploading.
docker exec -i "$CONTAINER" pg_restore -l < "$WORK/db.dump" > /dev/null
SIZE="$(stat -c %s "$WORK/db.dump")"
[ "$SIZE" -gt 1024 ] || { echo "dump too small: $SIZE bytes" >&2; exit 1; }

aws s3 cp --region "$REGION" --only-show-errors "$WORK/db.dump" "s3://$BUCKET/postgres/$DB_NAME-$TS.dump"
aws s3 cp --region "$REGION" --only-show-errors "$WORK/globals.sql.gz" "s3://$BUCKET/postgres/globals-$TS.sql.gz"
echo "uploaded $DB_NAME-$TS.dump ($SIZE bytes) to s3://$BUCKET/postgres/"
