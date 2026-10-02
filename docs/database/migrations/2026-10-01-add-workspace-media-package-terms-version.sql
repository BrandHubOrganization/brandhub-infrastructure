-- ============================================================
-- BrandHub — Migration: version Workspace Media Package terms
-- Date: 2026-10-01
-- Reason: DA-E50-03 tracks the exact terms revision that later
--         Agency and Client approvals apply to.
--
-- Idempotent: safe to run repeatedly on an existing V2 database.
-- ============================================================

ALTER TABLE workspace_media_packages
    ADD COLUMN IF NOT EXISTS terms_version INT;

UPDATE workspace_media_packages
SET terms_version = 1
WHERE terms_version IS NULL;

ALTER TABLE workspace_media_packages
    ALTER COLUMN terms_version SET DEFAULT 1,
    ALTER COLUMN terms_version SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_workspace_media_packages_terms_version_positive'
          AND conrelid = 'workspace_media_packages'::regclass
    ) THEN
        ALTER TABLE workspace_media_packages
            ADD CONSTRAINT chk_workspace_media_packages_terms_version_positive
            CHECK (terms_version > 0);
    END IF;
END $$;
