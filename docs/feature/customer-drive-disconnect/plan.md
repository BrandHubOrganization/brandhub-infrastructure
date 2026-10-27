# Plan
1. Add idempotent disconnecting column migration. Exclude pending cleanup from grants; expose status and block new OAuth. Fence generation and hold durable agency operation lease.
2. CustomerDriveDisconnectService orchestrates Mongo tombstones/session cancellation, remote deletion, then transactional quota receipts/reservations/mapping cleanup. Keep retry identity on failure. Guard quota commit against disconnected grants.
3. Existing AgencyStorageCard and connection hook show pending cleanup and destructive confirmation; invalidate all agency material caches on success/failure. Change vi/en workspace.json and service status type.
4. Extend CustomerDriveIntegrationTest and customer-drive.spec.ts for switching accounts, retry/404/isolation, confirmation and cancellation. Run Maven targeted tests, TypeScript and Playwright.

Add safe readiness warnings in CustomerDriveConnectionService; query missing schema objects in one SQL request; verify logged reasons without exposing secrets.
Readiness is logged on ApplicationReadyEvent as well as failed status checks; startup diagnostics catch database-access errors without failing application startup.

Add safe callback diagnostics to CustomerDriveCallback.tsx, exercised with a missing-session Playwright regression; keep URL scrubbing and context cleanup.
