-- Manager-led workspace package preparation and controlled guest sharing.
-- Additive upgrade only: no seed, reset, approval backfill or data deletion.
BEGIN;
DO $$ BEGIN
    IF to_regclass('public.media_packages') IS NULL OR to_regclass('public.workspace_media_packages') IS NULL
        OR to_regclass('public.media_campaigns') IS NULL THEN
        RAISE EXCEPTION 'Apply media package/campaign baseline first';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public'
        AND table_name='media_packages' AND column_name='custom_workspace_id') THEN
        RAISE EXCEPTION 'Apply 2026-11-04-media-package-workspace-scope.sql first';
    END IF;
    IF EXISTS (SELECT 1 FROM media_campaigns GROUP BY workspace_media_package_id HAVING count(*) > 1) THEN
        RAISE EXCEPTION 'Duplicate campaigns per agreement; resolve before migration';
    END IF;
END $$;
ALTER TABLE media_packages
    ADD COLUMN IF NOT EXISTS share_token VARCHAR(64),
    ADD COLUMN IF NOT EXISTS share_enabled BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE workspace_media_packages
    ADD COLUMN IF NOT EXISTS share_token VARCHAR(64),
    ADD COLUMN IF NOT EXISTS share_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS manager_led BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS preparation_status VARCHAR(16) NOT NULL DEFAULT 'LEGACY',
    ADD COLUMN IF NOT EXISTS preparation_actor_id UUID,
    ADD COLUMN IF NOT EXISTS preparation_lease UUID,
    ADD COLUMN IF NOT EXISTS preparation_lease_until TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS preparation_error VARCHAR(64),
    ADD COLUMN IF NOT EXISTS last_request_id UUID,
    ADD COLUMN IF NOT EXISTS last_request_hash VARCHAR(64);
CREATE UNIQUE INDEX IF NOT EXISTS uq_media_packages_share_token ON media_packages(share_token);
CREATE UNIQUE INDEX IF NOT EXISTS uq_workspace_media_packages_share_token ON workspace_media_packages(share_token);
CREATE INDEX IF NOT EXISTS idx_workspace_package_preparation ON workspace_media_packages(preparation_status, preparation_lease_until)
    WHERE preparation_status IN ('PENDING','PROCESSING');
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='workspace_media_packages'::regclass AND conname='chk_package_preparation_status') THEN
        ALTER TABLE workspace_media_packages ADD CONSTRAINT chk_package_preparation_status
            CHECK (preparation_status IN ('LEGACY','PENDING','PROCESSING','READY','FAILED','DEPLOYING','DEPLOYED'));
    END IF;
END $$;

-- Preserve legacy history actions and add an explicit manager save (not a counter-offer).
ALTER TABLE package_negotiation_events DROP CONSTRAINT IF EXISTS package_negotiation_events_action_check;
ALTER TABLE package_negotiation_events ADD CONSTRAINT package_negotiation_events_action_check
    CHECK (action IN ('BASELINE','REQUEST_CHANGE','COUNTER_OFFER','MANAGER_SAVE'));
DO $$ DECLARE c RECORD; BEGIN
    FOR c IN SELECT conname FROM pg_constraint WHERE conrelid='package_negotiation_events'::regclass
        AND contype='c' AND pg_get_constraintdef(oid) LIKE '%actor_role%' LOOP
        EXECUTE format('ALTER TABLE package_negotiation_events DROP CONSTRAINT %I', c.conname);
    END LOOP;
END $$;
ALTER TABLE package_negotiation_events ADD CONSTRAINT chk_package_event_actor
    CHECK ((action='BASELINE' AND actor_id IS NULL AND actor_role IS NULL)
        OR (action='REQUEST_CHANGE' AND actor_id IS NOT NULL AND actor_role='CLIENT')
        OR (action IN ('COUNTER_OFFER','MANAGER_SAVE') AND actor_id IS NOT NULL AND actor_role IN ('OWNER','MANAGER')));
COMMIT;
