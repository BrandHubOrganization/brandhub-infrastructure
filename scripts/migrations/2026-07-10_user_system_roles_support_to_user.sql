-- ============================================================
-- Migration: user_system_roles.system_role — SUPPORT → USER
-- Date: 2026-07-10
-- Reason: system role model simplified to ADMIN/USER only.
--         SUPPORT was never used anywhere in application code.
--         Default changed from ADMIN to USER (new users are USER by default).
--
-- Safe to run on a database that already has data (does NOT drop the table).
-- For a fresh/empty database, this is unnecessary — init-postgres.sql already
-- creates the table with the new constraint.
--
-- Idempotent: safe to run multiple times.
--   - DROP CONSTRAINT IF EXISTS → no-op if already dropped.
--   - UPDATE ... WHERE system_role = 'SUPPORT' → no-op once no rows match.
--   - Re-adding the constraint / changing the default just overwrites the
--     same values if run again.
--
-- How to run (Windows PowerShell, container name brandhub-postgres):
--   Get-Content brandhub-infrastructure\scripts\migrations\2026-07-10_user_system_roles_support_to_user.sql `
--     | docker exec -i brandhub-postgres psql -U brandhub -d brandhub
--
-- How to run (bash/macOS/Linux):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub \
--     < brandhub-infrastructure/scripts/migrations/2026-07-10_user_system_roles_support_to_user.sql
--
-- Verify after running:
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub -c "\d user_system_roles"
--   → Default should read 'USER'::character varying
--   → Check constraint should read: system_role::text = ANY (ARRAY['ADMIN','USER']::text[])
-- ============================================================

BEGIN;

-- 1. Drop the old CHECK constraint (allowed ADMIN, SUPPORT).
ALTER TABLE user_system_roles
    DROP CONSTRAINT IF EXISTS chk_user_system_roles_role;

-- 2. Migrate any existing SUPPORT rows to USER before the new constraint
--    would reject them.
UPDATE user_system_roles
SET system_role = 'USER'
WHERE system_role = 'SUPPORT';

-- 3. Change the column default from ADMIN to USER.
ALTER TABLE user_system_roles
    ALTER COLUMN system_role SET DEFAULT 'USER';

-- 4. Re-add the CHECK constraint restricted to ADMIN, USER.
ALTER TABLE user_system_roles
    ADD CONSTRAINT chk_user_system_roles_role CHECK (system_role IN ('ADMIN', 'USER'));

COMMIT;
