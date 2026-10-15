-- DA-948: durable Campaign review history and two-party versioned approvals.
BEGIN;
ALTER TABLE media_campaigns
    ADD COLUMN IF NOT EXISTS approved_by_agency_id UUID,
    ADD COLUMN IF NOT EXISTS approved_by_agency_version INT,
    ADD COLUMN IF NOT EXISTS approved_by_client_id UUID,
    ADD COLUMN IF NOT EXISTS approved_by_client_version INT;

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
COMMIT;
