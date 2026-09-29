-- Apply after 2026-09-24-monitoring.sql. No application data is changed.
BEGIN;
SET LOCAL lock_timeout = '5s';
CREATE TABLE monitoring_enrollments (
    token_hash CHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (btrim(name) <> ''),
    environment VARCHAR(50) NOT NULL CHECK (btrim(environment) <> ''),
    expires_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_monitoring_enrollments_expiry ON monitoring_enrollments(expires_at);
COMMENT ON TABLE monitoring_enrollments IS 'Single-use admin-issued host enrollment; only token digests are stored. Claimed atomically.';
COMMIT;
