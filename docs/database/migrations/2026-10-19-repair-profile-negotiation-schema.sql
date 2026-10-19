-- Additive repair for the schema gaps found in the local 2026-10-19 audit.
-- Back up and validate existing history before applying.
-- Run with psql --single-transaction -v ON_ERROR_STOP=1 -f <this-file>.
-- May follow 2026-10-19-postgres-demo-seed-runs.sql in the same psql transaction.
-- Requires the Business Service User.workingLanguage mapping to declare length 50.
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

ALTER TABLE public.users ALTER COLUMN working_language TYPE VARCHAR(50);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.package_negotiation_events'::regclass
            AND conname = 'package_negotiation_events_terms_snapshot_check'
    ) THEN
        ALTER TABLE public.package_negotiation_events
            ADD CONSTRAINT package_negotiation_events_terms_snapshot_check
            CHECK (jsonb_typeof(terms_snapshot) = 'object') NOT VALID;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.package_negotiation_events'::regclass
            AND conname = 'package_negotiation_events_check'
    ) THEN
        ALTER TABLE public.package_negotiation_events
            ADD CONSTRAINT package_negotiation_events_check CHECK (
                (action = 'BASELINE' AND actor_id IS NULL AND actor_role IS NULL)
                OR (action = 'REQUEST_CHANGE' AND actor_id IS NOT NULL AND actor_role = 'CLIENT')
                OR (action = 'COUNTER_OFFER' AND actor_id IS NOT NULL AND actor_role IN ('OWNER', 'MANAGER'))
            ) NOT VALID;
    END IF;
END $$;

ALTER TABLE public.package_negotiation_events
    VALIDATE CONSTRAINT package_negotiation_events_terms_snapshot_check;
ALTER TABLE public.package_negotiation_events
    VALIDATE CONSTRAINT package_negotiation_events_check;
