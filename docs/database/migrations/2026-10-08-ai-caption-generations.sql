-- FR 3.7.2: every caption generation, which option the Creator picked and what they finally kept.
-- Used for (1) history of AI-written content per task, (2) choosing better few-shot examples and a
-- dataset for the content LoRA later. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS ai_caption_generations (
    id            UUID         PRIMARY KEY,
    workspace_id  UUID         NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id       UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id       UUID,
    request       JSONB        NOT NULL,
    variants      JSONB        NOT NULL,
    context       JSONB        NOT NULL DEFAULT '{}',
    credits       INT          NOT NULL DEFAULT 0,
    chosen_type   VARCHAR(20),
    chosen_action VARCHAR(10)  CHECK (chosen_action IN ('INSERT','REPLACE')),
    final_text    TEXT,
    chosen_at     TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_ai_caption_generations_workspace ON ai_caption_generations(workspace_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_caption_generations_task ON ai_caption_generations(task_id) WHERE task_id IS NOT NULL;

COMMIT;
