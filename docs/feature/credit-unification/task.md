# Tasks

## Test compatibility repair (2026-10-21)

- [x] Update the five existing Workspace/Caption/Credit/Video test files for unified accounting.
- [x] Compile all repository tests without suppressing test compilation.
- [x] Run the affected unit tests and PostgreSQL integration tests on a disposable local test database.
- [x] Record results and remove disposable infrastructure. No shared database changes or production behavior changes.

- [x] Inventory routes, callers, schema and existing tests.
- [x] Add trusted actions, stable request identity and durable receipts to DA-974 execution.
- [x] Integrate Caption generate/refine/adapt and replay-safe history.
- [x] Integrate new Video requests/reconciliation; isolate legacy completion/refund.
- [x] Add migration and init parity without changing existing migration files.
- [x] Switch workspace balance and Dashboard reporting to DA-974.
- [x] Update shared Web request invalidation and workspace AI service contracts.
- [x] Update vi/en keys and Dashboard period/unavailable states.
- [x] Verify retained light/dark/responsive behavior for changed labels.
- [x] Run isolated SQL/API/provider-fixture checks, compile, typecheck/build and diff review.
- [x] Document actual results, prerequisites and remaining live checks; keep verification artifacts ignored and outside deliverables.

Deployment is separate: shared/local application DB APPLY, real JWT/Gateway/provider acceptance and Admin configuration of missing prices remain pending. No automatic live rollout is authorized by a checked implementation task.
