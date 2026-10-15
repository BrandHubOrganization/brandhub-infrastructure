-- FR 3.10.1 in-app channel (scope extended 2026-10-04): every broadcast recipient also gets an
-- inbox row, written in the same transaction as the email outbox snapshot.
-- Depends on 2026-10-04-admin-notifications-reports.sql. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS user_notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_id UUID NOT NULL REFERENCES admin_notifications(id),
    type VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content VARCHAR(5000) NOT NULL,
    action_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    read_at TIMESTAMPTZ,
    CONSTRAINT uq_user_notification UNIQUE (notification_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_user_notifications_inbox ON user_notifications(user_id, created_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_user_notifications_unread ON user_notifications(user_id) WHERE read_at IS NULL;

COMMIT;
