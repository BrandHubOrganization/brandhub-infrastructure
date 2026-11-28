# Local Database Seeding & Snapshot Restoration (`docker/compose/seed-guide.md`)

- Back to [Docker & Compose Manual](../README.md) · [Operational Database Manual](../../database/README.md) · [Backup & Restore Scripts](../../database/backups/README.md)

> **Architecture Note**: Legacy standalone `seed-postgres.yml` and `seed-mongo.yml` Compose containers were retired in V2. Schema initialization now runs automatically via Docker entrypoint bind-mounts, while synthetic demo data and team snapshots are loaded via `brandhub-business-service` (`DataSeeder`) or `database/backups/restore-*`.

---

## 1. Automatic Schema Bootstrap (Empty Docker Volumes)

When starting [`../run_dev.bat`](../run_dev.bat) or [`../run_dev_ai.bat`](../run_dev_ai.bat) with fresh named volumes (`brandhub-postgres-v2-data` and `brandhub-mongodb-data`), `shared/databases.yaml` automatically runs:

1. [`../../database/init/init-postgres-v2.sql`](../../database/init/init-postgres-v2.sql) — Bootstraps all **97 PostgreSQL tables**, triggers, `brandhub_schema_migrations`, and seeds the **6 active subscription plans**:
   - **Personal Studio (`PERSONAL`)**: `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`
   - **Agency (`AGENCY`)**: `BASIC`, `PLUS`, `ENTERPRISE` (billed via **SePay VietQR** `SEEPAY`)
2. [`../../database/init/init-mongo.js`](../../database/init/init-mongo.js) — Bootstraps all **52 MongoDB collections**, `$jsonSchema` validators (enforcing the 4 social platforms `FACEBOOK`, `INSTAGRAM`, `TIKTOK`, `THREADS`), and indexes.

If your volumes were created before recent migrations, either apply the incremental scripts in [`../../database/migrations/README.md`](../../database/migrations/README.md) or run the non-destructive catch-up patch [`../../database/scripts/patch-update-running-db.sql`](../../database/scripts/patch-update-running-db.sql).

---

## 2. Option A: Synthetic Application Seeder (`DataSeeder` in `brandhub-business-service`)

To generate deterministic synthetic demo accounts across the canonical BrandHub roles (`Owner`, `Manager`, `Creator`, `Client`, `Admin`), agencies, workspaces, media packages, campaigns, tasks, and posts with synchronized cross-store UUIDs:

1. Start the local Docker infrastructure stack:
   ```powershell
   cd docker
   .\run_dev.bat up
   ```
2. Start `brandhub-business-service` with `SEED_ENABLED=true` (via IDE run configuration, `.env`, or the `run-brandhub` desktop launcher):
   ```powershell
   cd ..\..\brandhub-business-service
   $env:SEED_ENABLED = "true"
   .\mvnw spring-boot:run
   ```

**How `DataSeeder` maintains cross-database consistency**:
- Inserts relational entities (`users`, `agencies`, `workspaces`, `media_packages`, `media_campaigns`, `tasks`) into PostgreSQL first within managed transactions.
- Reuses those exact UUIDs when upserting corresponding MongoDB mirror and workflow documents (`users`, `workspaces`, `workspace_members`, `clients`, `tasks`, `posts`, `chat_channels`).
- Safe and idempotent on restart; set `SEED_ENABLED=false` afterward for faster local boot times.

---

## 3. Option B: Restore Full Local Team Snapshots (`database/backups/`)

When testing against full staging-like agency datasets, place private `brandhub_postgres_full_<YYYYMMDD>.dump` and `brandhub_mongodb_full_<YYYYMMDD>.ejson` files in `database/backups/` (gitignored) and run:

```powershell
# 1. Ensure brandhub-postgres and brandhub-mongodb containers are running
cd docker
.\run_dev.bat up

# 2. Drop & restore PostgreSQL public schema + data
..\database\backups\restore-postgres.bat

# 3. Drop & restore MongoDB collections, $jsonSchema validators, indexes + documents
..\database\backups\restore-mongodb.bat
```

- Pass `-Force` to skip interactive `(y/N)` confirmation prompts (`restore-postgres.bat -Force`).
- To trim a large restored PostgreSQL snapshot down to 30 users while preserving the 5 core demo role accounts, run [`../../database/scripts/reduce-demo-users.sql`](../../database/scripts/reduce-demo-users.sql) (see [`../../database/README.md`](../../database/README.md)).
