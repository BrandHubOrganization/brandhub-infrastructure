-- Count only Client-submitted negotiation proposals. Manager/Owner counteroffers
-- still increment terms_version but do not consume this allowance.
BEGIN;
ALTER TABLE workspace_media_packages
    ADD COLUMN IF NOT EXISTS client_proposal_count INT NOT NULL DEFAULT 0;
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                   WHERE conname = 'chk_workspace_media_packages_client_proposal_count') THEN
        ALTER TABLE workspace_media_packages
            ADD CONSTRAINT chk_workspace_media_packages_client_proposal_count
            CHECK (client_proposal_count >= 0);
    END IF;
END $$;
COMMIT;
