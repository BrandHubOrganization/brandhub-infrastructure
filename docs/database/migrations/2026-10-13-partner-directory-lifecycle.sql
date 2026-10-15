-- ============================================================
-- BrandHub - PostgreSQL migration: partner directory lifecycle controls
-- Date: 2026-10-13
-- Reason: DA-949, DA-950 (FR 3.5.1, 3.5.2). Partner directory management,
--         optimistic locking, active status, first_used_at protection.
-- ============================================================
BEGIN;

ALTER TABLE third_party_collaborators
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS first_used_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS usage_history_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS version BIGINT NOT NULL DEFAULT 0;

-- Backfill first_used_at from existing campaign links
UPDATE third_party_collaborators t
SET first_used_at = c.min_used
FROM (
    SELECT collaborator_id, MIN(COALESCE(updated_at, now())) AS min_used
    FROM campaign_collaborators
    GROUP BY collaborator_id
) c
WHERE t.id = c.collaborator_id AND t.first_used_at IS NULL;

-- Guard function preventing assignment of inactive partners and durable first_used_at marking
CREATE OR REPLACE FUNCTION guard_campaign_partner_usage()
RETURNS TRIGGER AS $$
DECLARE
    v_is_active BOOLEAN;
    v_first_used_at TIMESTAMPTZ;
BEGIN
    IF NEW.collaborator_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT is_active, first_used_at INTO v_is_active, v_first_used_at
    FROM third_party_collaborators
    WHERE id = NEW.collaborator_id
    FOR UPDATE;

    IF v_is_active IS NULL THEN
        RAISE EXCEPTION 'Collaborator not found' USING ERRCODE = 'check_violation';
    END IF;

    IF NOT v_is_active THEN
        RAISE EXCEPTION 'Inactive collaborator cannot be assigned to campaign' USING ERRCODE = 'check_violation';
    END IF;

    IF v_first_used_at IS NULL THEN
        UPDATE third_party_collaborators
        SET first_used_at = now(),
            version = version + 1
        WHERE id = NEW.collaborator_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_guard_campaign_partner_usage ON campaign_collaborators;
CREATE TRIGGER trg_guard_campaign_partner_usage
BEFORE INSERT OR UPDATE OF collaborator_id ON campaign_collaborators
FOR EACH ROW EXECUTE FUNCTION guard_campaign_partner_usage();

COMMIT;
