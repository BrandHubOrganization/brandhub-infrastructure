# Tests
- Disconnect A deletes tracked resources and connection; connect B succeeds with fresh root.
- Google deletion failure retains pending cleanup and credentials; another connection is refused; retry succeeds; 404 is idempotent.
- Other agencies and SYSTEM_S3/SYSTEM_GDRIVE materials and quota are preserved.
- Committed Drive quota released once; reserved uploads fail and release; old OAuth cannot reconnect.
- In light/dark, mobile and keyboard, cancel warning sends no DELETE; confirmation explains irreversible deletion across agency workspaces and enables connect only after success.
- Switch language: matching vi/en keys, readable warning. Pending cleanup displays retry without connect. No real cloud resources are deleted during verification.

## Results
- Maven: 13 CustomerDriveIntegrationTest + 3 CustomerDriveApiTest passed, none skipped, PostgreSQL/MongoDB Testcontainers; Google calls mocked. Docker API compatibility required DOCKER_API_VERSION=1.44 and -Dapi.version=1.44.
- Playwright: 7 Drive tests passed; 2 confirmation cases also rerun and screenshots visually checked in light/dark at 390px, keyboard cancel/confirm. APIs mocked.
- Changed frontend files: ESLint and TypeScript passed. vi/en keys are parallel.
- Migration prepared only: apply docs/database/migrations/2026-10-27-customer-drive-disconnect.sql before backend restart/deploy. No live data or Drive files deleted.
- Final regression also covers disconnect before the first OAuth completion; pending state is invalidated even without a saved connection. Authorization creation is serialized with cleanup.

- Readiness warnings identify missing variable names, invalid Base64/32-byte key and missing schema objects, without including any secret values.

Readiness diagnostics: CustomerDriveReadinessTest (1) + CustomerDriveIntegrationTest (13) passed with none skipped; log assertions confirm reasons and absence of configuration values.

- Missing callback session: no complete request, actionable console reason/flags, no code/state leaked; valid callback still completes exactly once.

Callback diagnostics: regression first failed due to absent warning; after implementation all 8 Drive Playwright tests passed. Changed callback passes ESLint and TypeScript. No live OAuth requests were replayed; the actual user failure still needs presence flags/origin evidence.
