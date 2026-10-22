-- ============================================================
-- BrandHub PostgreSQL Init Script — V2
-- Purpose: Agency -> Workspace -> Media Package -> Media Campaign -> Task model.
-- Replaces init-postgres.sql (V1). See docs/database/migration/migration-plan-v1-to-v2.md.
--
-- Fresh database bootstrap; existing databases must use docs/database/migrations/.
-- CREATE IF NOT EXISTS does not upgrade existing table definitions.
-- Synchronized with PostgreSQL migrations through 2026-10-14.
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
-- PostgreSQL tables (52):
--   Monitoring:   monitoring_servers, monitoring_collectors,
--                 monitoring_health_targets, monitoring_health_results, monitoring_enrollments
--   Identity:     users, user_oauth_providers, user_refresh_tokens, user_system_roles,
--                 account_activation_tokens, subscription_plan_changes
--   Organization: agencies, agency_members, agency_invitations, workspaces,
--                 workspace_members, workspace_invitations, workspace_templates, client_profiles,
--                 workspace_hashtags
--   Commerce:     media_packages, workspace_media_packages, package_negotiation_events,
--                 media_campaigns, campaign_versions, campaign_review_events, campaign_deployments
--   Content & Outbox: tasks, task_content_operations, task_content_snapshots,
--                 content_request_completion_jobs
--   Collaborator: third_party_collaborators, campaign_collaborators
--   Mail Sending: mail_attachments, mail_batches, mail_deliveries, mail_send_quota, mail_suppressions
--   Admin & Mod:  user_strikes, sanction_reviews, admin_account_operations, admin_email_outbox,
--                 admin_notifications, admin_report_exports, content_moderation_reviews, user_notifications
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
    CREATE TYPE agency_member_role AS ENUM ('OWNER', 'MEMBER', 'CLIENT');
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
    CREATE TYPE campaign_status AS ENUM ('DRAFT', 'APPROVED', 'IN_PROGRESS', 'COMPLETED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE task_type AS ENUM ('POST');
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
    banner_url     VARCHAR,
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
    display_name    VARCHAR(255) NOT NULL,
    company         VARCHAR(255),
    industry        VARCHAR(100),
    logo_url        VARCHAR(500),
    banner_url      VARCHAR(500),
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
    source_workspace_id UUID,
    duplication_request_id UUID,
    duplication_fingerprint UUID,
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
    banner_url      VARCHAR,
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
CREATE UNIQUE INDEX IF NOT EXISTS uq_workspaces_duplication_request
    ON workspaces(agency_id, duplication_request_id)
    WHERE duplication_request_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_workspaces_source_workspace
    ON workspaces(source_workspace_id)
    WHERE source_workspace_id IS NOT NULL;

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
    agency_id            UUID         REFERENCES agencies(id) ON DELETE CASCADE,
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
    agency_id          UUID         CONSTRAINT fk_media_packages_agency REFERENCES agencies(id) ON DELETE RESTRICT,
    source_template_id UUID         CONSTRAINT fk_media_packages_source_template REFERENCES media_packages(id) ON DELETE SET NULL,
    is_available_to_workspaces BOOLEAN NOT NULL DEFAULT TRUE,
    duration_weeks     INT,
    budget_amount      DECIMAL(14,2),
    scope_description  TEXT,
    offering_details   JSONB,
    created_by         UUID         NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_media_packages_template_agency_scope CHECK (
        (is_template AND agency_id IS NULL)
        OR (NOT is_template AND agency_id IS NOT NULL)
    ),
    CONSTRAINT chk_media_packages_template_source CHECK (
        source_template_id IS NULL OR NOT is_template
    )
);

CREATE INDEX IF NOT EXISTS idx_media_packages_is_template ON media_packages(is_template);
CREATE INDEX IF NOT EXISTS idx_media_packages_agency_id ON media_packages(agency_id);
CREATE INDEX IF NOT EXISTS idx_media_packages_agency_available
    ON media_packages(agency_id, is_available_to_workspaces)
    WHERE NOT is_template;

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
    previous_terms         JSONB,
    terms_version          INT                        NOT NULL DEFAULT 1,
    client_proposal_count  INT                        NOT NULL DEFAULT 0,
    approved_by_agency_at  TIMESTAMPTZ,
    approved_by_client_at  TIMESTAMPTZ,
    created_at             TIMESTAMPTZ                NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ                NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_workspace_media_packages_terms_version_positive CHECK (terms_version > 0),
    CONSTRAINT chk_workspace_media_packages_client_proposal_count CHECK (client_proposal_count >= 0)
);

DROP TRIGGER IF EXISTS trg_workspace_media_packages_updated_at ON workspace_media_packages;
CREATE TRIGGER trg_workspace_media_packages_updated_at
BEFORE UPDATE ON workspace_media_packages
FOR EACH ROW EXECUTE FUNCTION set_updated_at();


CREATE TABLE IF NOT EXISTS package_negotiation_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID NOT NULL REFERENCES workspace_media_packages(id) ON DELETE CASCADE,
    terms_version INTEGER NOT NULL CHECK (terms_version >= 1),
    action VARCHAR(30) NOT NULL CHECK (action IN ('BASELINE','REQUEST_CHANGE','COUNTER_OFFER')),
    actor_id UUID,
    actor_role VARCHAR(20),
    note VARCHAR(2000),
    terms_snapshot JSONB NOT NULL CHECK (jsonb_typeof(terms_snapshot) = 'object'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_media_package_id, terms_version),
    CHECK ((action = 'BASELINE' AND actor_id IS NULL AND actor_role IS NULL)
        OR (action = 'REQUEST_CHANGE' AND actor_id IS NOT NULL AND actor_role = 'CLIENT')
        OR (action = 'COUNTER_OFFER' AND actor_id IS NOT NULL AND actor_role IN ('OWNER','MANAGER')))
);
CREATE INDEX IF NOT EXISTS idx_package_negotiation_history
    ON package_negotiation_events(workspace_media_package_id, terms_version DESC);

