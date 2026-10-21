-- Switch payment provider default from PayOS to SePay.
-- PostgreSQL 17; run with psql -X -v ON_ERROR_STOP=1.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SELECT pg_advisory_xact_lock(392026, 1021);

CREATE TABLE IF NOT EXISTS public.brandhub_schema_migrations (
  version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now(), description text NOT NULL
);
SELECT EXISTS(SELECT 1 FROM public.brandhub_schema_migrations WHERE version='20261020_payos_to_seepay_v1') AS already_applied \gset
\if :already_applied
  \echo 'Migration already applied; no changes.'
\else

ALTER TABLE billing_payment_attempts ALTER COLUMN provider SET DEFAULT 'SEEPAY';

INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261020_payos_to_seepay_v1','Switch default payment provider from PayOS to SePay');
\endif
COMMIT;
