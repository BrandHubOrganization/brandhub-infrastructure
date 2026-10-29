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
