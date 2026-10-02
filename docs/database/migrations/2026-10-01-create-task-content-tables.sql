-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-01-create-task-content-tables.sql
-- FR 3.6.10 Content Writing View — Yjs CRDT update log + periodic snapshot.
-- task_content_operations stores raw Yjs binary updates (base64), not
-- hand-defined insert/delete ops — Yjs itself is the operation/CRDT log, so
-- we don't redefine op semantics on top of it. sequence_number orders
-- updates per task and lets clients know which snapshot+tail they're at.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

CREATE TABLE IF NOT EXISTS task_content_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    sequence_number BIGINT NOT NULL,
    yjs_update TEXT NOT NULL,
    edited_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (task_id, sequence_number)
);

CREATE INDEX IF NOT EXISTS idx_task_content_operations_task_id ON task_content_operations(task_id);

CREATE TABLE IF NOT EXISTS task_content_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    sequence_number BIGINT NOT NULL,
    yjs_state TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_task_content_snapshots_task_id ON task_content_snapshots(task_id, sequence_number DESC);

COMMIT;
