BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
-- Explicit development funding, never a fabricated paid transaction/subscription.
-- No grant is created by this schema migration; no public API can mint DEV_SEED.
ALTER TABLE ai_credit_grants DROP CONSTRAINT IF EXISTS ai_credit_grants_kind_check;
ALTER TABLE ai_credit_grants ADD CONSTRAINT ai_credit_grants_kind_check
    CHECK (kind IN ('PLAN','PURCHASED','DEV_SEED'));
ALTER TABLE ai_credit_grants DROP CONSTRAINT IF EXISTS ai_credit_grants_check1;
ALTER TABLE ai_credit_grants ADD CONSTRAINT ai_credit_grants_check1 CHECK (
    (kind='PLAN' AND subscription_id IS NOT NULL AND period_start IS NOT NULL
        AND period_end IS NOT NULL AND period_end>period_start)
    OR (kind='PURCHASED' AND transaction_id IS NOT NULL AND period_start IS NULL AND period_end IS NULL)
    OR (kind='DEV_SEED' AND source_key LIKE 'DEV_SEED:%' AND subscription_id IS NULL
        AND transaction_id IS NULL AND period_start IS NULL AND period_end IS NULL));
COMMIT;
