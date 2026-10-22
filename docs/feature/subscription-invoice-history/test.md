# Test plan
Java: owner/non-owner/former owner, foreign order returns 404 before provider call; filters all predicates scoped; same-time cursor tie break no overlap; invalid cursor/date/limit rejected; empty; amount > JS safe integer preserved; verified fulfilled receipt only; GET no writes. HTTP provider fixtures: bearer, q full code, ISO8601 timestamps, UUID numeric mismatch avoided, extra matches rejected (other account/out/prefix/old date), missing token no call, 401/429/timeout/malformed -> safe errors. API v2 pagination has_more remains visible.
Browser: empty/loading/error/retry; agency isolation including pending old response; filter next/back; detail local/provider separately; no VAT invoice/download fake; receipt actual Blob; keyboard, mobile, light/dark and en/vi.
Run commands/results added after implementation. SePay unavailable must leave local history usable. Live smoke only read-only, secret values never logged.

## Results — 2026-10-21
- Backend: 15 tests, zero failures/errors/skips: InvoiceHistoryPostgresTest 3; InvoiceHistoryControllerTest 4; InvoiceProviderServiceTest 1; SePayTransactionClientTest 5; existing AgencyBillingServiceTest 2.
- Isolated PostgreSQL 17 on 127.0.0.1:55441/history_test; test fixture loads actual billing table definitions from the expand migration. No application data modified. Fresh image rejects legacy host timezone Asia/Saigon: test JVM explicitly uses UTC; application timestamps remain offset-aware.
- Command: mvn -q -Duser.timezone=UTC -Dtest=InvoiceHistoryPostgresTest,InvoiceHistoryControllerTest,InvoiceProviderServiceTest,SePayTransactionClientTest,AgencyBillingServiceTest test with BRANDHUB_HISTORY_ISOLATED_TEST=true and the exact loopback test URL.
- Browser: all 17 subscription tests passed, including 4 new history tests. Command: npx playwright test tests/e2e/subscription --workers=4 --reporter=list.
- npm run type-check and npm run build passed. Existing Vite chunk-size/dynamic-import warnings remain unrelated.
- One live read-only request to official SePay v2 with the locally configured API token returned HTTP 200, status success, one result and documented fields for latest BrandHub transfer code. No payment confirmation, replay, bank mutation or unrelated transaction dump occurred. This validates provider token/API compatibility, not a deployed end-to-end UI/backend session.
- VI/EN key parity passed. UI test covers 375px overflow, dark theme class and English heading. Full manual visual review not performed.
- No DB migration needed. Application Gateway/Business were not running during final checks; restart through the existing runner to load compiled code, then open /subscription/invoices or Payment history link on plans.
- SEPAY_API_TOKEN is now consumed server-side; SEPAY_API_SANDBOX=false by default. Missing/invalid token and provider failures leave internal history available. Rate gate is per process; a shared quota coordinator for multiple deployed instances is outside this local implementation.
- Legacy /billing/transactions stubs remain unused; the implemented agency-scoped API is /api/v1/billing/agencies/{agencyId}/invoices. Tax invoice generation, refunds and reconciliation writes are not claimed by this read-only history feature.

## Sidebar navigation correction
Owner dashboard with selected agency shows Payment history link and clicking navigates to /subscription/invoices; agency member does not see billing links. No new locale keys; existing semantic sidebar styles retained.

Sidebar correction verification: 2 targeted Playwright tests passed (owner direct navigation, member hidden); type-check and git diff --check passed.

## Right-side detail drawer
At1440px drawer width480px right aligned;375px full viewport; no horizontal overflow. Escape closes and restores focus; selected details and provider/receipt remain usable. Admin agency filter can still reset details without a modal overlay blocking table controls.

Drawer verification: 8 owner/admin history browser tests passed after adapting the prior inline-detail test to close the drawer before clicking controls covered by it. Drawer width/right alignment checked at1440px (480px, x960), mobile375px full width and no page overflow; Escape closes and restores trigger focus. Targeted dark screenshot check additionally passed after waiting for theme transitions: dark surface and light foreground verified. Desktop and mobile dark screenshots visually inspected. Type-check, scoped ESLint and diff check pass. Drawer overlays the right third; close it to access controls beneath that area. No payment/API/backend behavior changed.
