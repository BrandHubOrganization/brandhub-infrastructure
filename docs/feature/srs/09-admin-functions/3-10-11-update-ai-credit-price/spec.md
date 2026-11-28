> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.11 — Update AI Credit Price

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.11` |
| **Use Case ID** | `UC-138` |
| **Feature** | Update AI Credit Price |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30, BR-65` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Verified against `CreditPriceController.updatePrice()` & PostgreSQL advisory-locked immutable revisions) |

## 1. Objective & Business Value

Allow system `Admin` to update the unit credit cost (`unitCredits >= 0`) and `enabled` flag of any supported AI operation (`PUT /api/v1/admin/credit/prices/{operation}`) with `expectedRevision` optimistic concurrency and per-operation PostgreSQL transaction advisory locks, appending a new immutable price revision in `ai_credit_operation_prices` without altering active in-flight AI credit reservations.

## 2. User Story

As an authorized `Admin`, I want to execute **Update AI Credit Price** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30, BR-65` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Immutable Price Versioning & In-Flight Isolation (`BR-65`):** Every update inserts a new `revision = expectedRevision + 1` row in `ai_credit_operation_prices` under a PostgreSQL transaction advisory lock and logs to `audit_logs`. Active `ai_credit_reservations` keep the `price_id` / `unit_credits` frozen at reservation time.
- **2. Safe Integer & Stale Revision Validation:** `unitCredits` must be a non-negative safe integer (`0..9,007,199,254,740,991`); mismatched `expectedRevision` returns `409 CONFLICT` requiring UI reload rather than silently overwriting another `Admin`'s edit.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`credit.price.{edit,unitCredits,enabled,expectedRevisionConflict}` in `src/i18n/locales/{vi,en}/credit.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/credit/prices.tsx`, `pages/credit/components/CreditPriceDrawer.tsx`, `CreditAmountForm.tsx` on Web and `src/screens/admin/AdminCreditPricesScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/credit/prices.tsx`, `pages/credit/components/CreditPriceDrawer.tsx`, `CreditAmountForm.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminCreditPricesScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `PUT /api/v1/admin/credit/prices/{operation}` | Bearer (`Admin`) | `CreditPriceController.updatePrice()` -> `CreditConfigurationService.updatePrice()` (`{ unitCredits, enabled, expectedRevision }`) |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.10 — View AI Credit Price List](../3-10-10-view-ai-credit-price-list/spec.md) · [FR 3.10.12 — Import AI Credit Price CSV](../3-10-12-import-ai-credit-price-csv/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
