# Tests

Status: automated implementation checks PASS, 20/10/2026. Real signed-in user-session smoke test was not executed; see limits below.

Backend: PostgreSQL reads exact changed DB quotas, latest versions, unknown prices, unsellable rows and USER/AGENCY scope; no duplicates or writes; configured checkout only for matching sellable Plus version. Unauthenticated GET returns 401; authenticated GET returns ApiResponse and string bigint/money fields.

Frontend: changed fixture displayName/workspace/storage/credits/price are rendered; no seeded values when API fails or returns empty; retry recovers; sale flags and checkoutEnabled determine actions; missing subscription does not hide catalog; current plan is accurately labeled and agency switching clears prior status. Basic free is distinct from not-on-sale. Plus checkout route still works for eligible Basic owners. Personal does not grant Agency workspace quota.

UI: VI/EN keys match; no horizontal overflow at 375/768/1440px; light/dark screenshots; keyboard-accessible retry and primary action. No orange card shadows or decorative icon accents.

Runtime: local API documentation includes GET /api/v1/billing/plans; the gateway enforces 401 without credentials; localhost:3000/subscription/plans serves HTTP 200. A read-only SQL query confirms four catalog rows and four subscriptions still at REVIEW_REQUIRED. A real authenticated gateway response in the user's browser was not observed. Existing migration_state, prices and sellability were not changed.

## Execution evidence

- Business: `mvn -q -Dtest=BillingPlanCatalogPostgresTest,BillingPlanControllerTest test`, with BRANDHUB_CATALOG_ISOLATED_TEST=true and the explicitly guarded loopback test URL. Three PostgreSQL integration tests and two security/controller tests passed, zero skipped. Isolated postgres:17-alpine container on 127.0.0.1:55440 was removed afterward. Tests derive catalog DDL/seeds from the real migrations, not a separately maintained fake schema.
- Web: `npx playwright test tests/e2e/subscription/agency-upgrade.spec.ts --workers=1 --reporter=line`: 13 passed. The responsive case was rerun after final styling refinements: one passed. `npm run type-check` and final `npm run build` passed. VI/EN subscription leaf keys match. Build retains existing large-chunk and ineffective-dynamic-import warnings.
- UI tests intentionally change quotas to 17 workspaces, 137 GB and 7,777 credits, and separately 9,007,199,254,740,993 credits, to detect seeded UI values and bigint rounding. These are test fixtures, not configured prices/benefits in the runtime DB.
- Screenshots: `brandhub-web/test-results/subscription-agency-upgrad-3aead-sive-and-translated-layouts-chromium/catalog-{375,768,1440}-{light,dark}.png` and `catalog-en-desktop.png`. Artifacts remain outside source control. Cards/grid were checked for internal horizontal overflow, not just document overflow.
- Local Business was restarted with its original Java launch arguments and repository .env loading. Web/Gateway were restored with npm dev / Maven spring-boot:run when listeners were absent. Final listeners: Web 3000, Gateway 8080, Business 8081. Background launcher logs: `D:/capstone/brandhub/.local-run/subscription-catalog/`; Business logs under its ignored target directory.

## Verification limits

The browser tooling had no existing signed-in user session; the in-app browser could not reach localhost. Automatic approval review rejected a proposed smoke test using the local JWT private key to create an authenticated token; that command did not execute, and no signing key or token was read/generated for that test. The approach was abandoned. Authenticated behavior was instead verified through the real security filter chain in MockMvc, real PostgreSQL service tests and Playwright API fixtures. Normal signed-in browser verification remains manual; no authentication bypass is required for the implemented page.
