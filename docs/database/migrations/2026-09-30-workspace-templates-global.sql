-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-09-30-workspace-templates-global.sql
-- Allow agency_id NULL on workspace_templates — NULL means a global template
-- (admin-created, visible to every agency when creating a workspace).
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

ALTER TABLE workspace_templates ALTER COLUMN agency_id DROP NOT NULL;

-- CASCADE on agency delete only fires when agency_id is set; NULL rows are
-- untouched either way, so the existing FK action is already correct and
-- does not need to change.

COMMIT;
