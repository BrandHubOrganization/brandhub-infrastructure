# Local database backups

Database snapshots contain account records, password hashes, messages and authentication material. Keep them in private storage and never add them to Git. Local snapshots are ignored; removing them from the Git index preserves the local files.

Current snapshot (2026-11-23):

| File | Content |
| :--- | :--- |
| `brandhub_postgres_full_20261123.dump` | PostgreSQL schema + data: agency `SE08 Digital Agency`, workspace `Đại học FPT Tuyển sinh 2027 x SE08 Digital`, 6 team accounts |
| `brandhub_mongodb_full_20261123.ejson` | MongoDB schema (55 collections) + production data of that workspace (tasks, posts, chat, materials, surveys, video…) and System Health (6 servers, 2 collectors, 8 health targets) |

Materials and video assets point to production S3 keys; social accounts contain production page connections.

Both restore scripts pick the newest `*_full_*` file in this directory.

## 1. Restore PostgreSQL (Replace Existing DB with Full Schema + Data)

### Command Prompt (CMD) / Double-Click
```bat
cd docs\database\backups
restore_postgres.bat
```
*(Or skip confirmation prompt with `restore_postgres.bat -Force`)*

### PowerShell
```powershell
cd docs/database/backups
.\restore_postgres.ps1
```
*(Or skip confirmation prompt with `.\restore_postgres.ps1 -Force`; restore into another DB with `-DbName <name>`)*

The script automatically:
1. Terminates active sessions on the target `brandhub` database.
2. Drops and recreates the `public` schema (`DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;`).
3. Restores the full schema and data inside the `brandhub-postgres` Docker container (or via local `psql` / `pg_restore` if Docker is not used).
4. Prints the restored table count (`92` tables) and latest schema migrations.

---

## 2. Restore MongoDB

### Command Prompt (CMD) / Double-Click (No Python Required)
```bat
cd docs\database\backups
restore_mongodb.bat
```
Automatically ensures the `brandhub-mongodb` container is added and running in the `brandhub` Docker stack, then restores `brandhub_mongodb_full_20261123.ejson` (or the latest `brandhub_mongodb_full_*.ejson`) using `mongosh` inside the container.

### PowerShell
```powershell
cd docs/database/backups
.\restore_mongodb.ps1
```
*(Or skip confirmation prompt with `.\restore_mongodb.ps1 -Force`)*

### Python (Alternative)
```powershell
$env:MONGODB_URI = "mongodb://localhost:27017"
python restore_mongodb.py brandhub
```

Requires `pymongo` when using the Python script. Restoration drops existing collections in the target database; review the target before running it.
