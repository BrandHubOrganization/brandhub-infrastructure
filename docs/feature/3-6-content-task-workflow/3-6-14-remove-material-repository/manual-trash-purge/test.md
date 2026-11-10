# Verification
- Freshly deleted file can be queued immediately; original deletedAt is unchanged.
- Active file, referenced file, unauthorized user, and stale version cannot be queued.
- Bulk spans multiple pages, respects workspace/audience/ownership, excludes vault and active files, reports blocked skips.
- Worker claims manual requests younger than 30 days and retains reference/storage/quota protections.
- Cancel makes no request. Confirm uses modal, pending blocks duplicate submission. Bulk dialog explicitly says all accessible trash.
- VI/EN, light/dark and narrow screen preserve controls. API error shows translated feedback; queued is not reported as completed.

## Executed results (2026-11-05)
- Maven focused suites: 31 tests, 0 failures/errors/skips. Covers request service, HTTP contracts, purge worker, trash rules and access policy. Mock-based tests; storage production deletion was not exercised.
- npm run ci: pass (lint 0 errors / 82 existing warnings, type-check, production build). Existing large bundle warning remains.
- git diff --check: pass in web/business/infrastructure.
- Chrome DevTools could not connect: live browser theme/responsive/keyboard QA pending. Static review only.
- Feature not deployed; production change in this session was solely the authorized custom_workspace_id SQL migration (see prod/ec2-ecr/migrations).

## Operations
Automatic retention cleanup uses the existing purge-enabled and reference-inventory-verified gates. Explicit manual requests do not require these automatic flags: they require verified quota inventory and storage identity per file and undergo reference checks before queuing and deletion. The worker selects only explicit requests while automatic cleanup is disabled. The worker runs on its existing 60-second schedule and processes up to 50 files per batch. UI describes acceptance as requested rather than completed. Bulk counts may include skipped referenced, forbidden or concurrently changed files; it never bypasses storage checks or quota accounting. Audit records the requesting actor and retains original deletion metadata.

## Readiness regression
Default false automatic flags must not prevent a permitted, verified explicit request. Worker with flags false must only select marked requests and must not select expired files/drafts. Missing/unverified quota inventory must prevent enqueue and storage deletion. Existing references, conflict and access tests remain. The earlier operations note about gating manual requests is superseded by this correction.

Readiness correction verified: Maven focused suites (MaterialPermanentDeleteServiceTest, MaterialPurgeAccountingReadinessTest, MaterialTrashPurgeWorkerTest, MaterialRepositoryHttpTest, MaterialTrashRulesTest, MaterialAccessPolicyTest) passed: 37 tests, 0 failures/errors/skips. Regression first reproduced STORAGE_SCHEMA_NOT_READY with automatic flags false. Repeated AND query composition initially lost eligibility; corrected to a single conjunction and guarded by worker selection assertions. Local Business health GET returned UP; no live destructive request was replayed and running local service was not restarted. Changes require local restart.

Folder cases: empty folder succeeds; contained eligible files are queued atomically; active folder/file, other-owner descendants and referenced file abort without removing folders; CAS conflicts abort. Trash visibility excludes PURGE_IN_PROGRESS before pagination/counting. Verify confirmation cancellation/pending states and both locales.

Trash visibility/folder extension verified: 45 focused backend tests passed (including 2 query visibility and 6 transactional folder purge tests), npm run ci passed with 0 lint errors / 82 existing warnings, type-check and build succeeded. Diff whitespace checks passed. No real storage objects deleted during verification; no deployment/restart performed. Live browser QA remains pending. Folder removal aborts wholly on referenced/unauthorized/active descendants rather than partially deleting the tree.
