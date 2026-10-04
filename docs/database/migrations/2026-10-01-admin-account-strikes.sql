-- Run with psql autocommit before deploying the new Business Service.
-- Additive: never reinterpret legacy SUSPENDED or self-DEACTIVATED accounts.
ALTER TYPE user_status ADD VALUE IF NOT EXISTS 'FLAGGED';
ALTER TYPE user_status ADD VALUE IF NOT EXISTS 'PENDING_VERIFICATION';

BEGIN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS clean_period_ends_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reactivate_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS tokens_revoked_before TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS row_version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS session_version BIGINT NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_users_clean_period ON users(clean_period_ends_at)
    WHERE clean_period_ends_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_reactivate ON users(reactivate_at) WHERE reactivate_at IS NOT NULL;

CREATE TABLE IF NOT EXISTS user_strikes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    level VARCHAR(10) NOT NULL CHECK (level IN ('YELLOW','ORANGE','RED')),
    category VARCHAR(100) NOT NULL,
    reason VARCHAR(2000) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    converted_to_id UUID REFERENCES user_strikes(id) DEFERRABLE INITIALLY DEFERRED,
    removed_by UUID REFERENCES users(id),
    removed_at TIMESTAMPTZ,
    removal_reason VARCHAR(2000),
    CHECK (expires_at > created_at),
    CHECK ((removed_at IS NULL) = (removed_by IS NULL)),
    CHECK (converted_to_id IS NULL OR level = 'YELLOW')
);
CREATE INDEX IF NOT EXISTS idx_user_strikes_history ON user_strikes(user_id,created_at DESC,id DESC);
CREATE INDEX IF NOT EXISTS idx_user_strikes_live ON user_strikes(user_id,expires_at) WHERE removed_at IS NULL;

CREATE TABLE IF NOT EXISTS sanction_reviews (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING','CONFIRMED','CLOSED')),
    created_at TIMESTAMPTZ NOT NULL,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id),
    reason VARCHAR(2000)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sanction_one_pending ON sanction_reviews(user_id) WHERE status='PENDING';
CREATE TABLE IF NOT EXISTS admin_account_operations (
    user_id UUID NOT NULL REFERENCES users(id),
    operation_id UUID NOT NULL,
    payload_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id,operation_id)
);
CREATE TABLE IF NOT EXISTS admin_email_outbox (
    id UUID PRIMARY KEY,
    event_key VARCHAR(150) NOT NULL UNIQUE,
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMPTZ,
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attempts INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_admin_email_due ON admin_email_outbox(next_attempt_at) WHERE sent_at IS NULL;
COMMIT;

-- Rollback deployment: restore previous application; leave added tables/columns intact.
-- Do not drop strike/audit data or remove enum values. Export history before any future destructive migration.
