-- FR 3.7.6 / 3.7.7: one row per AI video job. The AI service keeps the live job in Redis (24h); this row
-- ties the job to its workspace/user (only they can read it), keeps the result after Redis expiry, and
-- links the AI credit charge so a failed or timed-out job is refunded exactly once.
-- Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_video_jobs (
    id             VARCHAR(64)  PRIMARY KEY,
    workspace_id   UUID         NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id        UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    usage_id       UUID         REFERENCES ai_credit_usages(id) ON DELETE SET NULL,
    prompt         TEXT         NOT NULL,
    style_key      VARCHAR(40),
    ambassador_id  VARCHAR(80),
    aspect_ratio   VARCHAR(5)   NOT NULL,
    status         VARCHAR(12)  NOT NULL DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','PROCESSING','COMPLETED','FAILED')),
    video_url      TEXT,
    error_code     VARCHAR(60),
    refunded_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    finished_at    TIMESTAMPTZ
);
-- S3 key of the stored MP4: the Content Studio attaches it to a post as media.
ALTER TABLE ai_video_jobs ADD COLUMN IF NOT EXISTS s3_key VARCHAR(300);
CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_workspace ON ai_video_jobs(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_open ON ai_video_jobs(created_at) WHERE status IN ('PENDING','PROCESSING');

COMMIT;
