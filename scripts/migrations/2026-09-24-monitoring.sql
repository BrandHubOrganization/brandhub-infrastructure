-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-09-24-monitoring.sql
-- One atomic transaction. Existing objects cause failure rather than hiding drift.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

CREATE TABLE monitoring_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    ip_address INET NOT NULL,
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    deployed_services TEXT[] NOT NULL DEFAULT '{}',
    agent_token_hash VARCHAR(255) NOT NULL CHECK (btrim(agent_token_hash) <> ''),
    cpu_percent NUMERIC(5,2) CHECK (cpu_percent BETWEEN 0 AND 100),
    ram_percent NUMERIC(5,2) CHECK (ram_percent BETWEEN 0 AND 100),
    disk_percent NUMERIC(5,2) CHECK (disk_percent BETWEEN 0 AND 100),
    uptime_seconds BIGINT CHECK (uptime_seconds >= 0),
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_monitoring_server_ip CHECK (
        masklen(ip_address) = CASE family(ip_address) WHEN 4 THEN 32 ELSE 128 END
    ),
    CONSTRAINT chk_monitoring_server_no_sample CHECK (
        last_seen_at IS NOT NULL OR
        (cpu_percent IS NULL AND ram_percent IS NULL AND disk_percent IS NULL AND uptime_seconds IS NULL)
    )
);

CREATE INDEX idx_monitoring_servers_environment ON monitoring_servers(environment, name, id);

COMMENT ON TABLE monitoring_servers IS 'Operator-managed physical hosts; one latest sample per host, no history. API serverId maps to id.';
COMMENT ON COLUMN monitoring_servers.id IS 'Stable across container redeploys; replacement host gets a new UUID. IP is not identity.';
COMMENT ON COLUMN monitoring_servers.agent_token_hash IS 'Hash only; never expose via API/logs. Provision a separate random agent credential.';
COMMENT ON COLUMN monitoring_servers.last_seen_at IS 'Backend receipt time of valid heartbeat; update atomically with all metrics. NULL means NO_DATA.';
COMMENT ON COLUMN monitoring_servers.updated_at IS 'Application-maintained metadata update time; heartbeat must not overwrite operator metadata.';


CREATE TABLE monitoring_collectors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    server_id UUID REFERENCES monitoring_servers(id) ON DELETE RESTRICT,
    token_hash VARCHAR(255) NOT NULL CHECK (btrim(token_hash) <> ''),
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_monitoring_collectors_server ON monitoring_collectors(server_id);

CREATE TABLE monitoring_health_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    kind VARCHAR(20) NOT NULL CHECK (kind IN ('SERVICE', 'CONTAINER', 'DATABASE', 'ENDPOINT')),
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    server_id UUID REFERENCES monitoring_servers(id) ON DELETE RESTRICT,
    service_name VARCHAR(100),
    instance_id VARCHAR(255),
    collector_id UUID NOT NULL REFERENCES monitoring_collectors(id) ON DELETE RESTRICT,
    check_scope VARCHAR(100) NOT NULL CHECK (btrim(check_scope) <> ''),
    probe_type VARCHAR(30) NOT NULL CHECK (probe_type IN ('HTTP', 'DOCKER', 'POSTGRESQL', 'REDIS', 'MONGODB', 'NEO4J')),
    probe_config JSONB NOT NULL DEFAULT '{}' CHECK (jsonb_typeof(probe_config) = 'object'),
    assertion JSONB NOT NULL DEFAULT '{}' CHECK (jsonb_typeof(assertion) = 'object'),
    credential_ref VARCHAR(255) CHECK (credential_ref IS NULL OR btrim(credential_ref) <> ''),
    interval_seconds INTEGER NOT NULL DEFAULT 30 CHECK (interval_seconds > 0),
    timeout_seconds INTEGER NOT NULL DEFAULT 5 CHECK (timeout_seconds > 0),
    stale_after_seconds INTEGER NOT NULL DEFAULT 90 CHECK (stale_after_seconds > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_monitoring_target_timing CHECK (
        timeout_seconds < interval_seconds AND interval_seconds < stale_after_seconds
    ),
    CONSTRAINT chk_monitoring_target_probe CHECK (
        (kind IN ('SERVICE', 'ENDPOINT') AND probe_type = 'HTTP') OR
        (kind = 'CONTAINER' AND probe_type = 'DOCKER' AND server_id IS NOT NULL) OR
        (kind = 'DATABASE' AND probe_type IN ('HTTP', 'POSTGRESQL', 'REDIS', 'MONGODB', 'NEO4J'))
    ),
    -- Supports provenance FK on latest result; one active collector per target.
    CONSTRAINT uq_monitoring_target_collector UNIQUE (id, collector_id)
);
CREATE INDEX idx_monitoring_targets_environment_kind ON monitoring_health_targets(environment, kind);
CREATE INDEX idx_monitoring_targets_server ON monitoring_health_targets(server_id);
CREATE INDEX idx_monitoring_targets_collector ON monitoring_health_targets(collector_id);
CREATE INDEX idx_monitoring_targets_service ON monitoring_health_targets(environment, service_name, instance_id);

