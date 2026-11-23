-- Automatic engagement mails M1–M5 (docs/superpowers/plans/2026-11-21-profile-data-utilization/04-auto-mail.md).
-- One row per (kind, recipient, subject) reminder stream; the unique key makes the hourly
-- EngagementReminderJob idempotent and its sent_count compare-and-set stops double sends.
-- Local/test databases get the table from Hibernate ddl-auto (EngagementReminder entity).
-- Idempotent; safe to run multiple times.
BEGIN;

CREATE TABLE IF NOT EXISTS engagement_reminders (
    id uuid PRIMARY KEY,
    kind varchar(32) NOT NULL,              -- M1..M5
    recipient_id uuid NOT NULL,
    subject_id uuid NOT NULL,               -- user / campaign / package / workspace
    sent_count int NOT NULL DEFAULT 0,
    first_triggered_at timestamptz NOT NULL,
    last_sent_at timestamptz,
    resolved_at timestamptz,
    CONSTRAINT uq_engagement_reminders UNIQUE (kind, recipient_id, subject_id)
);
CREATE INDEX IF NOT EXISTS idx_engagement_reminders_open
    ON engagement_reminders (kind) WHERE resolved_at IS NULL;

COMMIT;
