BEGIN;
-- Agency credit accounting (2026-10-20), compact baseline; no grants or backfill.
-- Apply the revised 2026-10-19 configuration migration first.
DO $$
BEGIN
    IF to_regclass('ai_credit_policies') IS NOT NULL
        OR to_regclass('ai_credit_member_limits') IS NOT NULL
        OR to_regclass('ai_credit_accounts') IS NOT NULL
        OR to_regclass('ai_credit_member_usage') IS NOT NULL THEN
        RAISE EXCEPTION 'Former Credit draft detected; stop and review a separate data-preserving conversion before applying the compact baseline';
    END IF;
    IF to_regclass('ai_credit_operation_prices') IS NULL OR NOT EXISTS (
        SELECT 1 FROM pg_attribute WHERE attrelid = 'agencies'::regclass
            AND attname = 'credit_policy_revision' AND NOT attisdropped
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_attribute WHERE attrelid = 'agency_members'::regclass
            AND attname = 'credit_limit_revision' AND NOT attisdropped
    ) THEN
        RAISE EXCEPTION 'Apply revised 2026-10-19-member-credit-configuration.sql first';
    END IF;
END;
$$;
-- NULL until the first verified entitlement establishes the monthly anchor.
-- Credit writes must lock the Agency row and preserve this original anchor.
ALTER TABLE agencies ADD COLUMN IF NOT EXISTS credit_cycle_anchor TIMESTAMPTZ;
CREATE TABLE IF NOT EXISTS ai_credit_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
    source_key VARCHAR(200) NOT NULL UNIQUE,
    kind VARCHAR(16) NOT NULL CHECK (kind IN ('PLAN', 'PURCHASED')),
    amount BIGINT NOT NULL CHECK (amount >= 0),
    used BIGINT NOT NULL DEFAULT 0 CHECK (used >= 0),
    held BIGINT NOT NULL DEFAULT 0 CHECK (held >= 0),
    subscription_id UUID REFERENCES user_subscriptions(id) ON DELETE RESTRICT,
    transaction_id UUID UNIQUE REFERENCES transactions(id) ON DELETE RESTRICT,
    period_start TIMESTAMPTZ,
    period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (used <= amount AND held <= amount - used),
    CHECK ((kind = 'PLAN' AND subscription_id IS NOT NULL AND period_start IS NOT NULL
            AND period_end IS NOT NULL AND period_end > period_start)
        OR (kind = 'PURCHASED' AND transaction_id IS NOT NULL AND period_start IS NULL AND period_end IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_plan_entitlement
    ON ai_credit_grants(subscription_id, period_start) WHERE kind = 'PLAN';
CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_agency_plan_period
    ON ai_credit_grants(agency_id, period_start) WHERE kind = 'PLAN';
CREATE INDEX IF NOT EXISTS idx_credit_grants_agency ON ai_credit_grants(agency_id, kind, period_end);
-- No member usage summary table: derive per-period used/held from reservations.
-- Historical reservations reference users, not membership rows (which may be removed).
CREATE TABLE IF NOT EXISTS ai_credit_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    request_key VARCHAR(128) NOT NULL,
    operation VARCHAR(40) NOT NULL,
    units INT NOT NULL CHECK (units > 0),
    payload_hash VARCHAR(64) NOT NULL CHECK (payload_hash ~ '^[a-f0-9]{64}$'),
    price_id UUID NOT NULL REFERENCES ai_credit_operation_prices(id) ON DELETE RESTRICT,
    unit_credits BIGINT NOT NULL CHECK (unit_credits >= 0),
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL CHECK (period_end > period_start),
    status VARCHAR(16) NOT NULL DEFAULT 'RESERVED' CHECK (status IN ('RESERVED', 'SETTLED', 'RELEASED')),
    successful_units INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    settled_at TIMESTAMPTZ,
    UNIQUE (agency_id, user_id, request_key),
    CHECK ((status = 'RESERVED' AND successful_units IS NULL AND settled_at IS NULL)
        OR (status = 'SETTLED' AND successful_units IS NOT NULL AND successful_units > 0
            AND successful_units <= units AND settled_at IS NOT NULL)
        OR (status = 'RELEASED' AND successful_units IS NOT NULL AND successful_units = 0 AND settled_at IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_credit_reservations_member
    ON ai_credit_reservations(agency_id, user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_credit_reservations_member_period
    ON ai_credit_reservations(agency_id, user_id, period_start);
CREATE INDEX IF NOT EXISTS idx_credit_reservations_pending
    ON ai_credit_reservations(created_at) WHERE status = 'RESERVED';
CREATE TABLE IF NOT EXISTS ai_credit_allocations (
    reservation_id UUID NOT NULL REFERENCES ai_credit_reservations(id) ON DELETE RESTRICT,
    grant_id UUID NOT NULL REFERENCES ai_credit_grants(id) ON DELETE RESTRICT,
    ordinal INT NOT NULL CHECK (ordinal >= 0),
    held_amount BIGINT NOT NULL CHECK (held_amount > 0),
    charged_amount BIGINT CHECK (charged_amount >= 0 AND charged_amount <= held_amount),
    PRIMARY KEY (reservation_id, grant_id),
    UNIQUE (reservation_id, ordinal)
);
COMMIT;
