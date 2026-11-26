> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.10.6 — View User

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.10.6` |
| **Use Case ID** | `UC-133` |
| **Feature** | View User |
| **Domain** | Admin Functions (`3.10`) |
| **Canonical Actors / Roles** | `Admin` |
| **Business Rules** | `BR-30` |
| **Message Codes** | `MSG01, MSG02, MSG07` |
| **Status** | Implemented — Production Verified (Verified against `AdminController.getAllUsers()` & `AdminUserController.detail()`) |

## 1. Objective & Business Value

Allow system `Admin` to search, filter, sort, and inspect all user accounts across the platform (`GET /api/v1/admin/users` and `GET /api/v1/admin/users/{userId}`), viewing canonical system roles, account status (`ACTIVE`, `PENDING_ACTIVATION`, `INACTIVE`, `SUSPENDED`), strike counts, linked OAuth providers, and Agency/Workspace memberships.

## 2. User Story

As an authorized `Admin`, I want to execute **View User** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-30` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Admin` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Multi-Faceted Filtering & Safe Projection:** Supports case-insensitive email/name search, `UserStatus` filter, `SystemRole` filter, strike threshold filter, and deterministic sorting while never exposing `password_hash`, `totp_secret`, or raw session tokens.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`admin.users.{table,filters,status,detail}` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/admin/components/AdminAccountsPanel.tsx`, `AdminUserTable.tsx`, `AdminAccountsPagination.tsx`, `AdminUserDialogs.tsx` on Web and `src/screens/admin/AdminUsersScreen.tsx` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/AdminAccountsPanel.tsx`, `AdminUserTable.tsx`, `AdminAccountsPagination.tsx`, `AdminUserDialogs.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/admin/AdminUsersScreen.tsx`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/admin/users?page={1}&size={20}&search={q}&status={s}&role={r}&strikeFilter={f}&sortBy={NEWEST}` | Bearer (`Admin`) | `AdminController.getAllUsers()` -> `AdminAccountQueryService.list()` paginated directory |
| `GET /api/v1/admin/users/{userId}` | Bearer (`Admin`) | `AdminUserController.detail()` -> `AdminUserDetail` full profile, memberships, subscription & violation summary |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Admin` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.10.7 — Create User](../3-10-7-create-user/spec.md) · [FR 3.10.8 — Update User](../3-10-8-update-user/spec.md) · [FR 3.10.9 — Deactivate User](../3-10-9-deactivate-user/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/09-admin-functions.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
