-- E50-08 / DA-950: partner directory lifecycle.
-- Adds is_active, first_used_at, usage_history_verified, version to
-- third_party_collaborators. A partner becomes "used" (first_used_at + version
-- bump) the first time a campaign links it; linking an inactive partner is
-- blocked with SQLSTATE 23514.
-- Rerunnable: idempotent columns, trigger, and backfill.

ALTER TABLE third_party_collaborators
    ADD COLUMN IF NOT EXISTS is_active              BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS first_used_at          TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS usage_history_verified BOOLEAN     NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS version                BIGINT      NOT NULL DEFAULT 0;

-- Backfill partners that already have campaign links.
UPDATE third_party_collaborators p
   SET first_used_at = COALESCE(first_used_at, NOW())
 WHERE first_used_at IS NULL
   AND EXISTS (SELECT 1 FROM campaign_collaborators l WHERE l.collaborator_id = p.id);

CREATE OR REPLACE FUNCTION mark_collaborator_usage_on_link()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE active BOOLEAN;
BEGIN
    SELECT is_active INTO active
      FROM third_party_collaborators
     WHERE id = NEW.collaborator_id
     FOR UPDATE;
    IF active IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'collaborator does not exist';
    END IF;
    IF NOT active THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'collaborator is inactive';
    END IF;
    UPDATE third_party_collaborators
       SET first_used_at = COALESCE(first_used_at, NOW()),
           version = version + 1
     WHERE id = NEW.collaborator_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_campaign_collaborator_mark_used ON campaign_collaborators;
CREATE TRIGGER trg_campaign_collaborator_mark_used
BEFORE INSERT ON campaign_collaborators
FOR EACH ROW EXECUTE FUNCTION mark_collaborator_usage_on_link();