CREATE OR REPLACE FUNCTION guard_package_negotiation_history() RETURNS TRIGGER AS $$
BEGIN
    -- Preserve existing parent hard-delete cascades without opening direct event deletion.
    IF TG_OP = 'DELETE' AND pg_trigger_depth() > 1 THEN RETURN OLD; END IF;
    RAISE EXCEPTION 'Package negotiation history is append-only' USING ERRCODE = '23514';
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_package_negotiation_immutable ON package_negotiation_events;
CREATE TRIGGER trg_package_negotiation_immutable BEFORE UPDATE OR DELETE ON package_negotiation_events
    FOR EACH ROW EXECUTE FUNCTION guard_package_negotiation_history();

ALTER TABLE workspaces
    DROP CONSTRAINT IF EXISTS fk_workspaces_media_package;
ALTER TABLE workspaces
    ADD CONSTRAINT fk_workspaces_media_package
    FOREIGN KEY (workspace_media_package_id) REFERENCES workspace_media_packages(id) ON DELETE SET NULL;

-- DA-E50-04: append-only package negotiation history.
-- Requires the terms-version migration. Run with psql -v ON_ERROR_STOP=1 -1.
-- Rerunnable: preserve existing history, baseline only non-draft selections
-- without history. A baseline is current known state, not reconstructed events.
CREATE TABLE IF NOT EXISTS package_negotiation_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID NOT NULL
        REFERENCES workspace_media_packages(id) ON DELETE CASCADE,
    terms_version INT NOT NULL CHECK (terms_version > 0),
    action VARCHAR(30) NOT NULL
        CHECK (action IN ('BASELINE', 'REQUEST_CHANGE', 'COUNTER_OFFER')),
    actor_id UUID,
    actor_role VARCHAR(20),
    note VARCHAR(2000),
    terms_snapshot JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_package_negotiation_events_version
        UNIQUE (workspace_media_package_id, terms_version)
);

CREATE OR REPLACE FUNCTION protect_package_negotiation_history()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE parent_exists BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Permit FK cascade only after the parent selection has been deleted.
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I.workspace_media_packages WHERE id = $1)',
                       TG_TABLE_SCHEMA)
            INTO parent_exists USING OLD.workspace_media_package_id;
        IF NOT parent_exists THEN
            RETURN OLD;
        END IF;
    END IF;
    RAISE EXCEPTION 'package_negotiation_events is append-only';
END;
$$;

DROP TRIGGER IF EXISTS trg_package_negotiation_events_append_only ON package_negotiation_events;
CREATE TRIGGER trg_package_negotiation_events_append_only
BEFORE UPDATE OR DELETE ON package_negotiation_events
FOR EACH ROW EXECUTE FUNCTION protect_package_negotiation_history();

INSERT INTO package_negotiation_events (
    workspace_media_package_id, terms_version, action, terms_snapshot
)
SELECT p.id, p.terms_version, 'BASELINE', p.final_terms
FROM workspace_media_packages p
WHERE p.negotiation_status <> 'DRAFT'
  AND NOT EXISTS (
      SELECT 1 FROM package_negotiation_events e
      WHERE e.workspace_media_package_id = p.id
  )
ON CONFLICT (workspace_media_package_id, terms_version) DO NOTHING;


CREATE TABLE IF NOT EXISTS media_campaigns (
    id                          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID             NOT NULL REFERENCES workspace_media_packages(id) ON DELETE RESTRICT,
    name                        VARCHAR(255)    NOT NULL,
    strategy_detail             TEXT,
    package_terms_snapshot      JSONB,
    package_terms_version       INT,
    allocation_period           VARCHAR(7),
    allocations                 JSONB NOT NULL DEFAULT '[]',
    deliverable_plan            JSONB NOT NULL DEFAULT '[]',
    work_items                  JSONB NOT NULL DEFAULT '[]',
    content_version             INT NOT NULL DEFAULT 1,
    row_version                 BIGINT NOT NULL DEFAULT 0,
    brand_guideline             TEXT,
    timeline                    JSONB           NOT NULL DEFAULT '{}',
    status                      campaign_status NOT NULL DEFAULT 'DRAFT',
    approved_by_agency_at       TIMESTAMPTZ,
    approved_by_agency_id       UUID,
    approved_by_agency_version  INT,
    approved_by_client_at       TIMESTAMPTZ,
    approved_by_client_id       UUID,
    approved_by_client_version  INT,
    completed_at                TIMESTAMPTZ,
    completed_by                UUID,
    completion_reason           VARCHAR(2000),
    completion_task_summary     JSONB,
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_campaigns_wmp_id ON media_campaigns(workspace_media_package_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_media_campaigns_agreement ON media_campaigns(workspace_media_package_id);

CREATE TABLE IF NOT EXISTS content_request_completion_jobs (
    campaign_id UUID PRIMARY KEY REFERENCES media_campaigns(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS campaign_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES media_campaigns(id) ON DELETE CASCADE,
    content_version INT NOT NULL,
    snapshot JSONB NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_campaign_versions_campaign_version UNIQUE (campaign_id, content_version)
);

CREATE TABLE IF NOT EXISTS campaign_review_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES media_campaigns(id) ON DELETE CASCADE,
    content_version INT NOT NULL,
    actor_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    actor_side VARCHAR(16) NOT NULL CHECK (actor_side IN ('AGENCY', 'CLIENT')),
    event_type VARCHAR(16) NOT NULL CHECK (event_type IN ('FEEDBACK', 'APPROVE')),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_campaign_review_events_campaign_created
    ON campaign_review_events(campaign_id, created_at DESC);

CREATE TABLE IF NOT EXISTS campaign_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL UNIQUE REFERENCES media_campaigns(id) ON DELETE CASCADE,
    content_version INT NOT NULL,
    requested_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(16) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'FAILED', 'SUCCEEDED')),
    attempt_count INT NOT NULL DEFAULT 0,
    last_error_code VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_campaign_deployments_status_created
    ON campaign_deployments(status, created_at);

DROP TRIGGER IF EXISTS trg_media_campaigns_updated_at ON media_campaigns;
CREATE TRIGGER trg_media_campaigns_updated_at
BEFORE UPDATE ON media_campaigns
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Content writing (2026-10-01 PostgreSQL migrations)
-- Minimal task anchor for the canvas editor, not a replacement for the
-- generic MongoDB tasks/task_approvals collections defined separately.
-- Create tasks before content tables because both reference tasks(id).
-- ============================================================

CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id),
    type task_type NOT NULL DEFAULT 'POST',
    title VARCHAR(255) NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tasks_workspace_id ON tasks(workspace_id);

