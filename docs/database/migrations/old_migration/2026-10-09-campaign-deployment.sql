-- DA-948 Stage 4. Preflight/backfill existing PostgreSQL tasks before cutover.
BEGIN;
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM tasks LIMIT 1) THEN
        RAISE EXCEPTION 'PostgreSQL tasks are not empty; reconcile and backfill to Mongo before cutover';
    END IF;
END $$;

ALTER TABLE media_campaigns
    ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS completed_by UUID,
    ADD COLUMN IF NOT EXISTS completion_reason VARCHAR(2000),
    ADD COLUMN IF NOT EXISTS completion_task_summary JSONB;

CREATE TABLE IF NOT EXISTS campaign_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL UNIQUE REFERENCES media_campaigns(id) ON DELETE CASCADE,
    content_version INT NOT NULL,
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(16) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'FAILED', 'SUCCEEDED')),
    attempt_count INT NOT NULL DEFAULT 0,
    last_error_code VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_campaign_deployments_status_created
    ON campaign_deployments(status, created_at);

-- Keep Yjs content and PostgreSQL tasks for audit, but the editor's Task
-- identity now resolves from Mongo. The old Task table receives no new writes.
ALTER TABLE task_content_operations DROP CONSTRAINT IF EXISTS task_content_operations_task_id_fkey;
ALTER TABLE task_content_snapshots DROP CONSTRAINT IF EXISTS task_content_snapshots_task_id_fkey;
COMMIT;
