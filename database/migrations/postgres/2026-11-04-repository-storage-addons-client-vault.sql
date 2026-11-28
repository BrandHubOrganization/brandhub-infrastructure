-- Repository S3 add-ons and Client vault accounting. Review/backup before applying.
BEGIN;
ALTER TABLE billing_plan_versions DISABLE TRIGGER billing_plan_version_immutable;
UPDATE billing_plan_versions SET storage_limit_bytes=5368709120 WHERE code IN ('BASIC','PERSONAL');
ALTER TABLE billing_plan_versions ENABLE TRIGGER billing_plan_version_immutable;
ALTER TABLE agency_storage_reservations ADD COLUMN IF NOT EXISTS owner_user_id uuid REFERENCES users(id);
ALTER TABLE storage_usage_entries ADD COLUMN IF NOT EXISTS owner_user_id uuid REFERENCES users(id);
-- Preserve existing Agency billing while allowing Client-scoped storage orders.
ALTER TABLE billing_orders ALTER COLUMN agency_id DROP NOT NULL;
ALTER TABLE billing_orders ADD COLUMN IF NOT EXISTS payer_scope text NOT NULL DEFAULT 'AGENCY';
DO $$ DECLARE item record; BEGIN
 FOR item IN SELECT conname FROM pg_constraint WHERE conrelid='billing_orders'::regclass AND contype='c' AND pg_get_constraintdef(oid) LIKE '%kind%' LOOP
  EXECUTE format('ALTER TABLE billing_orders DROP CONSTRAINT %I',item.conname);
 END LOOP;
END $$;
ALTER TABLE billing_orders ADD CONSTRAINT billing_order_kind_supported CHECK(kind IN ('SUBSCRIPTION','CREDIT_TOPUP','STORAGE_ADDON'));
ALTER TABLE billing_orders ADD CONSTRAINT billing_order_product_supported CHECK(
 (kind='SUBSCRIPTION' AND plan_version_id IS NOT NULL) OR (kind='CREDIT_TOPUP' AND plan_version_id IS NULL AND period_start IS NULL) OR (kind='STORAGE_ADDON' AND plan_version_id IS NULL));
ALTER TABLE billing_orders DROP CONSTRAINT IF EXISTS billing_order_payer_scope;
ALTER TABLE billing_orders ADD CONSTRAINT billing_order_payer_scope CHECK((payer_scope='AGENCY' AND agency_id IS NOT NULL) OR (payer_scope='CLIENT_VAULT' AND agency_id IS NULL AND payer_user_id IS NOT NULL AND kind='STORAGE_ADDON'));
CREATE UNIQUE INDEX IF NOT EXISTS uq_client_storage_checkout_key ON billing_orders(payer_user_id,kind,idempotency_key) WHERE payer_scope='CLIENT_VAULT';
ALTER TABLE billing_payment_attempts ALTER COLUMN agency_id DROP NOT NULL;
ALTER TABLE billing_payments ALTER COLUMN agency_id DROP NOT NULL;
ALTER TABLE billing_order_fulfillments ALTER COLUMN agency_id DROP NOT NULL;
ALTER TABLE billing_order_fulfillments DROP CONSTRAINT IF EXISTS billing_order_fulfillments_benefit_type_check;
ALTER TABLE billing_order_fulfillments ADD CONSTRAINT billing_order_fulfillments_benefit_type_check CHECK(benefit_type IN ('SUBSCRIPTION_PERIOD','CREDIT_GRANT','STORAGE_ADDON'));
-- Nullable tenant FKs need an additional global identity FK for Client orders.
ALTER TABLE billing_payment_attempts DROP CONSTRAINT IF EXISTS storage_attempt_order_identity;
ALTER TABLE billing_payment_attempts ADD CONSTRAINT storage_attempt_order_identity FOREIGN KEY(order_id) REFERENCES billing_orders(id);
ALTER TABLE billing_payments DROP CONSTRAINT IF EXISTS storage_payment_attempt_identity;
ALTER TABLE billing_payments ADD CONSTRAINT storage_payment_attempt_identity FOREIGN KEY(attempt_id) REFERENCES billing_payment_attempts(id);
ALTER TABLE billing_order_fulfillments DROP CONSTRAINT IF EXISTS storage_fulfillment_order_identity;
ALTER TABLE billing_order_fulfillments ADD CONSTRAINT storage_fulfillment_order_identity FOREIGN KEY(order_id) REFERENCES billing_orders(id);
CREATE TABLE IF NOT EXISTS storage_addon_plans (
 code text PRIMARY KEY, extra_bytes bigint NOT NULL CHECK(extra_bytes>0),
 price_monthly numeric(18,0) NOT NULL CHECK(price_monthly>0), active boolean NOT NULL DEFAULT true
);
INSERT INTO storage_addon_plans(code,extra_bytes,price_monthly) VALUES
 ('S3_ADDON_25GB',26843545600,49000),('S3_ADDON_100GB',107374182400,149000),('S3_ADDON_500GB',536870912000,499000)
 ON CONFLICT(code) DO NOTHING;
CREATE TABLE IF NOT EXISTS storage_addon_subscriptions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), agency_id uuid REFERENCES agencies(id), owner_user_id uuid REFERENCES users(id),
 plan_code text NOT NULL REFERENCES storage_addon_plans(code), extra_bytes bigint NOT NULL CHECK(extra_bytes>0),
 order_id uuid NOT NULL UNIQUE REFERENCES billing_orders(id), status text NOT NULL CHECK(status IN ('ACTIVE','EXPIRED','CANCELLED')),
 current_period_start timestamptz NOT NULL, current_period_end timestamptz NOT NULL,
 CHECK((agency_id IS NULL)<>(owner_user_id IS NULL)), CHECK(current_period_end>current_period_start)
);
CREATE INDEX IF NOT EXISTS idx_storage_addon_agency ON storage_addon_subscriptions(agency_id,current_period_end) WHERE status='ACTIVE';
CREATE INDEX IF NOT EXISTS idx_storage_addon_client ON storage_addon_subscriptions(owner_user_id,current_period_end) WHERE status='ACTIVE';
CREATE TABLE IF NOT EXISTS client_vault_storage_usage (
 user_id uuid PRIMARY KEY REFERENCES users(id), used_bytes bigint NOT NULL DEFAULT 0 CHECK(used_bytes>=0),
 reserved_bytes bigint NOT NULL DEFAULT 0 CHECK(reserved_bytes>=0), version bigint NOT NULL DEFAULT 0,
 inventory_verified_at timestamptz, updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS client_vault_quota_releases (
 material_id text PRIMARY KEY, owner_user_id uuid NOT NULL REFERENCES users(id), released_bytes bigint NOT NULL CHECK(released_bytes>=0), created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS repository_vault_migration_receipts (
 material_id text PRIMARY KEY, agency_id uuid NOT NULL REFERENCES agencies(id), owner_user_id uuid NOT NULL REFERENCES users(id), transferred_bytes bigint NOT NULL CHECK(transferred_bytes>=0), created_at timestamptz NOT NULL DEFAULT now()
);
-- Existing Client materials must be inventoried and their agency balances reconciled before marking verified.
COMMIT;
