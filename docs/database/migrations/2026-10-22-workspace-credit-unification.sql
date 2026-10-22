-- Subscription is the only wallet; Workspace caps replace personal caps.
-- Prerequisites: agency-subscription-expand, four-plan-catalog, subscription-observability.
-- Never drops/converts an existing DA-974 reservation. Review/reset test data separately.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SET LOCAL search_path=public;
SELECT pg_advisory_xact_lock(392026,1022);
DO $$
BEGIN
 IF to_regclass('agency_credit_wallets') IS NULL OR to_regclass('credit_grants') IS NULL
    OR to_regclass('workspace_credit_limits') IS NULL OR to_regclass('credit_usage_periods') IS NULL
    OR to_regclass('brandhub_schema_migrations') IS NULL THEN
  RAISE EXCEPTION 'Apply Subscription migrations first; DA-974 databases require reviewed reset/conversion';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND table_name='ai_credit_reservations' AND column_name='actor_id') THEN
  RAISE EXCEPTION 'Conflicting ai_credit_reservations schema; no automatic conversion or deletion';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND table_name='ai_credit_reservations' AND column_name='request_key')
   AND EXISTS(SELECT 1 FROM ai_credit_reservations) THEN
  RAISE EXCEPTION 'Existing reservations need explicit request/execution metadata conversion';
 END IF;
END $$;
SELECT EXISTS(SELECT 1 FROM brandhub_schema_migrations
 WHERE version='20261022_workspace_credit_v1') AS workspace_credit_applied \gset
\if :workspace_credit_applied
 \echo 'Workspace Credit migration already applied; no changes.'
\else
CREATE TABLE IF NOT EXISTS ai_credit_operation_prices (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 operation varchar(40) NOT NULL CHECK(operation IN ('CONTENT_GENERATE','CAPTION_VARIANTS','HASHTAG_GENERATE',
  'AMBASSADOR_GENERATE','CHARACTER_SHEET','COMMERCIAL_IMAGE','VIDEO_GENERATE')),
 revision bigint NOT NULL CHECK(revision>0), unit_credits bigint NOT NULL CHECK(unit_credits>=0),
 enabled boolean NOT NULL, created_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(operation,revision)
);
CREATE OR REPLACE FUNCTION guard_credit_price_history() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'Credit price versions are append-only'; END $$;
DROP TRIGGER IF EXISTS trg_credit_price_history ON ai_credit_operation_prices;
CREATE TRIGGER trg_credit_price_history BEFORE UPDATE OR DELETE ON ai_credit_operation_prices
 FOR EACH ROW EXECUTE FUNCTION guard_credit_price_history();

ALTER TABLE credit_grants ALTER COLUMN expires_at DROP NOT NULL;
ALTER TABLE credit_grants DROP CONSTRAINT credit_grants_source_type_check;
ALTER TABLE credit_grants ADD CONSTRAINT credit_grants_source_type_check
 CHECK(source_type IN ('TRIAL','PERIOD','TOPUP','OPENING','ADJUSTMENT','DEV_SEED'));
-- Extends purchased entitlement only; does not change any balances.
UPDATE credit_grants SET expires_at=NULL WHERE source_type='TOPUP';
ALTER TABLE credit_grants ADD CONSTRAINT ck_credit_grants_period_expiry
 CHECK(source_type<>'PERIOD' OR expires_at IS NOT NULL);
ALTER TABLE credit_grants ADD CONSTRAINT ck_credit_grants_topup_no_expiry
 CHECK(source_type<>'TOPUP' OR expires_at IS NULL);

ALTER TABLE ai_credit_reservations
 ADD COLUMN request_key varchar(128) NOT NULL,
 ADD COLUMN payload_hash varchar(64) NOT NULL CHECK(payload_hash ~ '^[a-f0-9]{64}$'),
 ADD COLUMN price_id uuid REFERENCES ai_credit_operation_prices(id) ON DELETE RESTRICT,
 ADD COLUMN unit_credits bigint NOT NULL CHECK(unit_credits>=0),
 ADD COLUMN units integer NOT NULL CHECK(units>0),
 ADD COLUMN successful_units integer,
 ADD COLUMN execution_state varchar(16) NOT NULL DEFAULT 'READY'
  CHECK(execution_state IN ('READY','RUNNING','WAITING','SUCCEEDED','FAILED','UNKNOWN')),
 ADD COLUMN execution_response jsonb,
 ADD COLUMN execution_updated_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE ai_credit_reservations DROP CONSTRAINT ai_credit_reservations_reserved_amount_check;
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ai_credit_reservations_reserved_amount_check CHECK(reserved_amount>=0);
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_frozen_amount
 CHECK(reserved_amount::numeric=unit_credits::numeric*units);
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_price_source
 CHECK((action IN ('CONTENT_GENERATE','AMBASSADOR_GENERATE','COMMERCIAL_IMAGE','VIDEO_GENERATE') AND price_id IS NOT NULL)
  OR (action IN ('CAPTION_VARIANTS','HASHTAG_GENERATE','CHARACTER_SHEET') AND price_id IS NULL
      AND unit_credits=0 AND rate_version='FREE_V1'));
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_outcome
 CHECK((status IN ('RESERVED','UNKNOWN') AND successful_units IS NULL AND settled_at IS NULL)
  OR (status='SETTLED' AND successful_units IS NOT NULL AND successful_units>0 AND successful_units<=units AND settled_at IS NOT NULL
      AND charged_amount::numeric=unit_credits::numeric*successful_units)
  OR (status='RELEASED' AND successful_units IS NOT NULL AND successful_units=0 AND charged_amount=0 AND settled_at IS NOT NULL));
CREATE UNIQUE INDEX uq_workspace_credit_request ON ai_credit_reservations(agency_id,actor_id,request_key);
CREATE UNIQUE INDEX uq_credit_provider_job ON ai_credit_reservations(provider_job_id) WHERE provider_job_id IS NOT NULL;
CREATE INDEX idx_workspace_credit_period ON ai_credit_reservations(agency_id,workspace_id,period_id);
CREATE INDEX idx_workspace_credit_actor ON ai_credit_reservations(agency_id,actor_id,created_at DESC);
CREATE INDEX idx_credit_video_reconciliation ON ai_credit_reservations(execution_updated_at)
 WHERE execution_state='WAITING' AND status IN ('RESERVED','UNKNOWN');
ALTER TABLE credit_reservation_allocations ADD COLUMN ordinal integer NOT NULL CHECK(ordinal>=0);
CREATE UNIQUE INDEX uq_workspace_credit_allocation_order ON credit_reservation_allocations(reservation_id,ordinal);
INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261022_workspace_credit_v1','Agency Subscription wallet; Workspace-only caps; durable/idempotent fixed-price AI accounting');
\endif
COMMIT;
