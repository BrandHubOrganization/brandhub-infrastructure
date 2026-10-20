-- Add/View hashtag collection. Apply before restarting Business (ddl-auto=validate).
CREATE TABLE IF NOT EXISTS workspace_hashtags (
    id UUID PRIMARY KEY,
    workspace_id UUID NOT NULL REFERENCES workspaces(id),
    tag VARCHAR(100) NOT NULL,
    normalized_tag VARCHAR(100) NOT NULL,
    purpose VARCHAR(30) NOT NULL CHECK (purpose IN ('BRAND','CAMPAIGN','TRENDING','EVENT_SPECIFIC')),
    added_by UUID NOT NULL REFERENCES users(id),
    added_by_name VARCHAR(255) NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT FALSE,
    campaign_id UUID REFERENCES media_campaigns(id),
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    version BIGINT NOT NULL DEFAULT 0
);
ALTER TABLE workspace_hashtags
    ADD COLUMN IF NOT EXISTS campaign_id UUID REFERENCES media_campaigns(id);
ALTER TABLE workspace_hashtags
    ADD COLUMN IF NOT EXISTS deleted_by UUID REFERENCES users(id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_workspace_hashtags_active_tag
    ON workspace_hashtags(workspace_id, normalized_tag) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_workspace_hashtags_list
    ON workspace_hashtags(workspace_id, created_at DESC, id DESC) WHERE deleted_at IS NULL;
