# Daily S3 trend replay
## Neo4j preflight resilience — planned
Status: planning only, not implemented or deployed.

### Problem and evidence
On 2026-10-31 the exact Replay driver probe failed once with ServiceUnavailable caused by socket.gaierror / Windows 11001 for the configured Aura hostname; an immediate second attempt succeeded and found apoc.refactor.mergeNodes. This establishes intermittent DNS resolution during the probe, not an Aura capacity breach. It does not establish which DNS server/network/VPN component is responsible.
Replay currently stops after a single verify_connectivity failure. Some graph operations use managed transactions with driver retry; that does not guarantee recovery for the separate one-shot readiness probe.

### Acceptance criteria
- Retry only read-only Neo4j readiness operations for transient DNS, connection/routing failures and bounded timeouts. Maximum three attempts, 2s then 5s async backoff, 15s per attempt, 60s total wall-clock budget (whichever limit is reached first).
- One attempt covers connectivity plus the APOC availability query. A successful first attempt has no delay. Preserve the same configured Aura URI/TLS/auth/database and shared driver; no IP pinning, disabling TLS or mock fallback.
- Authentication/authorization, invalid URI/configuration, certificate validation and non-transient query errors fail immediately. Missing APOC remains REPLAY_APOC_UNAVAILABLE and is not retried.
- Persist a safe final error category: REPLAY_NEO4J_DNS_UNAVAILABLE, REPLAY_NEO4J_CONNECTION_UNAVAILABLE, REPLAY_NEO4J_TIMEOUT, REPLAY_NEO4J_AUTH_FAILED, REPLAY_NEO4J_TLS_FAILED; retain REPLAY_NEO4J_UNAVAILABLE for unclassified failures. Validate actual driver exception types/causes during implementation.
- Keep Redis heartbeat/fencing active throughout preflight and backoff. Lease loss, shutdown or cancellation stops retries; no file adaptation, model extraction, aggregation or writes after preflight fails.
- No automatic Resume and no automatic rerun of AI batches. Existing completed file/day checkpoints and V3 source manifest remain unchanged. Connection retry alone does not fix replay interruption after an application restart.
- Admin displays localized explanations for the safe codes and preserves the existing explicit Resume action. New keys under admin.trendReplay.errors.* in both vi/en admin.json; keep fallback for unknown/legacy codes. Reuse current semantic colors/alert controls and verify light/dark mode.
- Log only approved diagnostic fields: job identity when available, phase, attempt/budget, exception class, safe reason category and socket error number. Never log passwords, full connection URIs, authentication headers, cookies or raw provider exception bodies.

### Out of scope
No global driver retry-policy changes, live crawl algorithm changes, schema/seed/migration, DNS adapter/OS changes, paid tier upgrades, S3 credentials/prefix work, Business attachment_ref fix, or automatic execution against real archives.
## S3 replay source separation & crawler key support
Replay S3 discovery is separated from the media bucket (`S3_BUCKET_NAME=brandhubmedia`) via `TREND_REPLAY_S3_BUCKET=crawler-social` and `TREND_REPLAY_S3_PREFIX=` (empty by default to allow scanning from the bucket root). If `TREND_REPLAY_S3_PREFIX` is configured to a non-empty prefix, requested prefixes must remain within that configured prefix; when empty, an empty prefix scans the bucket root and non-empty sub-prefixes are normalized safely. Web displays the active replay bucket and defaults the optional prefix input from Backend (`GET /api/v1/admin/ai/trend-replays` returns `bucket`, `default_prefix`, and `jobs`), never allowing arbitrary client-selected buckets. Date recognition supports both crawler `dd-MM-yyyy` folders (e.g., `30-10-2026/<page>/<page>_20261030_202232.json`) and legacy `YYYY-MM-DD`/`YYYYMMDD` keys; keys with missing or conflicting dates across folder/filename are excluded and counted in `ignored_keys`. Each preview pins its `bucket`, normalized `prefix`, file keys, sizes, and `ETag`s so subsequent configuration changes never mutate existing jobs or checkpoints.

## Multi-platform update
Replay must consume Facebook, Threads and TikTok archives with the same adapters used by live crawl. Preserve original publication/observation times (including published_at/collected_at), formats and platform source. Missing timestamps use archived day rather than now; explicit unsupported platforms fail safely. Preview labels file platform inferred from filename; unknown filename is explicitly unidentified until read. Actual per-file platform counts appear after reading.
New previews use NORMAL_PIPELINE_V3 with batches of 25 to match live delivery. Do not resume V2 extraction checkpoints with changed adapter/batch semantics; retain old jobs read-only and require a fresh preview. Keep oldest-day-first, shared TrendService batch extraction, label check and daily aggregation/persistence/resolution. No new crawl, no session/config editing, no DB reset or migration.
UI shows human processing stages, batch/file/day counts, platform labels, date limits (31 days, no future days), and links to live Pipeline/trend results. Keep start explicit and explain resume/paid processing. i18n keys admin.trendReplay.* in vi/en, semantic theme tokens, responsive keyboard-operable controls.

Admin selects an inclusive date range and an optional prefix under the configured replay S3
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
preview jobs cannot start: require a fresh NORMAL_PIPELINE_V3 preview.
Redis stores job metadata, history and fenced execution lease; storage is required,
not mock fallback. Pause on failure, resume explicitly at completed file/day
checkpoints. Process restarts surface Interrupted after lease expiry; no false Done.
Resume requires the same persistent filesystem (or shared volume across instances).
Only configured replay S3 bucket is accessible; 31 days, 500 files, 50 MiB per file and
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

- POST `/preview`: `{startDate:"2026-10-18", endDate:"2026-10-24", prefix:""}`.
  Read-only S3 discovery against `TREND_REPLAY_S3_BUCKET`; persists a PREVIEW manifest with pinned `bucket`, `prefix`, and dated files. Returns job ID and dated files.
- POST `/{id}/start`: starts PREVIEW or resumes FAILED/INTERRUPTED; returns 202.
  One replay globally; conflicting start returns 409. No automatic retry of Start.
- GET base: configured `bucket`, `default_prefix`, and last 20 `jobs`; GET `/{id}`: file/day statuses and current processing stage.
- GET `/{id}/days/{YYYY-MM-DD}`: candidates and normal DB publication status.

AI uses corresponding internal `/api/v1/ai/trends/replays` routes and snake_case
preview fields, protected by X-Internal-Key. Errors contain no credentials/raw posts.

## Operator steps

Start Redis and Chroma before AI. Verify Neo4j connectivity and the APOC
`apoc.refactor.mergeNodes` procedure, model/embedding dependencies and S3 read
credentials before starting a paid replay. Restart AI after dependency/env changes;
restart Business for the new controller and reload Web. Open
`/admin?view=trendReplay`, choose date range and an optional prefix within `TREND_REPLAY_S3_PREFIX` (leave blank to scan from bucket root when `TREND_REPLAY_S3_PREFIX` is empty),
Preview, inspect files, then explicitly Start. To warm up a full seven-day history,
include seven earlier dates in the selected range. Files without an unambiguous
`dd-MM-yyyy`, `YYYY-MM-DD` or `YYYYMMDD` date in their key are excluded (never guessed from upload date).
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
