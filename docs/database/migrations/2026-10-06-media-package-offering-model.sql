-- Additive migration: preserve all legacy packages, snapshots and campaigns.
BEGIN;
ALTER TABLE media_packages ADD COLUMN IF NOT EXISTS offering_model VARCHAR(30);
ALTER TABLE media_packages ADD COLUMN IF NOT EXISTS offering_details JSONB;
ALTER TABLE media_campaigns ADD COLUMN IF NOT EXISTS package_terms_snapshot JSONB;
ALTER TABLE media_campaigns ADD COLUMN IF NOT EXISTS package_terms_version INT;
ALTER TABLE media_campaigns ADD COLUMN IF NOT EXISTS allocation_period VARCHAR(7);
ALTER TABLE media_campaigns ADD COLUMN IF NOT EXISTS allocations JSONB NOT NULL DEFAULT '[]';
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_media_packages_offering_model'
                   AND conrelid = 'media_packages'::regclass) THEN
        ALTER TABLE media_packages ADD CONSTRAINT chk_media_packages_offering_model
            CHECK (offering_model IN ('CAMPAIGN', 'RETAINER', 'DELIVERABLE_BUNDLE'));
    END IF;
END $$;
COMMIT;
