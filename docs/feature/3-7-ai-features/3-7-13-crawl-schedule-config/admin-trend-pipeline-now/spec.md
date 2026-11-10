# Admin trend pipeline now

Corrected BA confirmed 2026-10-27: Admin starts the ENTIRE normal scheduled flow
immediately: crawl -> queue -> T0/T1/T2/T5 -> T4/T7 -> DB/cache publication and entity
resolution. This changes the trigger, not the pipeline. It is not an independent
crawler-control feature. Reuse social_crawler/run.py as scheduled ingestion entry;
retain legacy endpoints and leave the separate crawler-social repo untouched.

## Acceptance criteria

- Admin can request one immediate run of the existing run.py pipeline. Use the same
  sources, proxy, cookies, per-source delivery, RabbitMQ/S3 backup and downstream
  T0/T1/T2/T5 then T4/T7 processing as a scheduled run. Never feed mock/replay data.
- Preserve schedule.json and its enabled/cron settings. Manual runs are allowed
  while automatic scheduling is disabled; no new recurring schedule is created.
- A shared cross-process lock covers manual, scheduled and direct CLI run.py calls.
  Simultaneous manual requests or an existing run return TREND_PIPELINE_ALREADY_RUNNING (409),
  without starting another browser/pipeline. Detect still-active pipeline children
  after a parent crash before permitting another run.
- Return 202 only for accepted work. Keep RUNNING through collection, queue wait,
  batch processing, run aggregation, DB publication and entity resolution. Use the
  existing CrawlRunService.get_status for that exact pipeline run ID. COMPLETED
  requires terminal DB/cache publication and successful/skipped final resolution;
  partial source/batch/resolution failure is PARTIAL, never a false success. Missing
  worker progress remains QUEUED/PROCESSING; tracking outage is not completion.
- Validate runner readiness first. Missing environment/browser/session or unsupported
  deployment returns a safe actionable unavailable state; never install dependencies,
  download a browser or fall back to a different scraper automatically.
- Existing Admin authentication/auditing and internal service-key authentication
  apply. No client-supplied command, executable, path, URL or CLI arguments.
- vi/en keys under admin.trendPipeline remain parallel. Reuse
  compact shared Button/Dialog/Badge and semantic light/dark tokens. Confirm an
  explicit run, prevent duplicate clicks, show loading/409/unavailable and polling.

## Contract and storage

- AI internal GET /api/v1/ai/trends/pipeline, GET/POST same prefix + /runs.
- Business Admin GET /api/v1/admin/ai/trend-pipeline and GET/POST + /runs.
- A pipeline run includes stage, collection status, pipeline ID, batch progress,
  DB/live publication and entity-resolution status. Metadata adds readiness, schedule
  enabled/cron/next-run, timezone and scheduler-running state, without secrets.
- This deployment uses the bundled runner on the AI host and its dedicated Python
  environment. Runtime coordination/history live in ignored social_crawler/
  keep-local-only, on the same filesystem for API and scheduler. No Mongo/Postgres
  schema, init or seeder changes. Multi-host runner orchestration is out of scope.
- No real paid/provider crawl, database reset or shared storage writes during QA.

## Interrupted-run recovery (2026-10-30)

- A dead/failed crawler with no received closure manifest and no confirmed publication
  is INTERRUPTED, never RUNNING solely because Redis retains completed batches.
  Interrupted runs are visible without opening history and do not block new runs.
- Admin may explicitly recover an interrupted run by its opaque control ID using
  POST /runs/{id}/recover on the existing Business/AI prefixes. Recovery reuses
  run.py --recover-run with the original pipeline ID, no browser/new crawl and no
  forced batch reprocessing. It closes the saved run and preserves partial sources.
- Recovery needs valid local source metadata, Python dependencies, Redis and broker,
  not a Facebook session. Readiness for new crawls remains separately enforced.
- Unknown IDs return 404; invalid/stale/nonrecoverable runs return 409; active work
  conflicts and missing infrastructure remain 409/503. Admin/internal auth and one
  audit per accepted recovery apply. Fixed argv, no caller path/command overrides.
- Polling/startup never initiates provider calls. Show interrupted progress honestly,
  and confirm recovery may invoke downstream AI aggregation/provider costs.
- Shared dispatch/process locks cover normal start and recovery. Deduplicate attempts
  by original pipeline ID, preserve original counts and terminal partial semantics.
- UI keys under admin.trendPipeline: recover, recovering, interruptedDescription,
  recoveryUnavailable, recoveryNotReady, recoveryAccepted, recoveryConflict,
  runNotFound, confirmRecoveryTitle, confirmRecoveryDescription, sessionMissing,
  cancel and stage.INTERRUPTED/stage.RECOVERING, in vi/en admin.json. Use existing
  semantic light/dark tokens, keyboard-focusable controls and responsive wrapping.
- No DB migration/init/seeder change; executable QA stays in keep-local-only.
