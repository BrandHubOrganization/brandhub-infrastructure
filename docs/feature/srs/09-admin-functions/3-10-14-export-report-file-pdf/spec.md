> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.14 — Export Report File PDF

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.14` |
| **Use Case ID** | `UC-141` |
| **Feature** | Export Report File PDF |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30, BR-35` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Verified against `AdminReportController` (`POST /api/v1/admin/reports` + `GET /{id}/file?token=...`) & SePay revenue alignment) |

## 1. Objective & Business Value

Allow system `Admin` to generate and download executive PDF platform & SePay revenue reports (`POST /api/v1/admin/reports` -> `GET /api/v1/admin/reports/{id}/file?token=...`) for a selected date range, timezone, and optional plan filter, persisted in `admin_report_exports` and protected by dual `Admin` JWT + signed download token verification (`BR-35`).

## 2. User Story

As an authorized `Admin`, I want to execute **Export Report File PDF** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-35` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Dual-Factor Download Security (`BR-35`):** Possession of `token` alone is never sufficient; `AdminReportService.download()` verifies both live `SystemRole.ADMIN` identity and non-expired cryptographic token match (`403 FORBIDDEN` if a non-Admin replays the URL).
- **2. Exact Consistency with Revenue Dashboard:** Uses identical `AdminReportPeriod` and `AdminRevenueService` verified SePay queries as FR 3.10.13 so PDF totals match on-screen KPIs `100%`, with full Vietnamese Unicode font embedding.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`admin.reports.{exportPdf,generating,downloadReady,errors.expiredToken}` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/admin/components/AdminReportExport.tsx`, `AdminRevenuePanel.tsx` on Web and `src/screens/admin/AdminReportsScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminReportExport.tsx`, `AdminRevenuePanel.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminReportsScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `POST /api/v1/admin/reports` | Bearer (`Admin`) | `AdminReportController.create()` -> compiles verified SePay revenue & platform metrics into PDF, stores record in `admin_report_exports`, returns `{ id, fileName, downloadToken, expiresAt }` |
| `GET /api/v1/admin/reports/{id}/file?token={token}` | Bearer (`Admin`) + Signed `token` | `AdminReportController.download()` -> enforces `BR-35` (caller must STILL be `Admin` in addition to valid token), streams `application/pdf` with `Cache-Control: no-store` |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.13 — View Revenue Dashboard](../3-10-13-view-revenue-dashboard/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
