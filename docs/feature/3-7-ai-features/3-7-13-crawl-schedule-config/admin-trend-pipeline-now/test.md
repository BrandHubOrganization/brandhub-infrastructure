# Verification plan

- Manual and scheduled/direct CLI contenders cannot overlap; test real OS locks in
  separate processes. Busy requests do not launch another child. Releasing/exiting
  a process frees its lock; active orphan children prevent a new crawl.
- Fixed argv/cwd, no shell and no user commands. Missing Python/dependencies/browser/
  session returns unavailable before launching; no package installation or download.
- Success/failure/interruption/crashed parent update actual records honestly. Retain
  at most 20 completed runs, preserve active records and public run ID. No cookie,
  credential, environment values, local paths or raw subprocess output in responses.
- Collector exit 0 with no worker status stays QUEUED. Per-batch work is PROCESSING,
  finished batches without published status stay AGGREGATING, published data while
  resolution is pending stays RESOLVING. Only terminal publication plus completed/
  skipped resolution is COMPLETED; failed batches/source/resolution are PARTIAL or
  FAILED. Test no candidates, superseded live snapshot, missing Redis and retention.
- Existing pipeline entry is invoked once with unchanged source settings. Both
  successful and failed requests preserve schedule.json bytes and future schedule.
- API accepts background work with 202; 409 busy, 503 not ready. Internal key and
  Business Admin checks reject unauthorized callers. Audit accepted manual run once.
- Browser: Run now confirmation, pending/double-click guard, active disable, history
  polling, real schedule display, safe 409/503 and no premature success. Existing
  trend list/replay/graph still load. vi/en, light/dark and 375/768/1440 fit.
- No real network scrape, billable provider call, shared DB/Redis writes or seed.
  Executable QA and its generated files stay ignored outside src.

## Results — 2026-10-27

- 30 AI tests passed: 18 isolated pipeline/control cases and 12 existing scheduler/
  scheduler-ownership cases. Real Windows virtualenv/dummy process and OS lock tested.
  Fixed a false conflict caused by Windows venv's parent Python redirector.
- Existing Business AdminCrawlConfigServiceTest passed (5 tests). New isolated Mockito smoke
  verified Admin-only access, no upstream call on denial, one audit on acceptance,
  unchanged response payload and structured busy/unavailable mapping. Compile passed.
- Browser fixture passed confirmation/double-click, all full-flow stages, no early
  completion, 409/503, manual run with schedule disabled, vi/en, light/dark and no
  horizontal overflow at 375/768/1440. Error responses were deliberately mocked;
  no request reached live Business, Facebook or paid AI.
- Web targeted ESLint and production build passed. Existing build chunk-size/mixed
  static/dynamic-import warnings remain outside this feature.
- Read-only machine readiness: SESSION_MISSING; scheduler process not running.
  This does not prove live crawling or provider/database end-to-end success.

## Deployment and manual verification

1. Install declared AI requirements, including croniter/psutil. On the AI host,
   provision the bundled crawler with `start-local-facebook-crawler.bat setup`.
   Setup is an explicit operator action; readiness never installs/downloads anything.
2. Configure `FB_STORAGE_STATE` in AI `.env` to the session file (relative to
   social_crawler, or absolute). Run `start-local-facebook-crawler.bat login` and
   complete Facebook sign-in. Keep credentials and cookies local. Restart AI after
   creating/replacing its dedicated environment or changing inherited environment.
3. Start AI's existing crawl consumer with reachable RabbitMQ, trend Redis, Neo4j
   and Chroma dependencies. API and scheduler must share the same bundled crawler
   root/filesystem. Docker requires explicit runner/browser/session provisioning;
   a remote multi-host runner is not implemented by this local deployment.
4. Restart Business/AI for new routes. If using automatic scheduling, restart its
   process so it uses the shared run-control wrapper; schedule.json is unchanged.
   Starting that scheduler is optional for the manual button.
