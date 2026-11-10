# Cases

- UI refinement: today vs future Campaign start chooses the later; inclusive final day; expired/invalid timeline has no selectable range. Workspace timezone different from browser and DST boundaries yield correct instant bounds. Create and edit use the same bounds; do not auto-clamp old values. Picker min/max, manual entry inline/native validation, loading/failure/retry save disabled, periodic/focus bounds refresh. API validation retained. vi/en, light/dark and mobile smoke.

- Manager completion cancels PENDING only; completed status prevents creation/edit/receipt, IN_PROGRESS acceptance/denial remains available.
- Concurrent receive versus completion resolves by agreement lock; Mongo atomic predicates never cancel IN_PROGRESS.
- Outbox failure leaves entry; retry after Mongo success before SQL acknowledgement does not duplicate history/version.
- Unauthorized/invalid completion never enqueues. SQL rollback never exposes queue job.
- Deadline today/start/end accepted, yesterday/before-start/after-end rejected; timezone day rollover; missing/invalid timeline fails closed; cancellation ignores old deadline.
- Optional contacts accepted; Vietnam local and international accepted; letters, double +, >15 digits rejected; invalid email and non-HTTP(S) website rejected. Unknown contact keys preserved.
- Backend bypass of UI receives field validation errors; UI shows matching errors and preserves input. vi/en keys parallel; semantic errors readable light/dark.
- Do not run integration tests against Atlas or mutate shared test data.

## Verification 2026-10-14

UI refinement: 9 Node unit tests pass (`node --experimental-strip-types --test --test-isolation=none tests/unit/request-deadline.test.mjs`, Node 24). Covers today/future start/expired/current whole day, Workspace day rollover, 23/25-hour DST days, invalid dates/timezone, differing browser timezone. TypeScript, targeted ESLint, build and locale parity pass. Playwright isolated mock confirms actual native min/max, underflow/overflow, inline error on invalid submit, valid last-minute save, expired/config failure save disabled, mobile dark date form. Real account end-to-end and browser-specific native calendar appearance remain manual checks. No database changes required for this UI refinement.

89 backend tests pass across ContentRequestAcceptanceMongoTest (14, owned ephemeral Mongo replica-set), ContentRequestCompletionTest (3), ContentRequestDeadlineTest (3), PartnerContactValidationTest (11), ContentRequestServiceTest (23), ContentRequestReviewServiceTest (13), CampaignDeploymentServiceImplTest (2), DirectoryPartnerServiceTest (12), ContentRequestCampaignGateTest (8). Frontend type-check and targeted ESLint pass. PostgreSQL fresh init and repeatable new migration run successfully in an isolated postgres:17-alpine container. No Atlas/shared data changed. Manual browser/theme checks remain pending.

## Before testing locally

Back up PostgreSQL and stop Business Service writers. Apply only `docs/database/migrations/2026-10-14-content-request-completion.sql` to the intended existing PostgreSQL database (ON_ERROR_STOP=1). Do not rerun init. Restart Business Service with the migration present, then refresh UI. No new Mongo migration is required; the previously required Request V2/Acceptance migrations must already be applied.

Mark a test Campaign completed as Manager. New Request/create/update/receive fail immediately; the durable worker changes PENDING to CANCELLED on its next 5-second poll under healthy storage. History shows the Manager actor and CAMPAIGN_COMPLETED reason; IN_PROGRESS remains. Mongo downtime retains the SQL job for retry; no cross-database atomicity is claimed. Old Campaigns completed before this release are not automatically backfilled. Check pending jobs using `SELECT * FROM content_request_completion_jobs ORDER BY created_at;`.

The Request date picker remains native; the UI refinement adds min/max using Workspace day boundaries converted to browser-local input values. Server validation remains authoritative. 401/shared authentication is deliberately unchanged.