CREATE TABLE IF NOT EXISTS task_content_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL,
    sequence_number BIGINT NOT NULL,
    yjs_update TEXT NOT NULL,
    edited_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (task_id, sequence_number)
);

CREATE INDEX IF NOT EXISTS idx_task_content_operations_task_id ON task_content_operations(task_id);

CREATE TABLE IF NOT EXISTS task_content_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL,
    sequence_number BIGINT NOT NULL,
    yjs_state TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_task_content_snapshots_task_id ON task_content_snapshots(task_id, sequence_number DESC);

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
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    first_used_at TIMESTAMPTZ,
    usage_history_verified BOOLEAN NOT NULL DEFAULT FALSE,
    version      BIGINT            NOT NULL DEFAULT 0,
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

CREATE OR REPLACE FUNCTION mark_collaborator_usage_on_link()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE active BOOLEAN;
BEGIN
    SELECT is_active INTO active
      FROM third_party_collaborators
     WHERE id = NEW.collaborator_id
     FOR UPDATE;
    IF active IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'collaborator does not exist';
    END IF;
    IF NOT active THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'collaborator is inactive';
    END IF;
    UPDATE third_party_collaborators
       SET first_used_at = COALESCE(first_used_at, NOW()),
           version = version + 1
     WHERE id = NEW.collaborator_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_campaign_collaborator_mark_used ON campaign_collaborators;
CREATE TRIGGER trg_campaign_collaborator_mark_used
BEFORE INSERT ON campaign_collaborators
FOR EACH ROW EXECUTE FUNCTION mark_collaborator_usage_on_link();

-- ============================================================
-- Workspace hashtags group
-- ============================================================

