-- Agency subscription expand-only migration. PostgreSQL 17; run with psql -X -v ON_ERROR_STOP=1.
-- Does not activate paid plans, infer credit balances, or remove legacy tables.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
SELECT pg_advisory_xact_lock(392026, 1020);
CREATE TABLE IF NOT EXISTS public.brandhub_schema_migrations (
  version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now(), description text NOT NULL
);
SELECT EXISTS(SELECT 1 FROM public.brandhub_schema_migrations WHERE version='20261020_agency_subscription_expand_v1') AS already_applied \gset
\if :already_applied
  \echo 'Migration already applied; no changes.'
\else
SET LOCAL search_path = public;

CREATE TABLE billing_plan_versions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), code text NOT NULL CHECK(code IN ('BASIC','PLUS','ENTERPRISE')),
 version integer NOT NULL CHECK(version>0), display_name text NOT NULL,
 price_monthly numeric(18,0) CHECK(price_monthly>=0), currency char(3) NOT NULL DEFAULT 'VND' CHECK(currency='VND'),
 max_active_workspaces integer NOT NULL CHECK(max_active_workspaces>=0),
 max_internal_members integer NOT NULL CHECK(max_internal_members>=1), max_clients integer NOT NULL CHECK(max_clients>=0),
 storage_limit_bytes bigint NOT NULL CHECK(storage_limit_bytes>=0), monthly_ai_credits bigint NOT NULL CHECK(monthly_ai_credits>=0),
 max_concurrent_ai_jobs integer NOT NULL CHECK(max_concurrent_ai_jobs>=1),
 version_retention_days integer NOT NULL CHECK(version_retention_days>=0), trash_retention_days integer NOT NULL CHECK(trash_retention_days>=0),
 activity_retention_days integer NOT NULL CHECK(activity_retention_days>=0), features jsonb NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(features)='object'),
 is_sellable boolean NOT NULL DEFAULT false, created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(code,version), CHECK(NOT is_sellable OR price_monthly IS NOT NULL), CHECK(code<>'BASIC' OR price_monthly=0)
);
INSERT INTO billing_plan_versions(code,version,display_name,price_monthly,max_active_workspaces,max_internal_members,max_clients,storage_limit_bytes,monthly_ai_credits,max_concurrent_ai_jobs,version_retention_days,trash_retention_days,activity_retention_days,is_sellable) VALUES
 ('BASIC',1,'Basic',0,1,3,5,2000000000,0,1,7,7,30,true),
 ('PLUS',1,'Plus',NULL,10,15,50,100000000000,5000,3,90,30,180,false),
 ('ENTERPRISE',1,'Enterprise',NULL,50,50,200,1000000000000,25000,10,365,90,365,false);

