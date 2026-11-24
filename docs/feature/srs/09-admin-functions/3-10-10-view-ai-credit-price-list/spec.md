> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.10 — View AI Credit Price List

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.10` |
| **Use Case ID** | `UC-137` |
| **Feature** | View AI Credit Price List |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Owner, Admin` |
| **Business Rules** | `BR-30, BR-65` |
| **Message Codes** | `MSG01, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Consolidates read-catalog contract from `member-credit`, `workspace-credit-unification`, & `credit-price-csv-import`) |

## 1. Objective & Business Value

Display the authoritative AI Credit Operation Price Catalog (`GET /api/v1/credit/prices`) backed by immutable versioned rows in PostgreSQL `ai_credit_operation_prices`, clearly distinguishing billable operations (`CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE`), free operations (`FREE_V1` — `0` credits), `enabled` status, billing unit (`per request` vs `per image/video`), and current `revision` for `Admin` (`/admin/credit-prices`) and `Owner` (`/agency/:agencyId/credit`).

## 2. User Story

As an authorized `Owner, Admin`, I want to execute **View AI Credit Price List** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-65` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner, Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Transparent Missing vs Disabled vs Free States (`BR-65`):** Unconfigured operations explicitly show `unconfigured` (blocking paid dispatch rather than silently charging `0`); explicit `unitCredits = 0` with `enabled = true` shows `Free`; `enabled = false` shows `Disabled`.
- **2. Feature-Wide Flat Unit Pricing:** Each image/video/content operation uses one fixed unit-credit price across all supported aspect ratios (`4:5`, `9:16`, `16:9`, `1:1`) — dimension changes never add hidden surcharges.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`credit.catalog.*`, `credit.unit.*`, `credit.operation.*`, `credit.csv.featurePricing` in `src/i18n/locales/{vi,en}/credit.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/credit/prices.tsx` (`CreditPriceKpiRow.tsx`, `CreditCatalog.tsx`), `pages/credit/index.tsx` (read-only catalog card for `Owner`) on Web and `src/screens/admin/AdminCreditPricesScreen.tsx`, `src/screens/billing/AgencyCreditScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/credit/prices.tsx` (`CreditPriceKpiRow.tsx`, `CreditCatalog.tsx`), `pages/credit/index.tsx` (read-only catalog card for `Owner`)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminCreditPricesScreen.tsx`, `src/screens/billing/AgencyCreditScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/credit/prices` | Bearer (`Owner`, `Admin`, authenticated workspace members) | `CreditPriceController.prices()` -> `CreditConfigurationService.prices()` latest version per supported operation |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner, Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.11 — Update AI Credit Price](../3-10-11-update-ai-credit-price/spec.md) · [FR 3.10.12 — Import AI Credit Price CSV](../3-10-12-import-ai-credit-price-csv/spec.md) · [FR 3.9.4 — View AI Credit Tracking](../../08-subscription-billing/3-9-4-view-ai-credit-tracking/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
