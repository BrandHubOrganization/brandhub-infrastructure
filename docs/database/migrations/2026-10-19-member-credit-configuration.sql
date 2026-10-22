BEGIN;
-- Member credit configuration (2026-10-19), revised to the compact baseline.
-- No balance provisioning, legacy backfill, seed prices or AI enforcement.
-- Do not use this revision as an automatic converter for the former eight-table draft.
DO $$
BEGIN
    IF to_regclass('ai_credit_policies') IS NOT NULL
        OR to_regclass('ai_credit_member_limits') IS NOT NULL
        OR to_regclass('ai_credit_accounts') IS NOT NULL
        OR to_regclass('ai_credit_member_usage') IS NOT NULL THEN
        RAISE EXCEPTION 'Former Credit draft detected; stop and review a separate data-preserving conversion before applying the compact baseline';
    END IF;
END;
$$;
-- NULL default -> application fallback 10. NULL member override -> Agency default.
-- Zero explicitly blocks member usage. Owner bypasses the personal ceiling in service.
ALTER TABLE agencies
    ADD COLUMN IF NOT EXISTS credit_default_member_limit BIGINT
        CHECK (credit_default_member_limit >= 0),
    ADD COLUMN IF NOT EXISTS credit_policy_revision BIGINT NOT NULL DEFAULT 0
        CHECK (credit_policy_revision >= 0),
    ADD COLUMN IF NOT EXISTS credit_policy_updated_by UUID REFERENCES users(id) ON DELETE RESTRICT,
    ADD COLUMN IF NOT EXISTS credit_policy_updated_at TIMESTAMPTZ;
ALTER TABLE agency_members
    ADD COLUMN IF NOT EXISTS credit_limit_override BIGINT CHECK (credit_limit_override >= 0),
    ADD COLUMN IF NOT EXISTS credit_limit_revision BIGINT NOT NULL DEFAULT 0
        CHECK (credit_limit_revision >= 0),
    ADD COLUMN IF NOT EXISTS credit_limit_updated_by UUID REFERENCES users(id) ON DELETE RESTRICT,
    ADD COLUMN IF NOT EXISTS credit_limit_updated_at TIMESTAMPTZ;
CREATE TABLE IF NOT EXISTS ai_credit_operation_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operation VARCHAR(40) NOT NULL CHECK (operation IN (
        'CONTENT_GENERATE', 'CAPTION_VARIANTS', 'HASHTAG_GENERATE',
        'AMBASSADOR_GENERATE', 'CHARACTER_SHEET', 'COMMERCIAL_IMAGE', 'VIDEO_GENERATE'
    )),
    revision BIGINT NOT NULL CHECK (revision > 0),
    unit_credits BIGINT NOT NULL CHECK (unit_credits >= 0),
    enabled BOOLEAN NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (operation, revision)
);
CREATE OR REPLACE FUNCTION guard_credit_price_history() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Credit price versions are append-only';
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_credit_price_history ON ai_credit_operation_prices;
CREATE TRIGGER trg_credit_price_history
BEFORE UPDATE OR DELETE ON ai_credit_operation_prices
FOR EACH ROW EXECUTE FUNCTION guard_credit_price_history();
COMMIT;
