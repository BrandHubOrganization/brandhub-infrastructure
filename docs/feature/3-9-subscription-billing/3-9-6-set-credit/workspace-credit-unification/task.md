# Tasks

- [x] Confirm Agency/shared-cap semantics, NULL, zero, Owner participation and local-only reset scope/writer pause.
- [x] Implement shared Subscription schema extension and matching fresh init without editing teammates' migrations.
- [x] Verify schema on isolated PostgreSQL, including collision fail-safe and repeat apply.
- [x] Unify money mutations/journals and AI execution, replace member enforcement with Workspace caps.
- [x] Integrate lifecycle/grant/reporting and schema guards/seeders; preserve provider/content behavior.
- [x] Add authorized Workspace cap/list/usage APIs and retire member mutations.
- [x] Update Credit Web and parallel VI/EN; check light/dark, keyboard and responsive states.
- [x] Update only existing remote tests, keep local verification artifacts ignored, run compile and targeted tests/build.
- [x] Inventory then reset only authorized local financial test data; apply verified schema and verify unaffected data.
- [x] Record exact checks/results and manual test prerequisites; no unsupported readiness claims.

Remaining verification limitation: the separate Testcontainers webhook suite cannot initialize against the installed Docker engine (HTTP 400). Loopback PostgreSQL Subscription fulfillment/renewal tests pass; real paid AI, real payment and the complete live-service HTTP journey have not been executed.
