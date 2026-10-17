-- Deploy the classification-free Business Service/UI together with this migration.
-- Stop old writers first. Never re-run the older offering-model migration/seed afterward.
-- Preserves every package, workspace agreement, Campaign and historical JSON snapshot.
-- RESTRICT (no CASCADE) intentionally fails if an unexpected external dependency exists.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
ALTER TABLE public.media_packages DROP COLUMN IF EXISTS package_type RESTRICT;
ALTER TABLE public.media_packages DROP COLUMN IF EXISTS offering_model RESTRICT;
DROP TYPE IF EXISTS public.package_type RESTRICT;
COMMIT;
