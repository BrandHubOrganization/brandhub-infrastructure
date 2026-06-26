-- ============================================================
-- BrandHub PostgreSQL Init Script
-- DA-E06-07 | Idempotent (safe to re-run)
-- Tables: users, user_oauth_providers, user_refresh_tokens,
--         workspaces, workspace_members, clients,
--         subscription_plans, workspace_subscriptions,
--         invoices, payments, audit_logs
-- ============================================================

-- ── Enums ────────────────────────────────────────────────────

DO $$ BEGIN CREATE TYPE user_status AS ENUM ('ACTIVE','SUSPENDED','DELETED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE oauth_provider AS ENUM ('GOOGLE','FACEBOOK');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE member_role AS ENUM ('OWNER','MANAGER','CREATOR','VIEWER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE workspace_plan AS ENUM ('FREE','BASIC','PRO','ENTERPRISE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE subscription_status AS ENUM ('ACTIVE','EXPIRED','CANCELLED','TRIALING');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE invoice_status AS ENUM ('DRAFT','ISSUED','PAID','OVERDUE','VOID');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE payment_status AS ENUM ('PENDING','COMPLETED','FAILED','REFUNDED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN CREATE TYPE audit_action AS ENUM ('LOGIN','LOGOUT','CREATE','UPDATE','DELETE','ROLE_CHANGE','PERMISSION_CHANGE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── users ─────────────────────────────────────────────────────
-- Core identity only. role + workspace belong to workspace_members.
CREATE TABLE IF NOT EXISTS users (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR,                            -- null = OAuth-only
    full_name       VARCHAR(255) NOT NULL,
    avatar_url      VARCHAR,
    status          user_status  NOT NULL DEFAULT 'ACTIVE',
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    preferences     JSONB        NOT NULL DEFAULT '{}', -- {language, timezone, notifications}
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ── user_oauth_providers ──────────────────────────────────────
-- 1NF: extracted from users.oauth_providers[]
CREATE TABLE IF NOT EXISTS user_oauth_providers (
    id          UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider    oauth_provider NOT NULL,
    provider_id VARCHAR(255)   NOT NULL,
    UNIQUE (provider, provider_id)
);

CREATE INDEX IF NOT EXISTS idx_oauth_providers_user_id ON user_oauth_providers(user_id);

-- ── user_refresh_tokens ───────────────────────────────────────
-- 1NF: extracted from users.refresh_tokens[]
CREATE TABLE IF NOT EXISTS user_refresh_tokens (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    jti         VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON user_refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_jti     ON user_refresh_tokens(jti);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires ON user_refresh_tokens(expires_at);

-- ── workspaces ────────────────────────────────────────────────
-- Removed: plan (read from workspace_subscriptions), subscription_id (reverse lookup)
CREATE TABLE IF NOT EXISTS workspaces (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(100) NOT NULL UNIQUE,
    owner_id    UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    logo_url    VARCHAR,
    settings    JSONB        NOT NULL DEFAULT '{}', -- {brandColor, defaultLanguage, approvalRequired, timezone, defaultPlatforms, reportFrequency}
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workspaces_slug     ON workspaces(slug);
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON workspaces(owner_id);

-- ── workspace_members ─────────────────────────────────────────
-- Junction: user ↔ workspace with role in that workspace
CREATE TABLE IF NOT EXISTS workspace_members (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id  UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    user_id       UUID        NOT NULL REFERENCES users(id)      ON DELETE RESTRICT,
    role          member_role  NOT NULL,
    invited_by    UUID        REFERENCES users(id),
    joined_at     TIMESTAMPTZ,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_workspace_members_workspace ON workspace_members(workspace_id);
CREATE INDEX IF NOT EXISTS idx_workspace_members_user      ON workspace_members(user_id);

-- ── clients ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clients (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id          UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    name                  VARCHAR(255) NOT NULL,
    brand_name            VARCHAR(255),
    industry              VARCHAR(100),
    logo_url              VARCHAR,
    contact_email         VARCHAR(255),
    contact_phone         VARCHAR(50),
    assigned_manager_id   UUID        REFERENCES users(id),
    portal_access_enabled BOOLEAN      NOT NULL DEFAULT FALSE,
    portal_user_id        UUID        REFERENCES users(id),     -- FK thật (user with BRAND_CLIENT role)
    service_package       JSONB        NOT NULL DEFAULT '{}',   -- {postsPerMonth, platforms[], aiCreditsPerMonth}
    metadata              JSONB        NOT NULL DEFAULT '{}',
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clients_workspace_id ON clients(workspace_id);

-- ── subscription_plans ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subscription_plans (
    id               UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    name             workspace_plan NOT NULL UNIQUE,
    display_name     VARCHAR(100)   NOT NULL,
    price_monthly    DECIMAL(12,2)  NOT NULL,
    price_yearly     DECIMAL(12,2)  NOT NULL,
    max_members      INTEGER        NOT NULL,
    max_clients      INTEGER        NOT NULL,
    max_posts_month  INTEGER        NOT NULL,
    ai_credits_month INTEGER        NOT NULL,
    features         JSONB          NOT NULL DEFAULT '[]',
    is_active        BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── workspace_subscriptions ───────────────────────────────────
-- workspace_id is now a real FK to workspaces
CREATE TABLE IF NOT EXISTS workspace_subscriptions (
    id                   UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id         UUID                NOT NULL UNIQUE REFERENCES workspaces(id) ON DELETE RESTRICT,
    plan_id              UUID                NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    status               subscription_status NOT NULL DEFAULT 'TRIALING',
    trial_ends_at        TIMESTAMPTZ,
    current_period_start TIMESTAMPTZ         NOT NULL,
    current_period_end   TIMESTAMPTZ         NOT NULL,
    cancelled_at         TIMESTAMPTZ,
    cancel_reason        VARCHAR,
    created_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ws_sub_status_period ON workspace_subscriptions(status, current_period_end);

-- ── invoices ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoices (
    id              UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID           NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    subscription_id UUID           NOT NULL REFERENCES workspace_subscriptions(id) ON DELETE RESTRICT,
    invoice_number  VARCHAR(50)    NOT NULL UNIQUE,
    status          invoice_status NOT NULL DEFAULT 'DRAFT',
    amount          DECIMAL(12,2)  NOT NULL,
    currency        VARCHAR(3)     NOT NULL DEFAULT 'VND',
    period_start    TIMESTAMPTZ    NOT NULL,
    period_end      TIMESTAMPTZ    NOT NULL,
    issued_at       TIMESTAMPTZ,
    due_at          TIMESTAMPTZ,
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_invoices_workspace_id    ON invoices(workspace_id);
CREATE INDEX IF NOT EXISTS idx_invoices_subscription_id ON invoices(subscription_id);
CREATE INDEX IF NOT EXISTS idx_invoices_number          ON invoices(invoice_number);

-- ── payments ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
    id              UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID           NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    invoice_id      UUID           NOT NULL REFERENCES invoices(id)   ON DELETE RESTRICT,
    amount          DECIMAL(12,2)  NOT NULL,
    currency        VARCHAR(3)     NOT NULL DEFAULT 'VND',
    status          payment_status NOT NULL DEFAULT 'PENDING',
    payment_method  VARCHAR(50),   -- bank_transfer | momo | vnpay | stripe
    transaction_id  VARCHAR(255)   UNIQUE,
    paid_at         TIMESTAMPTZ,
    failed_reason   VARCHAR,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_workspace_id ON payments(workspace_id);
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id   ON payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payments_tx_id        ON payments(transaction_id);

-- ── audit_logs ────────────────────────────────────────────────
-- Append-only. workspace_id nullable (ADMIN global actions).
-- user_id is soft ref (UUID stored as text) — user may be deleted but log must persist.
CREATE TABLE IF NOT EXISTS audit_logs (
    id            BIGSERIAL    PRIMARY KEY,
    workspace_id  UUID,                              -- nullable for ADMIN-level actions
    user_id       UUID         NOT NULL,             -- soft ref: user may be deleted
    action        audit_action NOT NULL,
    resource_type VARCHAR(50)  NOT NULL,
    resource_id   VARCHAR(255),
    old_value     JSONB,
    new_value     JSONB,
    ip_address    VARCHAR(45),
    user_agent    VARCHAR,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_user_time     ON audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_workspace_time ON audit_logs(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_resource       ON audit_logs(resource_type, resource_id);

-- ── Seed: subscription_plans ──────────────────────────────────
INSERT INTO subscription_plans (name, display_name, price_monthly, price_yearly, max_members, max_clients, max_posts_month, ai_credits_month, features)
VALUES
    ('FREE',       'Free',       0,        0,        3,  1,   30,   50,  '["basic_scheduling","1_social_account"]'),
    ('BASIC',      'Basic',      490000,   4900000,  10, 5,   100,  200, '["scheduling","approval_workflow","3_social_accounts"]'),
    ('PRO',        'Pro',        990000,   9900000,  30, 20,  500,  1000,'["scheduling","approval_workflow","ai_content","10_social_accounts","analytics"]'),
    ('ENTERPRISE', 'Enterprise', 2990000,  29900000, -1, -1,  -1,   5000,'["all_features","unlimited_members","unlimited_clients","dedicated_support"]')
ON CONFLICT (name) DO NOTHING;
