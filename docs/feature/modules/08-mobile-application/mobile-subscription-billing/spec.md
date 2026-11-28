> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Studio & Agency Subscription Plans, SePay VietQR Checkout, AI Credit Caps & Invoice History

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-subscription-billing` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Admin` |
| **Consolidated Feature Scopes** | `mobile-subscription-billing` |
| **Aligned SRS Domains** | [3.9 Subscription & Billing](../../../srs/08-subscription-billing/README.md) (`3.9.1–3.9.6`) · [FR 3.10.10–3.10.14 Admin Billing/Revenue](../../../srs/09-admin-functions/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Provide full mobile visibility and execution for **Personal Studio & Business Agency Subscription Plans** (`SubscriptionPlansScreen.tsx`), **SePay VietQR Dynamic Checkout & Countdown** (`BillingModals.tsx` + `react-native-qrcode-svg`), **Unified Agency Wallet & Workspace AI Credit Governance** (`AgencyCreditScreen.tsx`), and **Invoice History & Receipt Inspection** (`InvoiceHistoryScreen.tsx`, `InvoiceDetailScreen.tsx`, plus `AdminInvoicesScreen.tsx` & `AdminRevenueScreen.tsx`).

## 2. User Stories

- As an Agency or Personal Studio `Owner` on mobile, I want to compare `1 / 3 / 6 / 12`-month plans, generate or save a SePay VietQR code to complete bank-app transfer on the same phone, monitor live payment fulfillment, manage Workspace AI Credit caps, and inspect/download verified receipts.

## 3. Consolidated Acceptance Criteria

1. **Dual-Line Plan Catalog & Upgrade Quote (`SubscriptionPlansScreen.tsx`, `studioPlans.test.ts`):** Automatically displays `STUDIO_FREE / STUDIO_PLUS / STUDIO_PRO` for `PERSONAL` Studio companies and `BASIC / PLUS / ENTERPRISE` for `AGENCY` companies across `1 / 3 / 6 / 12`-month billing cycles, showing `BillingOverviewResourcesCard.tsx` resource utilization and exact mid-period upgrade quotes (enforcing `Upgrade Plan` only, zero downgrade).
2. **Mobile SePay VietQR Checkout (`BillingModals.tsx`):** Creates/resumes idempotent `billing_orders`, renders crisp vector VietQR (`react-native-qrcode-svg`) + copyable bank account / exact transfer content (`provider_order_code`) + save-QR-to-gallery (`expo-media-library` for 1-phone banking app scan), live server-anchored `15-minute` `mm:ss` countdown, and live order fulfillment polling.
3. **Workspace AI Credit Balance, Top-Up & Caps (`AgencyCreditScreen.tsx`):** Displays `PLAN` + `PURCHASED` wallet balances, per-Workspace period usage (`workspaceLimit`, `workspaceUsed`, `workspaceHeld`), `Owner` Workspace cap editor (`null` unlimited vs `0` blocked with `expectedRevision`), read-only operation price catalog, and SePay credit top-up checkout.
4. **Cursor-Paginated Invoice History & Admin Revenue (`InvoiceHistoryScreen.tsx`, `InvoiceDetailScreen.tsx`, `AdminInvoicesScreen.tsx`, `AdminRevenueScreen.tsx`):** Lists orders with cursor pagination, shows order/payment/fulfillment detail + on-demand SePay API v2 lookup, and downloads verified `FULFILLED` PDF receipts.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`billing.*`, `subscription.*`, `credit.*`, `invoices.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `/agency/:id/subscription`, `/agency/:id/credit`, `/agency/:id/invoices`, `/admin?view=revenue`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/{SubscriptionPlansScreen,AgencyCreditScreen,InvoiceHistoryScreen,InvoiceDetailScreen}.tsx`, `src/components/billing/*`, `src/screens/admin/{AdminInvoicesScreen,AdminRevenueScreen,AdminCreditPricesScreen,AdminReportsScreen}.tsx`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/billing/plans?agencyId={id} & /agencies/{id}/subscription & /upgrade-quote` | Bearer (`Owner`) | `BillingPlanController` & `BillingController` <- `billingService.ts` |
| `POST /api/v1/billing/agencies/{id}/orders & /credits/orders & GET /orders/{orderId}` | Bearer (`Owner`) + `Idempotency-Key` | `BillingController` <- `billingService.ts` |
| `GET /api/v1/billing/agencies/{id}/credits/summary & /api/v1/agencies/{id}/credit/workspaces & PUT /{wid}/limit` | Bearer (`Owner, Manager, Creator`) | `CreditBalanceController` & `WorkspaceCreditController` <- `creditService.ts` |
| `GET /api/v1/billing/agencies/{id}/invoices/** & /api/v1/admin/billing/invoices` | Bearer (`Owner`, `Admin`) | `InvoiceHistoryController` & `AdminInvoiceHistoryController` <- `billingService.ts` |

## 6. Error Handling, Security & Edge Cases

- **Single-Device Mobile Banking Switch:** User saves VietQR to gallery (`expo-media-library`) or copies transfer code, switches to banking app, and returns to BrandHub Mobile; `AppState` foreground listener immediately re-polls `GET /orders/{orderId}` (unlocking cleanly behind `AppLockGate` if `> 60s`) and celebrates fulfillment.
- **`BIGINT` Precision on Mobile Hermes Engine:** Credit and VND amounts parse safely from string/safe-integer DTOs (`planLimitHint.test.ts`).

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.9 Subscription & Billing](../../../srs/08-subscription-billing/README.md) (`3.9.1–3.9.6`) · [FR 3.10.10–3.10.14 Admin Billing/Revenue](../../../srs/09-admin-functions/README.md)
- **BA & Architecture References:** [BA 08 Subscription & Billing](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
