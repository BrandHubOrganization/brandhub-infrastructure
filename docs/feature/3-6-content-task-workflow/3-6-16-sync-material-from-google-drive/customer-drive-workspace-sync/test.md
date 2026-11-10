# Tests
- Empty unverified agency initializes only with no materials, sessions, reservations or receipts; legacy inventory remains blocked. Concurrent initialization is idempotent.
- Missing connected Drive yields actionable error. Existing upload content validation and quota remain.
- Import a supported binary from mapped workspace (including nested folder), never agency root/other workspace; repeated listing produces one mapping/material; skip app-managed/native/shortcut and tombstones.
- Import count/bytes accounted once; metadata retry repairs after Mongo failure. Disconnect fences sync and removes resources.
- Broad scope absent: do not import and log reconnect required, never log credentials. Test pagination, errors and unique identity.
- vi/en error keys parallel; existing light/dark controls unchanged.

## Results
- Backend: 19 CustomerDriveIntegrationTest + 5 CustomerDriveApiTest + 1 CustomerDriveReadinessTest + 3 MaterialContentValidatorTest + 1 MaterialUploadCoordinatorTest = 29 passed, none skipped. PG/Mongo run in disposable Testcontainers, Google mocked.
- Frontend: 14 Playwright Drive/upload tests passed, covering light/dark and mobile upload, reconnection guidance, specific missing-agency-Drive error, internal visibility and existing callbacks.
- Actual configured Mongo supports transactions but lacked the upload session unique index; the additive index migration passed dry-run and apply. No collections reset, no validator replacement or legacy backfill.
- Applied granted_scope migration to local PG; enabled explicit local writes/sync flags. Business restarted successfully on 8081 with customer_drive_ready.
- The reported workspace agency currently has no Drive connection. A human Owner/Manager must authorize its Google account with the new full Drive scope before real upload/import can be verified. No live external file was imported or deleted during these checks.
