-- DA-1274 T5: Newsletter task (spec subtask-role-workspaces §16.1, §16.6, AC15, AC16).
-- Additive upgrade only: no seed, reset, backfill or data deletion. Safe to run twice.
-- Requires the Addendum B mail migrations (2026-10-28 scope, 2026-10-29 agency suppression).
BEGIN;
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public'
        AND table_name='mail_suppressions' AND column_name='agency_id') THEN
        RAISE EXCEPTION 'Apply the 2026-10-29 agency suppression migration first';
    END IF;
END $$;

-- mail_batches.kind already exists (SEND | TEST); Newsletter batches are kind NEWSLETTER.
ALTER TABLE mail_batches DROP CONSTRAINT IF EXISTS mail_batches_kind_check;
ALTER TABLE mail_batches ADD CONSTRAINT mail_batches_kind_check CHECK (kind IN ('SEND', 'TEST', 'NEWSLETTER'));

-- An unsubscribe from a Newsletter blocks every Newsletter of that Client, in every Workspace (§16.6).
ALTER TABLE mail_suppressions ADD COLUMN IF NOT EXISTS client_profile_id UUID;
CREATE INDEX IF NOT EXISTS idx_mail_suppressions_client_email
    ON mail_suppressions (client_profile_id, email_lower) WHERE client_profile_id IS NOT NULL;

-- Newsletter counters, apart from mail_send_quota so system mail keeps its own daily cap (§16.1).
-- period = 'YYYY-MM' (monthly quota per plan) or 'YYYY-MM-DD' (daily rate), Asia/Ho_Chi_Minh calendar.
CREATE TABLE IF NOT EXISTS newsletter_usage (
    agency_id UUID        NOT NULL REFERENCES agencies(id),
    period    VARCHAR(10) NOT NULL,
    used      INTEGER     NOT NULL DEFAULT 0 CHECK (used >= 0),
    PRIMARY KEY (agency_id, period)
);
COMMIT;
