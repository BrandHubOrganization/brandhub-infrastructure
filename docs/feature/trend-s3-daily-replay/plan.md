# Plan
## Neo4j preflight resilience — implementation plan
1. AI: in app/services/replay_readiness.py separate a single read-only graph probe, transient-error classification and bounded async retry orchestration. Use monotonic deadlines and asyncio timeout/sleep; unwrap causes conservatively, failing closed for auth/TLS/configuration errors even if wrapped in ServiceUnavailable. Do not retry all Exceptions.
2. Retain the existing shared async driver from app/utils/neo4j.py. Retry the connectivity/APOC probe as a unit. Do not replace session.run everywhere or change the NLP/graph write path. Count configured driver activity within the outer attempt and total budgets.
3. app/services/replay_runner.py: verify wait_work cancellation and heartbeat remain effective while readiness retries/sleeps; preserve structured safe error codes and checkpoints. Change only what tests prove necessary; no automatic resume.
4. Web: map recognized job/day/file error codes to translations in TrendReplayDetail.tsx using existing alerts; preserve raw safe legacy codes as fallback. Add parallel messages to src/i18n/locales/vi/admin.json and en/admin.json for DNS/network timeout/auth/TLS/APOC and a safe recovery instruction. Do not expose server credentials in the UI.
5. Verification: ignored Python QA with fake drivers, simulated DNS/auth/TLS/timeouts and controllable sleep/clock; existing replay order/resume/lease tests. Browser mocks for error messages, explicit Resume, vi/en, keyboard, 375/768/1440 and light/dark; Web CI. Keep existing tracked tests as appropriate; no new tests under src and no local QA artifacts in commits.
6. Rollout: finish code/isolated checks before service changes. Ensure no active Replay before restarting AI (read-only Redis job/lease check); coordinate with the user if one is active. Avoid --reload during a long manual run. Deploy Web/AI together, then perform read-only Neo4j/APOC probes without invoking AI or modifying graph data.
7. Acceptance: transient first-attempt DNS failure followed by success allows readiness to proceed; persistent failures stop within budget, retain checkpoints, and show a useful category. Real archive Resume remains an explicit operator action and is not part of automatic validation.
8. Risk/rollback: retries can increase time before reporting a real outage, so show PREFLIGHT and retain status polling/heartbeat. Nested driver retry must not exceed the outer deadline. Revert only this scoped retry/message change if needed; no DB rollback or preview recreation is required. Keep other current uncommitted feature work intact.
## S3 replay source separation & crawler key support
1. Separate replay S3 configuration (`TREND_REPLAY_S3_BUCKET=crawler-social`, `TREND_REPLAY_S3_PREFIX=`) from media (`S3_BUCKET_NAME=brandhubmedia`). Expose `bucket` and `default_prefix` alongside `jobs` in the replay list endpoint; disallow client-chosen buckets.
2. Allow empty prefix to scan from bucket root when `TREND_REPLAY_S3_PREFIX` is empty (or constrain to `TREND_REPLAY_S3_PREFIX` when set). Parse both crawler `dd-MM-yyyy` and `YYYY-MM-DD`/`YYYYMMDD` key dates; exclude keys with missing or conflicting dates. Keep pinned job `bucket`, `prefix`, `key`, and `ETag` immutable across config changes.
3. Update Business DTO/service and Web replay form so prefix is optional, defaults from Backend config, displays the active S3 bucket, explains that an empty prefix scans the whole bucket, and retains the 31-day and 500-file limits and multi-platform 25-post batch pipeline.
4. Verify with mocked S3/Redis unit checks, browser QA, Web CI, and a read-only preview against `crawler-social` when AWS credentials are valid (without starting AI extraction).

## Multi-platform update
1. Update replay_s3 discovery with conservative platform filename hints; add runtime platform counts to files.
2. Select registry adapter per raw platform/hint, normalize each adapter's timestamp fields while retaining original metadata. Use V3 contract and 25-row batches; prevent V2 resume without changing old checkpoints.
3. Update Web types/detail/form for platforms, translated stages and pipeline flow; validate dates before preview and retain API selection contract unchanged. Use shared Button and theme tokens for touched controls. Update vi/en admin.json.
4. Isolated adapter/runner/S3/Redis tests plus mocked browser QA and Web CI. No live S3 reads, paid extraction, replay starts or DB writes during verification.

1. Add bounded S3 manifest discovery/read module and request validation. Pin ETags,
   deterministic key dates and object sizes. Paginate listing; never arbitrary bucket.
2. Extend trend_run_store with optional root argument, preserving live defaults.
   Route replay through TrendService with separate history root and unchanged
   processing/persistence, then CrawlRunService finalization. Add historical daily
   snapshot support without changing normal live defaults.
3. Redis job store + leased async runner: start previewed job, sequential files/day,
   checkpoints, immutable source reads, safe failure and explicit resume.
4. AI internal /api/v1/ai/trends/replays preview/create/list/detail/resume routes.
5. Business Admin proxy controller/service + validated DTO, guarded authorization.
6. Feature-scoped Web service/types/hook/panels; Admin view/navigation and parallel
   src/i18n/locales/{vi,en}/admin.json keys; no new dependency/framework.
7. Isolated fake S3/Redis/pipeline checks and browser API-mocked fixture under
   keep-local-only; existing regressions, TypeScript/lint/build/Java compile.
8. Scoped old-trend preflight and cleanup only after user confirms stopped writers.
9. Read-only runtime preflight inside the leased async runner, before file work:
   Neo4j/APOC, Chroma heartbeat and MiniLM vector sanity. Import/model/network
   failures surface safe codes; no zero-vector or mock fallback. Restore missing
   dependencies from requirements, verify import compatibility, resume the existing
   job only when all checks pass. Do not reset checkpoints or replace the NLP model.
