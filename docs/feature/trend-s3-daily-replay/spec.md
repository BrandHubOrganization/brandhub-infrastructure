# Daily S3 trend replay

Admin selects an inclusive date range and a prefix under the configured raw S3
prefix. Preview pins JSON objects (key, ETag, size) by date embedded in the key,
never LastModified. Ambiguous/undated keys are excluded and counted. No S3 writes.
One day is one run, all its files are batches. Process oldest day first with
T0/T1/T2/T5, then T4/T7 over that day and at most seven prior days in this replay.
Preserve original publication times; use original observation time or archived
key date (explicit provenance), never current replay time. Exclude future posts.

Replay replaces acquisition only. Reuse TrendService and CrawlRunService for
Neo4j Trend/source evidence, embeddings, Chroma social_trend_chunks, Redis daily/
live snapshots and entity resolution. Historical daily snapshots may be written,
but an older day must never replace a newer live snapshot. No alternative scoring
or persistence pipeline. Checkpoints remain under TREND_RUN_DIR/replays/<job UUID>.
Admin shows whether DB persistence and live publication succeeded. Old isolated
preview jobs cannot start: require a fresh NORMAL_PIPELINE_V2 preview.
Redis stores job metadata, history and fenced execution lease; storage is required,
not mock fallback. Pause on failure, resume explicitly at completed file/day
checkpoints. Process restarts surface Interrupted after lease expiry; no false Done.
Resume requires the same persistent filesystem (or shared volume across instances).
Only configured S3 bucket is accessible; 31 days, 500 files, 50 MiB per file and
200k raw rows/job. Preview does not invoke models; Start warns that Gemini fallback
may incur costs. No automatic execution against the user's S3 during development.

Business API requires active Admin, forwards with internal key, audits start/resume.
Web /admin?view=trendReplay: form -> preview -> explicit Start -> polling job list
and per-day/file progress/results/errors. Existing BrandHub light/dark tokens;
labels under admin.trendReplay and admin.navigation.trendReplay in vi/en.
No schema migration, seed, automatic commit or push. Scoped cleanup is a separate
confirmed maintenance operation after writer shutdown and preflight; replay Start
never resets Mongo/Postgres/S3/RAG or queues.

Before processing files on each Start/Resume, a PREFLIGHT stage checks Neo4j and
APOC availability, Chroma heartbeat and a nonzero finite 384d embedding from the
configured local MiniLM model. Failure stops before extraction/paid labeling with
a safe readiness code. Keep the execution heartbeat/fencing active during preflight.
The probe uses neutral text, never raw posts; model weights may download once.

## API contract

Business Admin base: `/api/v1/admin/ai/trend-replays`.

- POST `/preview`: `{startDate:"2026-10-18", endDate:"2026-10-24", prefix:"crawler-raw/"}`.
  Read-only S3 discovery; persists a PREVIEW manifest. Returns job ID and dated files.
- POST `/{id}/start`: starts PREVIEW or resumes FAILED/INTERRUPTED; returns 202.
  One replay globally; conflicting start returns 409. No automatic retry of Start.
- GET base: last 20 jobs; GET `/{id}`: file/day statuses and current processing stage.
- GET `/{id}/days/{YYYY-MM-DD}`: candidates and normal DB publication status.

AI uses corresponding internal `/api/v1/ai/trends/replays` routes and snake_case
preview fields, protected by X-Internal-Key. Errors contain no credentials/raw posts.

## Operator steps

Start Redis and Chroma before AI. Verify Neo4j connectivity and the APOC
`apoc.refactor.mergeNodes` procedure, model/embedding dependencies and S3 read
credentials before starting a paid replay. Restart AI after dependency/env changes;
restart Business for the new controller and reload Web. Open
`/admin?view=trendReplay`, choose date range and a prefix within S3_PREFIX_RAW,
Preview, inspect files, then explicitly Start. To warm up a full seven-day history,
include seven earlier dates in the selected range. Files without an unambiguous
YYYY-MM-DD or YYYYMMDD date in their key are excluded (never guessed from upload date).
Errors block later days; fix the cause then Resume. After process interruption wait
up to 180 seconds for the lease to expire. Keep TREND_RUN_DIR persistent and shared
when using multiple AI instances; Redis metadata alone cannot restore lost files.
Redis job metadata is retained 45 days; replay feature/result files are not auto-deleted.
No RabbitMQ needed for the replay runner: it calls the same per-batch/day steps
directly; the existing live crawl consumer is unchanged.
Entity resolution failures or a busy resolution lock stop replay day completion;
fix/wait, then Resume. Partial-success resolution remains visible in day details.
Historic daily data uses the original date: query that date for the 24h endpoint,
or use the live 6h endpoint for the newest published snapshot.

## Known limitations

Replay history/checkpoints are isolated; published graph/vector data is shared
with live crawl. Redis protects a newer snapshot, but this protection does not
version or fence earlier Neo4j/Chroma writes for the same trend IDs. Replay and
live crawl do not share an ingestion lease; coordinate writers before replay.

The existing entity-resolution job is global when no brand ID is supplied, as
with current crawl/replay finalization. Its label-only partitions do not enforce
Brand/Workspace boundaries. Scope resolution before relying on tenant isolation.

If no newer snapshot exists, an archived replay may become the live snapshot,
including the 6h input used by hashtag suggestions. Historical publication needs
an explicit freshness/live-publication policy before treating it as current data.

Lease fencing protects job metadata; cancelling an async task cannot stop an
already-running blocking model/storage call in a thread. Storage-level ownership
checks are still needed to prevent stale writes after interruption.
