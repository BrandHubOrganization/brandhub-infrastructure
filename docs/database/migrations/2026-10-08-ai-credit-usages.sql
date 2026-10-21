-- FR 3.7.2 (and 3.7.7): per-use AI credit record so the agency monthly ledger (ai_credit_ledgers) and the
-- Owner's hard per-Creator limit (ai_credit_creator_limits, FR 3.9.7) can both be enforced, and a failed
-- AI job can be refunded. FR 3.9.5 (credit tracking) can read this table.
-- Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_credit_usages (
    id           UUID         PRIMARY KEY,
    agency_id    UUID         NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workspace_id UUID         REFERENCES workspaces(id) ON DELETE SET NULL,
    feature      VARCHAR(40)  NOT NULL,
    credits      INT          NOT NULL CHECK (credits >= 0),
    month        VARCHAR(7)   NOT NULL,
    reference    VARCHAR(120),
    refunded_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_credit_usages_agency_month ON ai_credit_usages(agency_id, month);
CREATE INDEX IF NOT EXISTS idx_ai_credit_usages_user_month ON ai_credit_usages(user_id, agency_id, month)
    WHERE refunded_at IS NULL;

COMMIT;
