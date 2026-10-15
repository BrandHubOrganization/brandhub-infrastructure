-- ============================================================
-- BrandHub - PostgreSQL migration: package negotiation history
-- Date: 2026-10-13
-- Reason: DA-945, DA-946 (FR 3.5.3). Preserve negotiation history
--         and enforce terms versioning. Append-only event store.
-- ============================================================
BEGIN;

CREATE TABLE IF NOT EXISTS package_negotiation_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID NOT NULL REFERENCES workspace_media_packages(id) ON DELETE CASCADE,
    terms_version INT NOT NULL,
    action VARCHAR(30) NOT NULL,
    actor_id UUID REFERENCES users(id),
    actor_role VARCHAR(20),
    note VARCHAR(2000),
    terms_snapshot JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pkg_negotiation_events_pkg_version
    ON package_negotiation_events(workspace_media_package_id, terms_version DESC);

CREATE OR REPLACE FUNCTION prevent_package_negotiation_event_mutation()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'package_negotiation_events is append-only and cannot be updated';
    ELSIF TG_OP = 'DELETE' THEN
        IF EXISTS (SELECT 1 FROM workspace_media_packages WHERE id = OLD.workspace_media_package_id) THEN
            RAISE EXCEPTION 'package_negotiation_events is append-only and direct deletes are not allowed';
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_pkg_negotiation_events_mutation ON package_negotiation_events;
CREATE TRIGGER trg_pkg_negotiation_events_mutation
BEFORE UPDATE OR DELETE ON package_negotiation_events
FOR EACH ROW EXECUTE FUNCTION prevent_package_negotiation_event_mutation();

-- Backfill baseline for active negotiations beyond initial version
INSERT INTO package_negotiation_events (
    id, workspace_media_package_id, terms_version, action, actor_id, actor_role, note, terms_snapshot, created_at
)
SELECT
    gen_random_uuid(),
    wmp.id,
    wmp.terms_version,
    'BASELINE',
    NULL,
    NULL,
    NULL,
    wmp.final_terms,
    now()
FROM workspace_media_packages wmp
WHERE wmp.terms_version > 1
  AND NOT EXISTS (
      SELECT 1 FROM package_negotiation_events pne
      WHERE pne.workspace_media_package_id = wmp.id
  );

COMMIT;
