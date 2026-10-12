-- FR 3.10.4 Content Moderation Queue — PostgreSQL side (decisions, strike link, audit trail).
-- The immutable content snapshot of each reviewed version lives in Mongo `post_versions`
-- (see 2026-10-04-create-post-versions-collection.js); this table stores its SHA-256 hash.
-- Run with psql before deploying the new Business Service. Additive and idempotent.

BEGIN;

CREATE TABLE IF NOT EXISTS content_moderation_reviews (
    id UUID PRIMARY KEY,
    post_id VARCHAR(64) NOT NULL,
    content_version BIGINT NOT NULL CHECK (content_version > 0),
    content_hash CHAR(64) NOT NULL,
    workspace_id UUID,
    author_id UUID NOT NULL REFERENCES users(id),
    source VARCHAR(20) NOT NULL CHECK (source IN ('FLAGGED_AUTHOR','COMPLIANCE','COPYRIGHT')),
    reason VARCHAR(2000) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','APPROVED','BLOCKED')),
    decision_note VARCHAR(2000),
    strike_level VARCHAR(10) CHECK (strike_level IN ('YELLOW','ORANGE','RED')),
    strike_category VARCHAR(100),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    row_version BIGINT NOT NULL DEFAULT 0,
    -- BR-64: one decision per immutable post version; a repeated flag reuses the pending row.
    CONSTRAINT uq_moderation_post_version UNIQUE (post_id, content_version),
    CHECK ((status = 'PENDING') = (reviewed_at IS NULL AND reviewed_by IS NULL)),
    CHECK (status <> 'APPROVED' OR char_length(btrim(decision_note)) >= 10),
    CHECK (status <> 'BLOCKED' OR (strike_level IS NOT NULL AND decision_note IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_moderation_queue ON content_moderation_reviews(status, created_at, id);
CREATE INDEX IF NOT EXISTS idx_moderation_author ON content_moderation_reviews(author_id);

COMMENT ON TABLE content_moderation_reviews IS
    'FR 3.10.4. BLOCK records the strike through the admin account journal with operation id = review id, so retries never add a second strike.';

COMMIT;