CREATE TABLE monitoring_health_results (
    target_id UUID PRIMARY KEY,
    collector_id UUID NOT NULL,
    check_id UUID NOT NULL,
    outcome VARCHAR(5) NOT NULL CHECK (outcome IN ('PASS', 'FAIL', 'ERROR')),
    checked_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    latency_ms NUMERIC(14,3) CHECK (latency_ms >= 0 AND latency_ms < 'Infinity'::numeric),
    reason_code VARCHAR(80),
    http_status SMALLINT CHECK (http_status BETWEEN 100 AND 599),
    runtime_state VARCHAR(30),
    runtime_health VARCHAR(30),
    CONSTRAINT fk_monitoring_result_owner FOREIGN KEY (target_id, collector_id)
        REFERENCES monitoring_health_targets(id, collector_id) ON DELETE RESTRICT,
    CONSTRAINT chk_monitoring_result_reason CHECK (
        (outcome = 'PASS' AND reason_code IS NULL) OR
        (outcome IN ('FAIL', 'ERROR') AND reason_code IS NOT NULL AND btrim(reason_code) <> '')
    ),
    CONSTRAINT chk_monitoring_result_clock CHECK (checked_at <= received_at + INTERVAL '10 seconds')
);

COMMENT ON TABLE monitoring_collectors IS 'Operator-provisioned sources; heartbeat independent of probes. API collectorId maps to id.';
COMMENT ON TABLE monitoring_health_targets IS 'Persistent allowlist, including targets with no result. Never auto-create from submitted samples.';
COMMENT ON COLUMN monitoring_health_targets.server_id IS 'NULL for managed/external targets; must not fabricate host metrics.';
COMMENT ON COLUMN monitoring_health_targets.check_scope IS 'READINESS/LIVENESS for services; documented scope for other probes. Validate contract in application.';
COMMENT ON COLUMN monitoring_health_targets.probe_config IS 'Operator-only address/selector configuration. No plaintext secrets or raw response; omit from public DTOs.';
COMMENT ON COLUMN monitoring_health_targets.credential_ref IS 'Reference resolved by worker secret provider; never a password, bearer token, or secret-bearing URI.';
COMMENT ON COLUMN monitoring_health_targets.stale_after_seconds IS 'Also used by ingestion as maximum past sample age; compare against backend time.';
COMMENT ON TABLE monitoring_health_results IS 'Exactly zero or one latest result per target. No history or persisted freshness status.';
COMMENT ON COLUMN monitoring_health_results.collector_id IS 'Result provenance; FK prevents retaining old result under a new assignment. Clear result before reassignment in same transaction.';
COMMENT ON COLUMN monitoring_health_results.check_id IS 'Idempotency key scoped to target. Same current checkId is a no-op; do not update received_at.';
COMMENT ON COLUMN monitoring_health_results.received_at IS 'Backend-assigned; never trust client timestamp. Application enforces ordering and past-age window atomically.';


SELECT table_name, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('monitoring_servers', 'monitoring_collectors',
                     'monitoring_health_targets', 'monitoring_health_results')
ORDER BY table_name, ordinal_position;

SELECT c.relname AS table_name, con.conname, pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('monitoring_servers', 'monitoring_collectors',
                   'monitoring_health_targets', 'monitoring_health_results')
ORDER BY c.relname, con.conname;

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('monitoring_servers', 'monitoring_collectors',
                    'monitoring_health_targets', 'monitoring_health_results')
ORDER BY tablename, indexname;

COMMIT;
