> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.3 — View Invoice History

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.3` |
| **Use Case ID** | `UC-124` |
| **Feature** | View Invoice History |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner, Admin` |
| **Business Rules** | `BR-20, BR-64` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `subscription-invoice-history` & `admin-invoice-history`) |

## 1. Objective & Business Value

Provide cursor-paginated, read-only Invoice & Payment History, right-side sliding Order Detail Drawer (`1/3` viewport at `>= 1024px`), verified PDF receipt download (`FULFILLED` + `VERIFIED` payment only, explicitly marked non-VAT receipt), and on-demand SePay API v2 transaction verification for both Agency `Owner` (`/agency/:agencyId/invoices`) and platform `Admin` (`/admin?view=revenue` / `AdminInvoicesPanel`).

## 2. User Story

As an authorized `Owner, Admin`, I want to execute **View Invoice History** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-64` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner, Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Strict Tenant & IDOR Protection:** `InvoiceHistoryService` verifies current `Owner` of `agencyId` on every request; former owners, non-owners, or cross-agency `orderId` probes receive `404/403` without leaking order metadata. `Admin` endpoints require fresh DB `ADMIN` verification.
- **2. Verified Receipt Gate:** Receipt download (`brandhub-receipt-{orderId}.pdf`) is generated **only** when the order is `FULFILLED` with a `VERIFIED` payment matching the order amount, clearly stating it is a payment confirmation receipt rather than a statutory tax/VAT invoice.
- **3. Safe On-Demand SePay API v2 Lookup:** Executed strictly outside PostgreSQL transactions via `SePayTransactionClient` (`transaction_content = provider_order_code`), verifying incoming direction, merchant account match, and post-order timestamp, returning minimal sanitized metadata (never exposing merchant bank balance or third-party PII) and never mutating order state on `GET`.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`subscription.invoices.*`, `subscription.invoiceDrawer.*`, `admin.invoices.*` in `src/i18n/locales/{vi,en}/subscription.json` & `admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/agency` Payment History + `InvoiceDetailDrawer` (`w-full lg:w-1/3` right-side sheet), `pages/admin/components/AdminInvoicesPanel.tsx`, `pages/admin/InvoicesPage.tsx` on Web and `src/screens/billing/InvoiceHistoryScreen.tsx`, `InvoiceDetailScreen.tsx`, `src/screens/admin/AdminInvoicesScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/agency` Payment History + `InvoiceDetailDrawer` (`w-full lg:w-1/3` right-side sheet), `pages/admin/components/AdminInvoicesPanel.tsx`, `pages/admin/InvoicesPage.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/InvoiceHistoryScreen.tsx`, `InvoiceDetailScreen.tsx`, `src/screens/admin/AdminInvoicesScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/billing/agencies/{agencyId}/invoices?cursor={c}&limit={20}&status={s}&kind={k}&from={iso}&to={iso}` | Bearer (`Owner`) | `InvoiceHistoryController.list()` -> cursor-paginated `(created_at, id) DESC` projection from `billing_orders` |
| `GET /api/v1/billing/agencies/{agencyId}/invoices/{orderId}` | Bearer (`Owner`) | `InvoiceHistoryController.detail()` -> payer UUID, plan snapshot, exact string amount, attempts, fulfillment & review reason |
| `GET /api/v1/billing/agencies/{agencyId}/invoices/{orderId}/receipt` | Bearer (`Owner`) | `InvoiceHistoryController.receipt()` -> `application/pdf` (`Cache-Control: no-store`) only when `FULFILLED` + `VERIFIED` payment |
| `GET /api/v1/billing/agencies/{agencyId}/invoices/{orderId}/sepay-transactions?page={1}` | Bearer (`Owner`) | `InvoiceHistoryController.lookup()` -> `InvoiceProviderService` read-only SePay API v2 lookup outside DB transaction (`<= 1 call / 400ms` rate gate) |
| `GET /api/v1/admin/billing/invoices & /agencies/{agencyId}/invoices/{orderId}[/receipt|/sepay-transactions]` | Bearer (`Admin`) | `AdminInvoiceHistoryController` -> global Admin view verified via live DB `AdminAccountService.requireAdmin` |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner, Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.2 — Make Payment (SePay)](../3-9-2-make-payment-sepay/spec.md) · [FR 3.10.13 — View Revenue Dashboard](../../09-admin-functions/3-10-13-view-revenue-dashboard/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
