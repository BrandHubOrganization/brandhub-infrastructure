# Plan

UI refinement: keep the outstanding list outside an `aria-expanded` Button disclosure in CampaignClosureDialog. Mount the cancellation controls only when expanded; clear local destructive intent on collapse, error reload and successful cancellation. Add vi/en campaign locale keys; no API/DB change.

1. Serialize acceptance and closure with existing PostgreSQL agreement lock. Resolve Campaign on acceptance before Mongo Request+Task transaction. Add campaignId to new Tasks and permit verified Request provenance with Campaign association.
2. Extract closure inspection and batch cancellation service/store. Preview isolates planned deployment checks from supplemental Task list. Read Request summaries scoped to workspace. Cancellation uses session transaction and compare-and-set status/updatedAt, stores audit embedded on Task; does not touch task_approvals.
3. Gate complete server-side; record separate completed/cancelled totals and existing durable PENDING cleanup. Do not co-commit Mongo cancellation with SQL completion.
4. Add additive Mongo migration preserving current validator, extend CANCELLED and optional cancellation audit; fresh init and read-only checker/test parity updated. No SQL schema change. Existing unlinked source Tasks reported, not backfilled. Do not replay old validators after this migration.
5. UI CampaignDelivery uses separate Task groups and new CampaignClosureDialog to fetch preflight, select explicit batch/reason/Other, confirm and refresh after cancellation/conflict; final complete only when preview ready. IN_PROGRESS links to Requests; pending count shown.
6. Unit/API/isolated Mongo tests for provenance, missing planned Tasks, all unfinished statuses, cross-scope/stale/partial rollback, idempotency/audit preservation and Request blocking. Typecheck/build/targeted lint; no Atlas writes or commits.

Locales: src/i18n/locales/{vi,en}/campaign.json. Existing use of Task APIs remains unchanged outside extended response/cancellation domain. Future Task workflow writers must respect CANCELLED terminal and Campaign lifecycle lock; coordinate with Task owner.
