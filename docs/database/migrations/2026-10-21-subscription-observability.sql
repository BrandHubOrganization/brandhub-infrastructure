-- Expand-only operational state. No orders, payments, balances or journals are modified.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
SELECT pg_advisory_xact_lock(392026, 1021);

CREATE TABLE IF NOT EXISTS subscription_operational_issues (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fingerprint varchar(200) NOT NULL UNIQUE,
    detector varchar(40) NOT NULL CHECK (detector IN ('LOCAL_CREDIT','LOCAL_PAYMENT','WEBHOOK','PROVIDER')),
    subject_key varchar(100) NOT NULL,
    rule varchar(80) NOT NULL,
    category varchar(20) NOT NULL CHECK (category IN ('SERVICE','DATABASE','WEBHOOK','PAYMENT','CREDIT')),
    severity varchar(10) NOT NULL CHECK (severity IN ('WARNING','CRITICAL')),
    status varchar(10) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','RESOLVED')),
    agency_id uuid REFERENCES agencies(id) ON DELETE RESTRICT,
    order_id uuid REFERENCES billing_orders(id) ON DELETE RESTRICT,
    details jsonb NOT NULL DEFAULT '{}' CHECK (jsonb_typeof(details)='object'),
    request_id varchar(64) NOT NULL CHECK (request_id ~ '^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$'),
    occurrences bigint NOT NULL DEFAULT 1 CHECK (occurrences>0),
    first_seen timestamptz NOT NULL DEFAULT now(),
    last_seen timestamptz NOT NULL DEFAULT now(),
    resolved_at timestamptz,
    CHECK ((status='RESOLVED')=(resolved_at IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_subscription_issues_open
    ON subscription_operational_issues(status,id);
CREATE INDEX IF NOT EXISTS idx_subscription_issues_subject
    ON subscription_operational_issues(detector,subject_key,status);

CREATE TABLE IF NOT EXISTS subscription_observation_jobs (
    name varchar(40) PRIMARY KEY,
    owner_token uuid,
    lease_until timestamptz,
    agency_cursor uuid,
    order_cursor uuid,
    event_cursor uuid,
    last_started_at timestamptz,
    last_completed_at timestamptz,
    last_outcome varchar(20) CHECK (last_outcome IN ('RUNNING','COMPLETED','DEGRADED','FAILED')),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS subscription_provider_checks (
    order_id uuid PRIMARY KEY REFERENCES billing_orders(id) ON DELETE RESTRICT,
    last_checked_at timestamptz NOT NULL DEFAULT now(),
    next_check_at timestamptz NOT NULL DEFAULT now(),
    outcome varchar(20) NOT NULL CHECK (outcome IN ('CHECKING','COMPLETE','UNKNOWN'))
);
CREATE INDEX IF NOT EXISTS idx_subscription_provider_due ON subscription_provider_checks(next_check_at,order_id);

CREATE TABLE IF NOT EXISTS brandhub_schema_migrations (
    version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now(), description text NOT NULL
);
INSERT INTO brandhub_schema_migrations(version,description)
VALUES ('20261021_subscription_observability_v1','Subscription issues, bounded reconciliation lease/cursors and provider read checkpoints')
ON CONFLICT(version) DO NOTHING;
COMMIT;
