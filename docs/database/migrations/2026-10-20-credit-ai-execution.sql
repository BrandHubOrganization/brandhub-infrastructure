BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
-- Additive AI dispatch metadata; no grants, prices or historical backfill.
ALTER TABLE ai_credit_reservations
    ADD COLUMN IF NOT EXISTS execution_state VARCHAR(16) NOT NULL DEFAULT 'READY'
        CHECK (execution_state IN ('READY','RUNNING','WAITING','SUCCEEDED','FAILED','UNKNOWN')),
    ADD COLUMN IF NOT EXISTS execution_response JSONB,
    ADD COLUMN IF NOT EXISTS upstream_job_id VARCHAR(200),
    ADD COLUMN IF NOT EXISTS execution_updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_upstream_job
    ON ai_credit_reservations(upstream_job_id) WHERE upstream_job_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_credit_video_reconciliation
    ON ai_credit_reservations(execution_updated_at) WHERE execution_state='WAITING' AND status='RESERVED';
COMMIT;
