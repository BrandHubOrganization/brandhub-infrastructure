# Plan

1. Add a shared crawler run-control module with an OS file lock, atomic private
   runtime records, process identity checks and bounded history. Wrap run.py's
   existing main without altering crawling, publication, closure or recovery logic.
   Scheduler subprocesses identify SCHEDULED versus MANUAL and use the same wrapper.
2. Add internal ingestion runner using a fixed executable/run.py command, hidden
   Windows process or detached Unix session, readiness preflight and safe errors.
   Prefer the dedicated social_crawler/.venv; no shell, installer or arbitrary input.
   Expose only through a full-pipeline orchestrator, separately from legacy APIs.
   Join local collection metadata with existing Redis CrawlRunService tracking by
   pipeline run ID. Wait for publication/resolution, not just process exit; never
   reimplement the downstream worker or publish sample data. Persist terminal view
   in private runtime metadata so Redis retention cannot turn finished jobs pending.
3. Add a thin Admin Business proxy/service with requireAdmin and audit. Keep legacy
   APIs intact; map upstream busy/unavailable to structured 409/503. Pass through
   the safe camelCase pipeline DTO. No global AI-client, editor, credit or publication changes.
4. Add a compact TrendPipelineControl component/hook. Display the real schedule
   next to Run pipeline now; show each pipeline stage and a bounded recent-runs
   list. Keep existing publication summary and trend/replay/graph views. Refresh
   trend queries after complete/partial publication, not after collector exit.
5. Parallel src/i18n/locales/vi/admin.json and en/admin.json updates, keyboard/mobile/
   light/dark verification. Add only required runner dependency declarations and
   ignore generated coordination data in Git/Docker. Document setup and rollout.
6. Test locks, races, process failure, unchanged cron, no shell/injection, auth/error
   mapping and UI polling using dummy subprocesses, temporary roots and mocked APIs.
   Keep new executable QA under ignored keep-local-only; do not run real Facebook
   crawling or paid APIs. Build/type-check/lint the changed services and Web.

## Interrupted-run correction

1. Reconcile failed crawler + absent closure into INTERRUPTED in TrendPipelineControl;
   retain genuine queued/closed-run work and confirmed terminal publication. Group
   attempts by pipeline ID before selecting active work. No startup/reconcile writes.
2. Add validated manifest recovery and a non-browser preflight to LocalTrendRunner;
   share fixed child launch, dispatch/process locks and original recovery CLI. Record
   attempt mode so active recovery uses RECOVERING, not CRAWLING.
3. Add internal recovery endpoint and safe 404/409 mapping. Proxy through thin
   AdminTrendPipelineController/AdminTrendPipelineService, preserving audit/auth.
4. Extend Web types/service/hook; show interrupted cards immediately, with explicit
   per-run recovery and shared pending guard. Separate crawl and recovery readiness.
   Reuse confirmation Dialog and recover source data without misleading success.
5. Update src/i18n/locales/{vi,en}/admin.json, preserving existing theme/layout.
   Isolated fake Redis, temporary manifests/dummy processes, mocked HTTP/browser QA
   cover restart, no duplicate launch, invalid input and interrupted-to-partial flow.
