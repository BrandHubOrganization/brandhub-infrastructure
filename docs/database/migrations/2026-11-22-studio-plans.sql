-- Studio plans for Personal companies (docs/feature/studio-personal-plans/plan.md section 2) + Enterprise 500 GB (AC12).
-- STUDIO_* versions are AGENCY scope (generated billing_scope), so they ride the existing Agency billing tables.
-- Run after 2026-11-22-agency-company-type.sql. Idempotent; safe to run multiple times. psql -X -v ON_ERROR_STOP=1
BEGIN;
ALTER TABLE billing_plan_versions DROP CONSTRAINT IF EXISTS billing_plan_versions_code_check;
ALTER TABLE billing_plan_versions ADD CONSTRAINT billing_plan_versions_code_check
  CHECK (code IN ('PERSONAL', 'BASIC', 'PLUS', 'ENTERPRISE', 'STUDIO_FREE', 'STUDIO_PLUS', 'STUDIO_PRO'));

INSERT INTO billing_plan_versions (code, version, display_name, price_monthly,
  max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits,
  max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable)
VALUES
  ('STUDIO_FREE', 1, 'Studio Free', 0, 1, 1, 0, 2147483648, 100, 1, 7, 7, 30,
   '{"product_line":"STUDIO","newsletter_email_quota":0,"support_level":"STANDARD_TICKET","early_renewal":"NONE","downgrade_allowed":false}'::jsonb, true),
  ('STUDIO_PLUS', 1, 'Studio Plus', 99000, 3, 1, 0, 5368709120, 900, 1, 30, 30, 90,
   '{"product_line":"STUDIO","newsletter_email_quota":0,"support_level":"STANDARD_TICKET","early_renewal":"AGENCY_PLUS_RENEWAL","downgrade_allowed":false}'::jsonb, true),
  ('STUDIO_PRO', 1, 'Studio Pro', 299000, 10, 3, 0, 32212254720, 2400, 2, 90, 30, 180,
   '{"product_line":"STUDIO","newsletter_email_quota":0,"support_level":"STANDARD_TICKET","early_renewal":"AGENCY_PLUS_RENEWAL","downgrade_allowed":false}'::jsonb, true)
ON CONFLICT (code, version) DO NOTHING;

INSERT INTO billing_plan_cycle_prices (plan_version_id, period_months, price)
SELECT v.id, c.months, c.price
FROM (VALUES ('STUDIO_PLUS', 3, 279000), ('STUDIO_PLUS', 6, 529000), ('STUDIO_PLUS', 12, 949000),
             ('STUDIO_PRO', 3, 849000), ('STUDIO_PRO', 6, 1599000), ('STUDIO_PRO', 12, 2869000)) AS c(code, months, price)
JOIN billing_plan_versions v ON v.code = c.code AND v.version = 1
ON CONFLICT (plan_version_id, period_months) DO NOTHING;

-- Personal companies on the Agency free plan move to Studio Free. Free plans have no periods/orders, so only the
-- subscription row changes; paid Personal subscriptions (if any) are left for manual review.
UPDATE agency_subscriptions s
   SET plan_version_id = f.id, version = s.version + 1, updated_at = now()
  FROM agencies a, billing_plan_versions p,
       (SELECT id FROM billing_plan_versions WHERE code = 'STUDIO_FREE' ORDER BY version DESC LIMIT 1) f
 WHERE a.id = s.agency_id AND a.company_type = 'PERSONAL'
   AND p.id = s.plan_version_id AND p.code = 'BASIC';

-- Enterprise storage 1 TB -> 500 GB as a new version (versions are immutable); price and benefits copied.
-- Existing subscriptions keep the version they point at.
INSERT INTO billing_plan_versions (code, version, display_name, price_monthly, currency,
  max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits,
  max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable)
SELECT v.code, v.version + 1, v.display_name, v.price_monthly, v.currency,
  v.max_active_workspaces, v.max_internal_members, v.max_clients, 500000000000, v.monthly_ai_credits,
  v.max_concurrent_ai_jobs, v.version_retention_days, v.trash_retention_days, v.activity_retention_days, v.features, v.is_sellable
FROM (SELECT * FROM billing_plan_versions WHERE code = 'ENTERPRISE' ORDER BY version DESC LIMIT 1) v
WHERE v.storage_limit_bytes <> 500000000000;

INSERT INTO billing_plan_cycle_prices (plan_version_id, period_months, price)
SELECT n.id, c.period_months, c.price
FROM (SELECT * FROM billing_plan_versions WHERE code = 'ENTERPRISE' ORDER BY version DESC LIMIT 1) n
JOIN billing_plan_versions o ON o.code = n.code AND o.version = n.version - 1
JOIN billing_plan_cycle_prices c ON c.plan_version_id = o.id
WHERE n.storage_limit_bytes = 500000000000
ON CONFLICT (plan_version_id, period_months) DO NOTHING;

UPDATE billing_plan_versions b SET is_sellable = false
 WHERE b.code = 'ENTERPRISE' AND b.is_sellable
   AND b.version < (SELECT max(version) FROM billing_plan_versions WHERE code = 'ENTERPRISE');

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261122_studio_plans_v1', 'Studio Free/Plus/Pro plans for Personal companies; Enterprise storage 500 GB')
ON CONFLICT (version) DO NOTHING;
COMMIT;
