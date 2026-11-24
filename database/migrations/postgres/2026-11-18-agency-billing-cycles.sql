-- FR 3.9.1 / 3.9.2: prepaid multi-month Agency subscriptions (3, 6, 12 months) with a discount.
-- Run after 2026-11-18-agency-plan-prices.sql. Idempotent. psql -X -v ON_ERROR_STOP=1
BEGIN;
-- 1-month price stays billing_plan_versions.price_monthly; longer cycles are priced per plan version.
CREATE TABLE IF NOT EXISTS billing_plan_cycle_prices (
 plan_version_id uuid NOT NULL REFERENCES billing_plan_versions(id) ON DELETE RESTRICT,
 period_months integer NOT NULL CHECK (period_months IN (3, 6, 12)),
 price numeric(18,0) NOT NULL CHECK (price > 0),
 created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY (plan_version_id, period_months)
);

-- ~5% / ~10% / ~20% off, rounded to x.x90.000 VND (Business & Finance sheet, 2026-11-18).
INSERT INTO billing_plan_cycle_prices (plan_version_id, period_months, price)
SELECT v.id, c.months, c.price
FROM (VALUES ('PLUS', 990000, 3, 2790000), ('PLUS', 990000, 6, 5290000), ('PLUS', 990000, 12, 9490000),
             ('ENTERPRISE', 3990000, 3, 11390000), ('ENTERPRISE', 3990000, 6, 21490000),
             ('ENTERPRISE', 3990000, 12, 38290000)) AS c(code, base, months, price)
JOIN billing_plan_versions v ON v.code = c.code AND v.price_monthly = c.base
ON CONFLICT (plan_version_id, period_months) DO NOTHING;

-- A prepaid period longer than one month receives its plan credits month by month, so one PERIOD grant per
-- (period, month start) instead of one per period.
DROP INDEX IF EXISTS uq_credit_period_once;
CREATE UNIQUE INDEX IF NOT EXISTS uq_credit_period_month ON credit_grants(period_id, valid_from)
 WHERE source_type = 'PERIOD';

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261118_agency_billing_cycles_v1', 'Prepaid 3/6/12-month Agency plans with monthly credit tranches')
ON CONFLICT (version) DO NOTHING;
COMMIT;
