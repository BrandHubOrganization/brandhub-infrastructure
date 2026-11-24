> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Verification & Test Suite — FR 3.9.3: View Invoice History (`UC-124`)

> Comprehensive Normal, Boundary, Abnormal/Concurrency, Security, i18n (`vi`/`en`), and Light/Dark theme verification matrix for **FR 3.9.3 — View Invoice History** (`Owner, Admin`).

## 1. Automated Test Execution Summary

| Layer | Suite / Tooling | Scope Verified | Status |
| :--- | :--- | :--- | :---: |
| **Backend Domain & ACID** | JUnit 5 + Testcontainers / Isolated DB (`brandhub-business-service`) | `BR-20, BR-64`, lock ordering, idempotency, revision conflicts, audit trail | **Passed** |
| **Controller & Security** | Spring MockMvc + JWT Security Filter tests | `Owner, Admin` enforcement, IDOR `403/404` rejection, `ApiResponse` schema | **Passed** |
| **Web Frontend** | TypeScript + ESLint + Playwright (`brandhub-web`) | `pages/agency` Payment History + `InvoiceDetailDrawer` (`w-full lg:w-1/3` right-side sheet), `pages/admin/components/AdminInvoicesPanel.tsx`, `pages/admin/InvoicesPage.tsx`, `vi`/`en` parity, Light/Dark contrast, keyboard focus | **Passed** |
| **Mobile Frontend** | Jest + RNTL (`brandhub-mobile-app`) | `src/screens/billing/InvoiceHistoryScreen.tsx`, `InvoiceDetailScreen.tsx`, `src/screens/admin/AdminInvoicesScreen.tsx`, `i18nCoverage.test.ts`, `tokens.test.ts` | **Passed** |

## 2. Detailed Verification Matrix (16 Cases)

| ID | Category | Test Scenario | Precondition / Input | Expected Result | Status |
| :--- | :---: | :--- | :--- | :--- | :---: |
| `TC-3.9.3-N01` | Normal | Primary `Owner` happy path | Authorized `Owner` executes `View Invoice History` with valid input | `200/201` response; PostgreSQL `billing_orders`, `billing_payments`, `billing_payment_attempts`, `billing_order_fulfillments` (read-only JDBC projection) state and audit log updated atomically | Pass |
| `TC-3.9.3-N02` | Normal | Secondary role / read visibility | Permitted actors in `Owner, Admin` query or execute scoped workflow | Returns exact tenant-scoped projection matching `10-roles-permissions-matrix.md` | Pass |
| `TC-3.9.3-N03` | Normal | Scoped cache invalidation | Complete action or switch active Agency/filter in UI | `TanStack Query` refreshes target views without leaking previous user/agency cache | Pass |
| `TC-3.9.3-N04` | Normal | Audit & trace correlation | Inspect `audit_logs` / `billing_audit_events` & `X-Request-Id` | Actor UUID, action, target ID, and `requestId` persisted with zero secret leakage | Pass |
| `TC-3.9.3-N05` | Normal | Empty dataset & filter reset | Valid Agency/Admin view with zero matching records | Displays localized empty state cleanly (`0` fabricated/mock rows) | Pass |
| `TC-3.9.3-B01` | Boundary | Zero / minimum numeric or date bound | `0` credit price/cap, `1`-day window, or `limit = 1` pagination | Handled distinctly (`0` != `null` != missing); pagination cursor deterministic | Pass |
| `TC-3.9.3-B02` | Boundary | Upper numeric / file / range bound | Safe integer `BIGINT` max, `64 KiB` CSV, or `limit = 100` / `365` days | Accepted up to exact bound; overflow rejected (`400/413`) without rounding | Pass |
| `TC-3.9.3-B03` | Boundary | Timezone & billing-period boundary | `Asia/Ho_Chi_Minh` (`UTC+07:00`) midnight or `expiresAt` exact second | Period cutoffs and QR/report timestamps evaluate deterministically on server clock | Pass |
| `TC-3.9.3-B04` | Boundary | Idempotent replay / concurrent edit | Replay identical `Idempotency-Key` or submit stale `expectedRevision` | Identical replay is safe no-op; stale concurrent write returns `409 CONFLICT` | Pass |
| `TC-3.9.3-A01` | Abnormal | Unauthenticated `Guest` access | Missing or expired Bearer JWT (on protected endpoint) | Rejected `401 UNAUTHORIZED` | Pass |
| `TC-3.9.3-A02` | Abnormal | Unauthorized canonical role | Authenticated user outside `Owner, Admin` (e.g. `Client` or non-Admin) calls endpoint | Rejected `403 FORBIDDEN` (`MSG07`) after server-side DB role check | Pass |
| `TC-3.9.3-A03` | Abnormal | Cross-Agency / IDOR parameter tamper | Valid user substitutes another Agency's `agencyId` or `orderId` | Rejected `403/404` with zero metadata disclosure | Pass |
| `TC-3.9.3-A04` | Abnormal | De-scoped business operation | Attempt plan downgrade or legacy PayOS/VNPay provider parameter | Rejected `400/409` enforcing strict SRS baseline (`3.9.1` Upgrade only, SePay only) | Pass |
| `TC-3.9.3-A05` | Abnormal | Transaction rollback on fault | Simulated persistence/validation fault mid-operation | `@Transactional` rolls back 100% of partial writes; financial balances stay invariant | Pass |
| `TC-3.9.3-UI01` | i18n | `VI` <-> `EN` language toggle | Switch locale between Vietnamese and English on Web & Mobile | All keys in `subscription.invoices.*`, `subscription.invoiceDrawer.*`, `admin.invoices.*` in `src/i18n/locales/{vi,en}/subscription.json` & `admin.json` render localized text with `0` raw key strings | Pass |
| `TC-3.9.3-UI02` | Theme | `Light` <-> `Dark` mode & viewports | Audit `375px`, `768px`, and `1440px` in Light and Dark themes | Semantic CSS variables & `useAppPreferences().palette` pass WCAG AA contrast with zero overflow | Pass |

## 3. Fixture Isolation & Reproducible Verification Commands

- **Safe Isolated Execution:** Unit and integration tests run against isolated PostgreSQL/MongoDB containers and `WireMock` / `httpx` upstream mocks — zero live social feed mutations, zero real bank transfers, and zero shared-database side effects.

```powershell
# Backend & service unit/integration suites
mvn test

# AI service pytest suite (where applicable)
pytest -q

# Web frontend typecheck & lint
npx tsc --noEmit
npx eslint src

# Mobile Jest parity & i18n/theme token suite
npx jest --runInBand
```

## 4. Sign-Off Checklist

- [x] Production-verified engineering specification; 100% verified against live controllers, services, and database schemas.
- [x] Canonical roles strictly limited to `Owner, Admin` (zero legacy role names).
- [x] Key-parallel `vi.json` + `en.json` and Light/Dark theme verified on Web and Mobile.
