# Local Database Backups & Restore (`database/backups/`)

- Back to [Operational Databases](../README.md) · [Infrastructure Hub](../../README.md) · [Seed & Restore Guide](../../docker/compose/seed-guide.md)

Database snapshots contain account records, password hashes, messages, and encrypted authentication material. Keep them in private storage and **never commit them to Git**. All `.dump`, `.sql`, `.ejson`, `.bson`, and `.archive*` files under `database/backups/` are gitignored and blocked by [`../../scripts/security/check_sensitive_paths.py`](../../scripts/security/check_sensitive_paths.py).

## Expected Local Snapshot Files

Place private snapshot files directly in `database/backups/` (both restore scripts automatically select the newest `*_full_*` snapshot in this directory when `-BackupFile` is omitted):

| File Pattern | Content |
| :--- | :--- |
| `brandhub_postgres_full_<YYYYMMDD>.dump` | Full PostgreSQL custom-format dump (schema + demo/staging agency, workspace, and team account records) |
| `brandhub_mongodb_full_<YYYYMMDD>.ejson` | Full MongoDB Extended JSON export (50+ collections with `$jsonSchema` validators, indexes, tasks, posts, chat, materials, surveys, video projects, and monitoring metadata) |

> **Note**: Exported material/video records may reference external S3 object keys, and social account records may reference external platform page connections. Review target environment variables before running publisher or storage purge jobs against restored snapshots.

---

## 1. Restore PostgreSQL (Replace Existing DB with Full Schema + Data)

### Command Prompt (CMD) / Double-Click

```bat
cd database\backups
restore-postgres.bat
```

*(Pass `-Force` to skip the interactive `(y/N)` confirmation prompt: `restore-postgres.bat -Force`)*

### PowerShell

```powershell
cd database/backups
.\restore-postgres.ps1
```

*(Optional flags: `-Force` to skip confirmation, `-DbName <name>` to target another database, `-BackupFile <file>` to choose a specific dump)*

What [`restore-postgres.ps1`](restore-postgres.ps1) does:
1. Terminates active sessions on the target `brandhub` database.
2. Drops and recreates the `public` schema (`DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;`).
3. Restores the full schema and data inside the `brandhub-postgres` Docker container (or via local `psql` / `pg_restore` if Docker is not running).
4. Prints the restored table count and latest recorded entries in `brandhub_schema_migrations`.

---

## 2. Restore MongoDB

### Command Prompt (CMD) / Double-Click (No Python Required)

```bat
cd database\backups
restore-mongodb.bat
```

*(Prompts for confirmation by default; pass `restore-mongodb.bat -Force` to skip the confirmation prompt)*

Automatically ensures the `brandhub-mongodb` container is running in the `brandhub` Docker Compose stack, then restores the latest `brandhub_mongodb_full_*.ejson` snapshot using `mongosh` inside the container.

### PowerShell

```powershell
cd database/backups
.\restore-mongodb.ps1
```

*(Optional flags: `-Force` to skip confirmation, `-DbName <name>`, `-BackupFile <file>`)*

### Python Alternative ([`restore-mongodb.py`](restore-mongodb.py))

```powershell
cd database/backups
$env:MONGODB_URI = "mongodb://localhost:27017"
python restore-mongodb.py brandhub
```

Requires `pymongo` when using the Python helper. Restoration drops and replaces existing collections in the target database; verify `MONGODB_URI` before running it.
