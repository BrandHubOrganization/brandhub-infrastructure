-- =============================================================================
-- Migration: 2026-11-11-mobile-google-oauth-link.sql
-- Purpose:
--   Mobile P0 Platform Essentials - Google OAuth Linking & Provider Integrity
--   - Add unique constraint/index on (user_id, provider) in user_oauth_providers
--     to ensure a user cannot link multiple accounts for the same OAuth provider.
--   - Support safe mobile linking and unlinking flows via deep link callback.
-- =============================================================================

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

-- 1. Ensure a user cannot link more than one external account for the same OAuth provider
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_oauth_provider
    ON public.user_oauth_providers (user_id, provider);

-- 2. Register migration in schema history
INSERT INTO public.brandhub_schema_migrations (version, description)
VALUES (
    '20261111_mobile_google_oauth_link_v1',
    'Enforce unique provider per user for mobile Google OAuth linking'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
