-- STAGED ONLY: review/apply after repository foundation and trash migrations.
-- Never rewrite existing providers or move existing objects.
BEGIN;
CREATE TABLE IF NOT EXISTS agency_drive_connections (
 agency_id uuid PRIMARY KEY REFERENCES agencies(id),
 connection_id uuid NOT NULL UNIQUE,
 connected_by uuid NOT NULL REFERENCES users(id),
 account_id text NOT NULL,
 account_email text NOT NULL,
 refresh_token_ciphertext text NOT NULL,
 root_folder_id text NOT NULL,
 connected boolean NOT NULL DEFAULT true,
 capacity_revision bigint NOT NULL DEFAULT 0,
 quota_full_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS workspace_drive_folders (
 workspace_id uuid PRIMARY KEY REFERENCES workspaces(id),
 agency_id uuid NOT NULL REFERENCES agency_drive_connections(agency_id),
 folder_id text NOT NULL,
 ordinal bigint NOT NULL CHECK(ordinal>0),
 UNIQUE(agency_id,ordinal)
);
CREATE TABLE IF NOT EXISTS repository_drive_objects (
 object_key text PRIMARY KEY,
 agency_id uuid NOT NULL REFERENCES agency_drive_connections(agency_id),
 connection_id uuid NOT NULL,
 file_id text NOT NULL UNIQUE,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS repository_drive_states (
 state_hash text PRIMARY KEY,
 agency_id uuid NOT NULL REFERENCES agencies(id),
 workspace_id uuid NOT NULL REFERENCES workspaces(id),
 actor_id uuid NOT NULL REFERENCES users(id),
 verifier_ciphertext text NOT NULL,
 generation bigint NOT NULL DEFAULT 0,
 expires_at timestamptz NOT NULL
);
CREATE TABLE IF NOT EXISTS repository_drive_generations (
 agency_id uuid PRIMARY KEY REFERENCES agencies(id),
 generation bigint NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS repository_drive_operations (
 agency_id uuid PRIMARY KEY REFERENCES agencies(id),
 lease_token uuid NOT NULL,
 lease_until timestamptz NOT NULL
);
-- The foundation migration creates this deterministic CHECK name.
ALTER TABLE agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_provider_check;
ALTER TABLE agency_storage_reservations ADD CONSTRAINT agency_storage_reservations_provider_check
 CHECK(provider IN ('SYSTEM_GDRIVE','SYSTEM_S3','USER_GDRIVE'));
CREATE INDEX IF NOT EXISTS ix_storage_provider_capacity
 ON agency_storage_reservations(agency_id,provider,state);
CREATE INDEX IF NOT EXISTS ix_customer_drive_account ON agency_drive_connections(account_id);
CREATE INDEX IF NOT EXISTS ix_customer_drive_state_expiry ON repository_drive_states(expires_at);
COMMIT;
