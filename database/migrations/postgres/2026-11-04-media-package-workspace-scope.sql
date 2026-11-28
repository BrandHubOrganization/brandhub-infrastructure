ALTER TABLE media_packages
    ADD COLUMN IF NOT EXISTS custom_workspace_id UUID REFERENCES workspaces(id) ON DELETE RESTRICT;
