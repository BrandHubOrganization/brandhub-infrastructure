-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-01-create-tasks-table.sql
-- Minimal Task entity — just enough to anchor FR 3.6.10 Content Writing View
-- (canvas editor). NOT the full FR 3.6.1 Identify Task Detail scope (no
-- assignee, due date, comments, etc.) — those fields are out of scope here.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

DO $$ BEGIN
    CREATE TYPE task_type AS ENUM ('POST');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id),
    type task_type NOT NULL DEFAULT 'POST',
    title VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tasks_workspace_id ON tasks(workspace_id);

COMMIT;
