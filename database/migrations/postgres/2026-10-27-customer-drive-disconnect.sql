-- Apply before deploying destructive customer Drive disconnect.
BEGIN;
ALTER TABLE agency_drive_connections ADD COLUMN IF NOT EXISTS disconnecting boolean NOT NULL DEFAULT false;
COMMIT;
