-- ============================================================
-- BrandHub PostgreSQL Init Script
-- Task: DA-E09-02
-- Purpose: create PostgreSQL schema and seed subscription plans.
--
-- Idempotent: safe to run again on an empty or existing development database.
-- Scope: PostgreSQL-owned entities only. MongoDB collections are intentionally
-- not mirrored here.
--
-- PostgreSQL tables:
--   Identity:  users, user_oauth_providers, user_refresh_tokens,
--              user_system_roles, password_reset_tokens
--   Workspace: workspaces, workspace_members, workspace_invitations,
--              workspace_member_permissions, clients
--   Billing:   subscription_plans, workspace_subscriptions, invoices,
--              payments, audit_logs
-- ============================================================

BEGIN;

-- Required for gen_random_uuid().
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Enums
-- ============================================================

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE oauth_provider AS ENUM ('GOOGLE', 'GITHUB', 'LINKEDIN', 'MICROSOFT');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE member_role AS ENUM ('OWNER', 'MANAGER', 'CREATOR', 'VIEWER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE workspace_plan AS ENUM ('FREE', 'BASIC', 'PRO', 'ENTERPRISE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELLED', 'TRIALING');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE invoice_status AS ENUM ('DRAFT', 'ISSUED', 'PAID', 'OVERDUE', 'VOID');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE audit_action AS ENUM ('LOGIN', 'LOGOUT', 'TOKEN_REFRESH', 'PASSWORD_RESET', 'CREATE', 'UPDATE', 'DELETE', 'ROLE_CHANGE', 'PERMISSION_CHANGE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- Shared trigger helpers
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prevent_audit_log_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'audit_logs is append-only and cannot be updated or deleted';
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Identity group
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email          VARCHAR(255) NOT NULL UNIQUE,
    phone          VARCHAR(20)  UNIQUE,
    password_hash  VARCHAR,
    full_name      VARCHAR(255) NOT NULL,
    avatar_url     VARCHAR,
    status         user_status  NOT NULL DEFAULT 'ACTIVE',
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
    preferences    JSONB        NOT NULL DEFAULT '{}',
    last_login_at  TIMESTAMPTZ,
    last_password_change TIMESTAMPTZ,
    otp_code       VARCHAR(6),
    otp_expiry     TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS user_oauth_providers (
    id          UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider    oauth_provider NOT NULL,
    provider_id VARCHAR(255)   NOT NULL,
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    UNIQUE (provider, provider_id)
);

CREATE INDEX IF NOT EXISTS idx_oauth_user_id ON user_oauth_providers(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_oauth_provider_unique
    ON user_oauth_providers(provider, provider_id);

CREATE TABLE IF NOT EXISTS user_refresh_tokens (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    jti         VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    ip_address  VARCHAR(45),
    user_agent  VARCHAR,
    device_info JSONB        NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rt_user_id ON user_refresh_tokens(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_rt_jti ON user_refresh_tokens(jti);
CREATE INDEX IF NOT EXISTS idx_rt_expires_at ON user_refresh_tokens(expires_at);

CREATE TABLE IF NOT EXISTS user_system_roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    system_role VARCHAR(50) NOT NULL DEFAULT 'USER',
    granted_by  UUID        REFERENCES users(id) ON DELETE SET NULL,
    granted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_user_system_roles_role CHECK (system_role IN ('ADMIN', 'USER'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_system_roles_user_id ON user_system_roles(user_id);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    used_at    TIMESTAMPTZ,
    ip_address VARCHAR(45),
    expires_at TIMESTAMPTZ  NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pwd_reset_user_id ON password_reset_tokens(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_pwd_reset_token ON password_reset_tokens(token_hash);

-- ============================================================
-- Workspace group
-- ============================================================

CREATE TABLE IF NOT EXISTS workspaces (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    slug       VARCHAR(100) NOT NULL UNIQUE,
    owner_id   UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    logo_url   VARCHAR,
    settings   JSONB        NOT NULL DEFAULT '{}',
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_workspaces_slug ON workspaces(slug);
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON workspaces(owner_id);

DROP TRIGGER IF EXISTS trg_workspaces_updated_at ON workspaces;
CREATE TRIGGER trg_workspaces_updated_at
BEFORE UPDATE ON workspaces
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS workspace_members (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    user_id      UUID        NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    role         member_role NOT NULL,
    invited_by   UUID        REFERENCES users(id) ON DELETE SET NULL,
    joined_at    TIMESTAMPTZ,
    is_active    BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_wm_workspace_id ON workspace_members(workspace_id);
CREATE INDEX IF NOT EXISTS idx_wm_user_id ON workspace_members(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_wm_unique ON workspace_members(workspace_id, user_id);

DROP TRIGGER IF EXISTS trg_workspace_members_updated_at ON workspace_members;
CREATE TRIGGER trg_workspace_members_updated_at
BEFORE UPDATE ON workspace_members
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS workspace_invitations (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id  UUID         NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    invited_email VARCHAR(255) NOT NULL,
    role          member_role  NOT NULL,
    invited_by    UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    token         VARCHAR(255) NOT NULL UNIQUE,
    status        VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    expires_at    TIMESTAMPTZ  NOT NULL,
    accepted_at   TIMESTAMPTZ,
    accepted_by   UUID         REFERENCES users(id) ON DELETE SET NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, invited_email),
    CONSTRAINT chk_workspace_invitations_status
        CHECK (status IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'REVOKED'))
);

CREATE INDEX IF NOT EXISTS idx_workspace_inv_workspace_id ON workspace_invitations(workspace_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_workspace_inv_token ON workspace_invitations(token);
CREATE INDEX IF NOT EXISTS idx_workspace_inv_email ON workspace_invitations(invited_email);
CREATE UNIQUE INDEX IF NOT EXISTS idx_workspace_inv_unique ON workspace_invitations(workspace_id, invited_email);

CREATE TABLE IF NOT EXISTS workspace_member_permissions (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_member_id UUID         NOT NULL REFERENCES workspace_members(id) ON DELETE CASCADE,
    permission          VARCHAR(100) NOT NULL,
    granted             BOOLEAN      NOT NULL,
    granted_by          UUID         REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_member_id, permission)
);

CREATE INDEX IF NOT EXISTS idx_perms_member_id ON workspace_member_permissions(workspace_member_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_perms_unique
    ON workspace_member_permissions(workspace_member_id, permission);

CREATE TABLE IF NOT EXISTS clients (
    id                    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id          UUID         NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    name                  VARCHAR(255) NOT NULL,
    brand_name            VARCHAR(255),
    industry              VARCHAR(100),
    logo_url              VARCHAR,
    contact_email         VARCHAR(255),
    contact_phone         VARCHAR(50),
    assigned_manager_id   UUID         REFERENCES users(id) ON DELETE SET NULL,
    portal_access_enabled BOOLEAN      NOT NULL DEFAULT FALSE,
    portal_user_id        UUID         REFERENCES users(id) ON DELETE SET NULL,
    service_package       JSONB        NOT NULL DEFAULT '{}',
    metadata              JSONB        NOT NULL DEFAULT '{}',
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_clients_workspace_id ON clients(workspace_id);
CREATE INDEX IF NOT EXISTS idx_clients_manager_id ON clients(assigned_manager_id);

DROP TRIGGER IF EXISTS trg_clients_updated_at ON clients;
CREATE TRIGGER trg_clients_updated_at
BEFORE UPDATE ON clients
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Billing group
-- ============================================================

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

CREATE UNIQUE INDEX IF NOT EXISTS idx_plans_name ON subscription_plans(name);

DROP TRIGGER IF EXISTS trg_subscription_plans_updated_at ON subscription_plans;
CREATE TRIGGER trg_subscription_plans_updated_at
BEFORE UPDATE ON subscription_plans
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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

CREATE UNIQUE INDEX IF NOT EXISTS idx_ws_sub_workspace_id ON workspace_subscriptions(workspace_id);
CREATE INDEX IF NOT EXISTS idx_ws_sub_status_period
    ON workspace_subscriptions(status, current_period_end);

DROP TRIGGER IF EXISTS trg_workspace_subscriptions_updated_at ON workspace_subscriptions;
CREATE TRIGGER trg_workspace_subscriptions_updated_at
BEFORE UPDATE ON workspace_subscriptions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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

CREATE INDEX IF NOT EXISTS idx_invoices_workspace_id ON invoices(workspace_id);
CREATE INDEX IF NOT EXISTS idx_invoices_subscription_id ON invoices(subscription_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_number ON invoices(invoice_number);

DROP TRIGGER IF EXISTS trg_invoices_updated_at ON invoices;
CREATE TRIGGER trg_invoices_updated_at
BEFORE UPDATE ON invoices
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS payments (
    id             UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id   UUID           NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    invoice_id     UUID           NOT NULL REFERENCES invoices(id) ON DELETE RESTRICT,
    amount         DECIMAL(12,2)  NOT NULL,
    currency       VARCHAR(3)     NOT NULL DEFAULT 'VND',
    status         payment_status NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255) UNIQUE,
    paid_at        TIMESTAMPTZ,
    failed_reason  VARCHAR,
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pay_workspace_id ON payments(workspace_id);
CREATE INDEX IF NOT EXISTS idx_pay_invoice_id ON payments(invoice_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_pay_tx_id ON payments(transaction_id);

DROP TRIGGER IF EXISTS trg_payments_updated_at ON payments;
CREATE TRIGGER trg_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS audit_logs (
    id            BIGSERIAL    PRIMARY KEY,
    workspace_id  UUID         REFERENCES workspaces(id) ON DELETE SET NULL,
    user_id       UUID         NOT NULL,
    action        audit_action NOT NULL,
    resource_type VARCHAR(50)  NOT NULL,
    resource_id   VARCHAR(255),
    old_value     JSONB,
    new_value     JSONB,
    ip_address    VARCHAR(45),
    user_agent    VARCHAR,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_user_time ON audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_workspace_time ON audit_logs(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_resource ON audit_logs(resource_type, resource_id);

DROP TRIGGER IF EXISTS trg_audit_logs_no_update ON audit_logs;
CREATE TRIGGER trg_audit_logs_no_update
BEFORE UPDATE ON audit_logs
FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_mutation();

DROP TRIGGER IF EXISTS trg_audit_logs_no_delete ON audit_logs;
CREATE TRIGGER trg_audit_logs_no_delete
BEFORE DELETE ON audit_logs
FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_mutation();

-- ============================================================
-- Seed subscription plans
-- ============================================================

INSERT INTO subscription_plans (
    name,
    display_name,
    price_monthly,
    price_yearly,
    max_members,
    max_clients,
    max_posts_month,
    ai_credits_month,
    features,
    is_active
)
VALUES
    (
        'FREE',
        'Free',
        0,
        0,
        3,
        1,
        30,
        50,
        '["basic_scheduling", "1_social_account"]'::jsonb,
        TRUE
    ),
    (
        'BASIC',
        'Basic',
        490000,
        4900000,
        10,
        5,
        100,
        200,
        '["scheduling", "approval_workflow", "3_social_accounts"]'::jsonb,
        TRUE
    ),
    (
        'PRO',
        'Pro',
        990000,
        9900000,
        30,
        20,
        500,
        1000,
        '["scheduling", "approval_workflow", "ai_content", "10_social_accounts", "analytics"]'::jsonb,
        TRUE
    ),
    (
        'ENTERPRISE',
        'Enterprise',
        2990000,
        29900000,
        -1,
        -1,
        -1,
        5000,
        '["all_features", "unlimited_members", "unlimited_clients", "dedicated_support"]'::jsonb,
        TRUE
    )
ON CONFLICT (name) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    price_monthly = EXCLUDED.price_monthly,
    price_yearly = EXCLUDED.price_yearly,
    max_members = EXCLUDED.max_members,
    max_clients = EXCLUDED.max_clients,
    max_posts_month = EXCLUDED.max_posts_month,
    ai_credits_month = EXCLUDED.ai_credits_month,
    features = EXCLUDED.features,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

COMMIT;
