-- DA-E50-04: append-only package negotiation history.
-- Requires the terms-version migration. Run with psql -v ON_ERROR_STOP=1 -1.
-- Rerunnable: preserve existing history, baseline only non-draft selections
-- without history. A baseline is current known state, not reconstructed events.
CREATE TABLE IF NOT EXISTS package_negotiation_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID NOT NULL
        REFERENCES workspace_media_packages(id) ON DELETE CASCADE,
    terms_version INT NOT NULL CHECK (terms_version > 0),
    action VARCHAR(30) NOT NULL
        CHECK (action IN ('BASELINE', 'REQUEST_CHANGE', 'COUNTER_OFFER')),
    actor_id UUID,
    actor_role VARCHAR(20),
    note VARCHAR(2000),
    terms_snapshot JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_package_negotiation_events_version
        UNIQUE (workspace_media_package_id, terms_version)
);

CREATE OR REPLACE FUNCTION protect_package_negotiation_history()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE parent_exists BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Permit FK cascade only after the parent selection has been deleted.
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I.workspace_media_packages WHERE id = $1)',
                       TG_TABLE_SCHEMA)
            INTO parent_exists USING OLD.workspace_media_package_id;
        IF NOT parent_exists THEN
            RETURN OLD;
        END IF;
    END IF;
    RAISE EXCEPTION 'package_negotiation_events is append-only';
END;
$$;

DROP TRIGGER IF EXISTS trg_package_negotiation_events_append_only ON package_negotiation_events;
CREATE TRIGGER trg_package_negotiation_events_append_only
BEFORE UPDATE OR DELETE ON package_negotiation_events
FOR EACH ROW EXECUTE FUNCTION protect_package_negotiation_history();

INSERT INTO package_negotiation_events (
    workspace_media_package_id, terms_version, action, terms_snapshot
)
SELECT p.id, p.terms_version, 'BASELINE', p.final_terms
FROM workspace_media_packages p
WHERE p.negotiation_status <> 'DRAFT'
  AND NOT EXISTS (
      SELECT 1 FROM package_negotiation_events e
      WHERE e.workspace_media_package_id = p.id
  )
ON CONFLICT (workspace_media_package_id, terms_version) DO NOTHING;
