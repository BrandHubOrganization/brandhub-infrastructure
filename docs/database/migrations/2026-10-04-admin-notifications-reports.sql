-- FR 3.10.1 (email broadcast) + FR 3.10.12 (PDF export) + BR-16 audit actions.
-- Run with psql autocommit before deploying the new Business Service:
--   docker exec -i brandhub-postgres psql -U postgres -d brandhub -v ON_ERROR_STOP=1 < 2026-10-04-admin-notifications-reports.sql
-- Additive and idempotent: safe to run twice. Depends on 2026-10-01-admin-account-strikes.sql (admin_email_outbox).

-- Enum values must be committed before any statement uses them.
ALTER TYPE audit_action ADD VALUE IF NOT EXISTS 'VIEW';
ALTER TYPE audit_action ADD VALUE IF NOT EXISTS 'EXPORT';

BEGIN;

CREATE TABLE IF NOT EXISTS admin_notifications (
    id UUID PRIMARY KEY,
    title VARCHAR(200) NOT NULL CHECK (char_length(btrim(title)) BETWEEN 5 AND 200),
    content VARCHAR(5000) NOT NULL CHECK (char_length(btrim(content)) BETWEEN 10 AND 5000),
    type VARCHAR(20) NOT NULL CHECK (type IN ('SYSTEM','MAINTENANCE','UPDATE','PROMOTION')),
    target_type VARCHAR(10) NOT NULL CHECK (target_type IN ('ALL','BY_PLAN','BY_ROLE')),
    target_values TEXT[] NOT NULL DEFAULT '{}',
    action_url VARCHAR(500),
    status VARCHAR(12) NOT NULL CHECK (status IN ('DRAFT','SCHEDULED','SENDING','SENT','FAILED','CANCELLED')),
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    recipient_count INTEGER,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    row_version BIGINT NOT NULL DEFAULT 0,
    CHECK (status <> 'SCHEDULED' OR scheduled_at IS NOT NULL),
    CHECK (target_type = 'ALL' OR cardinality(target_values) > 0)
);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_due
    ON admin_notifications(scheduled_at) WHERE status = 'SCHEDULED';
CREATE INDEX IF NOT EXISTS idx_admin_notifications_history
    ON admin_notifications(created_at DESC, id DESC);

-- One outbox row per recipient = delivery record; event_key keeps (notification, user) unique.
ALTER TABLE admin_email_outbox
    ADD COLUMN IF NOT EXISTS notification_id UUID REFERENCES admin_notifications(id),
    ADD COLUMN IF NOT EXISTS failed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_error VARCHAR(255);
CREATE INDEX IF NOT EXISTS idx_admin_email_outbox_notification
    ON admin_email_outbox(notification_id) WHERE notification_id IS NOT NULL;

-- Generated PDFs are private: bytes live here for 24h, metadata stays as the export audit.
CREATE TABLE IF NOT EXISTS admin_report_exports (
    id UUID PRIMARY KEY,
    report_type VARCHAR(20) NOT NULL CHECK (report_type IN ('REVENUE','USER','PLATFORM')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    timezone VARCHAR(40) NOT NULL,
    as_of TIMESTAMPTZ NOT NULL,
    row_count INTEGER NOT NULL,
    file_name VARCHAR(120) NOT NULL,
    file_size INTEGER NOT NULL,
    content BYTEA,
    token_hash CHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (period_end >= period_start),
    CHECK (expires_at > created_at)
);
CREATE INDEX IF NOT EXISTS idx_admin_report_exports_expiry
    ON admin_report_exports(expires_at) WHERE content IS NOT NULL;

COMMIT;
