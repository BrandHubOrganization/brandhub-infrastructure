-- Personal companies are one user on every Studio plan: STUDIO_PRO 3 -> 1 internal member.
-- Plan versions are immutable (billing_guard_plan_version), so this adds a new STUDIO_PRO version copied from the latest
-- one (price, benefits, sellable flag and cycle prices unchanged). The business service also caps PERSONAL companies
-- at 1 member at runtime, so existing subscriptions on the old version are already limited.
-- Run after 2026-11-22-studio-plans.sql. Idempotent; safe to run multiple times. psql -X -v ON_ERROR_STOP=1
BEGIN;
INSERT INTO billing_plan_versions (code, version, display_name, price_monthly, currency,
  max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits,
  max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable)
SELECT v.code, v.version + 1, v.display_name, v.price_monthly, v.currency,
  v.max_active_workspaces, 1, v.max_clients, v.storage_limit_bytes, v.monthly_ai_credits,
  v.max_concurrent_ai_jobs, v.version_retention_days, v.trash_retention_days, v.activity_retention_days, v.features, v.is_sellable
FROM (SELECT * FROM billing_plan_versions WHERE code = 'STUDIO_PRO' ORDER BY version DESC LIMIT 1) v
WHERE v.max_internal_members <> 1;

INSERT INTO billing_plan_cycle_prices (plan_version_id, period_months, price)
SELECT n.id, c.period_months, c.price
FROM (SELECT * FROM billing_plan_versions WHERE code = 'STUDIO_PRO' ORDER BY version DESC LIMIT 1) n
JOIN billing_plan_versions o ON o.code = n.code AND o.version = n.version - 1
JOIN billing_plan_cycle_prices c ON c.plan_version_id = o.id
WHERE n.max_internal_members = 1
ON CONFLICT (plan_version_id, period_months) DO NOTHING;

-- Only the newest Studio Pro version stays on sale.
UPDATE billing_plan_versions b SET is_sellable = false
 WHERE b.code = 'STUDIO_PRO' AND b.is_sellable
   AND b.version < (SELECT max(version) FROM billing_plan_versions WHERE code = 'STUDIO_PRO');

INSERT INTO brandhub_schema_migrations (version, description)
VALUES ('20261122_studio_single_user_v1', 'Studio Pro 3 -> 1 internal member (Personal = one user)')
ON CONFLICT (version) DO NOTHING;
COMMIT;
