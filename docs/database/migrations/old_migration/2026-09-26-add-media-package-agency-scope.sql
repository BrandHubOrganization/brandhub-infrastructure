-- ============================================================
-- BrandHub — Migration: scope custom media packages to an Agency
-- Date: 2026-09-26
-- Reason: DA-E50-01 stores both global Admin templates and Agency-custom
--         packages in media_packages. Templates must have no agency_id;
--         custom packages must belong to exactly one Agency.
--
-- Idempotent: safe to run repeatedly on an existing V2 database.
--
-- Existing rows are not rewritten because their owning Agency cannot be
-- inferred safely. The NOT VALID check protects every new/updated row;
-- normalize legacy rows before validating it with:
--   ALTER TABLE media_packages
--     VALIDATE CONSTRAINT chk_media_packages_template_agency_scope;
-- ============================================================

ALTER TABLE media_packages
    ADD COLUMN IF NOT EXISTS agency_id UUID;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_media_packages_agency'
          AND conrelid = 'media_packages'::regclass
    ) THEN
        ALTER TABLE media_packages
            ADD CONSTRAINT fk_media_packages_agency
            FOREIGN KEY (agency_id) REFERENCES agencies(id) ON DELETE RESTRICT;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_media_packages_agency_id
    ON media_packages(agency_id);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_media_packages_template_agency_scope'
          AND conrelid = 'media_packages'::regclass
    ) THEN
        ALTER TABLE media_packages
            ADD CONSTRAINT chk_media_packages_template_agency_scope CHECK (
                (is_template AND agency_id IS NULL)
                OR (NOT is_template AND agency_id IS NOT NULL)
            ) NOT VALID;
    END IF;
END $$;