CREATE TABLE agency_subscriptions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL UNIQUE REFERENCES agencies(id) ON DELETE RESTRICT,
 plan_version_id uuid NOT NULL REFERENCES billing_plan_versions(id) ON DELETE RESTRICT,
 status text NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','EXPIRED','SUSPENDED')),
 current_period_start timestamptz NOT NULL DEFAULT now(), current_period_end timestamptz,
 migration_state text NOT NULL DEFAULT 'REVIEW_REQUIRED' CHECK(migration_state IN ('REVIEW_REQUIRED','READY')),
 version bigint NOT NULL DEFAULT 0 CHECK(version>=0), created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(agency_id,id), CHECK(current_period_end IS NULL OR current_period_end>current_period_start)
);
CREATE INDEX idx_agency_sub_due ON agency_subscriptions(current_period_end) WHERE current_period_end IS NOT NULL;
CREATE TABLE billing_orders (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 payer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 kind text NOT NULL CHECK(kind IN ('SUBSCRIPTION','CREDIT_TOPUP')),
 status text NOT NULL DEFAULT 'PENDING_PAYMENT' CHECK(status IN ('PENDING_PAYMENT','PAID','FULFILLED','EXPIRED','CANCELLED','REVIEW_REQUIRED')),
 idempotency_key text NOT NULL CHECK(length(idempotency_key) BETWEEN 1 AND 200), payload_hash text NOT NULL CHECK(length(payload_hash)=64),
 amount numeric(18,0) NOT NULL CHECK(amount>0), currency char(3) NOT NULL DEFAULT 'VND' CHECK(currency='VND'),
 product_snapshot jsonb NOT NULL CHECK(jsonb_typeof(product_snapshot)='object'),
 plan_version_id uuid REFERENCES billing_plan_versions(id) ON DELETE RESTRICT,
 period_start timestamptz, period_end timestamptz, expires_at timestamptz NOT NULL,
 paid_at timestamptz, fulfilled_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(agency_id,id), UNIQUE(agency_id,kind,idempotency_key), CHECK(expires_at>created_at),
 CHECK((period_start IS NULL AND period_end IS NULL) OR (period_start IS NOT NULL AND period_end IS NOT NULL AND period_end>period_start)),
 CHECK((kind='SUBSCRIPTION' AND plan_version_id IS NOT NULL) OR (kind='CREDIT_TOPUP' AND plan_version_id IS NULL AND period_start IS NULL)),
 CHECK(status<>'FULFILLED' OR (paid_at IS NOT NULL AND fulfilled_at IS NOT NULL))
);
CREATE UNIQUE INDEX uq_pending_agency_subscription_order ON billing_orders(agency_id) WHERE kind='SUBSCRIPTION' AND status IN ('PENDING_PAYMENT','PAID');
CREATE INDEX idx_billing_orders_history ON billing_orders(agency_id,created_at DESC,id);
CREATE TABLE billing_payment_attempts (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL, order_id uuid NOT NULL,
 provider text NOT NULL DEFAULT 'SEEPAY', merchant_account text NOT NULL, provider_order_code text NOT NULL,
 payment_link_id text, status text NOT NULL CHECK(status IN ('PENDING','SUCCEEDED','FAILED','UNKNOWN')),
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(agency_id,id), UNIQUE(provider,merchant_account,provider_order_code), UNIQUE(provider,merchant_account,payment_link_id),
 FOREIGN KEY(agency_id,order_id) REFERENCES billing_orders(agency_id,id) ON DELETE RESTRICT
);
-- Separate transfer records: two real transfers to one link must both be retained.
CREATE TABLE billing_payments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL, attempt_id uuid NOT NULL,
 provider text NOT NULL, merchant_account text NOT NULL, provider_reference text NOT NULL,
 amount numeric(18,0) NOT NULL CHECK(amount>0), currency char(3) NOT NULL, paid_at timestamptz NOT NULL,
 verification_state text NOT NULL CHECK(verification_state IN ('VERIFIED','REVIEW_REQUIRED')),
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(agency_id,id), UNIQUE(provider,merchant_account,provider_reference),
 FOREIGN KEY(agency_id,attempt_id) REFERENCES billing_payment_attempts(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE billing_payment_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), provider text NOT NULL, merchant_account text NOT NULL,
 event_key text NOT NULL, payload_hash text NOT NULL CHECK(length(payload_hash)=64), order_id uuid REFERENCES billing_orders(id) ON DELETE RESTRICT,
 status text NOT NULL DEFAULT 'RECEIVED' CHECK(status IN ('RECEIVED','PROCESSED','REVIEW_REQUIRED')),
 received_at timestamptz NOT NULL DEFAULT now(), processed_at timestamptz, last_error text,
 UNIQUE(provider,merchant_account,event_key)
);
CREATE TABLE billing_order_fulfillments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL, order_id uuid NOT NULL,
 benefit_type text NOT NULL CHECK(benefit_type IN ('SUBSCRIPTION_PERIOD','CREDIT_GRANT')),
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(order_id,benefit_type),
 FOREIGN KEY(agency_id,order_id) REFERENCES billing_orders(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE agency_subscription_periods (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL, subscription_id uuid NOT NULL,
 plan_version_id uuid NOT NULL REFERENCES billing_plan_versions(id) ON DELETE RESTRICT,
 order_id uuid NOT NULL, starts_at timestamptz NOT NULL, ends_at timestamptz NOT NULL,
 status text NOT NULL CHECK(status IN ('FUTURE','CURRENT','ENDED')),
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(agency_id,id), UNIQUE(order_id), UNIQUE(subscription_id,starts_at),
 FOREIGN KEY(agency_id,subscription_id) REFERENCES agency_subscriptions(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,order_id) REFERENCES billing_orders(agency_id,id) ON DELETE RESTRICT, CHECK(ends_at>starts_at)
);
CREATE UNIQUE INDEX uq_one_future_period ON agency_subscription_periods(agency_id) WHERE status='FUTURE';
CREATE UNIQUE INDEX uq_one_current_period ON agency_subscription_periods(agency_id) WHERE status='CURRENT';

-- Existing parent tables are unchanged except a composite identity index for tenant-safe FKs.
CREATE UNIQUE INDEX uq_workspaces_agency_identity_billing ON workspaces(agency_id,id);
CREATE TABLE agency_credit_wallets (
 agency_id uuid PRIMARY KEY REFERENCES agencies(id) ON DELETE RESTRICT,
 available_credits bigint NOT NULL DEFAULT 0 CHECK(available_credits>=0), reserved_credits bigint NOT NULL DEFAULT 0 CHECK(reserved_credits>=0),
 opening_balance_state text NOT NULL DEFAULT 'PENDING' CHECK(opening_balance_state IN ('PENDING','VERIFIED')),
 version bigint NOT NULL DEFAULT 0 CHECK(version>=0), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE credit_grants (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agency_credit_wallets(agency_id) ON DELETE RESTRICT,
 source_type text NOT NULL CHECK(source_type IN ('TRIAL','PERIOD','TOPUP','OPENING','ADJUSTMENT')),
 source_key text NOT NULL, order_id uuid, period_id uuid, trial_owner_id uuid REFERENCES users(id) ON DELETE RESTRICT,
 amount bigint NOT NULL CHECK(amount>0), available bigint NOT NULL CHECK(available>=0), reserved bigint NOT NULL DEFAULT 0 CHECK(reserved>=0),
 consumed bigint NOT NULL DEFAULT 0 CHECK(consumed>=0), expired bigint NOT NULL DEFAULT 0 CHECK(expired>=0), revoked bigint NOT NULL DEFAULT 0 CHECK(revoked>=0),
 valid_from timestamptz NOT NULL, expires_at timestamptz NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(agency_id,id), UNIQUE(agency_id,source_type,source_key),
 FOREIGN KEY(agency_id,order_id) REFERENCES billing_orders(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,period_id) REFERENCES agency_subscription_periods(agency_id,id) ON DELETE RESTRICT,
 CHECK(expires_at>valid_from), CHECK(amount::numeric=available::numeric+reserved::numeric+consumed::numeric+expired::numeric+revoked::numeric),
 CHECK((source_type='TRIAL')=(trial_owner_id IS NOT NULL)),
 CHECK(source_type<>'TOPUP' OR order_id IS NOT NULL), CHECK(source_type<>'PERIOD' OR period_id IS NOT NULL)
);
CREATE UNIQUE INDEX uq_credit_trial_once ON credit_grants(trial_owner_id,source_key) WHERE source_type='TRIAL';
CREATE UNIQUE INDEX uq_credit_period_once ON credit_grants(period_id) WHERE source_type='PERIOD';
CREATE UNIQUE INDEX uq_credit_topup_once ON credit_grants(order_id) WHERE source_type='TOPUP';
CREATE INDEX idx_grant_spend ON credit_grants(agency_id,expires_at,id) WHERE available>0;
CREATE TABLE workspace_credit_limits (
 agency_id uuid NOT NULL, workspace_id uuid NOT NULL, cap bigint CHECK(cap>=0), version bigint NOT NULL DEFAULT 0 CHECK(version>=0),
 updated_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT, updated_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY(agency_id,workspace_id),
 FOREIGN KEY(agency_id,workspace_id) REFERENCES workspaces(agency_id,id) ON DELETE RESTRICT
);
-- Keep old creator limits untouched until service cutover; new scoped config preserves them separately.
CREATE TABLE agency_creator_credit_limits (
 agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT, creator_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 cap bigint CHECK(cap>=0), version bigint NOT NULL DEFAULT 0 CHECK(version>=0),
 updated_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT, updated_at timestamptz NOT NULL DEFAULT now(), PRIMARY KEY(agency_id,creator_id)
);
CREATE TABLE credit_usage_periods (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 starts_at timestamptz NOT NULL, ends_at timestamptz NOT NULL, kind text NOT NULL CHECK(kind IN ('BASIC_CALENDAR','PAID')),
 subscription_period_id uuid, UNIQUE(agency_id,id), UNIQUE(agency_id,starts_at,kind), CHECK(ends_at>starts_at),
 FOREIGN KEY(agency_id,subscription_period_id) REFERENCES agency_subscription_periods(agency_id,id) ON DELETE RESTRICT,
 CHECK((kind='PAID')=(subscription_period_id IS NOT NULL))
);
CREATE TABLE workspace_credit_usage (
 agency_id uuid NOT NULL, workspace_id uuid NOT NULL, period_id uuid NOT NULL,
 used bigint NOT NULL DEFAULT 0 CHECK(used>=0), reserved bigint NOT NULL DEFAULT 0 CHECK(reserved>=0),
 PRIMARY KEY(agency_id,workspace_id,period_id),
 FOREIGN KEY(agency_id,workspace_id) REFERENCES workspaces(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,period_id) REFERENCES credit_usage_periods(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE creator_credit_usage (
 agency_id uuid NOT NULL, creator_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT, period_id uuid NOT NULL,
 used bigint NOT NULL DEFAULT 0 CHECK(used>=0), reserved bigint NOT NULL DEFAULT 0 CHECK(reserved>=0),
 PRIMARY KEY(agency_id,creator_id,period_id), FOREIGN KEY(agency_id,period_id) REFERENCES credit_usage_periods(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE ai_credit_reservations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), job_id uuid NOT NULL UNIQUE, agency_id uuid NOT NULL,
 workspace_id uuid NOT NULL, actor_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT, period_id uuid NOT NULL,
 action text NOT NULL, model text NOT NULL, rate_version text NOT NULL,
 status text NOT NULL CHECK(status IN ('RESERVED','UNKNOWN','SETTLED','RELEASED')),
 reserved_amount bigint NOT NULL CHECK(reserved_amount>0), charged_amount bigint NOT NULL DEFAULT 0 CHECK(charged_amount>=0),
 provider_job_id text, deadline timestamptz NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), settled_at timestamptz,
 UNIQUE(agency_id,id), FOREIGN KEY(agency_id,workspace_id) REFERENCES workspaces(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,period_id) REFERENCES credit_usage_periods(agency_id,id) ON DELETE RESTRICT,
 CHECK(charged_amount<=reserved_amount), CHECK(deadline>created_at),
 CHECK(status='SETTLED' OR charged_amount=0), CHECK(status NOT IN ('SETTLED','RELEASED') OR settled_at IS NOT NULL)
);
CREATE INDEX idx_ai_reservation_reconcile ON ai_credit_reservations(deadline) WHERE status IN ('RESERVED','UNKNOWN');
CREATE TABLE credit_reservation_allocations (
 agency_id uuid NOT NULL, reservation_id uuid NOT NULL, grant_id uuid NOT NULL,
 amount bigint NOT NULL CHECK(amount>0), charged bigint NOT NULL DEFAULT 0 CHECK(charged>=0), released bigint NOT NULL DEFAULT 0 CHECK(released>=0),
 PRIMARY KEY(reservation_id,grant_id), CHECK(charged::numeric+released::numeric<=amount::numeric),
 FOREIGN KEY(agency_id,reservation_id) REFERENCES ai_credit_reservations(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,grant_id) REFERENCES credit_grants(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE credit_operations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 operation_key text NOT NULL, kind text NOT NULL CHECK(kind IN ('GRANT','RESERVE','SETTLE','RELEASE','EXPIRE','REVERSAL')),
 actor_id uuid REFERENCES users(id) ON DELETE RESTRICT, reservation_id uuid, reversal_of uuid,
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(agency_id,id), UNIQUE(agency_id,operation_key),
 FOREIGN KEY(agency_id,reservation_id) REFERENCES ai_credit_reservations(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,reversal_of) REFERENCES credit_operations(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE credit_entries (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL, operation_id uuid NOT NULL, grant_id uuid NOT NULL,
 available_delta bigint NOT NULL DEFAULT 0, reserved_delta bigint NOT NULL DEFAULT 0,
 consumed_delta bigint NOT NULL DEFAULT 0, expired_delta bigint NOT NULL DEFAULT 0, revoked_delta bigint NOT NULL DEFAULT 0,
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(operation_id,grant_id),
 FOREIGN KEY(agency_id,operation_id) REFERENCES credit_operations(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,grant_id) REFERENCES credit_grants(agency_id,id) ON DELETE RESTRICT,
 CHECK(available_delta<>0 OR reserved_delta<>0 OR consumed_delta<>0 OR expired_delta<>0 OR revoked_delta<>0)
);
CREATE INDEX idx_credit_entries_agency_time ON credit_entries(agency_id,created_at,id);
CREATE FUNCTION billing_reject_ledger_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'Billing journal is append-only; use a reversal entry' USING ERRCODE='23514'; END $$;
CREATE TRIGGER credit_entries_immutable BEFORE UPDATE OR DELETE ON credit_entries FOR EACH ROW EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TRIGGER credit_operations_immutable BEFORE UPDATE OR DELETE ON credit_operations FOR EACH ROW EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TRIGGER credit_entries_no_truncate BEFORE TRUNCATE ON credit_entries FOR EACH STATEMENT EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TRIGGER credit_operations_no_truncate BEFORE TRUNCATE ON credit_operations FOR EACH STATEMENT EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TABLE agency_resource_usage (
 agency_id uuid PRIMARY KEY REFERENCES agencies(id) ON DELETE RESTRICT,
 used_bytes bigint NOT NULL DEFAULT 0 CHECK(used_bytes>=0), reserved_bytes bigint NOT NULL DEFAULT 0 CHECK(reserved_bytes>=0),
 active_workspaces bigint NOT NULL DEFAULT 0 CHECK(active_workspaces>=0), internal_members bigint NOT NULL DEFAULT 0 CHECK(internal_members>=0),
 active_clients bigint NOT NULL DEFAULT 0 CHECK(active_clients>=0), inventory_state text NOT NULL DEFAULT 'PENDING' CHECK(inventory_state IN ('PENDING','VERIFIED')),
 version bigint NOT NULL DEFAULT 0 CHECK(version>=0), reconciled_at timestamptz, updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE storage_reservations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 upload_id uuid NOT NULL UNIQUE, workspace_id uuid, reserved_bytes bigint NOT NULL CHECK(reserved_bytes>0),
 status text NOT NULL DEFAULT 'RESERVED' CHECK(status IN ('RESERVED','UNKNOWN','FINALIZED','RELEASED')),
 expires_at timestamptz NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(agency_id,id), CHECK(expires_at>created_at),
 FOREIGN KEY(agency_id,workspace_id) REFERENCES workspaces(agency_id,id) ON DELETE RESTRICT
);
CREATE TABLE storage_objects (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 workspace_id uuid, reservation_id uuid, uploaded_by uuid REFERENCES users(id) ON DELETE RESTRICT,
 backend text NOT NULL, bucket text NOT NULL, object_key text NOT NULL, size_bytes bigint NOT NULL CHECK(size_bytes>=0),
 status text NOT NULL CHECK(status IN ('UPLOADING','ACTIVE','TRASH','DELETE_PENDING','DELETED')),
 created_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz,
 UNIQUE(backend,bucket,object_key), UNIQUE(agency_id,id),
 FOREIGN KEY(agency_id,workspace_id) REFERENCES workspaces(agency_id,id) ON DELETE RESTRICT,
 FOREIGN KEY(agency_id,reservation_id) REFERENCES storage_reservations(agency_id,id) ON DELETE RESTRICT,
 CHECK(status<>'DELETED' OR deleted_at IS NOT NULL)
);
CREATE INDEX idx_storage_agency_status ON storage_objects(agency_id,status);
CREATE TABLE billing_outbox_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 event_key text NOT NULL UNIQUE, event_type text NOT NULL, payload jsonb NOT NULL CHECK(jsonb_typeof(payload)='object'),
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts>=0), available_at timestamptz NOT NULL DEFAULT now(),
 published_at timestamptz, last_error text, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_billing_outbox_due ON billing_outbox_events(available_at,id) WHERE published_at IS NULL;
CREATE TABLE billing_audit_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
 actor_id uuid REFERENCES users(id) ON DELETE RESTRICT, action text NOT NULL, resource_id uuid,
 before_value jsonb, after_value jsonb, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TRIGGER billing_audit_immutable BEFORE UPDATE OR DELETE ON billing_audit_events FOR EACH ROW EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TRIGGER billing_audit_no_truncate BEFORE TRUNCATE ON billing_audit_events FOR EACH STATEMENT EXECUTE FUNCTION billing_reject_ledger_mutation();
CREATE TABLE billing_migration_reviews (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), source_table text NOT NULL, source_id uuid NOT NULL,
 owner_id uuid REFERENCES users(id) ON DELETE RESTRICT, candidate_agency_ids uuid[] NOT NULL DEFAULT '{}',
 reason text NOT NULL, status text NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING','RESOLVED')),
 resolved_agency_id uuid REFERENCES agencies(id) ON DELETE RESTRICT, resolved_by uuid REFERENCES users(id) ON DELETE RESTRICT,
 resolution_note text, resolved_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(source_table,source_id),
 CHECK(status<>'RESOLVED' OR (resolved_by IS NOT NULL AND resolved_at IS NOT NULL AND resolution_note IS NOT NULL AND length(btrim(resolution_note))>0))
);

-- No automatic paid mapping or credit reconstruction, even when owner has just one agency.
INSERT INTO agency_subscriptions(agency_id,plan_version_id,migration_state)
 SELECT a.id,p.id,'REVIEW_REQUIRED' FROM agencies a CROSS JOIN billing_plan_versions p WHERE p.code='BASIC' AND p.version=1;
INSERT INTO agency_credit_wallets(agency_id) SELECT id FROM agencies;
INSERT INTO agency_resource_usage(agency_id,active_workspaces,internal_members,active_clients)
 SELECT a.id,
 (SELECT count(*) FROM workspaces w WHERE w.agency_id=a.id AND w.status::text='ACTIVE'),
 (SELECT count(*) FROM (SELECT am.user_id FROM agency_members am WHERE am.agency_id=a.id UNION SELECT a.owner_id) members),
 (SELECT count(DISTINCT wm.client_profile_id) FROM workspace_members wm JOIN workspaces w ON w.id=wm.workspace_id
  WHERE w.agency_id=a.id AND wm.is_active AND wm.role::text='CLIENT')
 FROM agencies a;
INSERT INTO billing_migration_reviews(source_table,source_id,owner_id,candidate_agency_ids,reason)
 SELECT 'user_subscriptions',s.id,s.user_id,ARRAY(SELECT a.id FROM agencies a WHERE a.owner_id=s.user_id ORDER BY a.id),
 'Legacy entitlement must be mapped and balances reconciled before agency cutover' FROM user_subscriptions s;
INSERT INTO billing_migration_reviews(source_table,source_id,owner_id,candidate_agency_ids,reason)
 SELECT 'transactions',t.id,t.user_id,ARRAY(SELECT a.id FROM agencies a WHERE a.owner_id=t.user_id ORDER BY a.id),
 'Payer alone does not prove beneficiary agency; preserve original payment' FROM transactions t;
INSERT INTO billing_migration_reviews(source_table,source_id,owner_id,candidate_agency_ids,reason)
 SELECT 'subscription_plan_changes',s.id,s.user_id,ARRAY(SELECT a.id FROM agencies a WHERE a.owner_id=s.user_id ORDER BY a.id),
 'Legacy pending plan change requires explicit resolution; downgrade FR deferred' FROM subscription_plan_changes s WHERE s.status='PENDING';
INSERT INTO agency_creator_credit_limits(agency_id,creator_id,cap,updated_by)
 SELECT agency_id,creator_id,monthly_limit,set_by FROM ai_credit_creator_limits WHERE monthly_limit>=0;
INSERT INTO billing_migration_reviews(source_table,source_id,candidate_agency_ids,reason)
 SELECT 'ai_credit_creator_limits',id,ARRAY[agency_id],'Invalid legacy negative limit must be resolved' FROM ai_credit_creator_limits WHERE monthly_limit<0;

CREATE FUNCTION billing_guard_plan_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 IF TG_OP='DELETE' OR TG_OP='TRUNCATE' THEN
  RAISE EXCEPTION 'Plan versions are immutable; disable sale instead' USING ERRCODE='23514';
 END IF;
 IF (to_jsonb(NEW)-'is_sellable') IS DISTINCT FROM (to_jsonb(OLD)-'is_sellable') THEN
  RAISE EXCEPTION 'Create a new plan version to change price or benefits' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER billing_plan_version_immutable BEFORE UPDATE OR DELETE ON billing_plan_versions FOR EACH ROW EXECUTE FUNCTION billing_guard_plan_version();
CREATE TRIGGER billing_plan_version_no_truncate BEFORE TRUNCATE ON billing_plan_versions FOR EACH STATEMENT EXECUTE FUNCTION billing_guard_plan_version();
-- Guard paid-period overlap under the same parent lock as the application protocol.
CREATE FUNCTION billing_guard_period_overlap() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 PERFORM 1 FROM agency_subscriptions WHERE id=NEW.subscription_id AND agency_id=NEW.agency_id FOR UPDATE;
 IF EXISTS(SELECT 1 FROM agency_subscription_periods p WHERE p.subscription_id=NEW.subscription_id AND p.id<>NEW.id
   AND tstzrange(p.starts_at,p.ends_at,'[)') && tstzrange(NEW.starts_at,NEW.ends_at,'[)')) THEN
  RAISE EXCEPTION 'Subscription periods cannot overlap' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER billing_period_overlap BEFORE INSERT OR UPDATE ON agency_subscription_periods FOR EACH ROW EXECUTE FUNCTION billing_guard_period_overlap();

INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261020_agency_subscription_expand_v1','Expand only: agency billing catalog, payments, credit, budgets, storage; legacy review required');
\endif
COMMIT;

