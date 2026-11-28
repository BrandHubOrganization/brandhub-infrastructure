-- Product video durable coordinator. Additive only; no balance/ledger changes or historical backfill.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';

DO $$
BEGIN
    IF to_regclass('ai_credit_reservations') IS NULL OR to_regclass('ai_credit_operation_prices') IS NULL THEN
        RAISE EXCEPTION 'Apply existing DA-974 credit migrations before product video; no changes applied';
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS product_video_productions (
    id UUID PRIMARY KEY,
    workspace_id UUID NOT NULL REFERENCES workspaces(id),
    owner_id UUID NOT NULL REFERENCES users(id),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    project_id UUID NOT NULL,
    state VARCHAR(32) NOT NULL DEFAULT 'PLAN_READY' CHECK(state IN
      ('NEEDS_INPUT','PLAN_READY','GENERATING','RECONCILIATION_REQUIRED','SCENE_FAILED',
       'EDITING','VALIDATING','RENDER_FAILED','COMPLETED')),
    revision INTEGER NOT NULL DEFAULT 0 CHECK(revision>=0),
    render_id UUID,
    output_key TEXT,
    output_sha256 CHAR(64),
    output_size BIGINT NOT NULL DEFAULT 0 CHECK(output_size>=0),
    error_code VARCHAR(80),
    lease_token UUID,
    lease_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK(state<>'COMPLETED' OR (output_key IS NOT NULL AND output_sha256 IS NOT NULL AND output_size>0))
);
CREATE TABLE IF NOT EXISTS product_video_plans (
    production_id UUID NOT NULL REFERENCES product_video_productions(id),
    revision INTEGER NOT NULL CHECK(revision>0),
    plan_hash CHAR(64) NOT NULL CHECK(plan_hash ~ '^[a-f0-9]{64}$'),
    plan_json JSONB NOT NULL CHECK(octet_length(plan_json::text)<=262144),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY(production_id,revision)
);
CREATE TABLE IF NOT EXISTS product_video_quotes (
    id UUID PRIMARY KEY,
    production_id UUID NOT NULL,
    revision INTEGER NOT NULL,
    scene_id UUID,
    price_id UUID NOT NULL REFERENCES ai_credit_operation_prices(id),
    unit_credits BIGINT NOT NULL CHECK(unit_credits>=0),
    units INTEGER NOT NULL CHECK(units BETWEEN 1 AND 3),
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_key VARCHAR(128),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY(production_id,revision) REFERENCES product_video_plans(production_id,revision),
    CHECK(scene_id IS NULL OR units=1)
);
CREATE TABLE IF NOT EXISTS product_video_attempts (
    id UUID PRIMARY KEY,
    production_id UUID NOT NULL,
    revision INTEGER NOT NULL,
    scene_id UUID NOT NULL,
    attempt INTEGER NOT NULL CHECK(attempt>0),
    reservation_id UUID NOT NULL UNIQUE REFERENCES ai_credit_reservations(id),
    payload_hash CHAR(64) NOT NULL CHECK(payload_hash ~ '^[a-f0-9]{64}$'),
    state VARCHAR(24) NOT NULL DEFAULT 'READY' CHECK(state IN
      ('READY','SUBMITTING','PROCESSING','SUBMISSION_UNKNOWN','COMPLETED','FAILED')),
    s3_key TEXT,
    sha256 CHAR(64),
    file_size BIGINT CHECK(file_size>=0),
    error_code VARCHAR(80),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY(production_id,revision) REFERENCES product_video_plans(production_id,revision),
    UNIQUE(production_id,scene_id,attempt),
    CHECK(state<>'COMPLETED' OR (s3_key IS NOT NULL AND sha256 IS NOT NULL AND file_size>0))
);
CREATE TABLE IF NOT EXISTS product_video_requests (
    workspace_id UUID NOT NULL REFERENCES workspaces(id),
    owner_id UUID NOT NULL REFERENCES users(id),
    request_key VARCHAR(128) NOT NULL,
    production_id UUID NOT NULL REFERENCES product_video_productions(id),
    request_hash CHAR(64) NOT NULL CHECK(request_hash ~ '^[a-f0-9]{64}$'),
    quote_id UUID UNIQUE REFERENCES product_video_quotes(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY(workspace_id,owner_id,request_key)
);
CREATE INDEX IF NOT EXISTS idx_product_video_owner ON product_video_productions(workspace_id,owner_id,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_video_pending ON product_video_productions(updated_at)
    WHERE state IN ('GENERATING','RECONCILIATION_REQUIRED','EDITING','VALIDATING');
CREATE INDEX IF NOT EXISTS idx_product_video_quote ON product_video_quotes(production_id,revision,created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_video_attempt ON product_video_attempts(production_id,scene_id,attempt DESC);
COMMIT;

