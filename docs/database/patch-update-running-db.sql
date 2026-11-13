-- =============================================================================
-- Patch: Update Running PostgreSQL Container Without Deleting Volumes
-- Run this directly into brandhub-postgres container:
--   Get-Content brandhub-infrastructure\docs\database\patch-update-running-db.sql | docker exec -i brandhub-postgres psql -U brandhub -d brandhub
-- =============================================================================

BEGIN;

-- 1. Storage columns & verification (Fixes 503 SCHEMA_NOT_READY and 500 column owner_user_id does not exist)
ALTER TABLE agency_storage_reservations
ADD COLUMN IF NOT EXISTS owner_user_id uuid REFERENCES users (id);

ALTER TABLE storage_usage_entries
ADD COLUMN IF NOT EXISTS owner_user_id uuid REFERENCES users (id);

UPDATE agency_storage_usage
SET
    inventory_verified_at = now()
WHERE
    inventory_verified_at IS NULL;

-- 2. Drop retired demo seed runs table
DROP TABLE IF EXISTS public.seed_runs;

-- 3. Product video durable coordinator tables
CREATE TABLE IF NOT EXISTS product_video_productions (
    id UUID PRIMARY KEY,
    workspace_id UUID NOT NULL REFERENCES workspaces (id),
    owner_id UUID NOT NULL REFERENCES users (id),
    agency_id UUID NOT NULL REFERENCES agencies (id),
    project_id UUID NOT NULL,
    state VARCHAR(32) NOT NULL DEFAULT 'PLAN_READY' CHECK (
        state IN (
            'NEEDS_INPUT',
            'PLAN_READY',
            'GENERATING',
            'RECONCILIATION_REQUIRED',
            'SCENE_FAILED',
            'EDITING',
            'VALIDATING',
            'RENDER_FAILED',
            'COMPLETED'
        )
    ),
    revision INTEGER NOT NULL DEFAULT 0 CHECK (revision >= 0),
    render_id UUID,
    output_key TEXT,
    output_sha256 CHAR(64),
    output_size BIGINT NOT NULL DEFAULT 0 CHECK (output_size >= 0),
    error_code VARCHAR(80),
    lease_token UUID,
    lease_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (
        state <> 'COMPLETED'
        OR (
            output_key IS NOT NULL
            AND output_sha256 IS NOT NULL
            AND output_size > 0
        )
    )
);

