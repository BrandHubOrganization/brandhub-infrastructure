-- =============================================================================
-- Migration: 2026-10-30-drop-legacy-monitoring-billing-storage.sql
-- Purpose:
--   Consolidate PostgreSQL schema from 98 tables down to 84 tables by removing:
--   1. 5 Monitoring tables (migrated to MongoDB):
--      monitoring_health_results, monitoring_health_targets,
--      monitoring_collectors, monitoring_enrollments, monitoring_servers
--   2. 3 Legacy Storage Quota V1 tables (superseded by V2 agency_storage_*):
--      storage_objects, storage_reservations, agency_resource_usage
--   3. 6 Legacy Billing & AI Credit V1/V2 tables (superseded by V3 reservation/ledger):
--      ai_credit_usages, ai_credit_ledgers, ai_credit_creator_limits,
--      creator_credit_usage, agency_creator_credit_limits, billing_migration_reviews
--   4. Legacy usage_id columns/constraints on ai_caption_generations & ai_video_jobs
--   Preserves Admin user-subscription flow (subscription_plans, user_subscriptions,
--   subscription_plan_changes, transactions).
-- =============================================================================

BEGIN;

-- 1. Drop legacy usage_id column and dual-source check constraints on AI tables
ALTER TABLE IF EXISTS public.ai_video_jobs
    DROP CONSTRAINT IF EXISTS ck_ai_video_jobs_accounting_source,
    DROP CONSTRAINT IF EXISTS ai_video_jobs_usage_id_fkey,
    DROP COLUMN IF EXISTS usage_id;

ALTER TABLE IF EXISTS public.ai_caption_generations
    DROP CONSTRAINT IF EXISTS ai_caption_generations_usage_id_fkey,
    DROP COLUMN IF EXISTS usage_id;

-- 2. Drop 5 retired PostgreSQL Monitoring tables (active store is MongoDB)
DROP TABLE IF EXISTS public.monitoring_health_results;
DROP TABLE IF EXISTS public.monitoring_health_targets;
DROP TABLE IF EXISTS public.monitoring_collectors;
DROP TABLE IF EXISTS public.monitoring_enrollments;
DROP TABLE IF EXISTS public.monitoring_servers;

-- 3. Drop 3 legacy Storage Quota V1 tables
DROP TABLE IF EXISTS public.storage_objects;
DROP TABLE IF EXISTS public.storage_reservations;
DROP TABLE IF EXISTS public.agency_resource_usage;

-- 4. Drop 6 legacy Billing & AI Credit V1/V2 tables
DROP TABLE IF EXISTS public.ai_credit_usages;
DROP TABLE IF EXISTS public.ai_credit_ledgers;
DROP TABLE IF EXISTS public.ai_credit_creator_limits;
DROP TABLE IF EXISTS public.creator_credit_usage;
DROP TABLE IF EXISTS public.agency_creator_credit_limits;
DROP TABLE IF EXISTS public.billing_migration_reviews;

-- 5. Record schema migration
INSERT INTO public.brandhub_schema_migrations (version, description)
VALUES (
    '20261030_consolidate_monitoring_billing_storage_v1',
    'Drop 5 retired Monitoring tables, 3 V1 Storage tables, and 6 V1/V2 Billing/Credit tables'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
