-- Durable cancellation of PENDING Requests after Manager completes a Campaign.
-- No existing Campaigns/Requests are changed or backfilled.
BEGIN;
CREATE TABLE IF NOT EXISTS content_request_completion_jobs (
    campaign_id UUID PRIMARY KEY REFERENCES media_campaigns(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMIT;
