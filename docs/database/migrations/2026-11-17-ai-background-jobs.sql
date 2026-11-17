BEGIN;
CREATE TABLE IF NOT EXISTS ai_background_jobs (
    id uuid PRIMARY KEY,
    workspace_id uuid NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    actor_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    kind text NOT NULL CHECK (kind IN ('CAPTION','CONTENT','IMAGE','VIDEO','VIDEO_DIRECT')),
    request_key varchar(200) NOT NULL,
    input_hash char(64) NOT NULL,
    input jsonb NOT NULL,
    command jsonb NOT NULL,
    reservation_id uuid NOT NULL UNIQUE REFERENCES ai_credit_reservations(id) ON DELETE RESTRICT,
    status text NOT NULL DEFAULT 'QUEUED' CHECK (status IN
        ('QUEUED','RUNNING','RECONCILIATION_REQUIRED','SUCCEEDED','FAILED')),
    result jsonb,
    error_code text,
    lease_token uuid,
    lease_until timestamptz,
    next_attempt_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz,
    UNIQUE(actor_id,workspace_id,request_key)
);
CREATE INDEX IF NOT EXISTS idx_ai_background_jobs_claim
    ON ai_background_jobs(next_attempt_at,created_at) WHERE status NOT IN ('SUCCEEDED','FAILED');
CREATE INDEX IF NOT EXISTS idx_ai_background_jobs_actor
    ON ai_background_jobs(actor_id,created_at DESC,id DESC);
COMMIT;
