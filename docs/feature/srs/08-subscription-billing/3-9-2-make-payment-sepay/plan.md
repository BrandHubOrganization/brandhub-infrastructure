> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.9.2: Make Payment (SePay) (`UC-123`)

## 1. Architectural Scope & Touched Repositories

Implements **FR 3.9.2 — Make Payment (SePay)** ([spec.md](./spec.md)) for canonical roles `Owner`:

| Layer / Repository | Concrete Classes & Files |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `InboundSecurityWebFilter.java`, `JwtAuthFilterGatewayFilterFactory.java`, `RateLimitGatewayFilterFactory.java` |
| **Business Service (`brandhub-business-service`)** | `BillingController.createAgencyOrder()`, `BillingController`, `BillingController.sepayWebhook()` |
| **Database & Persistence Layer** | PostgreSQL `billing_orders`, `billing_payment_attempts`, `billing_payments`, `billing_payment_events`, `billing_order_fulfillments`, `agency_subscriptions`, `credit_grants`, `billing_outbox_events`, `billing_audit_events` |
| **Web Application (`brandhub-web`)** | `components/AgencyPaymentPanel.tsx`, `pages/agency/components/CompanyPlanSelector.tsx`, `/agency/:agencyId/subscription/checkout` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/BillingModals.tsx` (`react-native-qrcode-svg` VietQR display + countdown) |
| **i18n Locale Bundles** | Web: `subscription.checkout.{generatingQr,countdown,expired,createNewOrder,fulfilled}` in `src/i18n/locales/{vi,en}/subscription.json`; Mobile: `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (`tr()`) |

## 2. Database Schema, Concurrency & Financial/Audit Invariants

1. **Authoritative Persistence (PostgreSQL `billing_orders`, `billing_payment_attempts`, `billing_payments`, `billing_payment_events`, `billing_order_fulfillments`, `agency_subscriptions`, `credit_grants`, `billing_outbox_events`, `billing_audit_events`):**
   - Schema objects are defined canonically in `database/init/init-postgres-v2.sql` and additive migrations under `database/migrations/postgres/` (plus MongoDB `monitoring_*` collections for `3.10.3`).
   - Financial and credit amounts use exact integer / `BIGINT` arithmetic (serialized safely without IEEE-754 float rounding).
2. **Lock Ordering & Optimistic Revisions:**
   - Agency-scoped billing and credit mutations acquire parent Agency/Order locks in deterministic order under `READ_COMMITTED` / `REPEATABLE_READ` transactions and never hold database transactions open across external HTTP calls (such as SePay API v2 lookups).
   - Configuration and broadcast edits enforce `expectedRevision` / `rowVersion` optimistic concurrency (`409 CONFLICT` on stale writes).

## 3. End-to-End Execution Flow

1. **Client Action:** Authenticated `Owner` triggers `Make Payment (SePay)` on `components/AgencyPaymentPanel.tsx`, `pages/agency/components/CompanyPlanSelector.tsx`, `/agency/:agencyId/subscription/checkout` or `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/BillingModals.tsx` (`react-native-qrcode-svg` VietQR display + countdown).
2. **Gateway & Live Role Verification:** API Gateway validates JWT and forwards `X-Request-Id`; Business service verifies live `Owner` status and tenant ownership (`BR-20, BR-63, BR-64`).
3. **Transactional Domain Execution:** Service validates invariants, executes atomic persistence on PostgreSQL `billing_orders`, `billing_payment_attempts`, `billing_payments`, `billing_payment_events`, `billing_order_fulfillments`, `agency_subscriptions`, `credit_grants`, `billing_outbox_events`, `billing_audit_events`, writes immutable audit trail, and emits outbox/realtime notifications where applicable.
4. **UI Reconciliation:** Client receives `ApiResponse<T>` (or streamed `application/pdf` with `Cache-Control: no-store`), invalidates scoped `(userId, agencyId)` `TanStack Query` caches, and renders localized feedback.

## 4. Sequential Build Order

1. **Step 1 — Schema & DTO Contracts:** Verify SQL/MongoDB indexes, constraints, and `@Valid` request/response records.
2. **Step 2 — Domain Service & Concurrency Guards:** Implement core service logic, lock ordering, idempotency/revision checks, and audit logging.
3. **Step 3 — REST Controllers & Exception Mapping:** Wire controller endpoints and map domain errors (`400/403/404/409/413/503`) to `ApiResponse`.
4. **Step 4 — Web & Mobile UI Wiring:** Build/connect `components/AgencyPaymentPanel.tsx`, `pages/agency/components/CompanyPlanSelector.tsx`, `/agency/:agencyId/subscription/checkout` and `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/BillingModals.tsx` (`react-native-qrcode-svg` VietQR display + countdown) with complete Loading, Empty, Success, and Error/Conflict states.
5. **Step 5 — i18n (`vi.json` + `en.json`) & Light/Dark Theme:** Synchronize `subscription.checkout.{generatingQr,countdown,expired,createNewOrder,fulfilled}` in `src/i18n/locales/{vi,en}/subscription.json` across `vi` and `en` and verify Light/Dark semantic tokens.
6. **Step 6 — Verification:** Run JUnit 5 + Testcontainers PostgreSQL/MongoDB tests, Jest mobile tests, and Playwright UI tests ([test.md](./test.md)).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & API Envelope Contract

- **Standardized `ApiResponse<T>` Contract:** All JSON endpoints return `{ "success": boolean, "data": T, "error": { "code", "message" } | null, "requestId": string }` with deterministic HTTP status mapping (`200/201/204` success; `400` validation; `401` unauthenticated; `402` insufficient credit; `403` role/tenant forbidden; `404` scoped not found; `409` version/idempotency conflict; `429` rate limit; `503` upstream unavailable).
- **Key-Parallel i18n Synchronization:** All UI strings are added simultaneously in `vi.json` and `en.json` on `brandhub-web` and mirrored via `tr()` (`src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json`) on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
- **Semantic Light & Dark Mode Styling:** Web components use CSS custom properties and Tailwind `dark:` variants; Mobile screens use `useAppPreferences().palette` (`src/theme/tokens.ts`), maintaining WCAG AA contrast across Light and Dark modes.

## 6. Engineering Risks & Mitigations

- **Cross-User / Cross-Agency Cache Bleed:** Scope all `TanStack Query` keys by `(currentUserId, agencyId, filterParams)` and verify ownership server-side on every call.
- **Duplicate Webhook / Double-Click Submissions:** Mitigated by `Idempotency-Key`, unique `(provider, merchant_account, event_key)` constraints, and disabled busy buttons.
