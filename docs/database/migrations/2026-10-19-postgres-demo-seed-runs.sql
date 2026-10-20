-- Additive marker for the opt-in PostgreSQL demo dataset.
-- Safe to apply to a populated database; this creates metadata only.
CREATE TABLE IF NOT EXISTS seed_runs (
    dataset          VARCHAR(100) NOT NULL,
    dataset_version  INTEGER NOT NULL CHECK (dataset_version > 0),
    run_id           UUID NOT NULL UNIQUE,
    status           VARCHAR(16) NOT NULL CHECK (status IN ('running', 'complete', 'failed')),
    last_stage       VARCHAR(64),
    record_counts    JSONB NOT NULL DEFAULT '{}'::jsonb,
    manifest         JSONB NOT NULL DEFAULT '{}'::jsonb,
    failure_summary  VARCHAR(255),
    started_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at     TIMESTAMPTZ,
    failed_at        TIMESTAMPTZ,
    PRIMARY KEY (dataset, dataset_version),
    CHECK ((status = 'complete') = (completed_at IS NOT NULL)),
    CHECK ((status = 'failed') = (failed_at IS NOT NULL))
);
