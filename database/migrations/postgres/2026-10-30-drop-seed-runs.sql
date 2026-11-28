-- =============================================================================
-- Migration: 2026-10-30-drop-seed-runs.sql
-- Purpose:
--   Remove the one-off demo seed marker table (public.seed_runs) from PostgreSQL,
--   reducing the public schema from 84 tables down to 83 tables.
--   - public.seed_runs is not mapped to any JPA @Entity and is not used by any
--     runtime business/API logic (only referenced by opt-in CLI seed profiles:
--     seed, seed-postgres, seed-admin-demo via PostgresSeedRunStore).
-- =============================================================================

BEGIN;

DROP TABLE IF EXISTS public.seed_runs;

INSERT INTO public.brandhub_schema_migrations (version, description)
VALUES (
    '20261030_drop_seed_runs_v1',
    'Drop one-off demo seed marker table public.seed_runs'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
