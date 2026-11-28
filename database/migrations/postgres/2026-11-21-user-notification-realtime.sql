-- Realtime in-app notifications: every inbox row announces its recipient on commit.
-- business-service LISTENs on 'user_notification' and pushes a STOMP signal to
-- /user/queue/notifications. Postgres folds identical payloads in one transaction,
-- so an Admin broadcast emits one NOTIFY per recipient, not per statement.
-- Idempotent; safe to run multiple times.
CREATE OR REPLACE FUNCTION notify_user_notification() RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify('user_notification', NEW.user_id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_user_notification_notify
    AFTER INSERT ON user_notifications
    FOR EACH ROW EXECUTE FUNCTION notify_user_notification();
