-- ============================================================
-- BrandHub PostgreSQL Init Script — V2
-- Purpose: Agency -> Workspace -> Media Package -> Media Campaign -> Task model.
-- Replaces init-postgres.sql (V1). See docs/database/migration/migration-plan-v1-to-v2.md.
--
-- Idempotent: safe to run again on an empty or existing V2 database.
-- Scope: PostgreSQL-owned entities only. MongoDB collections are not mirrored here.
--
-- Decisions confirmed 2026-09-16 (docs/database/migration/migration-plan-v1-to-v2.md §0):
--   - client_profiles / media_packages / tasks+task_approvals: per DBML as-is.
--   - workspace_member_permissions: DROPPED, not recreated (YAGNI — 4 fixed roles suffice).
--   - No data migration from V1 — dev/staging drop & recreate.
--   - workspace_member_role: OWNER removed (Agency-level only), now MANAGER/CREATOR/CLIENT.
--     Agency Owner participating in a workspace holds MANAGER or CREATOR like anyone else.
--   - agency_members: added role column (OWNER/MEMBER) — explicit instead of deriving from agencies.owner_id.
--   - workspace_members: at most 1 active MANAGER per workspace (no co-manage), enforced via partial unique index.
--   - workspaces: added created_by for audit consistency with other tables.
--   - ai_credit_ledgers: split into ai_credit_ledgers (Agency-wide monthly usage, no user)
--     + ai_credit_creator_limits (per-Creator cap set by Owner, config only, not usage tracking).
--
-- PostgreSQL tables (27):
--   Monitoring:   monitoring_servers, monitoring_collectors,
--                 monitoring_health_targets, monitoring_health_results
--   Identity:     users, user_oauth_providers, user_refresh_tokens, user_system_roles
--   Organization: agencies, agency_members, agency_invitations, workspaces,
--                 workspace_members, workspace_invitations, workspace_templates, client_profiles
--   Commerce:     media_packages, workspace_media_packages, media_campaigns
--   Collaborator: third_party_collaborators, campaign_collaborators
--   Billing:      subscription_plans, user_subscriptions, transactions,
--                 ai_credit_ledgers, ai_credit_creator_limits, audit_logs
-- ============================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Enums
-- ============================================================

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETED', 'DEACTIVATED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE oauth_provider AS ENUM ('GOOGLE', 'FACEBOOK');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE workspace_member_role AS ENUM ('MANAGER', 'CREATOR', 'CLIENT');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE agency_member_role AS ENUM ('OWNER', 'MEMBER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE entity_status AS ENUM ('ACTIVE', 'SOFT_DELETED', 'INACTIVE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE agency_category AS ENUM (
        'MARKETING', 'FNB', 'FASHION', 'BEAUTY', 'TECHNOLOGY', 'REAL_ESTATE',
        'EDUCATION', 'HEALTHCARE', 'RETAIL', 'FINANCE', 'ENTERTAINMENT', 'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE workspace_industry AS ENUM (
        'FNB', 'FASHION', 'BEAUTY', 'TECHNOLOGY', 'REAL_ESTATE', 'EDUCATION',
        'HEALTHCARE', 'SERVICES', 'RETAIL', 'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE company_size AS ENUM (
        'SIZE_1_10', 'SIZE_11_50', 'SIZE_51_200', 'SIZE_201_500', 'SIZE_500_PLUS'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('PENDING', 'ACCEPTED', 'EXPIRED', 'REVOKED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE package_negotiation_status AS ENUM ('DRAFT', 'CLIENT_REQUESTED_CHANGE', 'AGENCY_COUNTERED', 'APPROVED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE package_type AS ENUM ('BY_DURATION', 'BY_BUDGET', 'FULL_DELEGATION');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE campaign_status AS ENUM ('DRAFT', 'APPROVED', 'IN_PROGRESS', 'COMPLETED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE collaborator_type AS ENUM ('NEWSPAPER', 'BANNER', 'TV', 'OTHER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE cooperation_status AS ENUM ('CONTACTED', 'NEGOTIATING', 'CONFIRMED', 'LIVE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_plan_name AS ENUM ('BASIC', 'PRO', 'ENTERPRISE');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELLED', 'TRIALING');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE transaction_status AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE transaction_type AS ENUM ('UPGRADE_PLAN', 'BUY_CREDIT');
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
-- Identity group (unchanged from V1)
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email          VARCHAR(255) NOT NULL UNIQUE,
    phone          VARCHAR(20)  UNIQUE,
    password_hash  VARCHAR,
    full_name      VARCHAR(255) NOT NULL,
    avatar_url     VARCHAR,
    professional_title VARCHAR(255),
    bio            TEXT,
    portfolio_urls JSONB        NOT NULL DEFAULT '[]',
    working_language VARCHAR(50),
    skills         JSONB        NOT NULL DEFAULT '[]',
    location       VARCHAR(255),
    years_of_experience INTEGER,
    linkedin_url   VARCHAR,
    facebook_url   VARCHAR,
    instagram_url  VARCHAR,
    tiktok_url     VARCHAR,
    website        VARCHAR,
    banner_url     VARCHAR,
    status         user_status  NOT NULL DEFAULT 'ACTIVE',
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
    last_banned_at TIMESTAMPTZ,
    preferences    JSONB        NOT NULL DEFAULT '{}',
    last_login_at  TIMESTAMPTZ,
    last_password_change TIMESTAMPTZ,
    otp_code       VARCHAR(6),
    otp_expiry     TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    two_factor_enabled BOOLEAN   NOT NULL DEFAULT FALSE,
    totp_secret      VARCHAR(64),
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

CREATE TABLE IF NOT EXISTS user_refresh_tokens (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    jti         VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ  NOT NULL,
    ip_address  VARCHAR(45),
    user_agent  VARCHAR(255),
    device_info JSONB        NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rt_user_id ON user_refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_rt_expires_at ON user_refresh_tokens(expires_at);

CREATE TABLE IF NOT EXISTS user_system_roles (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    system_role VARCHAR(50) NOT NULL DEFAULT 'USER',
    granted_by  UUID        REFERENCES users(id) ON DELETE SET NULL,
    granted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_user_system_roles_role CHECK (system_role IN ('ADMIN', 'USER'))
);

-- ============================================================
-- Organization group — Agency & Workspace (V2)
-- ============================================================

CREATE TABLE IF NOT EXISTS agencies (
    id             UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    name           VARCHAR(255)     NOT NULL,
    owner_id       UUID             NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    logo_url       VARCHAR,
    description    TEXT,
    category       agency_category,
    company_size   company_size,
    website        VARCHAR(255),
    phone          VARCHAR(30),
    location       VARCHAR(255),
    brand_color    VARCHAR(9),
    logo_icon      VARCHAR(50),
    tagline        VARCHAR(140),
    founded_year   INTEGER,
    facebook_url   VARCHAR(255),
    linkedin_url   VARCHAR(255),
    instagram_url  VARCHAR(255),
    status         entity_status    NOT NULL DEFAULT 'ACTIVE',
    deleted_at     TIMESTAMPTZ,
    created_at     TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agencies_owner_id ON agencies(owner_id);

DROP TRIGGER IF EXISTS trg_agencies_updated_at ON agencies;
CREATE TRIGGER trg_agencies_updated_at
BEFORE UPDATE ON agencies
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS agency_members (
    id         UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id  UUID               NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
    user_id    UUID               NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    role       agency_member_role NOT NULL DEFAULT 'MEMBER',
    joined_at  TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    UNIQUE (agency_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_agency_members_agency_id ON agency_members(agency_id);

CREATE TABLE IF NOT EXISTS agency_invitations (
    id            UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id     UUID                  NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    invited_email VARCHAR(255)          NOT NULL,
    invited_by    UUID                  NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    token         VARCHAR(255)          NOT NULL UNIQUE,
    note          VARCHAR(500),
    workspace_id  UUID,
    role          workspace_member_role,
    status        invitation_status     NOT NULL DEFAULT 'PENDING',
    expires_at    TIMESTAMPTZ           NOT NULL,
    accepted_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ           NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agency_inv_agency_id ON agency_invitations(agency_id);
-- Chỉ chặn trùng khi còn PENDING — cho phép mời lại email đã REVOKED/EXPIRED/ACCEPTED
-- trước đó (khớp check pendingInvitationExists trong AgencyServiceImpl.inviteMember).
CREATE UNIQUE INDEX IF NOT EXISTS idx_agency_inv_unique_pending
    ON agency_invitations(agency_id, invited_email) WHERE status = 'PENDING';

CREATE TABLE IF NOT EXISTS client_profiles (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID         REFERENCES users(id) ON DELETE SET NULL,
    agency_id       UUID         REFERENCES agencies(id) ON DELETE CASCADE,
    display_name    VARCHAR(255) NOT NULL,
    company         VARCHAR(255),
    industry        VARCHAR(100),
    logo_url        VARCHAR(500),
    phone           VARCHAR(50),
    website         VARCHAR(255),
    location        VARCHAR(255),
    description     TEXT,
    social_links    JSONB,
    note            TEXT,
    contact_name    VARCHAR(255),
    contact_email   VARCHAR(255),
    company_size    VARCHAR(50),
    instagram_url   VARCHAR(500),
    tax_code        VARCHAR(50),
    address         VARCHAR(500),
    tagline         VARCHAR(255),
    founded_year    INTEGER,
    budget_range    VARCHAR(50),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_profiles_user_id ON client_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_client_profiles_agency_id ON client_profiles(agency_id);

DROP TRIGGER IF EXISTS trg_client_profiles_updated_at ON client_profiles;
CREATE TRIGGER trg_client_profiles_updated_at
BEFORE UPDATE ON client_profiles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS workspaces (
    id              UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id       UUID              NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
    name            VARCHAR(255)      NOT NULL,
    created_by      UUID              NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    workspace_media_package_id UUID,
    timezone_config VARCHAR(100)      NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    settings        JSONB             NOT NULL DEFAULT '{}',
    industry        workspace_industry,
    company_size    company_size,
    website         VARCHAR(255),
    phone           VARCHAR(30),
    location        VARCHAR(255),
    description     VARCHAR(500),
    brand_color     VARCHAR(9),
    logo_icon       VARCHAR(50),
    logo_url        VARCHAR(255),
    tagline         VARCHAR(140),
    founded_year    INTEGER,
    facebook_url    VARCHAR(255),
    linkedin_url    VARCHAR(255),
    instagram_url   VARCHAR(255),
    status          entity_status     NOT NULL DEFAULT 'ACTIVE',
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workspaces_agency_id ON workspaces(agency_id);

DROP TRIGGER IF EXISTS trg_workspaces_updated_at ON workspaces;
CREATE TRIGGER trg_workspaces_updated_at
BEFORE UPDATE ON workspaces
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- agency_invitations.workspace_id references a table created after it above.
DO $$ BEGIN
    ALTER TABLE agency_invitations
        ADD CONSTRAINT fk_agency_inv_workspace_id
        FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS workspace_members (
    id                 UUID                   PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id       UUID                   NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    user_id            UUID                   REFERENCES users(id) ON DELETE RESTRICT,
    client_profile_id  UUID                   REFERENCES client_profiles(id) ON DELETE RESTRICT,
    role               workspace_member_role  NOT NULL,
    added_by           UUID                   REFERENCES users(id) ON DELETE SET NULL,
    joined_at          TIMESTAMPTZ,
    is_active          BOOLEAN                NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ            NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ            NOT NULL DEFAULT NOW(),
    -- CLIENT luôn cần client_profile_id; user_id đi kèm khi client là user thật đã
    -- accept invitation (tự login), NULL khi manager tự thêm client thủ công (chưa
    -- có tài khoản). Role khác CLIENT luôn cần user_id, không bao giờ có client_profile_id.
    CONSTRAINT chk_workspace_members_identity CHECK (
        (role = 'CLIENT' AND client_profile_id IS NOT NULL)
        OR (role != 'CLIENT' AND user_id IS NOT NULL AND client_profile_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_wm_workspace_id ON workspace_members(workspace_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_wm_unique_user ON workspace_members(workspace_id, user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_wm_unique_client ON workspace_members(workspace_id, client_profile_id) WHERE client_profile_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_wm_one_manager ON workspace_members(workspace_id) WHERE role = 'MANAGER' AND is_active = TRUE;

DROP TRIGGER IF EXISTS trg_workspace_members_updated_at ON workspace_members;
CREATE TRIGGER trg_workspace_members_updated_at
BEFORE UPDATE ON workspace_members
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- CHỈ dành cho CLIENT (actor ngoài Agency). MANAGER/CREATOR gán thẳng vào workspace_members
-- (FR 3.4.19 Add Workspace Member), không qua bảng này — không cần accept/token/expires_at.
CREATE TABLE IF NOT EXISTS workspace_invitations (
    id            UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id  UUID                  NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    invited_email VARCHAR(255)          NOT NULL,
    invited_by    UUID                  NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    token         VARCHAR(255)          NOT NULL UNIQUE,
    role          workspace_member_role,
    status        invitation_status     NOT NULL DEFAULT 'PENDING',
    expires_at    TIMESTAMPTZ           NOT NULL,
    accepted_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ           NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, invited_email)
);

CREATE INDEX IF NOT EXISTS idx_workspace_inv_workspace_id ON workspace_invitations(workspace_id);

CREATE TABLE IF NOT EXISTS workspace_templates (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id            UUID         NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    name                 VARCHAR(255) NOT NULL,
    source_workspace_id  UUID         REFERENCES workspaces(id) ON DELETE SET NULL,
    config_snapshot      JSONB        NOT NULL,
    created_by           UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workspace_templates_agency_id ON workspace_templates(agency_id);

-- ============================================================
-- Commerce group — Media Package & Campaign (V2, new)
-- ============================================================

CREATE TABLE IF NOT EXISTS media_packages (
    id                 UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name               VARCHAR(255) NOT NULL,
    is_template        BOOLEAN      NOT NULL DEFAULT FALSE,
    package_type       package_type NOT NULL,
    duration_weeks     INT,
    budget_amount      DECIMAL(14,2),
    scope_description  TEXT,
    created_by         UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_packages_is_template ON media_packages(is_template);

DROP TRIGGER IF EXISTS trg_media_packages_updated_at ON media_packages;
CREATE TRIGGER trg_media_packages_updated_at
BEFORE UPDATE ON media_packages
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS workspace_media_packages (
    id                     UUID                       PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id           UUID                       NOT NULL UNIQUE REFERENCES workspaces(id) ON DELETE RESTRICT,
    package_id             UUID                       NOT NULL REFERENCES media_packages(id) ON DELETE RESTRICT,
    negotiation_status     package_negotiation_status NOT NULL DEFAULT 'DRAFT',
    final_terms            JSONB                      NOT NULL DEFAULT '{}',
    approved_by_agency_at  TIMESTAMPTZ,
    approved_by_client_at  TIMESTAMPTZ,
    created_at             TIMESTAMPTZ                NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ                NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS trg_workspace_media_packages_updated_at ON workspace_media_packages;
CREATE TRIGGER trg_workspace_media_packages_updated_at
BEFORE UPDATE ON workspace_media_packages
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE workspaces
    DROP CONSTRAINT IF EXISTS fk_workspaces_media_package;
ALTER TABLE workspaces
    ADD CONSTRAINT fk_workspaces_media_package
    FOREIGN KEY (workspace_media_package_id) REFERENCES workspace_media_packages(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS media_campaigns (
    id                          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID             NOT NULL REFERENCES workspace_media_packages(id) ON DELETE RESTRICT,
    name                        VARCHAR(255)    NOT NULL,
    strategy_detail             TEXT,
    brand_guideline             TEXT,
    timeline                    JSONB           NOT NULL DEFAULT '{}',
    status                      campaign_status NOT NULL DEFAULT 'DRAFT',
    approved_by_agency_at       TIMESTAMPTZ,
    approved_by_client_at       TIMESTAMPTZ,
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_campaigns_wmp_id ON media_campaigns(workspace_media_package_id);

DROP TRIGGER IF EXISTS trg_media_campaigns_updated_at ON media_campaigns;
CREATE TRIGGER trg_media_campaigns_updated_at
BEFORE UPDATE ON media_campaigns
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Collaborator group (V2, new)
-- ============================================================

CREATE TABLE IF NOT EXISTS third_party_collaborators (
    id           UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id    UUID              NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    partner_name VARCHAR(255)      NOT NULL,
    partner_type collaborator_type NOT NULL,
    contact_info JSONB             NOT NULL DEFAULT '{}',
    notes        TEXT,
    created_by   UUID              NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at   TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_collaborators_agency_id ON third_party_collaborators(agency_id);

DROP TRIGGER IF EXISTS trg_collaborators_updated_at ON third_party_collaborators;
CREATE TRIGGER trg_collaborators_updated_at
BEFORE UPDATE ON third_party_collaborators
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS campaign_collaborators (
    id                  UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    media_campaign_id   UUID               NOT NULL REFERENCES media_campaigns(id) ON DELETE CASCADE,
    collaborator_id     UUID               NOT NULL REFERENCES third_party_collaborators(id) ON DELETE RESTRICT,
    cooperation_status  cooperation_status NOT NULL DEFAULT 'CONTACTED',
    updated_by          UUID               REFERENCES users(id) ON DELETE SET NULL,
    updated_at          TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    UNIQUE (media_campaign_id, collaborator_id)
);

-- ============================================================
-- Billing group
-- ============================================================

CREATE TABLE IF NOT EXISTS subscription_plans (
    id               UUID                   PRIMARY KEY DEFAULT gen_random_uuid(),
    name             subscription_plan_name NOT NULL UNIQUE,
    display_name     VARCHAR(100)           NOT NULL,
    price_monthly    DECIMAL(12,2)          NOT NULL,
    max_workspaces   INT                    NOT NULL,
    ai_credits_month INT                    NOT NULL,
    features         JSONB                  NOT NULL DEFAULT '[]',
    is_active        BOOLEAN                NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ            NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_subscriptions (
    id                   UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id              UUID                NOT NULL UNIQUE REFERENCES users(id) ON DELETE RESTRICT,
    plan_id              UUID                NOT NULL REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    status               subscription_status NOT NULL DEFAULT 'TRIALING',
    current_period_start TIMESTAMPTZ         NOT NULL,
    current_period_end   TIMESTAMPTZ         NOT NULL,
    cancelled_at         TIMESTAMPTZ,
    created_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_sub_status_period ON user_subscriptions(status, current_period_end);

DROP TRIGGER IF EXISTS trg_user_subscriptions_updated_at ON user_subscriptions;
CREATE TRIGGER trg_user_subscriptions_updated_at
BEFORE UPDATE ON user_subscriptions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS transactions (
    id             UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID               NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    type           transaction_type   NOT NULL,
    amount         DECIMAL(12,2)      NOT NULL,
    currency       VARCHAR(3)         NOT NULL DEFAULT 'VND',
    status         transaction_status NOT NULL DEFAULT 'PENDING',
    ref_id         VARCHAR(255),
    payos_tx_id    VARCHAR(255) UNIQUE,
    paid_at        TIMESTAMPTZ,
    failed_reason  VARCHAR,
    created_at     TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ        NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);

DROP TRIGGER IF EXISTS trg_transactions_updated_at ON transactions;
CREATE TRIGGER trg_transactions_updated_at
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS ai_credit_ledgers (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id      UUID         NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    month          VARCHAR(7)   NOT NULL,
    used_amount    INT          NOT NULL DEFAULT 0,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (agency_id, month)
);

DROP TRIGGER IF EXISTS trg_ai_credit_ledgers_updated_at ON ai_credit_ledgers;
CREATE TRIGGER trg_ai_credit_ledgers_updated_at
BEFORE UPDATE ON ai_credit_ledgers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS ai_credit_creator_limits (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id      UUID         NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    creator_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    monthly_limit  INT          NOT NULL,
    set_by         UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (agency_id, creator_id)
);

DROP TRIGGER IF EXISTS trg_ai_credit_creator_limits_updated_at ON ai_credit_creator_limits;
CREATE TRIGGER trg_ai_credit_creator_limits_updated_at
BEFORE UPDATE ON ai_credit_creator_limits
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS audit_logs (
    id            BIGSERIAL    PRIMARY KEY,
    agency_id     UUID         REFERENCES agencies(id) ON DELETE SET NULL,
    user_id       UUID         NOT NULL,
    action        audit_action NOT NULL,
    resource_type VARCHAR(50)  NOT NULL,
    resource_id   VARCHAR(255),
    ip_address    VARCHAR(45),
    user_agent    VARCHAR(512),
    old_value     JSONB,
    new_value     JSONB,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_user_time ON audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_agency_time ON audit_logs(agency_id, created_at DESC);
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

INSERT INTO subscription_plans (name, display_name, price_monthly, max_workspaces, ai_credits_month, features, is_active)
VALUES
    ('BASIC', 'Basic', 490000, 3, 200, '["scheduling", "approval_workflow"]'::jsonb, TRUE),
    ('PRO', 'Pro', 990000, 10, 1000, '["scheduling", "approval_workflow", "ai_content", "analytics"]'::jsonb, TRUE),
    ('ENTERPRISE', 'Enterprise', 2990000, -1, 5000, '["all_features", "unlimited_workspaces", "dedicated_support"]'::jsonb, TRUE)
ON CONFLICT (name) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    price_monthly = EXCLUDED.price_monthly,
    max_workspaces = EXCLUDED.max_workspaces,
    ai_credits_month = EXCLUDED.ai_credits_month,
    features = EXCLUDED.features,
    is_active = EXCLUDED.is_active;

-- ============================================================
-- System Health Monitoring (FR 3.10.3)
-- Mirrors scripts/migrations/2026-09-24-monitoring.sql for fresh databases.
-- ============================================================

CREATE TABLE IF NOT EXISTS monitoring_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    ip_address INET NOT NULL,
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    deployed_services TEXT[] NOT NULL DEFAULT '{}',
    agent_token_hash VARCHAR(255) NOT NULL CHECK (btrim(agent_token_hash) <> ''),
    cpu_percent NUMERIC(5,2) CHECK (cpu_percent BETWEEN 0 AND 100),
    ram_percent NUMERIC(5,2) CHECK (ram_percent BETWEEN 0 AND 100),
    disk_percent NUMERIC(5,2) CHECK (disk_percent BETWEEN 0 AND 100),
    uptime_seconds BIGINT CHECK (uptime_seconds >= 0),
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_monitoring_server_ip CHECK (
        masklen(ip_address) = CASE family(ip_address) WHEN 4 THEN 32 ELSE 128 END
    ),
    CONSTRAINT chk_monitoring_server_no_sample CHECK (
        last_seen_at IS NOT NULL OR
        (cpu_percent IS NULL AND ram_percent IS NULL AND disk_percent IS NULL AND uptime_seconds IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_monitoring_servers_environment ON monitoring_servers(environment, name, id);

COMMENT ON TABLE monitoring_servers IS 'Operator-managed physical hosts; one latest sample per host, no history. API serverId maps to id.';
COMMENT ON COLUMN monitoring_servers.id IS 'Stable across container redeploys; replacement host gets a new UUID. IP is not identity.';
COMMENT ON COLUMN monitoring_servers.agent_token_hash IS 'Hash only; never expose via API/logs. Provision a separate random agent credential.';
COMMENT ON COLUMN monitoring_servers.last_seen_at IS 'Backend receipt time of valid heartbeat; update atomically with all metrics. NULL means NO_DATA.';
COMMENT ON COLUMN monitoring_servers.updated_at IS 'Application-maintained metadata update time; heartbeat must not overwrite operator metadata.';


CREATE TABLE IF NOT EXISTS monitoring_collectors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    server_id UUID REFERENCES monitoring_servers(id) ON DELETE RESTRICT,
    token_hash VARCHAR(255) NOT NULL CHECK (btrim(token_hash) <> ''),
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_monitoring_collectors_server ON monitoring_collectors(server_id);

CREATE TABLE IF NOT EXISTS monitoring_health_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    kind VARCHAR(20) NOT NULL CHECK (kind IN ('SERVICE', 'CONTAINER', 'DATABASE', 'ENDPOINT')),
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    server_id UUID REFERENCES monitoring_servers(id) ON DELETE RESTRICT,
    service_name VARCHAR(100),
    instance_id VARCHAR(255),
    collector_id UUID NOT NULL REFERENCES monitoring_collectors(id) ON DELETE RESTRICT,
    check_scope VARCHAR(100) NOT NULL CHECK (btrim(check_scope) <> ''),
    probe_type VARCHAR(30) NOT NULL CHECK (probe_type IN ('HTTP', 'DOCKER', 'POSTGRESQL', 'REDIS', 'MONGODB', 'NEO4J')),
    probe_config JSONB NOT NULL DEFAULT '{}' CHECK (jsonb_typeof(probe_config) = 'object'),
    assertion JSONB NOT NULL DEFAULT '{}' CHECK (jsonb_typeof(assertion) = 'object'),
    credential_ref VARCHAR(255) CHECK (credential_ref IS NULL OR btrim(credential_ref) <> ''),
    interval_seconds INTEGER NOT NULL DEFAULT 30 CHECK (interval_seconds > 0),
    timeout_seconds INTEGER NOT NULL DEFAULT 5 CHECK (timeout_seconds > 0),
    stale_after_seconds INTEGER NOT NULL DEFAULT 90 CHECK (stale_after_seconds > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_monitoring_target_timing CHECK (
        timeout_seconds < interval_seconds AND interval_seconds < stale_after_seconds
    ),
    CONSTRAINT chk_monitoring_target_probe CHECK (
        (kind IN ('SERVICE', 'ENDPOINT') AND probe_type = 'HTTP') OR
        (kind = 'CONTAINER' AND probe_type = 'DOCKER' AND server_id IS NOT NULL) OR
        (kind = 'DATABASE' AND probe_type IN ('HTTP', 'POSTGRESQL', 'REDIS', 'MONGODB', 'NEO4J'))
    ),
    -- Supports provenance FK on latest result; one active collector per target.
    CONSTRAINT uq_monitoring_target_collector UNIQUE (id, collector_id)
);
CREATE INDEX IF NOT EXISTS idx_monitoring_targets_environment_kind ON monitoring_health_targets(environment, kind);
CREATE INDEX IF NOT EXISTS idx_monitoring_targets_server ON monitoring_health_targets(server_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_targets_collector ON monitoring_health_targets(collector_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_targets_service ON monitoring_health_targets(environment, service_name, instance_id);

CREATE TABLE IF NOT EXISTS monitoring_health_results (
    target_id UUID PRIMARY KEY,
    collector_id UUID NOT NULL,
    check_id UUID NOT NULL,
    outcome VARCHAR(5) NOT NULL CHECK (outcome IN ('PASS', 'FAIL', 'ERROR')),
    checked_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    latency_ms NUMERIC(14,3) CHECK (latency_ms >= 0 AND latency_ms < 'Infinity'::numeric),
    reason_code VARCHAR(80),
    http_status SMALLINT CHECK (http_status BETWEEN 100 AND 599),
    runtime_state VARCHAR(30),
    runtime_health VARCHAR(30),
    CONSTRAINT fk_monitoring_result_owner FOREIGN KEY (target_id, collector_id)
        REFERENCES monitoring_health_targets(id, collector_id) ON DELETE RESTRICT,
    CONSTRAINT chk_monitoring_result_reason CHECK (
        (outcome = 'PASS' AND reason_code IS NULL) OR
        (outcome IN ('FAIL', 'ERROR') AND reason_code IS NOT NULL AND btrim(reason_code) <> '')
    ),
    CONSTRAINT chk_monitoring_result_clock CHECK (checked_at <= received_at + INTERVAL '10 seconds')
);

COMMENT ON TABLE monitoring_collectors IS 'Operator-provisioned sources; heartbeat independent of probes. API collectorId maps to id.';
COMMENT ON TABLE monitoring_health_targets IS 'Persistent allowlist, including targets with no result. Never auto-create from submitted samples.';
COMMENT ON COLUMN monitoring_health_targets.server_id IS 'NULL for managed/external targets; must not fabricate host metrics.';
COMMENT ON COLUMN monitoring_health_targets.check_scope IS 'READINESS/LIVENESS for services; documented scope for other probes. Validate contract in application.';
COMMENT ON COLUMN monitoring_health_targets.probe_config IS 'Operator-only address/selector configuration. No plaintext secrets or raw response; omit from public DTOs.';
COMMENT ON COLUMN monitoring_health_targets.credential_ref IS 'Reference resolved by worker secret provider; never a password, bearer token, or secret-bearing URI.';
COMMENT ON COLUMN monitoring_health_targets.stale_after_seconds IS 'Also used by ingestion as maximum past sample age; compare against backend time.';
COMMENT ON TABLE monitoring_health_results IS 'Exactly zero or one latest result per target. No history or persisted freshness status.';
COMMENT ON COLUMN monitoring_health_results.collector_id IS 'Result provenance; FK prevents retaining old result under a new assignment. Clear result before reassignment in same transaction.';
COMMENT ON COLUMN monitoring_health_results.check_id IS 'Idempotency key scoped to target. Same current checkId is a no-op; do not update received_at.';
COMMENT ON COLUMN monitoring_health_results.received_at IS 'Backend-assigned; never trust client timestamp. Application enforces ordering and past-age window atomically.';

CREATE TABLE monitoring_enrollments (
    token_hash CHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_monitoring_enrollments_expiry ON monitoring_enrollments(expires_at);

COMMIT;