CREATE TABLE IF NOT EXISTS workspace_hashtags (
    id             UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id   UUID              NOT NULL REFERENCES workspaces(id),
    tag            VARCHAR(100)      NOT NULL,
    normalized_tag VARCHAR(100)      NOT NULL,
    purpose        VARCHAR(30)       NOT NULL CHECK (purpose IN ('BRAND','CAMPAIGN','TRENDING','EVENT_SPECIFIC')),
    added_by       UUID              NOT NULL REFERENCES users(id),
    added_by_name  VARCHAR(255)      NOT NULL,
    is_required    BOOLEAN           NOT NULL DEFAULT FALSE,
    campaign_id    UUID              REFERENCES media_campaigns(id),
    deleted_at     TIMESTAMPTZ,
    deleted_by     UUID              REFERENCES users(id),
    created_at     TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    version        BIGINT            NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_workspace_hashtags_active_tag
    ON workspace_hashtags(workspace_id, normalized_tag) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_workspace_hashtags_list
    ON workspace_hashtags(workspace_id, created_at DESC, id DESC) WHERE deleted_at IS NULL;

-- ============================================================
-- Durable usage marker survives Campaign/link deletion; inactive partners cannot gain new links.
CREATE OR REPLACE FUNCTION guard_campaign_partner_usage() RETURNS TRIGGER AS $$
DECLARE partner_active BOOLEAN;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.collaborator_id = OLD.collaborator_id THEN
        RETURN NEW;
    END IF;
    SELECT is_active INTO partner_active FROM third_party_collaborators
    WHERE id = NEW.collaborator_id FOR UPDATE;
    IF partner_active IS FALSE THEN
        RAISE EXCEPTION 'Inactive collaborator cannot be assigned' USING ERRCODE = '23514';
    END IF;
    UPDATE third_party_collaborators
    SET first_used_at = CURRENT_TIMESTAMP, version = version + 1
    WHERE id = NEW.collaborator_id AND first_used_at IS NULL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_campaign_partner_usage ON campaign_collaborators;
CREATE TRIGGER trg_campaign_partner_usage
    BEFORE INSERT OR UPDATE OF collaborator_id ON campaign_collaborators
    FOR EACH ROW EXECUTE FUNCTION guard_campaign_partner_usage();

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
-- Mail sending (FR 3.6.28-3.6.32)
-- Mirrors docs/database/migrations/2026-10-12-create-mail-sending-tables.sql for fresh databases.
-- ============================================================

CREATE TABLE IF NOT EXISTS mail_attachments (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    uploaded_by   UUID NOT NULL REFERENCES users(id),
    name          VARCHAR(255) NOT NULL,
    content_type  VARCHAR(100) NOT NULL,
    size          BIGINT NOT NULL,
    s3_key        VARCHAR(500) NOT NULL,
    kind          VARCHAR(16) NOT NULL DEFAULT 'FILE' CHECK (kind IN ('FILE', 'IMAGE')),
    bound         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_mail_attachments_workspace
    ON mail_attachments (workspace_id, bound, created_at);

CREATE TABLE IF NOT EXISTS mail_batches (
    id               UUID PRIMARY KEY,
    workspace_id     UUID NOT NULL REFERENCES workspaces(id),
    workspace_name   VARCHAR(255),
    template_id      VARCHAR(64) NOT NULL,
    template_name    VARCHAR(120) NOT NULL,
    sent_by          UUID NOT NULL REFERENCES users(id),
    sender_email     VARCHAR(255) NOT NULL,
    sender_name      VARCHAR(255),
    kind             VARCHAR(16) NOT NULL DEFAULT 'SEND' CHECK (kind IN ('SEND', 'TEST')),
    status           VARCHAR(16) NOT NULL
                     CHECK (status IN ('SCHEDULED', 'QUEUED', 'SENDING', 'COMPLETED', 'CANCELLED', 'FAILED')),
    subject          VARCHAR(200) NOT NULL,
    body_html        TEXT NOT NULL,
    attachments      JSONB,
    scheduled_at     TIMESTAMPTZ,
    timezone         VARCHAR(64) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    total            INT NOT NULL,
    accepted         INT NOT NULL,
    rejected_count   INT NOT NULL DEFAULT 0,
    sent_count       INT NOT NULL DEFAULT 0,
    failed_count     INT NOT NULL DEFAULT 0,
    suppressed_count INT NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_mail_batches_workspace ON mail_batches (workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mail_batches_due ON mail_batches (status, scheduled_at);

CREATE TABLE IF NOT EXISTS mail_deliveries (
    id                  UUID PRIMARY KEY,
    batch_id            UUID NOT NULL REFERENCES mail_batches(id) ON DELETE CASCADE,
    recipient           VARCHAR(255) NOT NULL,
    recipient_name      VARCHAR(255),
    variables           JSONB,
    rendered_subject    VARCHAR(255) NOT NULL,
    rendered_body_html  TEXT NOT NULL,
    external_audience   BOOLEAN NOT NULL DEFAULT FALSE,
    status              VARCHAR(16) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'SUPPRESSED')),
    attempts            INT NOT NULL DEFAULT 0,
    last_error          VARCHAR(500),
    next_attempt_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at             TIMESTAMPTZ,
    event_key           VARCHAR(300) NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_due ON mail_deliveries (status, next_attempt_at);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_batch ON mail_deliveries (batch_id);

CREATE TABLE IF NOT EXISTS mail_send_quota (
    day         DATE NOT NULL,
    scope       VARCHAR(16) NOT NULL CHECK (scope IN ('SYSTEM', 'WORKSPACE')),
    scope_id    VARCHAR(64) NOT NULL,
    sent_count  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (day, scope, scope_id)
);

CREATE TABLE IF NOT EXISTS mail_suppressions (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    email_lower   VARCHAR(255) NOT NULL,
    reason        VARCHAR(32) NOT NULL DEFAULT 'UNSUBSCRIBED',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, email_lower)
);

-- ============================================================
-- Content request completion outbox (durable SQL queue)
-- ============================================================

CREATE TABLE IF NOT EXISTS content_request_completion_jobs (
    campaign_id  UUID        PRIMARY KEY,
    workspace_id UUID        NOT NULL,
    actor_id     UUID        NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_content_req_completion_jobs_created
    ON content_request_completion_jobs (created_at);

-- ============================================================
-- Seed subscription plans
-- ============================================================

INSERT INTO subscription_plans (name, display_name, price_monthly, max_workspaces, ai_credits_month, features, is_active)
VALUES
    ('BASIC', 'Basic', 490000, 3, 200, '["scheduling", "approval_workflow"]'::jsonb, TRUE),
    ('PRO', 'Pro', 990000, 10, 1000, '["scheduling", "approval_workflow", "ai_content", "analytics"]'::jsonb, TRUE),
    ('ENTERPRISE', 'Enterprise', 2990000, -1, 5000, '["all_features", "unlimited_workspaces", "dedicated_support"]'::jsonb, TRUE)
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- Explicit PostgreSQL demo seed run marker
-- ============================================================

CREATE TABLE IF NOT EXISTS seed_runs (
    dataset          VARCHAR(100) NOT NULL,
    dataset_version  INTEGER NOT NULL CHECK (dataset_version > 0),
    run_id           UUID NOT NULL UNIQUE,
    status           VARCHAR(16) NOT NULL CHECK (status IN ('running', 'complete', 'failed')),
    last_stage       VARCHAR(64),
    record_counts    JSONB NOT NULL DEFAULT '{}'::jsonb,
    manifest         JSONB NOT NULL DEFAULT '{}'::jsonb,
    failure_summary  VARCHAR(255),
    started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at     TIMESTAMPTZ,
    failed_at        TIMESTAMPTZ,
    PRIMARY KEY (dataset, dataset_version),
    CHECK ((status = 'complete') = (completed_at IS NOT NULL)),
    CHECK ((status = 'failed') = (failed_at IS NOT NULL))
);

-- ============================================================
-- System Health Monitoring (FR 3.10.3)
-- Mirrors docs/database/migrations/2026-09-24-monitoring.sql for fresh databases.
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

CREATE TABLE IF NOT EXISTS monitoring_enrollments (
    token_hash CHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_monitoring_enrollments_expiry ON monitoring_enrollments(expires_at);
COMMENT ON TABLE monitoring_enrollments IS 'Single-use admin-issued host enrollment; only token digests are stored. Claimed atomically.';


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
    notification_id UUID REFERENCES admin_notifications(id),
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

-- ---- 2026-10-08-ai-credit-usages.sql ----
-- FR 3.7.2 (and 3.7.7): per-use AI credit record so the agency monthly ledger (ai_credit_ledgers) and the
-- Owner's hard per-Creator limit (ai_credit_creator_limits, FR 3.9.7) can both be enforced, and a failed
-- AI job can be refunded. FR 3.9.5 (credit tracking) can read this table.
-- Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_credit_usages (
    id           UUID         PRIMARY KEY,
    agency_id    UUID         NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workspace_id UUID         REFERENCES workspaces(id) ON DELETE SET NULL,
    feature      VARCHAR(40)  NOT NULL,
    credits      INT          NOT NULL CHECK (credits >= 0),
    month        VARCHAR(7)   NOT NULL,
    reference    VARCHAR(120),
    refunded_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_credit_usages_agency_month ON ai_credit_usages(agency_id, month);
CREATE INDEX IF NOT EXISTS idx_ai_credit_usages_user_month ON ai_credit_usages(user_id, agency_id, month)
    WHERE refunded_at IS NULL;

COMMIT;

-- ---- 2026-10-08-ai-caption-generations.sql ----
-- FR 3.7.2: every caption generation, which option the Creator picked and what they finally kept.
-- Used for (1) history of AI-written content per task, (2) choosing better few-shot examples and a
-- dataset for the content LoRA later. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_caption_generations (
    id            UUID         PRIMARY KEY,
    workspace_id  UUID         NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id       UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id       UUID,
    request       JSONB        NOT NULL,
    variants      JSONB        NOT NULL,
    context       JSONB        NOT NULL DEFAULT '{}',
    credits       INT          NOT NULL DEFAULT 0,
    chosen_type   VARCHAR(20),
    chosen_action VARCHAR(10)  CHECK (chosen_action IN ('INSERT','REPLACE')),
    final_text    TEXT,
    chosen_at     TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_caption_generations_workspace ON ai_caption_generations(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_caption_generations_task ON ai_caption_generations(task_id) WHERE task_id IS NOT NULL;

COMMIT;

-- ---- 2026-10-08-ai-video-jobs.sql ----
-- FR 3.7.6 / 3.7.7: one row per AI video job. The AI service keeps the live job in Redis (24h); this row
-- ties the job to its workspace/user (only they can read it), keeps the result after Redis expiry, and
-- links the AI credit charge so a failed or timed-out job is refunded exactly once.
-- Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_video_jobs (
    id             VARCHAR(64)  PRIMARY KEY,
    workspace_id   UUID         NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id        UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    usage_id       UUID         REFERENCES ai_credit_usages(id) ON DELETE SET NULL,
    prompt         TEXT         NOT NULL,
    style_key      VARCHAR(40),
    ambassador_id  VARCHAR(80),
    aspect_ratio   VARCHAR(5)   NOT NULL,
    status         VARCHAR(12)  NOT NULL DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','PROCESSING','COMPLETED','FAILED')),
    video_url      TEXT,
    error_code     VARCHAR(60),
    refunded_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    finished_at    TIMESTAMPTZ
);
-- S3 key of the stored MP4: the Content Studio attaches it to a post as media.
ALTER TABLE ai_video_jobs ADD COLUMN IF NOT EXISTS s3_key VARCHAR(300);
CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_workspace ON ai_video_jobs(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_video_jobs_open ON ai_video_jobs(created_at) WHERE status IN ('PENDING','PROCESSING');

COMMIT;

-- ---- 2026-10-12-create-mail-sending-tables.sql ----
-- ============================================================
-- BrandHub - PostgreSQL migration: mail sending tables
-- Date: 2026-10-12
-- Reason: FR 3.6.28-3.6.32 (DA-1002, DA-1256..DA-1258). Batches, per-recipient
--         deliveries (outbox), daily quota, suppression list, attachments.
-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-12-create-mail-sending-tables.sql
-- Statuses are varchar + CHECK (not PG enums) so the JDBC code stays simple.
-- ============================================================
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

CREATE TABLE IF NOT EXISTS mail_attachments (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    uploaded_by   UUID NOT NULL REFERENCES users(id),
    name          VARCHAR(255) NOT NULL,
    content_type  VARCHAR(100) NOT NULL,
    size          BIGINT NOT NULL,
    s3_key        VARCHAR(500) NOT NULL,
    kind          VARCHAR(16) NOT NULL DEFAULT 'FILE' CHECK (kind IN ('FILE', 'IMAGE')),
    bound         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_mail_attachments_workspace
    ON mail_attachments (workspace_id, bound, created_at);

CREATE TABLE IF NOT EXISTS mail_batches (
    id               UUID PRIMARY KEY,
    workspace_id     UUID NOT NULL REFERENCES workspaces(id),
    workspace_name   VARCHAR(255),
    template_id      VARCHAR(64) NOT NULL,
    template_name    VARCHAR(120) NOT NULL,
    sent_by          UUID NOT NULL REFERENCES users(id),
    sender_email     VARCHAR(255) NOT NULL,
    sender_name      VARCHAR(255),
    kind             VARCHAR(16) NOT NULL DEFAULT 'SEND' CHECK (kind IN ('SEND', 'TEST')),
    status           VARCHAR(16) NOT NULL
                     CHECK (status IN ('SCHEDULED', 'QUEUED', 'SENDING', 'COMPLETED', 'CANCELLED', 'FAILED')),
    subject          VARCHAR(200) NOT NULL,
    body_html        TEXT NOT NULL,
    attachments      JSONB,
    scheduled_at     TIMESTAMPTZ,
    timezone         VARCHAR(64) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    total            INT NOT NULL,
    accepted         INT NOT NULL,
    rejected_count   INT NOT NULL DEFAULT 0,
    sent_count       INT NOT NULL DEFAULT 0,
    failed_count     INT NOT NULL DEFAULT 0,
    suppressed_count INT NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_mail_batches_workspace ON mail_batches (workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mail_batches_due ON mail_batches (status, scheduled_at);

CREATE TABLE IF NOT EXISTS mail_deliveries (
    id                  UUID PRIMARY KEY,
    batch_id            UUID NOT NULL REFERENCES mail_batches(id) ON DELETE CASCADE,
    recipient           VARCHAR(255) NOT NULL,
    recipient_name      VARCHAR(255),
    variables           JSONB,
    rendered_subject    VARCHAR(255) NOT NULL,
    rendered_body_html  TEXT NOT NULL,
    external_audience   BOOLEAN NOT NULL DEFAULT FALSE,
    status              VARCHAR(16) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'SUPPRESSED')),
    attempts            INT NOT NULL DEFAULT 0,
    last_error          VARCHAR(500),
    next_attempt_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    sent_at             TIMESTAMPTZ,
    event_key           VARCHAR(300) NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_due ON mail_deliveries (status, next_attempt_at);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_batch ON mail_deliveries (batch_id);

CREATE TABLE IF NOT EXISTS mail_send_quota (
    day         DATE NOT NULL,
    scope       VARCHAR(16) NOT NULL CHECK (scope IN ('SYSTEM', 'WORKSPACE')),
    scope_id    VARCHAR(64) NOT NULL,
    sent_count  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (day, scope, scope_id)
);

CREATE TABLE IF NOT EXISTS mail_suppressions (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    email_lower   VARCHAR(255) NOT NULL,
    reason        VARCHAR(32) NOT NULL DEFAULT 'UNSUBSCRIBED',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, email_lower)
);

COMMIT;

-- Subscription baseline: 2026-10-20-agency-subscription-expand.sql

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



-- Subscription baseline: 2026-10-20-four-plan-catalog.sql

-- Four-product catalog: Personal (USER), Basic/Plus/Enterprise (AGENCY).
-- Prerequisite: 2026-10-20-agency-subscription-expand.sql.
-- PostgreSQL 17; run with psql -X -v ON_ERROR_STOP=1 -f <this file>.
-- Preserves existing versions and subscriptions. Does not enable paid sales.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
SELECT pg_advisory_xact_lock(392026, 1020);
SET LOCAL search_path = public;

DO $$
BEGIN
  IF to_regclass('public.brandhub_schema_migrations') IS NULL
     OR to_regclass('public.billing_plan_versions') IS NULL THEN
    RAISE EXCEPTION 'Apply 2026-10-20-agency-subscription-expand.sql first';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM brandhub_schema_migrations
    WHERE version = '20261020_agency_subscription_expand_v1'
  ) THEN
    RAISE EXCEPTION 'Agency subscription expand migration is not recorded as applied';
  END IF;
END $$;

SELECT EXISTS (
  SELECT 1 FROM brandhub_schema_migrations
  WHERE version = '20261020_four_plan_catalog_v1'
) AS already_applied \gset
\if :already_applied
  \echo 'Four-plan catalog migration already applied; no changes.'
\else

ALTER TABLE billing_plan_versions
  DROP CONSTRAINT billing_plan_versions_code_check,
  ADD CONSTRAINT billing_plan_versions_code_check
    CHECK (code IN ('PERSONAL', 'BASIC', 'PLUS', 'ENTERPRISE')),
  ADD COLUMN billing_scope text GENERATED ALWAYS AS (
    CASE WHEN code = 'PERSONAL' THEN 'USER'::text ELSE 'AGENCY'::text END
  ) STORED,
  ADD CONSTRAINT billing_plan_versions_id_scope_key UNIQUE (id, billing_scope);

COMMENT ON COLUMN billing_plan_versions.billing_scope IS
  'Derived from product code; Personal belongs to a user, Agency tiers belong to an agency.';

-- Stored generated columns are calculated after BEFORE triggers. Exclude the
-- derived field from the immutable-row comparison so sale-flag changes still work.
-- Its source (code) remains immutable and scope cannot be assigned directly.
CREATE OR REPLACE FUNCTION billing_guard_plan_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' OR TG_OP = 'TRUNCATE' THEN
    RAISE EXCEPTION 'Plan versions are immutable; disable sale instead' USING ERRCODE = '23514';
  END IF;
  IF (to_jsonb(NEW) - 'is_sellable' - 'billing_scope')
       IS DISTINCT FROM (to_jsonb(OLD) - 'is_sellable' - 'billing_scope') THEN
    RAISE EXCEPTION 'Create a new plan version to change price or benefits' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;

-- Enforce scope on every existing Agency plan reference, including pending orders.
-- Existing FKs remain in place. Nullable plan_version_id on credit top-ups is preserved.
ALTER TABLE agency_subscriptions
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT agency_subscriptions_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

ALTER TABLE billing_orders
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT billing_orders_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

ALTER TABLE agency_subscription_periods
  ADD COLUMN plan_billing_scope text NOT NULL DEFAULT 'AGENCY'
    CHECK (plan_billing_scope = 'AGENCY'),
  ADD CONSTRAINT agency_subscription_periods_plan_scope_fkey
    FOREIGN KEY (plan_version_id, plan_billing_scope)
    REFERENCES billing_plan_versions (id, billing_scope) ON DELETE RESTRICT;

-- Proposed quota values; paid prices remain unknown and paid sales disabled.
-- Never overwrite an existing immutable version or configured commercial terms.
INSERT INTO billing_plan_versions (
  code, version, display_name, price_monthly,
  max_active_workspaces, max_internal_members, max_clients,
  storage_limit_bytes, monthly_ai_credits, max_concurrent_ai_jobs,
  version_retention_days, trash_retention_days, activity_retention_days,
  features, is_sellable
) VALUES
  ('PERSONAL', 1, 'Personal', NULL, 0, 1, 0,
   20000000000, 1000, 1, 30, 30, 90,
   '{"max_personal_spaces":1,"quota_policy":"PROPOSED"}'::jsonb, false),
  ('BASIC', 1, 'Basic', 0, 1, 3, 5,
   2000000000, 0, 1, 7, 7, 30, '{}'::jsonb, true),
  ('PLUS', 1, 'Plus', NULL, 10, 15, 50,
   100000000000, 5000, 3, 90, 30, 180, '{}'::jsonb, false),
  ('ENTERPRISE', 1, 'Enterprise', NULL, 50, 50, 200,
   1000000000000, 25000, 10, 365, 90, 365, '{}'::jsonb, false)
ON CONFLICT (code, version) DO NOTHING;

INSERT INTO brandhub_schema_migrations (version, description) VALUES (
  '20261020_four_plan_catalog_v1',
  'Ensure four versioned products, derive USER/AGENCY scope, prevent Personal assignment to Agency billing'
);
\endif
COMMIT;


-- Subscription baseline: 2026-10-20-payos-to-seepay.sql

-- Switch payment provider default from PayOS to SePay.
-- PostgreSQL 17; run with psql -X -v ON_ERROR_STOP=1.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SELECT pg_advisory_xact_lock(392026, 1021);

CREATE TABLE IF NOT EXISTS public.brandhub_schema_migrations (
  version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now(), description text NOT NULL
);
SELECT EXISTS(SELECT 1 FROM public.brandhub_schema_migrations WHERE version='20261020_payos_to_seepay_v1') AS already_applied \gset
\if :already_applied
  \echo 'Migration already applied; no changes.'
\else

ALTER TABLE billing_payment_attempts ALTER COLUMN provider SET DEFAULT 'SEEPAY';

INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261020_payos_to_seepay_v1','Switch default payment provider from PayOS to SePay');
\endif
COMMIT;


-- Subscription baseline: 2026-10-21-subscription-observability.sql

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


-- Subscription baseline: 2026-10-22-workspace-credit-unification.sql

-- Subscription is the only wallet; Workspace caps replace personal caps.
-- Prerequisites: agency-subscription-expand, four-plan-catalog, subscription-observability.
-- Never drops/converts an existing DA-974 reservation. Review/reset test data separately.
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SET LOCAL search_path=public;
SELECT pg_advisory_xact_lock(392026,1022);
DO $$
BEGIN
 IF to_regclass('agency_credit_wallets') IS NULL OR to_regclass('credit_grants') IS NULL
    OR to_regclass('workspace_credit_limits') IS NULL OR to_regclass('credit_usage_periods') IS NULL
    OR to_regclass('brandhub_schema_migrations') IS NULL THEN
  RAISE EXCEPTION 'Apply Subscription migrations first; DA-974 databases require reviewed reset/conversion';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND table_name='ai_credit_reservations' AND column_name='actor_id') THEN
  RAISE EXCEPTION 'Conflicting ai_credit_reservations schema; no automatic conversion or deletion';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND table_name='ai_credit_reservations' AND column_name='request_key')
   AND EXISTS(SELECT 1 FROM ai_credit_reservations) THEN
  RAISE EXCEPTION 'Existing reservations need explicit request/execution metadata conversion';
 END IF;
END $$;
SELECT EXISTS(SELECT 1 FROM brandhub_schema_migrations
 WHERE version='20261022_workspace_credit_v1') AS workspace_credit_applied \gset
\if :workspace_credit_applied
 \echo 'Workspace Credit migration already applied; no changes.'
\else
CREATE TABLE IF NOT EXISTS ai_credit_operation_prices (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 operation varchar(40) NOT NULL CHECK(operation IN ('CONTENT_GENERATE','CAPTION_VARIANTS','HASHTAG_GENERATE',
  'AMBASSADOR_GENERATE','CHARACTER_SHEET','COMMERCIAL_IMAGE','VIDEO_GENERATE')),
 revision bigint NOT NULL CHECK(revision>0), unit_credits bigint NOT NULL CHECK(unit_credits>=0),
 enabled boolean NOT NULL, created_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(operation,revision)
);
CREATE OR REPLACE FUNCTION guard_credit_price_history() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'Credit price versions are append-only'; END $$;
DROP TRIGGER IF EXISTS trg_credit_price_history ON ai_credit_operation_prices;
CREATE TRIGGER trg_credit_price_history BEFORE UPDATE OR DELETE ON ai_credit_operation_prices
 FOR EACH ROW EXECUTE FUNCTION guard_credit_price_history();

ALTER TABLE credit_grants ALTER COLUMN expires_at DROP NOT NULL;
ALTER TABLE credit_grants DROP CONSTRAINT credit_grants_source_type_check;
ALTER TABLE credit_grants ADD CONSTRAINT credit_grants_source_type_check
 CHECK(source_type IN ('TRIAL','PERIOD','TOPUP','OPENING','ADJUSTMENT','DEV_SEED'));
-- Extends purchased entitlement only; does not change any balances.
UPDATE credit_grants SET expires_at=NULL WHERE source_type='TOPUP';
ALTER TABLE credit_grants ADD CONSTRAINT ck_credit_grants_period_expiry
 CHECK(source_type<>'PERIOD' OR expires_at IS NOT NULL);
ALTER TABLE credit_grants ADD CONSTRAINT ck_credit_grants_topup_no_expiry
 CHECK(source_type<>'TOPUP' OR expires_at IS NULL);

ALTER TABLE ai_credit_reservations
 ADD COLUMN request_key varchar(128) NOT NULL,
 ADD COLUMN payload_hash varchar(64) NOT NULL CHECK(payload_hash ~ '^[a-f0-9]{64}$'),
 ADD COLUMN price_id uuid REFERENCES ai_credit_operation_prices(id) ON DELETE RESTRICT,
 ADD COLUMN unit_credits bigint NOT NULL CHECK(unit_credits>=0),
 ADD COLUMN units integer NOT NULL CHECK(units>0),
 ADD COLUMN successful_units integer,
 ADD COLUMN execution_state varchar(16) NOT NULL DEFAULT 'READY'
  CHECK(execution_state IN ('READY','RUNNING','WAITING','SUCCEEDED','FAILED','UNKNOWN')),
 ADD COLUMN execution_response jsonb,
 ADD COLUMN execution_updated_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE ai_credit_reservations DROP CONSTRAINT ai_credit_reservations_reserved_amount_check;
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ai_credit_reservations_reserved_amount_check CHECK(reserved_amount>=0);
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_frozen_amount
 CHECK(reserved_amount::numeric=unit_credits::numeric*units);
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_price_source
 CHECK((action IN ('CONTENT_GENERATE','AMBASSADOR_GENERATE','COMMERCIAL_IMAGE','VIDEO_GENERATE') AND price_id IS NOT NULL)
  OR (action IN ('CAPTION_VARIANTS','HASHTAG_GENERATE','CHARACTER_SHEET') AND price_id IS NULL
      AND unit_credits=0 AND rate_version='FREE_V1'));
ALTER TABLE ai_credit_reservations ADD CONSTRAINT ck_ai_credit_outcome
 CHECK((status IN ('RESERVED','UNKNOWN') AND successful_units IS NULL AND settled_at IS NULL)
  OR (status='SETTLED' AND successful_units IS NOT NULL AND successful_units>0 AND successful_units<=units AND settled_at IS NOT NULL
      AND charged_amount::numeric=unit_credits::numeric*successful_units)
  OR (status='RELEASED' AND successful_units IS NOT NULL AND successful_units=0 AND charged_amount=0 AND settled_at IS NOT NULL));
CREATE UNIQUE INDEX uq_workspace_credit_request ON ai_credit_reservations(agency_id,actor_id,request_key);
CREATE UNIQUE INDEX uq_credit_provider_job ON ai_credit_reservations(provider_job_id) WHERE provider_job_id IS NOT NULL;
CREATE INDEX idx_workspace_credit_period ON ai_credit_reservations(agency_id,workspace_id,period_id);
CREATE INDEX idx_workspace_credit_actor ON ai_credit_reservations(agency_id,actor_id,created_at DESC);
CREATE INDEX idx_credit_video_reconciliation ON ai_credit_reservations(execution_updated_at)
 WHERE execution_state='WAITING' AND status IN ('RESERVED','UNKNOWN');
ALTER TABLE credit_reservation_allocations ADD COLUMN ordinal integer NOT NULL CHECK(ordinal>=0);
CREATE UNIQUE INDEX uq_workspace_credit_allocation_order ON credit_reservation_allocations(reservation_id,ordinal);
INSERT INTO brandhub_schema_migrations(version,description) VALUES
 ('20261022_workspace_credit_v1','Agency Subscription wallet; Workspace-only caps; durable/idempotent fixed-price AI accounting');
\endif
COMMIT;

-- Unified Caption/Video credit linkage (2026-10-21). Same DDL as the additive migration.
-- DA-974: preserve legacy history, link new Video jobs to unified reservations.
-- Prerequisites: caption-generations, video-jobs, compact credit-accounting + credit-ai-execution.
-- Stop Business/workers, apply before deploying the matching build. No seed/balance conversion.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = public;

DO $$
BEGIN
    IF to_regclass('ai_caption_generations') IS NULL OR to_regclass('ai_video_jobs') IS NULL
        OR to_regclass('ai_credit_reservations') IS NULL THEN
        RAISE EXCEPTION 'Apply Caption/Video and compact Credit migrations first; no changes applied';
    END IF;
END $$;

ALTER TABLE ai_caption_generations ALTER COLUMN credits TYPE BIGINT;
ALTER TABLE ai_video_jobs ADD COLUMN IF NOT EXISTS reservation_id UUID;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='ai_video_jobs'::regclass
        AND conname='fk_ai_video_jobs_reservation') THEN
        ALTER TABLE ai_video_jobs ADD CONSTRAINT fk_ai_video_jobs_reservation
            FOREIGN KEY (reservation_id) REFERENCES ai_credit_reservations(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='ai_video_jobs'::regclass
        AND conname='ck_ai_video_jobs_accounting_source') THEN
        ALTER TABLE ai_video_jobs ADD CONSTRAINT ck_ai_video_jobs_accounting_source
            CHECK (usage_id IS NULL OR reservation_id IS NULL);
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_ai_video_jobs_reservation
    ON ai_video_jobs(reservation_id) WHERE reservation_id IS NOT NULL;

COMMIT;
