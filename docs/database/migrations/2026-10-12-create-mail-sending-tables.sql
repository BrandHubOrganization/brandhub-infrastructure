-- ============================================================
-- BrandHub - PostgreSQL migration: mail sending tables
-- Date: 2026-10-12
-- Reason: FR 3.6.28-3.6.32 (DA-1002, DA-1256..DA-1258). Batches, per-recipient
--         deliveries (outbox), daily quota, suppression list, attachments.
-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-12-create-mail-sending-tables.sql
-- Statuses are varchar + CHECK (not PG enums) so the JDBC code stays simple.
-- ============================================================
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

CREATE TABLE IF NOT EXISTS mail_attachments (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    uploaded_by   UUID NOT NULL REFERENCES users(id),
    name          VARCHAR(255) NOT NULL,
    content_type  VARCHAR(100) NOT NULL,
    size          BIGINT NOT NULL,
    s3_key        VARCHAR(500) NOT NULL,
    kind          VARCHAR(16) NOT NULL DEFAULT 'FILE' CHECK (kind IN ('FILE', 'IMAGE')),
    bound         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_mail_attachments_workspace
    ON mail_attachments (workspace_id, bound, created_at);

CREATE TABLE IF NOT EXISTS mail_batches (
    id               UUID PRIMARY KEY,
    workspace_id     UUID NOT NULL REFERENCES workspaces(id),
    workspace_name   VARCHAR(255),
    template_id      VARCHAR(64) NOT NULL,
    template_name    VARCHAR(120) NOT NULL,
    sent_by          UUID NOT NULL REFERENCES users(id),
    sender_email     VARCHAR(255) NOT NULL,
    sender_name      VARCHAR(255),
    kind             VARCHAR(16) NOT NULL DEFAULT 'SEND' CHECK (kind IN ('SEND', 'TEST')),
    status           VARCHAR(16) NOT NULL
                     CHECK (status IN ('SCHEDULED', 'QUEUED', 'SENDING', 'COMPLETED', 'CANCELLED', 'FAILED')),
    subject          VARCHAR(200) NOT NULL,
    body_html        TEXT NOT NULL,
    attachments      JSONB,
    scheduled_at     TIMESTAMPTZ,
    timezone         VARCHAR(64) NOT NULL DEFAULT 'Asia/Ho_Chi_Minh',
    total            INT NOT NULL,
    accepted         INT NOT NULL,
    rejected_count   INT NOT NULL DEFAULT 0,
    sent_count       INT NOT NULL DEFAULT 0,
    failed_count     INT NOT NULL DEFAULT 0,
    suppressed_count INT NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at     TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_mail_batches_workspace ON mail_batches (workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mail_batches_due ON mail_batches (status, scheduled_at);

CREATE TABLE IF NOT EXISTS mail_deliveries (
    id                  UUID PRIMARY KEY,
    batch_id            UUID NOT NULL REFERENCES mail_batches(id) ON DELETE CASCADE,
    recipient           VARCHAR(255) NOT NULL,
    recipient_name      VARCHAR(255),
    variables           JSONB,
    rendered_subject    VARCHAR(255) NOT NULL,
    rendered_body_html  TEXT NOT NULL,
    external_audience   BOOLEAN NOT NULL DEFAULT FALSE,
    status              VARCHAR(16) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING', 'SENT', 'FAILED', 'SUPPRESSED')),
    attempts            INT NOT NULL DEFAULT 0,
    last_error          VARCHAR(500),
    next_attempt_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    sent_at             TIMESTAMPTZ,
    event_key           VARCHAR(300) NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_due ON mail_deliveries (status, next_attempt_at);
CREATE INDEX IF NOT EXISTS idx_mail_deliveries_batch ON mail_deliveries (batch_id);

CREATE TABLE IF NOT EXISTS mail_send_quota (
    day         DATE NOT NULL,
    scope       VARCHAR(16) NOT NULL CHECK (scope IN ('SYSTEM', 'WORKSPACE')),
    scope_id    VARCHAR(64) NOT NULL,
    sent_count  INT NOT NULL DEFAULT 0,
    PRIMARY KEY (day, scope, scope_id)
);

CREATE TABLE IF NOT EXISTS mail_suppressions (
    id            UUID PRIMARY KEY,
    workspace_id  UUID NOT NULL REFERENCES workspaces(id),
    email_lower   VARCHAR(255) NOT NULL,
    reason        VARCHAR(32) NOT NULL DEFAULT 'UNSUBSCRIBED',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (workspace_id, email_lower)
);

COMMIT;
