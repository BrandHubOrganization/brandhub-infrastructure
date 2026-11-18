-- FR 3.9.1 Upgrade Plan: publish Agency plan prices (Business & Finance sheet, 2026-11-18).
-- Plus 990.000 VND/month is sold via SePay; Enterprise 3.990.000 VND/month is shown but sold through sales contact.
-- Plan versions are immutable (billing_guard_plan_version), so each price is a new version copied from the latest one.
-- Idempotent; safe to run multiple times. psql -X -v ON_ERROR_STOP=1
BEGIN;
INSERT INTO billing_plan_versions (code, version, display_name, price_monthly, currency,
  max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits,
  max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable)
SELECT v.code, v.version + 1, v.display_name, p.price, v.currency,
  v.max_active_workspaces, v.max_internal_members, v.max_clients, v.storage_limit_bytes, v.monthly_ai_credits,
  v.max_concurrent_ai_jobs, v.version_retention_days, v.trash_retention_days, v.activity_retention_days, v.features, p.sellable
FROM (VALUES ('PLUS', 990000::numeric, true), ('ENTERPRISE', 3990000::numeric, false)) AS p(code, price, sellable)
JOIN LATERAL (SELECT * FROM billing_plan_versions b WHERE b.code = p.code ORDER BY b.version DESC LIMIT 1) v ON true
WHERE v.price_monthly IS DISTINCT FROM p.price;

-- Only the newest Plus version stays on sale.
UPDATE billing_plan_versions b SET is_sellable = false
 WHERE b.code = 'PLUS' AND b.is_sellable
   AND b.version < (SELECT max(version) FROM billing_plan_versions WHERE code = 'PLUS');
COMMIT;
