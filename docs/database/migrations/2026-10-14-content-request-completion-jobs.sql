-- ============================================================
-- BrandHub - PostgreSQL migration: content request completion jobs
-- Date: 2026-10-14
-- Reason: DA-951, DA-948. Outbox queue for asynchronous cleanup
--         and cancellation of pending content requests upon campaign completion.
-- ============================================================
BEGIN;

CREATE TABLE IF NOT EXISTS content_request_completion_jobs (
    campaign_id  UUID PRIMARY KEY,
    workspace_id UUID NOT NULL,
    actor_id     UUID NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_content_req_completion_jobs_created
    ON content_request_completion_jobs (created_at);

COMMIT;
