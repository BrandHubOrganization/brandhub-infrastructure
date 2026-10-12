-- DA-947: run after the package offering/proposal migrations. No data is deleted.
BEGIN;
LOCK TABLE media_campaigns IN SHARE ROW EXCLUSIVE MODE;
DO $$
DECLARE conflicts TEXT;
BEGIN
    SELECT string_agg(workspace_media_package_id::text, ', ') INTO conflicts
    FROM (SELECT workspace_media_package_id FROM media_campaigns
          GROUP BY workspace_media_package_id HAVING count(*) > 1) duplicates;
    IF conflicts IS NOT NULL THEN
        RAISE EXCEPTION 'Multiple campaigns exist for agreements: %. Resolve explicitly before migration.', conflicts;
    END IF;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS uq_media_campaigns_agreement
    ON media_campaigns(workspace_media_package_id);
ALTER TABLE media_campaigns
    ADD COLUMN IF NOT EXISTS deliverable_plan JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS work_items JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS content_version INT NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS row_version BIGINT NOT NULL DEFAULT 0;
-- Legacy drafts retain empty deliverable_plan and are read-only until reviewed.
-- Never reinterpret monthly snapshots or overwrite historical allocations.
COMMIT;
