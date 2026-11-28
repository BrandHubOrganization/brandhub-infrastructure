> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# SePay Payment ACID Verification Suite, Java Benchmark Runner & Subscription Production Observability

| Field | Value |
| :--- | :--- |
| **Module Slug** | `payment-java-runner` |
| **Category** | `07-billing-publisher-and-observability` — Billing Verification, Publisher Resilience & System Health Observability |
| **Canonical Actors / Roles** | `Owner, Admin` |
| **Consolidated Feature Scopes** | `payment-java-runner`, `payment-tests-in-repository`, `subscription-production-observability` |
| **Aligned SRS Domains** | [FR 3.9.1 — Upgrade Plan](../../../srs/08-subscription-billing/3-9-1-upgrade-plan/spec.md) · [FR 3.9.2 — Make Payment (SePay)](../../../srs/08-subscription-billing/3-9-2-make-payment-sepay/spec.md) · [FR 3.10.3 — System Health Monitoring](../../../srs/09-admin-functions/3-10-3-system-health-monitoring/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Consolidate BrandHub's financial reliability and operational reconciliation stack: the deterministic **Java Payment API, ACID Concurrency & Apache Bench Load Runner** (`payment-java-runner`), the **In-Repository Business Service Payment & Webhook Regression Suite** (`payment-tests-in-repository`), and **Subscription Production Observability & Admin Reconciliation** (`SubscriptionOperationsController` — `subscription-production-observability`).

## 2. User Stories

- As an `Admin` or platform engineer, I want automated ACID concurrency tests (`payment-tests-in-repository`), reproducible Java load/chaos verification (`payment-java-runner`), and live operational issue detection & reconciliation (`GET /api/v1/admin/billing/operations/issues|status` & `POST /reconcile`) so zero SePay webhook anomalies or outbox stalls go unnoticed.

## 3. Consolidated Acceptance Criteria

1. **Java Payment API / ACID / Load Runner (`payment-java-runner`):** Standalone Java HTTP + JDBC verification harness executing sequential contract checks, concurrent SePay webhook replay storms, race-timed `EXPIRED` vs `PENDING_PAYMENT` fulfillment tests, double-payment `MANUAL_REVIEW` guards (`AB-10`), and Apache Bench throughput baselines against isolated PostgreSQL instances without touching live bank accounts.
2. **In-Repository Business Payment Suite (`payment-tests-in-repository`):** JUnit 5 + Testcontainers PostgreSQL transaction-proxy tests inside `brandhub-business-service` verifying `AgencyBillingService`, `(provider, merchant_account, event_key)` uniqueness, lock ordering (`Agency -> Order`), rollback atomicity across `billing_orders` / `billing_payments` / `credit_grants` / `billing_outbox_events`, and exact `BIGINT` ledger invariants.
3. **Subscription Production Observability (`subscription-production-observability`):** `SubscriptionOperationsController` (`GET /api/v1/admin/billing/operations/issues`, `GET /status`, `POST /reconcile`) backed by PostgreSQL `subscription_operational_issues`, `subscription_observation_jobs`, and `subscription_provider_checks` surfaces unmatched transfers, delayed outbox events, or manual-review orders to `Admin` with audited reconciliation actions.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`admin.billingOps.{issues,status,reconcile,manualReview}.*` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminRevenuePanel.tsx` & `AdminInvoicesPanel.tsx` (manual-review status & audit badges)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminInvoicesScreen.tsx` (read-only operational status badges)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/admin/billing/operations/issues` | Bearer (`Admin`) | `SubscriptionOperationsController` -> lists open `subscription_operational_issues` (`MANUAL_REVIEW`, unmatched webhooks, outbox lag) |
| `GET /api/v1/admin/billing/operations/status` | Bearer (`Admin`) | `SubscriptionOperationsController` -> health of `subscription_observation_jobs` & `subscription_provider_checks` |
| `POST /api/v1/admin/billing/operations/reconcile` | Bearer (`Admin`) | `SubscriptionOperationsController` -> audited operator reconciliation & issue resolution |

## 6. Error Handling, Security & Edge Cases

- **Uncertain Commit / Network Drop on Webhook:** Provider replay is idempotent; reconciliation never double-grants entitlements (`billing_order_fulfillments` unique constraint).
- **Test Harness Safety Guard:** `payment-java-runner` refuses non-local / non-fixture JDBC URLs so load tests can never target production databases.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.9.1 — Upgrade Plan](../../../srs/08-subscription-billing/3-9-1-upgrade-plan/spec.md) · [FR 3.9.2 — Make Payment (SePay)](../../../srs/08-subscription-billing/3-9-2-make-payment-sepay/spec.md) · [FR 3.10.3 — System Health Monitoring](../../../srs/09-admin-functions/3-10-3-system-health-monitoring/spec.md)
- **BA & Architecture References:** [BA 08 Subscription & Billing](../../../../ba/08-subscription-billing.md) · [BA 09 Admin Functions](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
