# Test plan

Seams: actual AgencyBillingService public create/order/webhook methods through Spring transaction proxy and PostgreSQL; existing local QA API endpoints plus SQL financial oracle. These are the previously accepted seams. No collaborator mocks for transactional behavior.

1. Same id/same payload: one payment/period/grant/outbox. Same id/amount changed: unchanged original hash/financial state, durable warning/audit.
2. Changed duplicate content to unknown code or another agency: original event warning/audit, no new fulfillment or cross-agency link.
3. Equivalent numeric scale/timezone timestamp: idempotent without false conflict.
4. Audit write failure: exception/rollback, retry after fault removal records evidence once; original payment remains unchanged.
5. paidAt before expiry: pending and polled EXPIRED both fulfill once. paidAt at/after expiry, missing/bad date, bad amount remain review.
6. Concurrent duplicate callbacks and replay after late fulfillment: one financial effect.
7. A conflicting already-purchased plan/future period keeps late order in review with reason.
8. Existing QA TX-04/TX-09 expected unchanged; run dependent mutation load only after all prerequisites PASS. Report skip/BLOCKED honestly.

Actual execution results: see verification below.

9. Distinct event IDs on the same fulfilled order: two stored payments (one VERIFIED, one REVIEW_REQUIRED), one period/grant/outbox and original attempt SUCCEEDED. AB-10 exposed the original attempt being overwritten to UNKNOWN; expected is unchanged.


## Actual results

Business suite: 1093 registered, 1020 executed PASS, 73 existing gated skips, no failures/errors. All 11 new PostgreSQL Testcontainers regressions PASS. QA webhook-fix-complete: 26 selected cases PASS including AB-06–10 and TX-06; 22 cases not selected. Both primary bugs and additional AB-10 bug demonstrated RED before their production fix.

Commands: `mvn test -Dapi.version=1.44` in business-service; QA commands and raw per-case evidence are in `qa/payment/README.md` and `qa/payment/reports/webhook-fix-complete/`. Final report: `qa/payment/reports/webhook-fix-complete/fix-summary.md`.

Harness correction: TX-04 previously froze event.last_error while requiring a warning. It now freezes financial/order/wallet effects and separately verifies original event hash/status/identity plus durable warning/audit. Expected business behavior did not change. Deadline equality fixture was aligned with PostgreSQL timestamp precision. Narrow test context excludes application auto-configuration.

## Standards

Wildcard imports and abbreviated variables corrected; final static review reports no hard safety/transaction blocker.

## Spec

Global duplicate detection, canonical/exact legacy replay, audit rollback, cross-agency isolation and late-expiry behavior match the accepted policy. Additional-payment review preserves original successful attempt. Original reports retained, no source business expectations relaxed, no commit/push.
