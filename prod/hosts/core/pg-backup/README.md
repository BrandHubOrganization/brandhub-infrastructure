# Postgres backup (pg_dump → S3)

Production uses daily `pg_dump` instead of EBS snapshots.

- Host: core EC2 (`i-01cba58d9f08be748`), container `brandhub-postgres`.
- Schedule: `brandhub-pg-backup.timer`, daily 19:00 UTC (02:00 Vietnam), `Persistent=true` so a missed run fires after boot.
- Target: `s3://brandhub-db-backup-prd-134875421878/postgres/` (`<db>-<ts>.dump` custom format + `globals-<ts>.sql.gz`, no role passwords). SSE-S3, TLS only, kept 14 days (`db_backup_retention_days` in `terraform/3-backend`).
- The EC2 role can only `PutObject`; it cannot list, read or delete dumps. Restore with an admin AWS identity.

## Install / update

```bash
sudo install -m 750 brandhub-pg-backup.sh /usr/local/bin/brandhub-pg-backup.sh
sudo install -m 644 brandhub-pg-backup.service brandhub-pg-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now brandhub-pg-backup.timer
```

Run now: `sudo systemctl start brandhub-pg-backup.service`, logs: `journalctl -u brandhub-pg-backup.service`.

## Restore

```bash
aws s3 cp s3://brandhub-db-backup-prd-134875421878/postgres/brandhub-<ts>.dump /var/tmp/restore.dump
docker exec -i brandhub-postgres sh -c 'createdb -U "$POSTGRES_USER" brandhub_restore && pg_restore -U "$POSTGRES_USER" -d brandhub_restore --no-owner' < /var/tmp/restore.dump
```

Check `brandhub_restore`, then swap databases during a maintenance window (stop Business/Publisher first). Remove `/var/tmp/restore.dump` afterwards.
