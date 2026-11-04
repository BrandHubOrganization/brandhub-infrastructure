# Tasks

- [x] Shared cross-process lock, runtime records and actual process detection.
- [x] Wrap existing run.py and identify manual/scheduled invocations.
- [x] Add full-pipeline readiness/start/status/history and existing worker tracking.
- [x] Add Admin-only Business proxy, audit and structured error mapping.
- [x] Integrate Run pipeline now with schedule, all processing stages and recent runs.
- [x] Update vi/en keys; verify keyboard, light/dark and mobile.
- [x] Verify isolated race/failure/auth/UI cases and build/lint.
- [x] Document deployment, runtime storage and init/seeder impact.

Live provider verification remains pending Facebook session configuration. No real
crawl or paid provider execution was performed during implementation.

## Interrupted-run recovery
- [x] Correct stale RUNNING mapping and deduplicate recovery attempts.
- [x] Add manifest-validated, browser-independent recovery with shared locks.
- [x] Add authenticated recovery API/proxy and accepted-action audit.
- [x] Show interrupted cards and recovery confirmation with shared pending guard.
- [x] Update vi/en and check keyboard, light/dark and responsive layout.
- [x] Verify restart, races, original run ID, partial sources and unchanged schedule.
- [x] Document rollout and verify live status read-only; no real recovery during QA.
