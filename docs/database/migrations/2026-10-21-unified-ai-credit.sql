-- DA-974: preserve legacy history, link new Video jobs to unified reservations.
-- Prerequisites: caption-generations, video-jobs, compact credit-accounting + credit-ai-execution.
-- Stop Business/workers, apply before deploying the matching build. No seed/balance conversion.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
SET LOCAL search_path = public;

DO $$
BEGIN
    IF to_regclass('ai_caption_generations') IS NULL OR to_regclass('ai_video_jobs') IS NULL
        OR to_regclass('ai_credit_reservations') IS NULL THEN
        RAISE EXCEPTION 'Apply Caption/Video and compact Credit migrations first; no changes applied';
    END IF;
END $$;

ALTER TABLE ai_caption_generations ALTER COLUMN credits TYPE BIGINT;
ALTER TABLE ai_video_jobs ADD COLUMN IF NOT EXISTS reservation_id UUID;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='ai_video_jobs'::regclass
        AND conname='fk_ai_video_jobs_reservation') THEN
        ALTER TABLE ai_video_jobs ADD CONSTRAINT fk_ai_video_jobs_reservation
            FOREIGN KEY (reservation_id) REFERENCES ai_credit_reservations(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid='ai_video_jobs'::regclass
        AND conname='ck_ai_video_jobs_accounting_source') THEN
        ALTER TABLE ai_video_jobs ADD CONSTRAINT ck_ai_video_jobs_accounting_source
            CHECK (usage_id IS NULL OR reservation_id IS NULL);
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_ai_video_jobs_reservation
    ON ai_video_jobs(reservation_id) WHERE reservation_id IS NOT NULL;

COMMIT;
