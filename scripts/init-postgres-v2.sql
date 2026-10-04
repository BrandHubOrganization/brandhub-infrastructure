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
-- PostgreSQL tables (23):
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
    working_language VARCHAR(10),
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

COMMIT;

-- =====================================================================
-- Admin Management (FR 3.10.x) — folded in from docs/database/migrations after
-- verification (test DB twice, dev DB twice). Keep in sync with those files.
-- =====================================================================

-- ---- 2026-10-01-admin-account-strikes.sql ----
-- Run with psql autocommit before deploying the new Business Service.
-- Additive: never reinterpret legacy SUSPENDED or self-DEACTIVATED accounts.
ALTER TYPE user_status ADD VALUE IF NOT EXISTS 'FLAGGED';
ALTER TYPE user_status ADD VALUE IF NOT EXISTS 'PENDING_VERIFICATION';

BEGIN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS clean_period_ends_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reactivate_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS tokens_revoked_before TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS row_version BIGINT NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS session_version BIGINT NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_users_clean_period ON users(clean_period_ends_at)
    WHERE clean_period_ends_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_reactivate ON users(reactivate_at) WHERE reactivate_at IS NOT NULL;

CREATE TABLE IF NOT EXISTS user_strikes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    level VARCHAR(10) NOT NULL CHECK (level IN ('YELLOW','ORANGE','RED')),
    category VARCHAR(100) NOT NULL,
    reason VARCHAR(2000) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    converted_to_id UUID REFERENCES user_strikes(id) DEFERRABLE INITIALLY DEFERRED,
    removed_by UUID REFERENCES users(id),
    removed_at TIMESTAMPTZ,
    removal_reason VARCHAR(2000),
    CHECK (expires_at > created_at),
    CHECK ((removed_at IS NULL) = (removed_by IS NULL)),
    CHECK (converted_to_id IS NULL OR level = 'YELLOW')
);
CREATE INDEX IF NOT EXISTS idx_user_strikes_history ON user_strikes(user_id,created_at DESC,id DESC);
CREATE INDEX IF NOT EXISTS idx_user_strikes_live ON user_strikes(user_id,expires_at) WHERE removed_at IS NULL;

CREATE TABLE IF NOT EXISTS sanction_reviews (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL CHECK (status IN ('PENDING','CONFIRMED','CLOSED')),
    created_at TIMESTAMPTZ NOT NULL,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id),
    reason VARCHAR(2000)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sanction_one_pending ON sanction_reviews(user_id) WHERE status='PENDING';
