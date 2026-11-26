-- Synchronize Agency Subscription pricing, quotas, retention windows, and feature metadata
-- for BASIC, PLUS (Plus / Pro), and ENTERPRISE plans.
-- Idempotent and safe to run on existing or freshly initialized databases.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = public;

ALTER TABLE billing_plan_versions DISABLE TRIGGER billing_plan_version_immutable;

-- BASIC: $0 /Agency/month, 1 workspace, 3 internal members, 1 client, 2 GB, 0 plan credit,
-- 1 concurrent AI job, 1,000 newsletter emails/month, 30d activity, 7d version, 7d trash.
UPDATE billing_plan_versions
   SET display_name = 'Basic',
       price_monthly = 0,
       max_active_workspaces = 1,
       max_internal_members = 3,
       max_clients = 1,
       storage_limit_bytes = 2000000000,
       monthly_ai_credits = 0,
       max_concurrent_ai_jobs = 1,
       version_retention_days = 7,
       trash_retention_days = 7,
       activity_retention_days = 30,
       features = COALESCE(features, '{}'::jsonb) || '{"price_usd_monthly":0,"newsletter_email_quota":1000,"support_level":"STANDARD_TICKET","early_renewal":"NONE","downgrade_allowed":false}'::jsonb,
       is_sellable = true
 WHERE code = 'BASIC';

-- PLUS (Plus / Pro): $300 /Agency/month (VND checkout amount preserved if already configured, else 7,500,000 VND),
-- 10 workspaces, 15 internal members, 30 clients, 100 GB, 5,000 plan credits/month,
-- 3 concurrent AI jobs, 10,000 newsletter emails/month, 180d activity, 90d version, 30d trash.
UPDATE billing_plan_versions
   SET display_name = 'Plus / Pro',
       max_active_workspaces = 10,
       max_internal_members = 15,
       max_clients = 30,
       storage_limit_bytes = 100000000000,
       monthly_ai_credits = 5000,
       max_concurrent_ai_jobs = 3,
       version_retention_days = 90,
       trash_retention_days = 30,
       activity_retention_days = 180,
       features = COALESCE(features, '{}'::jsonb) || '{"price_usd_monthly":300,"newsletter_email_quota":10000,"support_level":"PRIORITY","early_renewal":"AGENCY_PLUS_RENEWAL","downgrade_allowed":false}'::jsonb
 WHERE code = 'PLUS';

UPDATE billing_plan_versions
   SET price_monthly = COALESCE(price_monthly, 7500000),
       is_sellable = true
 WHERE code = 'PLUS'
   AND version = (SELECT max(version) FROM billing_plan_versions WHERE code = 'PLUS');

-- ENTERPRISE: 50 workspaces, 100 internal members, 200 clients, 1,000 GB (1 TB), 25,000 plan credits/month,
-- 10 concurrent AI jobs, 50,000 newsletter emails/month, 365d activity, 365d version, 90d trash.
UPDATE billing_plan_versions
   SET display_name = 'Enterprise',
       max_active_workspaces = 50,
       max_internal_members = 100,
       max_clients = 200,
       storage_limit_bytes = 1000000000000,
       monthly_ai_credits = 25000,
       max_concurrent_ai_jobs = 10,
       version_retention_days = 365,
       trash_retention_days = 90,
       activity_retention_days = 365,
       features = COALESCE(features, '{}'::jsonb) || '{"price_usd_monthly":null,"newsletter_email_quota":50000,"support_level":"DEDICATED_SLA_24_7","early_renewal":"MONTHLY_YEARLY_CYCLE","downgrade_allowed":false}'::jsonb
 WHERE code = 'ENTERPRISE';

ALTER TABLE billing_plan_versions ENABLE TRIGGER billing_plan_version_immutable;

-- Keep legacy admin subscription_plans table synchronized with the new entitlements.
UPDATE subscription_plans
   SET display_name = 'Basic',
       price_monthly = 0,
       max_workspaces = 1,
       ai_credits_month = 0,
       features = '["workspace_1","members_3","clients_1","storage_2gb","newsletter_1000","purchased_credit","workspace_cap"]'::jsonb
 WHERE name = 'BASIC';

UPDATE subscription_plans
   SET display_name = 'Plus / Pro',
       price_monthly = 7500000,
       max_workspaces = 10,
       ai_credits_month = 5000,
       features = '["workspace_10","members_15","clients_30","storage_100gb","newsletter_10000","priority_support","early_renewal"]'::jsonb
 WHERE name = 'PRO';

UPDATE subscription_plans
   SET display_name = 'Enterprise',
       price_monthly = 0,
       max_workspaces = 50,
       ai_credits_month = 25000,
       features = '["workspace_50","members_100","clients_200","storage_1tb","newsletter_50000","dedicated_sla_24_7","cycle_renewal"]'::jsonb
 WHERE name = 'ENTERPRISE';

INSERT INTO public.brandhub_schema_migrations (version, description)
VALUES (
    '20261118_agency_subscription_entitlements_v1',
    'Align Basic/Plus-Pro/Enterprise pricing, quotas, retention windows, and feature flags'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
