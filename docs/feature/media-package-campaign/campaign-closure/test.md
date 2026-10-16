# Tests

- Refinement: unfinished names/statuses always visible; initially no cancellation checkboxes/reason/button. Open cancellation option by keyboard/click, select explicitly; opening sends no write. Collapse and reopen clears selections/reason/note/confirmation. Normal completion remains blocked regardless of disclosure state; successful cancellation refreshes readiness and collapses controls. vi/en labels, mobile and both themes remain readable.

- Newly accepted Request Task campaignId=current, campaignWorkItemId=null, source preserved; acceptance retry no duplicate, closed Campaign forbids new acceptance. Null-campaign legacy reads retained but closure blocks unlinked source Tasks pending review.
- Missing/wrong planned identity fails deployment check; supplemental Tasks never alter approved workItems/deliverable quantities and do not count as missing/extra planned entries.
- BACKLOG, DETAIL_IDENTIFIED, ASSIGNED, IN_PROGRESS, QC_REVIEW, MANAGER_REVIEW, CLIENT_REVIEW all block; COMPLETED/CANCELLED allow. IN_PROGRESS Request blocks even if Tasks terminal; PENDING preview count and successful completion queue unchanged.
- Manager only; other workspace/campaign Task rejected; completed Task rejected; stale status/updatedAt rolls back entire batch; invalid/OTHER empty reason rejected. Repeat cancellation preserves original audit. Mixed sources allowed; task_approvals untouched.
- Acceptance versus completion uses same agreement lock; final completion rechecks Tasks/Requests and ignores reason bypass. Mongo outage/schema absence must fail closed, not treat unknown as empty.
- Mongo migration dry run has no writes; APPLY preserves validator/indexes/data and appends CANCELLED; repeat APPLY safe; init matches cumulative migrations.
- Dialog shows no default selections/reason, selected count/reason confirmation; conflict reloads state; busy guards double submit; request links work. vi/en and light/dark, keyboard and mobile.

## Deployment

Back up Atlas and freeze writers. Run prior Request V2/Acceptance if missing, then new campaign-closure migration DRY_RUN and review; APPLY only on intended brandhub. No init on live DB. Restart code after schema. Do not backfill old unlinked Task data without explicit review/approval.

## Verification 2026-10-14

UI refinement verification: TypeScript, targeted ESLint, production build and vi/en key parity pass. Isolated Playwright mock confirms collapsed default, visible outstanding list, keyboard expand, selection/reason reset on collapse, OTHER note required, explicit confirmation before cancellation and final completion after readiness. Mobile/tablet/desktop 375/768/1440 have no horizontal overflow; vi/light and en/dark checked. No real API/account/database writes. The existing mockContentLibraryService build warning is unrelated.

- 97 targeted backend checks across CampaignClosureControllerTest (3), ContentRequestControllerTest (8), ContentRequestReviewControllerTest (5), CampaignClosureServiceTest (13), CampaignDeploymentServiceImplTest (2), ContentRequestReviewServiceTest (13), ContentRequestCampaignGateTest (8), ContentRequestAcceptanceMongoTest (16 on owned ephemeral replica set), ContentRequestServiceTest (23), ContentRequestDeadlineTest (3), ContentRequestCompletionTest (3). No shared DB or Spring application seeders used.
- 12 offline migration/checker tests: fresh init matches eight migrations; closure DRY_RUN does not mutate, APPLY repeat preserves indexes/earlier validators. Real Mongo 7 smoke confirms DRY_RUN/APPLY/repeat and cancellation audit validation (caught/fixed mongosh optional-chain method compatibility).
- Frontend type-check, targeted ESLint and production build pass (existing unrelated mockContentLibrary dynamic-import warning remains). Browser mock proves no preselection, OTHER requires note, first click only confirms, one batch submit, completion enabled after terminal Tasks, received Request warning/link, planned/supplemental separation. Mobile dark screenshot inspected, width 375/scrollWidth 375. Temporary harness had development HMR/createRoot warning and favicon 404; neither involved production API.
- Live Atlas migration, real account end-to-end, legacy data reconciliation and concurrent writes from other members' future Task workflows remain integration checks. Those writers must respect CANCELLED and Campaign lifecycle gates; no editor/approval module was rewritten.

Playground: prepend `globalThis.CAMPAIGN_CLOSURE_APPLY = false;` then full `docs/database/migrations/2026-10-14-campaign-closure.js`. Review output and backup, then switch flag true and Run All. The script selects brandhub itself. Never rerun init. No new PostgreSQL migration in this change; existing content_request_completion_jobs remains required.
