# Local database backups

Database snapshots contain account records, password hashes, messages and authentication material. Keep them in private storage and never add them to Git. Local snapshots are ignored; removing them from the Git index preserves the local files.

## 1. Restore PostgreSQL (Replace Existing DB with Full Schema + Data)

Place `brandhub_postgres_full_20261112.sql` (or `brandhub_postgres_full_20261112.dump`) in this directory (`docs/database/backups/`), then run:

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
*(Or skip confirmation prompt with `.\restore_postgres.ps1 -Force`)*

The script automatically:
1. Terminates active sessions on the target `brandhub` database.
2. Drops and recreates the `public` schema (`DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;`) to remove all legacy tables, types, and constraints.
3. Restores the full schema and data inside the `brandhub-postgres` Docker container (or via local `psql` / `pg_restore` if Docker is not used).
4. Verifies the restored table count (`93` tables) and latest schema migrations.

---

## 2. Restore MongoDB

`restore_mongodb.py` reads a locally supplied `brandhub_mongodb_full_20261029.ejson` bundle and requires `MONGODB_URI` in the environment. Obtain backups through an authorized private channel. Restoration drops existing collections; review the script and target database before running it.
