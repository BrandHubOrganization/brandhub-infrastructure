# Verification
- Free/paid with Drive available => USER_GDRIVE. Drive full + active paid with S3 available => SYSTEM_S3. Free/expired/full S3 => actionable failure.
- Timeout/revoked grant never routes to S3. Idempotent retry retains selected provider.
- Concurrent reservation capacity/quota, release/purge accounting, immutable provider and reads after plan expiry.
- Owner/Manager connect; Creator/Client forbidden. Creator creates internal files; only Owner/Manager share Client audience.
- OAuth state single use and actor/workspace bound; altered PKCE/state/code denied; tokens absent from API/logs; reconnect same account.
- Idempotent folder provisioning by ID; unicode names; same-name agencies/workspaces isolated.
- Private preview, range/video, expiration, disconnect, missing/deleted external object; no public Drive permissions.
- Frontend connect completion, denial/retry, disabled/unconfigured, vi/en parity, light/dark and narrow viewport.

Status: implementation in progress; no live migration or OAuth connection performed.

## Implementation evidence
- Added source: CustomerDriveConnectionService/API/ObjectStore/Links, authenticated workspace management controller, capability media controller, encrypted grant storage, DriveOperationLease and Drive-first paid-overflow routing.
- Backend tests cover Drive preference, paid-only overflow, expiration, generic failures, simultaneous reservations, commit during capacity sampling, shared Google account across agencies, actor-bound single-use OAuth state, disconnect fencing, recovery after uncertain copy/deletion, operation-bound expiring capabilities, exact provider capacity classification and single URI encoding.
- Frontend verification includes Owner/Manager controls, Creator/Client isolation, callback replay avoidance/history cleanup and one bounded fresh-reservation retry on capacity failure. Repository regression also exercises previous view/update/download/Trash workflows.
- Runtime remains disabled by default; live Google/production rollout is not verified by local mocks and disposable database tests. Follow plan.md before activation.

## Final local verification — 2026-10-26
- Business full Maven suite: 1288 tests, 0 failures, 0 errors, 93 existing conditional skips. Customer Drive tests: 14 tests, no skips, including real disposable PostgreSQL/Mongo setup.
- Gateway full Maven suite:47 tests, 0 failures/errors/skips. Includes capability IP throttling/fail-closed behavior and capability-query log redaction.
- Web: TypeScript/build passed;14 unit tests passed; changed source ESLint clean. Existing bundle-size advisory remains.
- Repository Playwright regression:26 tests passed. Two additional Owner/Manager keyboard checks passed;390px light/dark screenshots visually inspected.
- Git diff whitespace checks passed. Migration applied only to disposable test databases.

## Standards review
Initial gateway YAML, remote-I/O transaction, recovery and UI error-state findings were fixed. Final independent recheck found no remaining high-impact issue. Small existing repository conventions were preserved; this is not a claim that all pre-existing source is lint-clean.

## Spec review
Initial stale-capacity, shared-account, purchased-quota, Owner access, recovery, encoding and disconnect-race findings were fixed and covered by tests. Final independent recheck found no remaining high-impact issue.

The user explicitly requested keeping all changes uncommitted for later consolidation. No work was staged or committed.

## 2026-10-27 BR update
Disconnect A removes BrandHub-managed Drive files/folders, invalidates materials and old callbacks, releases quota and allows B. Failure retains retry state and blocks B; other providers/agencies remain. Targeted validation: 13 integration + 3 API tests passed with local Testcontainers; 7 Playwright Drive tests passed with mocked APIs.

- New workspace folders use workspaces.name, including Unicode. Existing workspace_1 mapping is renamed to the workspace name, retains folder ID, and never creates a duplicate. Same-name folders require no PATCH.

Workspace naming validation: 14 integration + 4 API tests passed, none skipped. Mapped folder rename preserves ID, handles Unicode and skips PATCH when name already matches. No live rename performed: current configured database contains no workspace_drive_folders mapping. Restart business to load the naming change; existing mapped folders sync when folder(workspace) next resolves.
