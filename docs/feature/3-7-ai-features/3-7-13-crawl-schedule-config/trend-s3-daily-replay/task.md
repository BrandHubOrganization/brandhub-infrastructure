# Tasks
## Neo4j preflight resilience
- [x] Reproduce exact Replay probe failure and immediate successful retry; record limits of the diagnosis.
- [x] Save spec -> plan -> task -> test before code.
- [x] Implement safe driver-error classification and bounded async graph preflight retry (max 3 attempts, 2s/5s backoff, 15s per-attempt, 60s total deadline).
- [x] Verify timeout/cancellation, lease heartbeat and no model/file work after failure (13 isolated unit tests in `test_neo4j_preflight.py` passed).
- [x] Add translated error guidance in vi/admin.json + en/admin.json and legacy-code fallback.
- [x] Verify light/dark, responsive layout and keyboard/Resume behavior (`TrendReplayDetail.tsx` error block + resume hint + action button).
- [x] Run isolated retry, existing replay/resume/lease regressions and Web CI (`tsc -b --noEmit` and `eslint` 0 errors).
- [x] Review diff for secrets, unrelated features and local/test artifacts.
- [x] Check active Replay before restarting; verified active lease is `None`.
- [x] Run read-only Neo4j/APOC smoke checks and report results; do not auto-resume or invoke paid AI.

## S3 replay source separation & crawler key support
- [x] Update `spec -> plan -> task -> test` docs for replay S3 separation and crawler `dd-MM-yyyy` support.
- [x] Separate `TREND_REPLAY_S3_BUCKET`/`TREND_REPLAY_S3_PREFIX` config, support optional/root prefix and `dd-MM-yyyy` date parsing, and return S3 source info to UI.
- [x] Update Web replay form to show active bucket, make prefix optional with Backend default, and keep 31-day/500-file bounds and V3 batch-25 pipeline unchanged.
- [x] Run isolated S3/date/config tests, Java compile, browser QA, Web CI, and live read-only `crawler-social` preview check (`POST /api/v1/ai/trends/replays/preview` -> HTTP 200, 5 days `2026-10-26`..`2026-10-30`, 118 files).

## Multi-platform update
- [x] Support all three native adapters and preserve timestamps.
- [x] Version new replay checkpoints and match 25-post batches.
- [x] Add platform and processing-stage UI, date validation and locale parity.
- [x] Verify isolated regressions, browser UI and Web CI; no live replay.

- [x] Validate and preview S3 file manifest.
- [x] Isolate replay history and daily pipeline results.
- [x] Persist/fence execution, progress, errors, resume and API routes.
- [x] Admin Business access checks, forwarding and audit.
- [x] Admin form/preview/tracking/results and vi/en labels.
- [x] Verify ordering, dedup, history exclusion, lease-expiry/resume, failure handling with isolated dependencies.
- [x] Verify UI responsive/light-dark and build; no live writes/costs.
- [x] Verify real S3/model replay recovery after the user's explicit instruction to continue.
- [ ] User acceptance of the real published results in Admin UI.
- [x] Reuse complete live downstream persistence; expose DB publication status.
- [x] Verify historical daily publication, failure propagation and live defaults.
- [x] Confirm scoped cleanup; perform read-only preflight of available stores.
- [ ] Clear authorized trend data only after Neo4j is reachable (operator deferred cleanup).
- [x] Add leased PREFLIGHT before extraction and test failure blocks file/model work.
- [x] Verify resume from completed checkpoints and normal publication.
- [ ] Scope entity resolution to public trend data and enforce namespace boundaries.
- [ ] Protect shared graph/vector writes against stale replay and concurrent crawl.
- [ ] Define historical versus current-live publication and freshness policy.
- [ ] Fence in-flight storage writes when replay ownership is lost.
