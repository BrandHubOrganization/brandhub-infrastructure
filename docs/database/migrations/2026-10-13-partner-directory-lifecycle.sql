-- DA-949 / DA-950. Stop application writers during rollout; run before deploying new binaries.
-- Legacy rows remain history-unverified, including those with no surviving Campaign links.
BEGIN;
LOCK TABLE third_party_collaborators, campaign_collaborators IN SHARE ROW EXCLUSIVE MODE;
ALTER TABLE third_party_collaborators
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS first_used_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS usage_history_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS version BIGINT NOT NULL DEFAULT 0;

UPDATE third_party_collaborators p
SET first_used_at = history.first_seen, version = p.version + 1
FROM (SELECT collaborator_id, MIN(updated_at) AS first_seen
      FROM campaign_collaborators GROUP BY collaborator_id) history
WHERE p.id = history.collaborator_id AND p.first_used_at IS NULL;

CREATE OR REPLACE FUNCTION guard_campaign_partner_usage() RETURNS TRIGGER AS $$
DECLARE partner_active BOOLEAN;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.collaborator_id = OLD.collaborator_id THEN
        RETURN NEW;
    END IF;
    SELECT is_active INTO partner_active FROM third_party_collaborators
    WHERE id = NEW.collaborator_id FOR UPDATE;
    IF partner_active IS FALSE THEN
        RAISE EXCEPTION 'Inactive collaborator cannot be assigned' USING ERRCODE = '23514';
    END IF;
    UPDATE third_party_collaborators
    SET first_used_at = CURRENT_TIMESTAMP, version = version + 1
    WHERE id = NEW.collaborator_id AND first_used_at IS NULL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_campaign_partner_usage ON campaign_collaborators;
CREATE TRIGGER trg_campaign_partner_usage
    BEFORE INSERT OR UPDATE OF collaborator_id ON campaign_collaborators
    FOR EACH ROW EXECUTE FUNCTION guard_campaign_partner_usage();
COMMIT;
