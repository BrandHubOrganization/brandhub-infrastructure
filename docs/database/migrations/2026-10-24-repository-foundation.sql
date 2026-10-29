-- Repository expansion only. Run through repository-migrate.ps1 (dry-run by default).
-- No object inventory, paid catalog changes, or production activation are performed here.
BEGIN;

CREATE TABLE IF NOT EXISTS agency_storage_usage (
    agency_id uuid PRIMARY KEY REFERENCES agencies(id),
    used_bytes bigint NOT NULL DEFAULT 0 CHECK (used_bytes >= 0),
    reserved_bytes bigint NOT NULL DEFAULT 0 CHECK (reserved_bytes >= 0),
    inventory_verified_at timestamptz,
    version bigint NOT NULL DEFAULT 0,
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS system_storage_pools (
    provider varchar(32) PRIMARY KEY CHECK (provider = 'SYSTEM_GDRIVE'),
    capacity_bytes bigint NOT NULL CHECK (capacity_bytes > 0),
    physical_used_bytes bigint NOT NULL DEFAULT 0 CHECK (physical_used_bytes >= 0),
    reserved_peak_bytes bigint NOT NULL DEFAULT 0 CHECK (reserved_peak_bytes >= 0),
    observed_at timestamptz,
    version bigint NOT NULL DEFAULT 0,
    updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO system_storage_pools(provider,capacity_bytes)
VALUES ('SYSTEM_GDRIVE',5000000000000) ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS agency_storage_reservations (
    id uuid PRIMARY KEY,
    agency_id uuid NOT NULL REFERENCES agencies(id),
    workspace_id uuid NOT NULL REFERENCES workspaces(id),
    actor_id uuid NOT NULL REFERENCES users(id),
    material_id varchar(64) NOT NULL UNIQUE,
    request_key varchar(128) NOT NULL,
    fingerprint varchar(64) NOT NULL,
    provider varchar(32) NOT NULL CHECK (provider IN ('SYSTEM_GDRIVE','SYSTEM_S3')),
    reserved_bytes bigint NOT NULL CHECK (reserved_bytes > 0),
    committed_bytes bigint CHECK (committed_bytes >= 0 AND committed_bytes <= reserved_bytes),
    derivative boolean NOT NULL DEFAULT false,
    state varchar(16) NOT NULL CHECK (state IN ('RESERVED','COMMITTED','RELEASED','EXPIRED')),
    phase varchar(24) NOT NULL DEFAULT 'CREATED',
    pool_hold_bytes bigint NOT NULL DEFAULT 0 CHECK (pool_hold_bytes >= 0),
    staging_cleaned_at timestamptz,
    claim_token uuid,
    claim_until timestamptz,
    expires_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(agency_id,actor_id,request_key)
);
ALTER TABLE agency_storage_reservations ADD COLUMN IF NOT EXISTS staging_cleaned_at timestamptz;
CREATE INDEX IF NOT EXISTS idx_storage_res_expiry ON agency_storage_reservations(state,expires_at);
CREATE INDEX IF NOT EXISTS idx_storage_res_agency ON agency_storage_reservations(agency_id,state);

CREATE TABLE IF NOT EXISTS storage_usage_entries (
    id uuid PRIMARY KEY,
    operation_key varchar(160) NOT NULL UNIQUE,
    agency_id uuid NOT NULL REFERENCES agencies(id),
    workspace_id uuid NOT NULL REFERENCES workspaces(id),
    reservation_id uuid NOT NULL REFERENCES agency_storage_reservations(id),
    material_id varchar(64) NOT NULL,
    kind varchar(24) NOT NULL CHECK (kind IN ('RESERVE','COMMIT','RELEASE','EXPIRE','PURGE_RELEASE')),
    used_delta bigint NOT NULL,
    reserved_delta bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_storage_entries_scope ON storage_usage_entries(agency_id,workspace_id);

-- Existing agencies are intentionally NOT marked inventoried. Backfill must verify
-- existing binary/derived/trash usage before setting inventory_verified_at.
INSERT INTO agency_storage_usage(agency_id) SELECT id FROM agencies ON CONFLICT DO NOTHING;
UPDATE billing_plan_versions SET storage_limit_bytes=21474836480 WHERE code='BASIC';
COMMIT;
