-- BrandHub — PostgreSQL initialization script
-- Runs automatically on first container start
-- Path in container: /docker-entrypoint-initdb.d/init-postgres.sql
-- Idempotent: all statements use IF NOT EXISTS / ON CONFLICT DO NOTHING

-- ============================================================
-- EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";  -- gen_random_uuid()

-- ============================================================
-- ENUMS
-- ============================================================

DO $$ BEGIN
  CREATE TYPE workspace_plan AS ENUM ('FREE', 'BASIC', 'PRO', 'ENTERPRISE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE subscription_status AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELLED', 'TRIALING');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE invoice_status AS ENUM ('DRAFT', 'ISSUED', 'PAID', 'OVERDUE', 'VOID');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE payment_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE audit_action AS ENUM ('LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'ROLE_CHANGE', 'PERMISSION_CHANGE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================
-- TABLE: subscription_plans
-- Master data — available workspace plans and their limits
-- ============================================================

CREATE TABLE IF NOT EXISTS subscription_plans (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name             workspace_plan NOT NULL,
  display_name     VARCHAR(100)  NOT NULL,
  price_monthly    DECIMAL(12,2) NOT NULL,
  price_yearly     DECIMAL(12,2) NOT NULL,
  max_workspaces   INTEGER       NOT NULL DEFAULT 1,
  max_members      INTEGER       NOT NULL,   -- -1 = unlimited
  max_clients      INTEGER       NOT NULL,   -- -1 = unlimited
  max_posts_month  INTEGER       NOT NULL,   -- -1 = unlimited
  ai_credits_month INTEGER       NOT NULL,   -- -1 = unlimited
  features         JSONB         NOT NULL DEFAULT '[]',
  is_active        BOOLEAN       NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT uq_subscription_plans_name UNIQUE (name)
);

COMMENT ON TABLE subscription_plans IS 'Master data for available workspace plans. Do not DELETE a plan with active subscriptions.';
COMMENT ON COLUMN subscription_plans.features IS 'Array of feature flag strings, e.g. ["ai_image_gen","ambassador_mode"]';

-- ============================================================
-- TABLE: workspace_subscriptions
-- One row per workspace — current billing subscription
-- ============================================================

CREATE TABLE IF NOT EXISTS workspace_subscriptions (
  id                   UUID                NOT NULL DEFAULT gen_random_uuid(),
  workspace_id         VARCHAR(24)         NOT NULL,  -- soft ref → workspaces._id (MongoDB ObjectId)
  plan_id              UUID                NOT NULL,
  status               subscription_status NOT NULL DEFAULT 'TRIALING',
  trial_ends_at        TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ         NOT NULL,
  current_period_end   TIMESTAMPTZ         NOT NULL,
  cancelled_at         TIMESTAMPTZ,
  cancel_reason        TEXT,
  created_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_workspace_subscriptions PRIMARY KEY (id),
  CONSTRAINT uq_workspace_subscriptions_workspace UNIQUE (workspace_id),
  CONSTRAINT fk_workspace_subscriptions_plan
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_period_order
    CHECK (current_period_end > current_period_start)
);

CREATE INDEX IF NOT EXISTS idx_workspace_subscriptions_status_period
  ON workspace_subscriptions (status, current_period_end);

COMMENT ON TABLE workspace_subscriptions IS 'One active subscription per workspace. workspace_id is a soft ref to MongoDB workspaces._id.';
COMMENT ON COLUMN workspace_subscriptions.workspace_id IS 'MongoDB ObjectId as string (24 hex chars). No FK constraint — cross-DB soft reference.';

-- ============================================================
-- TABLE: invoices
-- Financial invoices — immutable after status = ISSUED
-- ============================================================

CREATE TABLE IF NOT EXISTS invoices (
  id              UUID           NOT NULL DEFAULT gen_random_uuid(),
  workspace_id    VARCHAR(24)    NOT NULL,  -- soft ref → workspaces._id (MongoDB)
  subscription_id UUID           NOT NULL,
  invoice_number  VARCHAR(50)    NOT NULL,
  status          invoice_status NOT NULL DEFAULT 'DRAFT',
  amount          DECIMAL(15,2)  NOT NULL,
  currency        CHAR(3)        NOT NULL DEFAULT 'VND',
  period_start    TIMESTAMPTZ    NOT NULL,
  period_end      TIMESTAMPTZ    NOT NULL,
  issued_at       TIMESTAMPTZ,
  due_at          TIMESTAMPTZ,
  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_invoices PRIMARY KEY (id),
  CONSTRAINT uq_invoices_number UNIQUE (invoice_number),
  CONSTRAINT fk_invoices_subscription
    FOREIGN KEY (subscription_id) REFERENCES workspace_subscriptions(id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_invoice_amount_positive
    CHECK (amount >= 0),
  CONSTRAINT chk_invoice_period_order
    CHECK (period_end > period_start)
);

CREATE INDEX IF NOT EXISTS idx_invoices_workspace_id  ON invoices (workspace_id);
CREATE INDEX IF NOT EXISTS idx_invoices_subscription  ON invoices (subscription_id);
CREATE INDEX IF NOT EXISTS idx_invoices_number        ON invoices (invoice_number);
CREATE INDEX IF NOT EXISTS idx_invoices_status        ON invoices (status);

COMMENT ON TABLE invoices IS 'Financial invoices. After status = ISSUED, no UPDATE allowed (enforced at application layer).';
COMMENT ON COLUMN invoices.workspace_id IS 'MongoDB ObjectId as string. Soft reference — no FK constraint across databases.';

-- ============================================================
-- TABLE: payments
-- Payment transaction records — must be atomic with invoice update
-- ============================================================

CREATE TABLE IF NOT EXISTS payments (
  id              UUID           NOT NULL DEFAULT gen_random_uuid(),
  workspace_id    VARCHAR(24)    NOT NULL,  -- soft ref → workspaces._id (MongoDB)
  invoice_id      UUID           NOT NULL,
  amount          DECIMAL(15,2)  NOT NULL,
  currency        CHAR(3)        NOT NULL DEFAULT 'VND',
  status          payment_status NOT NULL DEFAULT 'PENDING',
  payment_method  VARCHAR(50),              -- bank_transfer | momo | vnpay | stripe
  transaction_id  VARCHAR(255),             -- external payment gateway TX ID
  paid_at         TIMESTAMPTZ,
  failed_reason   TEXT,
  created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),

  CONSTRAINT pk_payments PRIMARY KEY (id),
  CONSTRAINT uq_payments_transaction UNIQUE (transaction_id),
  CONSTRAINT fk_payments_invoice
    FOREIGN KEY (invoice_id) REFERENCES invoices(id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_payment_amount_positive
    CHECK (amount > 0)
);

CREATE INDEX IF NOT EXISTS idx_payments_invoice_id   ON payments (invoice_id);
CREATE INDEX IF NOT EXISTS idx_payments_workspace_id ON payments (workspace_id);
CREATE INDEX IF NOT EXISTS idx_payments_transaction  ON payments (transaction_id);
CREATE INDEX IF NOT EXISTS idx_payments_status       ON payments (status);

COMMENT ON TABLE payments IS 'Payment transactions. INSERT + invoice UPDATE must be in a single transaction. No DELETE after COMPLETED.';

-- ============================================================
-- TABLE: audit_logs
-- Append-only security audit log — NO UPDATE, NO DELETE ever
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_logs (
  id            BIGSERIAL     PRIMARY KEY,  -- BIGSERIAL: very high volume, UUID overhead not justified
  workspace_id  VARCHAR(24),                -- nullable: ADMIN-level actions may have no workspace
  user_id       VARCHAR(24)   NOT NULL,     -- soft ref → users._id (MongoDB)
  action        audit_action  NOT NULL,
  resource_type VARCHAR(100)  NOT NULL,     -- User | Post | Workspace | Client | SocialAccount | ...
  resource_id   VARCHAR(255),               -- ID of affected entity (any DB)
  old_value     JSONB,                      -- state before change (null for CREATE/LOGIN)
  new_value     JSONB,                      -- state after change (null for DELETE/LOGOUT)
  ip_address    VARCHAR(45),                -- IPv4 or IPv6
  user_agent    TEXT,
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()

  -- No FK constraints: audit_logs must survive even if referenced entities are deleted
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_created
  ON audit_logs (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_workspace_created
  ON audit_logs (workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource
  ON audit_logs (resource_type, resource_id);

COMMENT ON TABLE audit_logs IS 'Append-only security log. No UPDATE or DELETE permission granted to any service account. BIGSERIAL PK for high-volume inserts.';
COMMENT ON COLUMN audit_logs.workspace_id IS 'Nullable — ADMIN actions (e.g. global config change) have no workspace scope.';

-- ============================================================
-- SEED: subscription_plans
-- ============================================================

INSERT INTO subscription_plans (
  name, display_name,
  price_monthly, price_yearly,
  max_workspaces, max_members, max_clients, max_posts_month, ai_credits_month,
  features, is_active
) VALUES
  (
    'FREE', 'Free',
    0, 0,
    1, 3, 1, 30, 50,
    '["basic_scheduling","basic_analytics"]',
    TRUE
  ),
  (
    'BASIC', 'Basic',
    490000, 4900000,
    1, 10, 5, 150, 300,
    '["basic_scheduling","basic_analytics","content_requests","multi_platform"]',
    TRUE
  ),
  (
    'PRO', 'Professional',
    990000, 9900000,
    1, 30, 20, 500, 1000,
    '["basic_scheduling","basic_analytics","content_requests","multi_platform","ai_content_gen","ai_image_gen","advanced_reports","approval_workflow"]',
    TRUE
  ),
  (
    'ENTERPRISE', 'Enterprise',
    2990000, 29900000,
    1, -1, -1, -1, 5000,
    '["basic_scheduling","basic_analytics","content_requests","multi_platform","ai_content_gen","ai_image_gen","advanced_reports","approval_workflow","ambassador_mode","ai_video_gen","dedicated_support","sla"]',
    TRUE
  )
ON CONFLICT (name) DO NOTHING;

-- ============================================================

DO $$ BEGIN
  RAISE NOTICE '✅ BrandHub PostgreSQL initialized: 5 tables, 4 subscription plans seeded.';
END $$;
