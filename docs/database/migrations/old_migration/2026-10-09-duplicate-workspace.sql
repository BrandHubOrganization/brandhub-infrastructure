ALTER TABLE workspaces
    ADD COLUMN IF NOT EXISTS source_workspace_id UUID,
    ADD COLUMN IF NOT EXISTS duplication_request_id UUID,
    ADD COLUMN IF NOT EXISTS duplication_fingerprint UUID;

CREATE UNIQUE INDEX IF NOT EXISTS uq_workspaces_duplication_request
    ON workspaces(agency_id, duplication_request_id)
    WHERE duplication_request_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_workspaces_source_workspace
    ON workspaces(source_workspace_id)
    WHERE source_workspace_id IS NOT NULL;
