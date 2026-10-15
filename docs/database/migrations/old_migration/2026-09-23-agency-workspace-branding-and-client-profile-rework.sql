-- ============================================================
-- BrandHub — Migration: Agency/Workspace branding fields, ClientProfile
--                        rework (userId+agencyId), invitation extras
-- Date: 2026-09-23
-- Reason: init-postgres-v2.sql predates several entity commits merged
--         2026-09-21/22. Hibernate ddl-auto=validate boots fail until
--         DB matches. Covers:
--           - 3d35cc3 / 990149d: Agency.category, Agency.companySize,
--             Workspace.industry, Workspace.companySize + contact
--             fields (website/phone/location)
--           - 75a1099 / 96ed91c: Agency + Workspace branding fields
--             (brandColor/logoIcon/tagline/foundedYear/social links),
--             Workspace.description, Workspace.logoUrl
--           - 227a8c4 / 5620207: ClientProfile.linked_user_id ->
--             user_id, + agency_id (client profile now scoped per
--             agency, matches ClientProfile.java exactly), + website/
--             industry/location/description/social_links, drop
--             email/brand_name (no longer in entity)
--           - 96ed91c: WorkspaceInvitation.role
--           - 7c648ab: AgencyInvitation.note/workspace_id/role
--
-- Idempotent: safe to run repeatedly on any existing V2 database.
--
-- Usage (against the running postgres container):
--   docker exec -i brandhub-postgres psql -U brandhub -d brandhub < 2026-09-23-agency-workspace-branding-and-client-profile-rework.sql
-- ============================================================

DO $$ BEGIN
    CREATE TYPE agency_category AS ENUM (
        'MARKETING', 'FNB', 'FASHION', 'BEAUTY', 'TECHNOLOGY', 'REAL_ESTATE',
        'EDUCATION', 'HEALTHCARE', 'RETAIL', 'FINANCE', 'ENTERTAINMENT', 'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE workspace_industry AS ENUM (
        'FNB', 'FASHION', 'BEAUTY', 'TECHNOLOGY', 'REAL_ESTATE', 'EDUCATION',
        'HEALTHCARE', 'SERVICES', 'RETAIL', 'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE company_size AS ENUM (
        'SIZE_1_10', 'SIZE_11_50', 'SIZE_51_200', 'SIZE_201_500', 'SIZE_500_PLUS'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- agencies -----------------------------------------------------
ALTER TABLE agencies
    ADD COLUMN IF NOT EXISTS category      agency_category,
    ADD COLUMN IF NOT EXISTS company_size  company_size,
    ADD COLUMN IF NOT EXISTS website       VARCHAR(255),
    ADD COLUMN IF NOT EXISTS phone         VARCHAR(30),
    ADD COLUMN IF NOT EXISTS location      VARCHAR(255),
    ADD COLUMN IF NOT EXISTS brand_color   VARCHAR(9),
    ADD COLUMN IF NOT EXISTS logo_icon     VARCHAR(50),
    ADD COLUMN IF NOT EXISTS tagline       VARCHAR(140),
    ADD COLUMN IF NOT EXISTS founded_year  INTEGER,
    ADD COLUMN IF NOT EXISTS facebook_url  VARCHAR(255),
    ADD COLUMN IF NOT EXISTS linkedin_url  VARCHAR(255),
    ADD COLUMN IF NOT EXISTS instagram_url VARCHAR(255);

-- workspaces -----------------------------------------------------
ALTER TABLE workspaces
    ADD COLUMN IF NOT EXISTS industry      workspace_industry,
    ADD COLUMN IF NOT EXISTS company_size  company_size,
    ADD COLUMN IF NOT EXISTS website       VARCHAR(255),
    ADD COLUMN IF NOT EXISTS phone         VARCHAR(30),
    ADD COLUMN IF NOT EXISTS location      VARCHAR(255),
    ADD COLUMN IF NOT EXISTS description   VARCHAR(500),
    ADD COLUMN IF NOT EXISTS brand_color   VARCHAR(9),
    ADD COLUMN IF NOT EXISTS logo_icon     VARCHAR(50),
    ADD COLUMN IF NOT EXISTS logo_url      VARCHAR(255),
    ADD COLUMN IF NOT EXISTS tagline       VARCHAR(140),
    ADD COLUMN IF NOT EXISTS founded_year  INTEGER,
    ADD COLUMN IF NOT EXISTS facebook_url  VARCHAR(255),
    ADD COLUMN IF NOT EXISTS linkedin_url  VARCHAR(255),
    ADD COLUMN IF NOT EXISTS instagram_url VARCHAR(255);

-- client_profiles: linked_user_id -> user_id, + agency_id, + entity fields ---
DO $$ BEGIN
    ALTER TABLE client_profiles RENAME COLUMN linked_user_id TO user_id;
EXCEPTION WHEN undefined_column THEN NULL; END $$;

ALTER TABLE client_profiles
    ADD COLUMN IF NOT EXISTS agency_id    UUID REFERENCES agencies(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS website      VARCHAR(255),
    ADD COLUMN IF NOT EXISTS location     VARCHAR(255),
    ADD COLUMN IF NOT EXISTS description  TEXT,
    ADD COLUMN IF NOT EXISTS social_links JSONB;

-- email/brand_name no longer in entity; industry/logo_url widen to match it.
ALTER TABLE client_profiles
    DROP COLUMN IF EXISTS email,
    DROP COLUMN IF EXISTS brand_name;

ALTER TABLE client_profiles ALTER COLUMN industry TYPE VARCHAR(100);
ALTER TABLE client_profiles ALTER COLUMN logo_url TYPE VARCHAR(500);

DROP INDEX IF EXISTS idx_client_profiles_linked_user_id;
DROP INDEX IF EXISTS idx_client_profiles_email;
CREATE INDEX IF NOT EXISTS idx_client_profiles_user_id ON client_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_client_profiles_agency_id ON client_profiles(agency_id);

-- workspace_invitations.role --------------------------------------
ALTER TABLE workspace_invitations
    ADD COLUMN IF NOT EXISTS role workspace_member_role;

-- agency_invitations: note / workspace_id / role -------------------
ALTER TABLE agency_invitations
    ADD COLUMN IF NOT EXISTS note         VARCHAR(500),
    ADD COLUMN IF NOT EXISTS workspace_id UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS role         workspace_member_role;
