-- BrandHub — Agency Media Package catalog
--
-- System templates remain global reference records. Agency Owners create an
-- independent Agency package, optionally cloned from a template, and control
-- whether that package is offered to Clients in Agency Workspaces.

ALTER TABLE media_packages
    ADD COLUMN IF NOT EXISTS source_template_id UUID,
    ADD COLUMN IF NOT EXISTS is_available_to_workspaces BOOLEAN;

UPDATE media_packages
SET is_available_to_workspaces = TRUE
WHERE is_available_to_workspaces IS NULL;

ALTER TABLE media_packages
    ALTER COLUMN is_available_to_workspaces SET DEFAULT TRUE,
    ALTER COLUMN is_available_to_workspaces SET NOT NULL;

DO $$ BEGIN
    ALTER TABLE media_packages
        ADD CONSTRAINT fk_media_packages_source_template
        FOREIGN KEY (source_template_id) REFERENCES media_packages(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    ALTER TABLE media_packages
        ADD CONSTRAINT chk_media_packages_template_source
        CHECK (source_template_id IS NULL OR NOT is_template);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_media_packages_agency_available
    ON media_packages(agency_id, is_available_to_workspaces)
    WHERE NOT is_template;
