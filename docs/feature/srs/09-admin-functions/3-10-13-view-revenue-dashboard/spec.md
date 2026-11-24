> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.13 — View Revenue Dashboard

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.13` |
| **Use Case ID** | `UC-140` |
| **Feature** | View Revenue Dashboard |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30, BR-35` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `admin-sepay-revenue` & `admin-revenue-invoices` (`AdminRevenueController` + embedded `AdminInvoicesPanel`)) |

## 1. Objective & Business Value

Provide system `Admin` at `/admin?view=revenue` with an authoritative **SePay-verified** Revenue Dashboard (`GET /api/v1/admin/revenue`) displaying gross collected revenue, active MRR/ARR (derived from current active billing periods), daily receipt bar charts (`AS receipt_date`), plan-tier revenue breakdown across all 6 plans (`STUDIO_FREE/PLUS/PRO` + `BASIC/PLUS/ENTERPRISE`), and the integrated global `AdminInvoicesPanel`.

## 2. User Story

As an authorized `Admin`, I want to execute **View Revenue Dashboard** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-35` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Verified SePay Source of Truth (`admin-sepay-revenue`):** Aggregates strictly `VERIFIED` `billing_payments` joined to `FULFILLED` `billing_orders` and `billing_plan_versions` — excluding `PENDING_PAYMENT`, `MANUAL_REVIEW`, and retired legacy tables. Plans with zero collections display `0 VND` cleanly.
- **2. Accurate MRR/ARR & Unified Invoice Experience (`admin-revenue-invoices`):** MRR/ARR derives from active `CURRENT` subscription period amounts rather than mutable catalog list prices. Duplicate sidebar invoice links are consolidated directly into `/admin?view=revenue` via `AdminInvoicesPanel.tsx` (with `/admin/invoices` redirecting cleanly).
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`admin.revenue.{kpis,mrr,arr,dailyReceipts,byPlan,invoicesSection}` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/admin/components/AdminRevenuePanel.tsx`, `AdminInvoicesPanel.tsx`, `AdminDateRangePicker.tsx`, `AdminReportExport.tsx` on Web and `src/screens/admin/AdminRevenueScreen.tsx`, `AdminCharts.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminRevenuePanel.tsx`, `AdminInvoicesPanel.tsx`, `AdminDateRangePicker.tsx`, `AdminReportExport.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminRevenueScreen.tsx`, `AdminCharts.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/admin/revenue?from={YYYY-MM-DD}&to={YYYY-MM-DD}&timezone={tz}&plan={code}` | Bearer (`Admin`) | `AdminRevenueController.overview()` -> `REPEATABLE_READ` `AdminRevenueService` aggregation + `AdminAudit.record('VIEW', 'ADMIN_REVENUE', ...)` |
| `GET /api/v1/admin/billing/invoices` | Bearer (`Admin`) | `AdminInvoiceHistoryController.list()` -> embedded full-featured invoice panel below revenue KPIs (`admin-revenue-invoices`) |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.14 — Export Report File PDF](../3-10-14-export-report-file-pdf/spec.md) · [FR 3.9.3 — View Invoice History](../../08-subscription-billing/3-9-3-view-invoice-history/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
