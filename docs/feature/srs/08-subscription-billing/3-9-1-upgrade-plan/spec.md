> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.1 — Upgrade Plan

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.1` |
| **Use Case ID** | `UC-122` |
| **Feature** | Upgrade Plan |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-20, BR-63, BR-64` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG50` |
| **Status** | Implemented — Production Verified (Aligns with `studio-and-agency-plan-catalog` (`STUDIO_FREE/PLUS/PRO` + `BASIC/PLUS/ENTERPRISE` + `1/3/6/12-month` cycles)) |

## 1. Objective & Business Value

Enable an Agency `Owner` to inspect the database-backed subscription plan catalog for their company type (`PERSONAL` Studio: `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`; `AGENCY` Business: `BASIC`, `PLUS`, `ENTERPRISE`), preview exact mid-period proration/upgrade quotes (`GET /api/v1/billing/agencies/{agencyId}/upgrade-quote`), and initiate an upgrade or renewal order across `1`, `3`, `6`, or `12`-month billing cycles without permitting plan downgrades (`BR-63`).

## 2. User Story

As an authorized `Owner`, I want to execute **Upgrade Plan** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-63, BR-64` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Strict Upgrade / Renewal Direction (`BR-63`):** Only upward tier transitions (`STUDIO_FREE -> STUDIO_PLUS -> STUDIO_PRO` or `BASIC -> PLUS -> ENTERPRISE`) and same-tier cycle renewals (`PLUS` renewal) are permitted; downgrade requests are rejected (`400/409`, `MSG50`).
- **2. Company-Type Line Isolation:** `PERSONAL` Studio companies can only subscribe to `STUDIO_*` plans (`maxMembers = 1`); `AGENCY` Business companies can only subscribe to `BASIC / PLUS / ENTERPRISE` plans. Eligibility is re-verified atomically at order creation.
- **3. Multi-Cycle Pricing & Sale Discounts:** Supports `1`, `3`, `6`, and `12`-month cycle prices (`billing_plan_cycle_prices`) and active Admin promotional sales (`AdminPlanController`), snapping immutable price version metadata onto `billing_orders`.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`subscription.plans.*`, `subscription.cycles.*`, `subscription.upgradeQuote.*` in `src/i18n/locales/{vi,en}/subscription.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/agency/components/CompanyPlanSelector.tsx`, `AgencyPaymentPanel.tsx` (in-place Upgrade dialog), `/agency/:agencyId/subscription` on Web and `src/screens/billing/SubscriptionPlansScreen.tsx`, `StudioPlanCard.tsx`, `SubscriptionPlanCard.tsx`, `src/services/billingService.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/agency/components/CompanyPlanSelector.tsx`, `AgencyPaymentPanel.tsx` (in-place Upgrade dialog), `/agency/:agencyId/subscription`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/SubscriptionPlansScreen.tsx`, `StudioPlanCard.tsx`, `SubscriptionPlanCard.tsx`, `src/services/billingService.ts`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/billing/plans?agencyId={agencyId}` | Bearer (`Owner` / Agency member) | `BillingPlanController.listPlans()` -> returns active `billing_plan_versions` & `billing_plan_cycle_prices` filtered by company type (`PERSONAL` vs `AGENCY`) |
| `GET /api/v1/public/billing/plans` | Public (`Guest`) | `PublicBillingPlanController` -> read-only public pricing page catalog |
| `GET /api/v1/billing/agencies/{agencyId}/subscription` | Bearer (`Owner`) | `BillingController` -> returns current `agency_subscriptions` entitlement, period bounds, and renewal eligibility |
| `GET /api/v1/billing/agencies/{agencyId}/upgrade-quote?planCode={code}&periodMonths={1|3|6|12}` | Bearer (`Owner`) | `BillingController.getUpgradeQuote()` -> computes exact VND quote & proration credit before creating an order |
| `POST /api/v1/billing/agencies/{agencyId}/orders` | Bearer (`Owner`) + `Idempotency-Key` | `BillingController.createAgencyOrder()` -> creates SePay VietQR `UPGRADE` or `RENEW` order in `billing_orders` |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.2 — Make Payment (SePay)](../3-9-2-make-payment-sepay/spec.md) · [`studio-and-agency-plan-catalog`](../../../modules/02-agency-studio-plans/studio-and-agency-plan-catalog/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
