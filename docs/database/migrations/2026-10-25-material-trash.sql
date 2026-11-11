-- Stage only; apply via the normal migration process before enabling Trash writes/purge.
BEGIN;
CREATE TABLE IF NOT EXISTS material_quota_releases (
    material_id varchar(64) PRIMARY KEY,
    agency_id uuid NOT NULL REFERENCES agencies(id),
    workspace_id uuid NOT NULL REFERENCES workspaces(id),
    released_bytes bigint NOT NULL CHECK (released_bytes >= 0),
    released_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_material_releases_date ON material_quota_releases(released_at);
CREATE TABLE IF NOT EXISTS material_audit_receipts (
    event_id varchar(160) PRIMARY KEY,
    delivered_at timestamptz NOT NULL DEFAULT now()
);
COMMIT;
