-- Campaign Brief, Execution Strategy & Partner Collaboration schema verification/upgrade.
-- Additive only: preserves all existing campaign, timeline, brief, and collaborator records. Safe to run twice.
BEGIN;

ALTER TABLE IF EXISTS media_campaigns
    ADD COLUMN IF NOT EXISTS strategy_detail TEXT,
    ADD COLUMN IF NOT EXISTS brand_guideline TEXT,
    ADD COLUMN IF NOT EXISTS timeline JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Structured campaign brief fields (formats, concept, objectives, channels, audiences, generatedBrief)
-- live inside media_campaigns.timeline->'brief'; GIN indexing keeps brief/date queries fast.
CREATE INDEX IF NOT EXISTS idx_media_campaigns_timeline_gin
    ON media_campaigns USING GIN (timeline);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'collaborator_type') THEN
        CREATE TYPE collaborator_type AS ENUM ('NEWSPAPER', 'BANNER', 'TV', 'OTHER');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'cooperation_status') THEN
        CREATE TYPE cooperation_status AS ENUM ('CONTACTED', 'NEGOTIATING', 'CONFIRMED', 'LIVE');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS third_party_collaborators (
    id           UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id    UUID              NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
    partner_name VARCHAR(255)      NOT NULL,
    type         collaborator_type NOT NULL DEFAULT 'OTHER',
    contact_info JSONB             NOT NULL DEFAULT '{}'::jsonb,
    notes        TEXT,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    first_used_at TIMESTAMPTZ,
    version      INTEGER           NOT NULL DEFAULT 1,
    created_at   TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_collaborators_agency_id
    ON third_party_collaborators (agency_id);

CREATE TABLE IF NOT EXISTS campaign_collaborators (
    id                 UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    media_campaign_id  UUID               NOT NULL REFERENCES media_campaigns(id) ON DELETE CASCADE,
    collaborator_id    UUID               NOT NULL REFERENCES third_party_collaborators(id) ON DELETE RESTRICT,
    cooperation_status cooperation_status NOT NULL DEFAULT 'CONTACTED',
    updated_by         UUID               REFERENCES users(id) ON DELETE SET NULL,
    updated_at         TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
    UNIQUE (media_campaign_id, collaborator_id)
);

COMMIT;
