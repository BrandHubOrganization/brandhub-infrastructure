# Verification
## Neo4j preflight resilience
### Verification results (2026-10-31)
- PASS: 13 isolated Python unit tests in `keep-local-only/test_neo4j_preflight.py` and 9 regression tests in `keep-local-only/test_replay_readiness.py` (22 tests passing):
  - First probe succeeds: 1 attempt, no delay, proceed cleanly.
  - DNS fails once then succeeds: 2 attempts, 1 delay (2s backoff), returns success.
  - DNS fails all 3 attempts: bounded to 3 attempts, raises safe `REPLAY_NEO4J_DNS_UNAVAILABLE`.
  - Connection/routing fails all attempts: bounded retry, raises safe `REPLAY_NEO4J_CONNECTION_UNAVAILABLE`.
  - Timeout: enforces per-attempt and total deadline budget, raises safe `REPLAY_NEO4J_TIMEOUT`.
  - Auth failure: immediate fail on attempt 1 without retry, raises `REPLAY_NEO4J_AUTH_FAILED`.
  - TLS/SSL failure: immediate fail on attempt 1 without retry, raises `REPLAY_NEO4J_TLS_FAILED`.
  - Missing APOC: immediate fail on attempt 1 without retry, raises `REPLAY_APOC_UNAVAILABLE`.
  - Cancellation / lease loss: cooperative cancellation during backoff sleep, immediately raises `asyncio.CancelledError`.
  - Recursive cause / context inspection: correctly extracts root cause when wrapped in driver `ServiceUnavailable`.
- PASS: Web CI in `brandhub-web` (`npx tsc -b --noEmit` and `npm run lint` with 0 errors).
- PASS: Localized error guidance in `vi/admin.json` and `en/admin.json` under `admin.trendReplay.errors.*` for all recognized error codes, with fallback to raw error code and recovery hint. Start/Resume button remains active and accessible on `FAILED` and `INTERRUPTED` statuses.
- PASS: Verified Redis active lease is `None` before touching service configurations.

## S3 replay source separation & crawler key support
Verify `TREND_REPLAY_S3_BUCKET=crawler-social` and `TREND_REPLAY_S3_PREFIX=` separation from `S3_BUCKET_NAME=brandhubmedia`, empty-prefix root discovery, configured-prefix enforcement when non-empty, `dd-MM-yyyy` + `YYYYMMDD`/`YYYY-MM-DD` matching and conflicting-date exclusion, immutable pinned job bucket/prefix/ETag across config changes, Business optional prefix forwarding, Web bucket badge + optional prefix validation + vi/en copy, browser QA, Web CI, and read-only live preview against `crawler-social` without starting AI execution.

### S3 replay source separation result (2026-10-31)
- PASS: 24 isolated Python tests in `keep-local-only/test_daily_replay.py` and `keep-local-only/test_replay_v3.py` (1 external Redis QA test deselected): independent `TREND_REPLAY_S3_BUCKET=crawler-social` / `TREND_REPLAY_S3_PREFIX=` vs `S3_BUCKET_NAME=brandhubmedia`, empty-prefix (`""`) root discovery on `crawler-social`, non-empty prefix boundary enforcement, `dd-MM-yyyy` + `YYYYMMDD_HHMMSS` / `YYYY-MM-DD` date parsing and conflicting-date rejection (`ignored_keys`), and `ReplayJobs.list()` returning active `bucket`/`default_prefix` while preserving pinned job `bucket`/`prefix`/`ETag` after settings change.
- PASS: Java `mvn compile` and `keep-local-only/TrendReplaySmoke.java` verified `TrendReplayRequest` and `AdminTrendReplayService` optional/null/blank/trimmed prefix forwarding and 31-day validation.
- PASS: Web CI (`npm run lint`, `npx tsc -b --noEmit`, `npm run build` with 0 errors) and Playwright mocked browser QA (`keep-local-only/replay-v3-browser.js` + `replay-v3-old-preview.js`): `s3://crawler-social` header badge, `default_prefix` population and blank root-prefix preview submission, 31-day & future-date validation, `vi`/`en` locales and light/dark themes at 375/768/1440px with 0 layout overflow or console/page errors.
- PASS: Read-only live `crawler-social` preview check (`POST http://localhost:8082/api/v1/ai/trends/replays/preview` with `{"start_date": "2026-10-25", "end_date": "2026-10-30", "prefix": ""}`): returned HTTP 200 (`status=PREVIEW`, `bucket=crawler-social`, `prefix=""`, `ignored_keys=6`) with 5 discovered days and 118 total files (`2026-10-26`: 20, `2026-10-27`: 23, `2026-10-28`: 24, `2026-10-29`: 26, `2026-10-30`: 25). No replay execution, AI model call, or DB write was invoked.

