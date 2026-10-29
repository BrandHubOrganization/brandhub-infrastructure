-- DA-1192 (DA-E38-03): scheduled report email to workspace clients.
-- The shared email outbox can carry a PDF attachment that is rebuilt at send time from
-- attachment_ref (e.g. CLIENT_REPORT:<workspaceId>:<from>:<to>), so no file is stored.
-- The report schedule itself lives in workspaces.settings->>'reportFrequency' (WEEKLY / MONTHLY).
-- Additive and idempotent.

BEGIN;

ALTER TABLE admin_email_outbox ADD COLUMN IF NOT EXISTS attachment_ref VARCHAR(100);

COMMIT;
