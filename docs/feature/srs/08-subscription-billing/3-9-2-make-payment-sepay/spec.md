> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.2 — Make Payment (SePay)

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.2` |
| **Use Case ID** | `UC-123` |
| **Feature** | Make Payment (SePay) |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-20, BR-63, BR-64` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG51, MSG52` |
| **Status** | Implemented — Production Verified (Consolidates `subscription-payment-dialog`, `subscription-auto-checkout`, `subscription-webhook-corrections`, `payment-qr-countdown`) |

## 1. Objective & Business Value

Execute dynamic **SePay (VietQR)** bank-transfer checkout and webhook-driven ACID fulfillment for Agency subscription upgrades/renewals, AI credit top-ups, and S3 storage add-ons. Opening checkout as `Owner` automatically creates or resumes an idempotent `15-minute` payment order in an accessible dialog (`AgencyPaymentPanel.tsx`) with a live `mm:ss` server-anchored countdown, while `POST /api/v1/billing/webhooks/sepay` reconciles incoming transfers idempotently and activates entitlements.

## 2. User Story

As an authorized `Owner`, I want to execute **Make Payment (SePay)** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-63, BR-64` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Auto-Checkout Dialog & `15-Minute` Countdown (`subscription-payment-dialog`, `subscription-auto-checkout`, `payment-qr-countdown`):** Clicking Upgrade opens an accessible dialog without page reload, using a `sessionStorage` `Idempotency-Key` scoped to `(userId, agencyId, planCode, periodMonths)` and a StrictMode request guard. `AgencyPaymentPanel` renders a live `mm:ss` countdown derived from server `expiresAt` (`now + 15 minutes`); closing/reopening preserves the deadline, stops background polling while closed, and hides the QR at `00:00` with an explicit 'Create New Order' action.
- **2. Webhook Idempotency & Conflict Evidence (`subscription-webhook-corrections`):** Reserves unique `(provider, merchant_account, event_key)` in `billing_payment_events` before parsing transfer content. Exact duplicate event IDs with matching canonical business fingerprint (normalized numeric scale & timestamp offset, or legacy hash) are safe `200 {success: true}` no-ops; mutated duplicate payloads record immutable conflict audit hashes without overwriting original financial state.
- **3. Late-Arrival & Double-Payment Safety (`AB-10`):** Verified incoming transfers (`transferType = in`, exact `amount`, `createdAt <= paidAt < expiresAt`) fulfill both `PENDING_PAYMENT` and race-timed `EXPIRED` orders atomically (updating `billing_orders`, `billing_payments`, `billing_order_fulfillments`, `agency_subscriptions`, `credit_grants`, and `billing_outbox_events` under Agency -> Order row lock order). A second distinct bank transfer on an already `FULFILLED` order is recorded for `MANUAL_REVIEW` while strictly preserving `SUCCEEDED` on the original attempt and never double-granting.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`subscription.checkout.{generatingQr,countdown,expired,createNewOrder,fulfilled}` in `src/i18n/locales/{vi,en}/subscription.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`components/AgencyPaymentPanel.tsx`, `pages/agency/components/CompanyPlanSelector.tsx`, `/agency/:agencyId/subscription/checkout` on Web and `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/BillingModals.tsx` (`react-native-qrcode-svg` VietQR display + countdown) on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `components/AgencyPaymentPanel.tsx`, `pages/agency/components/CompanyPlanSelector.tsx`, `/agency/:agencyId/subscription/checkout`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/BillingModals.tsx` (`react-native-qrcode-svg` VietQR display + countdown)
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/billing/agencies/{agencyId}/orders` | Bearer (`Owner`) + `Idempotency-Key` | `BillingController.createAgencyOrder()` -> auto-creates/resumes `PENDING_PAYMENT` order (`expires_at = created_at + 15m`) + VietQR payload |
| `GET /api/v1/billing/agencies/{agencyId}/orders/{orderId}` | Bearer (`Owner`) | `BillingController` -> polls authoritative order status (`PENDING_PAYMENT`, `FULFILLED`, `EXPIRED`, `MANUAL_REVIEW`) |
| `POST /api/v1/billing/webhooks/sepay` | SePay Webhook `Authorization` Header | `BillingController.sepayWebhook()` -> routes to `StorageAddonService.acceptIfStorage()` or `AgencyBillingService.acceptWebhook()` |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.1 — Upgrade Plan](../3-9-1-upgrade-plan/spec.md) · [FR 3.9.3 — View Invoice History](../3-9-3-view-invoice-history/spec.md) · [`payment-java-runner`](../../../modules/07-billing-publisher-and-observability/payment-java-runner/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
