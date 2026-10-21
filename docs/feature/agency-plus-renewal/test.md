# Agency Plus renewal

Basic upgrade regression atomic rollback; active Plus renewal schedules future and does not grant credit early; scheduler activation at boundary grants once and expires old monthly balance once; expired Plus renew starts from payment; webhook replay no duplicate; non-owner/suspended blocked; one future/pending max. Popup sends RENEWAL and new cycle-scoped key, expiry today shown; queued disables additional renewal. Inspect targeted DB after transaction.

## Results — 2026-10-21
- Backend: 13 tests passed, zero failures/errors/skips: AgencyBillingPostgresTest 2 (rollback/replay; early renewal/deferred grant/activation/lapsed renewal), AgencyBillingServiceTest 2, BillingPlanControllerTest 2, InvoiceHistoryControllerTest 4, AdminInvoiceHistoryControllerTest 3.
- PostgreSQL 17 isolated package_test on loopback55439; renewal test loads actual paid-period overlap trigger and enforces unique future period. Replay creates one period; activation expires old 5,000 and grants new 5,000 exactly once. Non-owner and queued second renewal rejected. No real provider payments initiated.
- mvn -q -Duser.timezone=UTC -Dtest=AgencyBillingPostgresTest,AgencyBillingServiceTest,BillingPlanControllerTest,InvoiceHistoryControllerTest,AdminInvoiceHistoryControllerTest test with BRANDHUB_BILLING_ISOLATED_TEST=true and exact loopback test URL.
- All 22 subscription Playwright tests passed; targeted renewal test passed again after changing fulfilled-renewal UI text to Renewal recorded (future period is not prematurely called active).
- Typecheck, scoped ESLint and production build passed. Existing Vite chunk warnings unchanged. Subscription VI/EN parity and diff checks passed.
- Scheduled sweep runs every60s after15s startup, per-agency transaction/lock; checkout and webhook advance the same lifecycle atomically under their existing transaction. No schema migration required; existing FUTURE periods, ledger and indexes reused.
- AIM Academy Agency 5a4f221b-1350-4421-b060-d0eb7ccaf94d / subscription73aacb1c-aa9d-4d1a-ac60-0179a1fee289: current_period_end, CURRENT period.ends_at and linked PERIOD grant.expires_at set to2026-10-21T23:59:59+07:00. Status remains ACTIVE until that time. Single transaction with identity/PLUS/READY/no-future guards and TEST_EXPIRY_OVERRIDE audit. Existing payment/order receipt history preserved as original financial records; this is a local test entitlement override.
- Backup: .local-backups/aim-expiry-20261021/before-20261021-124042.json. No wallet balance changed by the test override; expiry sweep records the ledger change when due.
- Restart Business in the existing runner to load lifecycle/renewal code. UI uses existing plans page and payment popup. No live renewal checkout or bank transfer was performed.
- Broader Enterprise upgrades, AI provider reserve/settle and outbox delivery worker remain outside this task. Database test fixture container removed after verification.