5. Admin > Xem trend > Chạy pipeline ngay. Confirm once; expect 202, then observe
   collection, queued/batch work, aggregation, DB publication and resolution. Check
   the exact pipelineRunId in worker logs and the resulting live trend snapshot.
   Disconnecting a worker must keep pending work pending, never invent completion.
6. No Mongo/Postgres migration, init or seeder change. Existing worker DB writes
   remain exactly those of the scheduled flow. Local coordination/log/cache files
   and executable QA stay ignored under keep-local-only, excluded from Docker.

## Interrupted recovery verification

- Reproduce dead crawler, 18 completed batches, no Redis/local closure: INTERRUPTED,
  not active; keep 450 posts/18 counts, no publication claimed and no provider calls.
- Missing Facebook cookies blocks new crawling but permits configured recovery;
  missing interpreter/dependencies, invalid/traversing manifest, missing files or
  a still-active collector blocks recovery with safe errors and no child launch.
- Recover original ID using fixed --recover-run only; completed batch markers are
  retained. Closure marks unvisited sources interrupted and final status partial.
- Same/opposite-action concurrent requests and separate API workers start at most
  one child. Double-click/retry and stale/unknown IDs return clear 409/404.
- Fresh closure/publication wins over interrupted crawler state; an old publication
  cannot finish a newer recovery attempt. Older attempts do not keep polling active.
- Existing nonfailed collection/queued/aggregation/resolution behavior stays valid.
- Admin/internal auth deny before launch; audit accepted recovery once. No browser
  session, cookies, local paths or raw exceptions are exposed in API responses.
- Browser mocked recovery while ready=false/session missing: interrupted card is
  visible without history; keyboard confirm/cancel, pending disable, 409/404/503,
  refreshed stage/counts and vi/en/light/dark/375px. No native browser confirmation.
- Run isolated regressions/build/lint; inspect real orphan status read-only only.
  Do not publish/recover the real run, rerun crawling or call paid AI during QA.

### Results — 2026-10-30

- 36 isolated AI checks passed (existing pipeline plus recovery regressions), using
  FakeRedis/temp roots/dummy child processes. Native recovery keeps the original
  pipeline ID and fixed argv. Actual run.py closure code, with publisher mocked,
  retains all 18 delivered batches and marks unvisited sources interrupted. No
  forced redelivery, browser crawl or live provider calls. Shared OS lock/race,
  malformed source/path/symlink, authentication and 404/409/503 cases covered.
- Business compile and local Mockito harness passed: Admin guards precede upstream
  calls, invalid IDs denied, original pipeline ID retained, one accepted recovery
  audit, safe failure mappings and no audit on rejected requests. No DB connection.
- Web lint/build passed. Real browser with all APIs mocked passed visible interrupted
  card without history, missing-session recovery, keyboard confirm/cancel, double
  click, partial result, explicit errors/readiness, vi/en and both themes at
  375/768/1440. Screenshots inspected; mobile explanation/button stack without
  horizontal overflow. Expected mocked 404/409/503 console entries only.
- Read-only check of the existing real run `20261027_145518`: running=null,
  status/stage=INTERRUPTED, canRecover=true, batchFinished=batchTotal=18.
  Recovery-only dependencies are present; unused requests/browser requirements
  do not block recovery. No real closure/recovery/provider execution performed.
- All new executable QA, logs and screenshots remain ignored in keep-local-only.

### Recovery rollout

Restart Business and AI Service after deploying the changed controllers/services;
reload Admin > Trends. The interrupted card is visible immediately. Select
Recover this run, review the confirmation, then explicitly confirm to publish its
saved closure and resume downstream aggregation. This action can invoke AI providers.
No Facebook login is required to close saved work; new crawls still require login.
Existing missing sources remain partial; do not mark the full 11-source run complete.
No migration, init, seeder, data reset, Redis deletion or schedule change is needed.