CREATE TABLE IF NOT EXISTS admin_account_operations (
    user_id UUID NOT NULL REFERENCES users(id),
    operation_id UUID NOT NULL,
    payload_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id,operation_id)
);
CREATE TABLE IF NOT EXISTS admin_email_outbox (
    id UUID PRIMARY KEY,
    event_key VARCHAR(150) NOT NULL UNIQUE,
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMPTZ,
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attempts INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_admin_email_due ON admin_email_outbox(next_attempt_at) WHERE sent_at IS NULL;
COMMIT;

-- Rollback deployment: restore previous application; leave added tables/columns intact.
-- Do not drop strike/audit data or remove enum values. Export history before any future destructive migration.

-- ---- 2026-10-04-admin-notifications-reports.sql ----
-- FR 3.10.1 (email broadcast) + FR 3.10.12 (PDF export) + BR-16 audit actions.
-- Run with psql autocommit before deploying the new Business Service:
--   docker exec -i brandhub-postgres psql -U postgres -d brandhub -v ON_ERROR_STOP=1 < 2026-10-04-admin-notifications-reports.sql
-- Additive and idempotent: safe to run twice. Depends on 2026-10-01-admin-account-strikes.sql (admin_email_outbox).

-- Enum values must be committed before any statement uses them.
ALTER TYPE audit_action ADD VALUE IF NOT EXISTS 'VIEW';
ALTER TYPE audit_action ADD VALUE IF NOT EXISTS 'EXPORT';

BEGIN;

CREATE TABLE IF NOT EXISTS admin_notifications (
    id UUID PRIMARY KEY,
    title VARCHAR(200) NOT NULL CHECK (char_length(btrim(title)) BETWEEN 5 AND 200),
    content VARCHAR(5000) NOT NULL CHECK (char_length(btrim(content)) BETWEEN 10 AND 5000),
    type VARCHAR(20) NOT NULL CHECK (type IN ('SYSTEM','MAINTENANCE','UPDATE','PROMOTION')),
    target_type VARCHAR(10) NOT NULL CHECK (target_type IN ('ALL','BY_PLAN','BY_ROLE')),
    target_values TEXT[] NOT NULL DEFAULT '{}',
    action_url VARCHAR(500),
    status VARCHAR(12) NOT NULL CHECK (status IN ('DRAFT','SCHEDULED','SENDING','SENT','FAILED','CANCELLED')),
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    recipient_count INTEGER,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    row_version BIGINT NOT NULL DEFAULT 0,
    CHECK (status <> 'SCHEDULED' OR scheduled_at IS NOT NULL),
    CHECK (target_type = 'ALL' OR cardinality(target_values) > 0)
);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_due
    ON admin_notifications(scheduled_at) WHERE status = 'SCHEDULED';
CREATE INDEX IF NOT EXISTS idx_admin_notifications_history
    ON admin_notifications(created_at DESC, id DESC);

-- One outbox row per recipient = delivery record; event_key keeps (notification, user) unique.
ALTER TABLE admin_email_outbox
    ADD COLUMN IF NOT EXISTS notification_id UUID REFERENCES admin_notifications(id),
    ADD COLUMN IF NOT EXISTS failed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_error VARCHAR(255);
CREATE INDEX IF NOT EXISTS idx_admin_email_outbox_notification
    ON admin_email_outbox(notification_id) WHERE notification_id IS NOT NULL;

-- Generated PDFs are private: bytes live here for 24h, metadata stays as the export audit.
CREATE TABLE IF NOT EXISTS admin_report_exports (
    id UUID PRIMARY KEY,
    report_type VARCHAR(20) NOT NULL CHECK (report_type IN ('REVENUE','USER','PLATFORM')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    timezone VARCHAR(40) NOT NULL,
    as_of TIMESTAMPTZ NOT NULL,
    row_count INTEGER NOT NULL,
    file_name VARCHAR(120) NOT NULL,
    file_size INTEGER NOT NULL,
    content BYTEA,
    token_hash CHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (period_end >= period_start),
    CHECK (expires_at > created_at)
);
CREATE INDEX IF NOT EXISTS idx_admin_report_exports_expiry
    ON admin_report_exports(expires_at) WHERE content IS NOT NULL;

COMMIT;

-- ---- 2026-10-04-content-moderation.sql ----
-- FR 3.10.4 Content Moderation Queue — PostgreSQL side (decisions, strike link, audit trail).
-- The immutable content snapshot of each reviewed version lives in Mongo `post_versions`
-- (see 2026-10-04-create-post-versions-collection.js); this table stores its SHA-256 hash.
-- Run with psql before deploying the new Business Service. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS content_moderation_reviews (
    id UUID PRIMARY KEY,
    post_id VARCHAR(64) NOT NULL,
    content_version BIGINT NOT NULL CHECK (content_version > 0),
    content_hash CHAR(64) NOT NULL,
    workspace_id UUID,
    author_id UUID NOT NULL REFERENCES users(id),
    source VARCHAR(20) NOT NULL CHECK (source IN ('FLAGGED_AUTHOR','COMPLIANCE','COPYRIGHT')),
    reason VARCHAR(2000) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','BLOCKED')),
    decision_note VARCHAR(2000),
    strike_level VARCHAR(10) CHECK (strike_level IN ('YELLOW','ORANGE','RED')),
    strike_category VARCHAR(100),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    row_version BIGINT NOT NULL DEFAULT 0,
    -- BR-64: one decision per immutable post version; a repeated flag reuses the pending row.
    CONSTRAINT uq_moderation_post_version UNIQUE (post_id, content_version),
    CHECK ((status = 'PENDING') = (reviewed_at IS NULL AND reviewed_by IS NULL)),
    CHECK (status <> 'APPROVED' OR char_length(btrim(decision_note)) >= 10),
    CHECK (status <> 'BLOCKED' OR (strike_level IS NOT NULL AND decision_note IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_moderation_queue ON content_moderation_reviews(status, created_at, id);
CREATE INDEX IF NOT EXISTS idx_moderation_author ON content_moderation_reviews(author_id);

COMMENT ON TABLE content_moderation_reviews IS
    'FR 3.10.4. BLOCK records the strike through the admin account journal with operation id = review id, so retries never add a second strike.';

COMMIT;

-- ---- 2026-10-04-user-notifications.sql ----
-- FR 3.10.1 in-app channel (scope extended 2026-10-04): every broadcast recipient also gets an
-- inbox row, written in the same transaction as the email outbox snapshot.
-- Depends on 2026-10-04-admin-notifications-reports.sql. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS user_notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_id UUID NOT NULL REFERENCES admin_notifications(id),
    type VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content VARCHAR(5000) NOT NULL,
    action_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    read_at TIMESTAMPTZ,
    CONSTRAINT uq_user_notification UNIQUE (notification_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_user_notifications_inbox ON user_notifications(user_id, created_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_user_notifications_unread ON user_notifications(user_id) WHERE read_at IS NULL;

COMMIT;

-- ---- 2026-10-05-admin-user-provisioning.sql ----
-- FR 3.10.7 Create User + FR 3.10.8 Update User.
-- Admin-created accounts start PENDING_VERIFICATION with require_password_reset=true; a one-time
-- activation link proves email ownership and sets the user's own password in one step (BR-15).
-- Admin plan changes are recorded for the next billing period and still require payment (BR-60).
-- Additive and idempotent.

BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS require_password_reset BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS account_activation_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (expires_at > created_at)
);
CREATE INDEX IF NOT EXISTS idx_activation_tokens_open
    ON account_activation_tokens(user_id) WHERE used_at IS NULL AND revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS subscription_plan_changes (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPLIED','CANCELLED')),
    -- NULL: no current period yet, the change starts with the user's first paid subscription.
    effective_at TIMESTAMPTZ,
    payment_required BOOLEAN NOT NULL DEFAULT TRUE,
    requested_by UUID NOT NULL REFERENCES users(id),
    reason VARCHAR(2000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_plan_change_pending
    ON subscription_plan_changes(user_id) WHERE status = 'PENDING';

COMMIT;
