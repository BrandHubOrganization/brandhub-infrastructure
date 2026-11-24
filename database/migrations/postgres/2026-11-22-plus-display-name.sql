-- Agency PLUS display name "Plus / Pro" -> "Plus".
-- Plan versions are immutable (billing_guard_plan_version), so the rename is a new PLUS version copied from the latest
-- one (price, benefits, sellable flag and cycle prices unchanged). Existing subscriptions keep the version they point at.
-- Run after 2026-11-22-studio-plans.sql. Idempotent; safe to run multiple times. psql -X -v ON_ERROR_STOP=1
BEGIN;
INSERT INTO billing_plan_versions (code, version, display_name, price_monthly, currency,
  max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits,
  max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable)
SELECT v.code, v.version + 1, 'Plus', v.price_monthly, v.currency,
  v.max_active_workspaces, v.max_internal_members, v.max_clients, v.storage_limit_bytes, v.monthly_ai_credits,
  v.max_concurrent_ai_jobs, v.version_retention_days, v.trash_retention_days, v.activity_retention_days, v.features, v.is_sellable
FROM (SELECT * FROM billing_plan_versions WHERE code = 'PLUS' ORDER BY version DESC LIMIT 1) v
WHERE v.display_name <> 'Plus';

INSERT INTO billing_plan_cycle_prices (plan_version_id, period_months, price)
SELECT n.id, c.period_months, c.price
FROM (SELECT * FROM billing_plan_versions WHERE code = 'PLUS' ORDER BY version DESC LIMIT 1) n
JOIN billing_plan_versions o ON o.code = n.code AND o.version = n.version - 1
JOIN billing_plan_cycle_prices c ON c.plan_version_id = o.id
WHERE n.display_name = 'Plus'
ON CONFLICT (plan_version_id, period_months) DO NOTHING;

-- Only the newest Plus version stays on sale.
UPDATE billing_plan_versions b SET is_sellable = false
 WHERE b.code = 'PLUS' AND b.is_sellable
   AND b.version < (SELECT max(version) FROM billing_plan_versions WHERE code = 'PLUS');

-- Legacy catalog row (mutable table).
UPDATE subscription_plans SET display_name = 'Plus' WHERE name = 'PRO' AND display_name <> 'Plus';

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261122_plus_display_name_v1', 'Agency PLUS display name Plus / Pro -> Plus (new plan version)')
ON CONFLICT (version) DO NOTHING;
COMMIT;
