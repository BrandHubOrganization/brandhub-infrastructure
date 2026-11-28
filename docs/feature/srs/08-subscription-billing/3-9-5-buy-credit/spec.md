> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.5 — Buy Credit

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.5` |
| **Use Case ID** | `UC-126` |
| **Feature** | Buy Credit |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-20, BR-64, BR-65` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG51` |
| **Status** | Implemented — Production Verified (Consolidates verified SePay `BUY_CREDIT` grant handoff from `member-credit` & `workspace-credit-unification`) |

## 1. Objective & Business Value

Allow an Agency `Owner` to purchase non-expiring top-up AI Credit packs via **SePay (VietQR)** (`POST /api/v1/billing/agencies/{agencyId}/credits/orders` / `POST /api/v1/billing/credits/buy`), minting `PURCHASED` `credit_grants` into `agency_credit_wallets` strictly upon verified SePay webhook settlement — never from unverified browser redirects.

## 2. User Story

As an authorized `Owner`, I want to execute **Buy Credit** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-64, BR-65` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Server-Trusted Grant Minting Only (`BR-64`, `BR-65`):** Browser clients never supply arbitrary credit grant amounts to a minting endpoint; `billing_orders` locks the package price and credit quantity at order creation, and `PURCHASED` grants are issued exclusively inside the verified SePay fulfillment transaction.
- **2. Non-Expiring Purchased Credit Priority:** `PURCHASED` credits never expire at subscription cycle rollover and remain spendable even if a paid subscription later expires; during active subscriptions, `PLAN` credits are always allocated first (`PLAN -> PURCHASED -> DEV_SEED`) to maximize customer value.
- **3. Idempotent Fulfillment:** Duplicate SePay webhook deliveries or concurrent polling never issue duplicate `credit_grants` (`billing_order_fulfillments` unique constraint).
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`credit.topUp.*`, `subscription.checkout.*` in `src/i18n/locales/{vi,en}/credit.json` & `subscription.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/credit/components/TopUpDialog.tsx`, `components/AgencyPaymentPanel.tsx`, `/agency/:agencyId/credit` on Web and `src/screens/billing/AgencyCreditScreen.tsx`, `BillingModals.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/credit/components/TopUpDialog.tsx`, `components/AgencyPaymentPanel.tsx`, `/agency/:agencyId/credit`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/AgencyCreditScreen.tsx`, `BillingModals.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/billing/agencies/{agencyId}/credits/orders` | Bearer (`Owner`) + `Idempotency-Key` | `BillingController` -> creates `BUY_CREDIT` order in `billing_orders` with server-constructed `CREDIT:<quantity>` reference & dynamic VietQR |
| `POST /api/v1/billing/credits/buy` | Bearer (`Owner`) | `BillingController` -> initiates credit top-up checkout order |
| `POST /api/v1/billing/webhooks/sepay` | SePay Webhook Auth | `AgencyBillingService` -> verifies bank transfer & atomically writes non-expiring `PURCHASED` grant in `credit_grants` + `credit_entries` |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.2 — Make Payment (SePay)](../3-9-2-make-payment-sepay/spec.md) · [FR 3.9.4 — View AI Credit Tracking](../3-9-4-view-ai-credit-tracking/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
