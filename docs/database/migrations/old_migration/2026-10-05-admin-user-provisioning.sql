-- FR 3.10.7 Create User + FR 3.10.8 Update User.
-- Admin-created accounts start PENDING_VERIFICATION with require_password_reset=true; a one-time
-- activation link proves email ownership and sets the user's own password in one step (BR-15).
-- Admin plan changes are recorded for the next billing period and still require payment (BR-60).
-- Additive and idempotent.

BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS require_password_reset BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS account_activation_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (expires_at > created_at)
);
CREATE INDEX IF NOT EXISTS idx_activation_tokens_open
    ON account_activation_tokens(user_id) WHERE used_at IS NULL AND revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS subscription_plan_changes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPLIED','CANCELLED')),
    -- NULL: no current period yet, the change starts with the user's first paid subscription.
    effective_at TIMESTAMPTZ,
    payment_required BOOLEAN NOT NULL DEFAULT TRUE,
    requested_by UUID NOT NULL REFERENCES users(id),
    reason VARCHAR(2000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_plan_change_pending
    ON subscription_plan_changes(user_id) WHERE status = 'PENDING';

COMMIT;
