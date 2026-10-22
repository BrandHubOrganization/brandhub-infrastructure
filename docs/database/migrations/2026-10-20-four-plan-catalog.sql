-- Four-product catalog: Personal (USER), Basic/Plus/Enterprise (AGENCY).
-- Prerequisite: 2026-10-20-agency-subscription-expand.sql.
-- PostgreSQL 17; run with psql -X -v ON_ERROR_STOP=1 -f <this file>.
-- Preserves existing versions and subscriptions. Does not enable paid sales.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
SELECT pg_advisory_xact_lock(392026, 1020);
SET LOCAL search_path = public;

DO $$
BEGIN
  IF to_regclass('public.brandhub_schema_migrations') IS NULL
     OR to_regclass('public.billing_plan_versions') IS NULL THEN
    RAISE EXCEPTION 'Apply 2026-10-20-agency-subscription-expand.sql first';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM brandhub_schema_migrations
    WHERE version = '20261020_agency_subscription_expand_v1'
  ) THEN
    RAISE EXCEPTION 'Agency subscription expand migration is not recorded as applied';
  END IF;
END $$;

SELECT EXISTS (
  SELECT 1 FROM brandhub_schema_migrations
  WHERE version = '20261020_four_plan_catalog_v1'
) AS already_applied \gset
\if :already_applied
  \echo 'Four-plan catalog migration already applied; no changes.'
\else

ALTER TABLE billing_plan_versions
  DROP CONSTRAINT billing_plan_versions_code_check,
  ADD CONSTRAINT billing_plan_versions_code_check
    CHECK (code IN ('PERSONAL', 'BASIC', 'PLUS', 'ENTERPRISE')),
  ADD COLUMN billing_scope text GENERATED ALWAYS AS (
    CASE WHEN code = 'PERSONAL' THEN 'USER'::text ELSE 'AGENCY'::text END
  ) STORED,
  ADD CONSTRAINT billing_plan_versions_id_scope_key UNIQUE (id, billing_scope);

COMMENT ON COLUMN billing_plan_versions.billing_scope IS
  'Derived from product code; Personal belongs to a user, Agency tiers belong to an agency.';

-- Stored generated columns are calculated after BEFORE triggers. Exclude the
-- derived field from the immutable-row comparison so sale-flag changes still work.
-- Its source (code) remains immutable and scope cannot be assigned directly.
CREATE OR REPLACE FUNCTION billing_guard_plan_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR TG_OP = 'TRUNCATE' THEN
    RAISE EXCEPTION 'Plan versions are immutable; disable sale instead' USING ERRCODE = '23514';
  END IF;
  IF (to_jsonb(NEW) - 'is_sellable' - 'billing_scope')
       IS DISTINCT FROM (to_jsonb(OLD) - 'is_sellable' - 'billing_scope') THEN
    RAISE EXCEPTION 'Create a new plan version to change price or benefits' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

-- Enforce scope on every existing Agency plan reference, including pending orders.
-- Existing FKs remain in place. Nullable plan_version_id on credit top-ups is preserved.
ALTER TABLE agency_subscriptions
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT agency_subscriptions_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

ALTER TABLE billing_orders
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT billing_orders_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

ALTER TABLE agency_subscription_periods
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT agency_subscription_periods_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

-- Proposed quota values; paid prices remain unknown and paid sales disabled.
-- Never overwrite an existing immutable version or configured commercial terms.
INSERT INTO billing_plan_versions (
  code, version, display_name, price_monthly,
  max_active_workspaces, max_internal_members, max_clients,
  storage_limit_bytes, monthly_ai_credits, max_concurrent_ai_jobs,
  version_retention_days, trash_retention_days, activity_retention_days,
  features, is_sellable
) VALUES
  ('PERSONAL', 1, 'Personal', NULL, 0, 1, 0,
   20000000000, 1000, 1, 30, 30, 90,
   '{"max_personal_spaces":1,"quota_policy":"PROPOSED"}'::jsonb, false),
  ('BASIC', 1, 'Basic', 0, 1, 3, 5,
   2000000000, 0, 1, 7, 7, 30, '{}'::jsonb, true),
  ('PLUS', 1, 'Plus', NULL, 10, 15, 50,
   100000000000, 5000, 3, 90, 30, 180, '{}'::jsonb, false),
  ('ENTERPRISE', 1, 'Enterprise', NULL, 50, 50, 200,
   1000000000000, 25000, 10, 365, 90, 365, '{}'::jsonb, false)
ON CONFLICT (code, version) DO NOTHING;

INSERT INTO brandhub_schema_migrations (version, description) VALUES (
  '20261020_four_plan_catalog_v1',
  'Ensure four versioned products, derive USER/AGENCY scope, prevent Personal assignment to Agency billing'
);
\endif
COMMIT;
