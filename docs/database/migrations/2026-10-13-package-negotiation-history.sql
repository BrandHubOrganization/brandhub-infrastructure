-- DA-945. Backup and pause Package writers before rollout; never invent lost negotiation rounds.
BEGIN;
LOCK TABLE workspace_media_packages IN SHARE ROW EXCLUSIVE MODE;
CREATE TABLE IF NOT EXISTS package_negotiation_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_media_package_id UUID NOT NULL REFERENCES workspace_media_packages(id) ON DELETE CASCADE,
    terms_version INTEGER NOT NULL CHECK (terms_version >= 1),
    action VARCHAR(30) NOT NULL CHECK (action IN ('BASELINE','REQUEST_CHANGE','COUNTER_OFFER')),
    actor_id UUID,
    actor_role VARCHAR(20),
    note VARCHAR(2000),
    terms_snapshot JSONB NOT NULL CHECK (jsonb_typeof(terms_snapshot) = 'object'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_media_package_id, terms_version),
    CHECK ((action = 'BASELINE' AND actor_id IS NULL AND actor_role IS NULL)
        OR (action = 'REQUEST_CHANGE' AND actor_id IS NOT NULL AND actor_role = 'CLIENT')
        OR (action = 'COUNTER_OFFER' AND actor_id IS NOT NULL AND actor_role IN ('OWNER','MANAGER')))
);
CREATE INDEX IF NOT EXISTS idx_package_negotiation_history
    ON package_negotiation_events(workspace_media_package_id, terms_version DESC);

CREATE OR REPLACE FUNCTION guard_package_negotiation_history() RETURNS TRIGGER AS $$
BEGIN
    -- Preserve existing parent hard-delete cascades without opening direct event deletion.
    IF TG_OP = 'DELETE' AND pg_trigger_depth() > 1 THEN RETURN OLD; END IF;
    RAISE EXCEPTION 'Package negotiation history is append-only' USING ERRCODE = '23514';
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trg_package_negotiation_immutable ON package_negotiation_events;
CREATE TRIGGER trg_package_negotiation_immutable BEFORE UPDATE OR DELETE ON package_negotiation_events
    FOR EACH ROW EXECUTE FUNCTION guard_package_negotiation_history();

INSERT INTO package_negotiation_events(workspace_media_package_id,terms_version,action,terms_snapshot)
SELECT p.id,p.terms_version,'BASELINE',p.final_terms FROM workspace_media_packages p
WHERE p.negotiation_status <> 'DRAFT'
    AND NOT EXISTS (SELECT 1 FROM package_negotiation_events e WHERE e.workspace_media_package_id=p.id);
COMMIT;