## Multi-platform update
Check mixed-platform adaptation, missing/preserved/future/invalid timestamps, unsupported platform failure, deterministic S3 date/platform hints, 25-row batch checkpoints, V2 start rejection, oldest-day processing and resume. Mock browser: preview validation, file platform labels/counts, stages, old preview read-only, error/empty/progress/results, vi/en light/dark at 375/768/1440. Run Web CI; no real provider or persistence calls.

### Multi-platform result (2026-10-31)
- PASS: 33 isolated Python tests (one external Redis QA test deselected), including adapter timestamps/metadata, mixed sources, filename hints, envelope platform preservation, 25/25/1 batching, actual platform counts, V3 creation and V2 start rejection, existing order/resume/preflight regressions.
- PASS: browser mocks for invalid dates, preview, three platform labels, one explicit Start, completion/persistence/counts/results and old V2 preview guidance with no Start. Vietnamese/English, light/dark, 375/768/1440px; fixed existing hidden progress element causing mobile horizontal overflow.
- PASS: Web CI, zero errors; existing 189 lint warnings and large-bundle warning remain. QA sources/logs/screenshots ignored in keep-local-only; no tracked tests added.
- No live S3/provider/DB calls, no operational replay launch, no cleanup/seed/migration. Live crawler, queue consumer and scoring/persistence algorithms unchanged.

## Isolated verification

Reject invalid/broad/escaped prefixes, invalid IDs, future/reversed dates, more than
31 days, more than 500 objects, oversized files and malformed JSON. Discovery must
paginate, group by an unambiguous key date and pin reads to the previewed ETag.

Use fake S3/model/graph/vector services and a disposable Redis instance. Verify
oldest-day-first processing, all file batches before daily aggregation, previous
days only in the history window, duplicate handling and original source dates.
Failures block later days; explicit resume skips completed checkpoints. Missing
checkpoints and changed source objects must block instead of silently rebuilding.

Verify preflight checks Neo4j/APOC, Chroma and finite nonzero 384d vectors before
file/model work; failures leave extraction checkpoints untouched. Verify replay
tracking keys and history roots are isolated and normal live defaults remain intact.

Check Admin authorization, internal-key protection, date validation and start/resume
auditing. On Web, check preview invalidation, duplicate Start prevention, polling,
errors/results, vi/en, keyboard interaction and light/dark responsive layouts.

All executable QA files and generated artifacts stay in ignored keep-local-only
folders. This document is a shared verification plan, not executable test code.
Never flush shared Redis or call paid models as part of isolated QA.

## Verification result — 2026-10-26

93 checks passed: 89 existing regression checks and four local behavior repros.
Coverage includes replay, normal-pipeline compatibility, runtime readiness,
caption generation, RAG ingestion, Ambassador API/client, Commercial image API,
video parameters/styles, scheduling/event-loop behavior and trend persistence.
Worker/model and graph/vector calls were mocked; Redis was disposable. These
checks do not establish real worker availability or performance under load.

The four passing repros confirm unresolved behavior, not fixes:

1. A stale same-day replay can update graph data while Redis keeps a newer snapshot.
2. Global resolution can cluster same-label/name entities across Brand namespaces.
3. An archived replay can populate the live cache when no newer snapshot exists.
4. An in-flight blocking vector write can finish after async task cancellation.

See the known limitations in spec.md and remaining work in task.md. Require an
explicitly authorized runtime test for real S3 reads, paid AI or shared persistence;
inspect daily publication and resolution status rather than treating HTTP 202 as
successful completion.
