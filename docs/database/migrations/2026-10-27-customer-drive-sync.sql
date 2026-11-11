BEGIN;
ALTER TABLE agency_drive_connections ADD COLUMN IF NOT EXISTS granted_scope text NOT NULL DEFAULT '';
COMMIT;