CREATE TABLE IF NOT EXISTS product_video_plans (
    production_id UUID NOT NULL REFERENCES product_video_productions (id),
    revision INTEGER NOT NULL CHECK (revision > 0),
    plan_hash CHAR(64) NOT NULL CHECK (plan_hash ~ '^[a-f0-9]{64}$'),
    plan_json JSONB NOT NULL CHECK (
        octet_length(plan_json::text) <= 262144
    ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (production_id, revision)
);

CREATE TABLE IF NOT EXISTS product_video_quotes (
    id UUID PRIMARY KEY,
    production_id UUID NOT NULL,
    revision INTEGER NOT NULL,
    scene_id UUID,
    price_id UUID NOT NULL REFERENCES ai_credit_operation_prices (id),
    unit_credits BIGINT NOT NULL CHECK (unit_credits >= 0),
    units INTEGER NOT NULL CHECK (units BETWEEN 1 AND 3),
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_key VARCHAR(128),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (production_id, revision) REFERENCES product_video_plans (production_id, revision),
    CHECK (
        scene_id IS NULL
        OR units = 1
    )
);

CREATE TABLE IF NOT EXISTS product_video_attempts (
    id UUID PRIMARY KEY,
    production_id UUID NOT NULL,
    revision INTEGER NOT NULL,
    scene_id UUID NOT NULL,
    attempt INTEGER NOT NULL CHECK (attempt > 0),
    reservation_id UUID NOT NULL UNIQUE REFERENCES ai_credit_reservations (id),
    payload_hash CHAR(64) NOT NULL CHECK (
        payload_hash ~ '^[a-f0-9]{64}$'
    ),
    state VARCHAR(24) NOT NULL DEFAULT 'READY' CHECK (
        state IN (
            'READY',
            'SUBMITTING',
            'PROCESSING',
            'SUBMISSION_UNKNOWN',
            'COMPLETED',
            'FAILED'
        )
    ),
    s3_key TEXT,
    sha256 CHAR(64),
    file_size BIGINT CHECK (file_size >= 0),
    error_code VARCHAR(80),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    FOREIGN KEY (production_id, revision) REFERENCES product_video_plans (production_id, revision),
    UNIQUE (
        production_id,
        scene_id,
        attempt
    ),
    CHECK (
        state <> 'COMPLETED'
        OR (
            s3_key IS NOT NULL
            AND sha256 IS NOT NULL
            AND file_size > 0
        )
    )
);

CREATE TABLE IF NOT EXISTS product_video_requests (
    workspace_id UUID NOT NULL REFERENCES workspaces (id),
    owner_id UUID NOT NULL REFERENCES users (id),
    request_key VARCHAR(128) NOT NULL,
    production_id UUID NOT NULL REFERENCES product_video_productions (id),
    request_hash CHAR(64) NOT NULL CHECK (
        request_hash ~ '^[a-f0-9]{64}$'
    ),
    quote_id UUID UNIQUE REFERENCES product_video_quotes (id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (
        workspace_id,
        owner_id,
        request_key
    )
);

CREATE INDEX IF NOT EXISTS idx_product_video_owner ON product_video_productions (
    workspace_id,
    owner_id,
    created_at DESC
);

CREATE INDEX IF NOT EXISTS idx_product_video_pending ON product_video_productions (updated_at)
WHERE
    state IN (
        'GENERATING',
        'RECONCILIATION_REQUIRED',
        'EDITING',
        'VALIDATING'
    );

CREATE INDEX IF NOT EXISTS idx_product_video_quote ON product_video_quotes (
    production_id,
    revision,
    created_at DESC
);

CREATE INDEX IF NOT EXISTS idx_product_video_attempt ON product_video_attempts (
    production_id,
    scene_id,
    attempt DESC
);

-- 4. Media packages workspace scope & sharing
ALTER TABLE media_packages
ADD COLUMN IF NOT EXISTS custom_workspace_id UUID REFERENCES workspaces (id) ON DELETE RESTRICT;

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

CREATE UNIQUE INDEX IF NOT EXISTS uq_media_packages_share_token ON media_packages (share_token);

CREATE UNIQUE INDEX IF NOT EXISTS uq_workspace_media_packages_share_token ON workspace_media_packages (share_token);

CREATE INDEX IF NOT EXISTS idx_workspace_package_preparation ON workspace_media_packages (
    preparation_status,
    preparation_lease_until
)
WHERE
    preparation_status IN ('PENDING', 'PROCESSING');

-- 5. Storage add-on and client vault tables
CREATE TABLE IF NOT EXISTS storage_addon_plans (
    code text PRIMARY KEY,
    extra_bytes bigint NOT NULL CHECK (extra_bytes > 0),
    price_monthly numeric(18, 0) NOT NULL CHECK (price_monthly > 0),
    active boolean NOT NULL DEFAULT true
);

INSERT INTO
    storage_addon_plans (
        code,
        extra_bytes,
        price_monthly
    )
VALUES (
        'S3_ADDON_25GB',
        26843545600,
        49000
    ),
    (
        'S3_ADDON_100GB',
        107374182400,
        149000
    ),
    (
        'S3_ADDON_500GB',
        536870912000,
        499000
    )
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS storage_addon_subscriptions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    agency_id uuid REFERENCES agencies (id),
    owner_user_id uuid REFERENCES users (id),
    plan_code text NOT NULL REFERENCES storage_addon_plans (code),
    extra_bytes bigint NOT NULL CHECK (extra_bytes > 0),
    order_id uuid NOT NULL UNIQUE REFERENCES billing_orders (id),
    status text NOT NULL CHECK (
        status IN (
            'ACTIVE',
            'EXPIRED',
            'CANCELLED'
        )
    ),
    current_period_start timestamptz NOT NULL,
    current_period_end timestamptz NOT NULL,
    CHECK (
        (agency_id IS NULL) <> (owner_user_id IS NULL)
    ),
    CHECK (
        current_period_end > current_period_start
    )
);

CREATE INDEX IF NOT EXISTS idx_storage_addon_agency ON storage_addon_subscriptions (agency_id, current_period_end)
WHERE
    status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_storage_addon_client ON storage_addon_subscriptions (
    owner_user_id,
    current_period_end
)
WHERE
    status = 'ACTIVE';

CREATE TABLE IF NOT EXISTS client_vault_storage_usage (
    user_id uuid PRIMARY KEY REFERENCES users (id),
    used_bytes bigint NOT NULL DEFAULT 0 CHECK (used_bytes >= 0),
    reserved_bytes bigint NOT NULL DEFAULT 0 CHECK (reserved_bytes >= 0),
    version bigint NOT NULL DEFAULT 0,
    inventory_verified_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS client_vault_quota_releases (
    material_id text PRIMARY KEY,
    owner_user_id uuid NOT NULL REFERENCES users (id),
    released_bytes bigint NOT NULL CHECK (released_bytes >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS repository_vault_migration_receipts (
    material_id text PRIMARY KEY,
    agency_id uuid NOT NULL REFERENCES agencies (id),
    owner_user_id uuid NOT NULL REFERENCES users (id),
    transferred_bytes bigint NOT NULL CHECK (transferred_bytes >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 6. Email outbox attachment_ref
ALTER TABLE admin_email_outbox
ADD COLUMN IF NOT EXISTS attachment_ref VARCHAR(100);

-- 7. Record schema migrations
INSERT INTO
    brandhub_schema_migrations (version, description)
VALUES (
        '20261029_client_report_email',
        'Attachment ref for scheduled client report email'
    ),
    (
        '20261030_drop_seed_runs',
        'Drop retired demo seed runs table'
    ),
    (
        '20261030_product_video_pipeline',
        'Product video durable coordinator tables'
    ),
    (
        '20261104_media_package_workspace_scope',
        'Workspace scope on media packages'
    ),
    (
        '20261104_repository_storage_addons_client_vault',
        'S3 storage add-ons and client vault'
    ),
    (
        '20261106_manager_led_package_sharing',
        'Manager-led package preparation and guest sharing'
    )
ON CONFLICT (version) DO NOTHING;

COMMIT;