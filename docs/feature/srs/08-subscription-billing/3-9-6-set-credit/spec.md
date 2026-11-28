> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.6 — Set Credit

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.6` |
| **Use Case ID** | `UC-127` |
| **Feature** | Set Credit |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-20, BR-65` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07, MSG53` |
| **Status** | Implemented — Production Verified (Consolidates `workspace-credit-unification` & `member-credit` (`WorkspaceCreditController` + retired personal-limit `410` compatibility)) |

## 1. Objective & Business Value

Allow an Agency `Owner` to configure per-Workspace AI Credit spending ceilings (`PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit`) with optimistic concurrency (`expectedRevision`), governing how much of the shared Agency wallet each Workspace (`Owner`, `Manager`, `Creator`) may consume per billing period.

## 2. User Story

As an authorized `Owner`, I want to execute **Set Credit** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-65` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Semantic Distinction of `NULL` vs `0` (`BR-65`):** `cap = null` explicitly removes the separate Workspace ceiling (Workspace may spend up to the shared Agency wallet); `cap = 0` explicitly blocks all positive-cost AI generations in that Workspace; blank UI inputs are never coerced to `0`.
- **2. Overlapping Ceiling Model & Non-Retroactivity:** Workspace caps are spending ceilings (not pre-allocated sub-wallets), so the sum of caps across Workspaces may exceed the Agency balance. Lowering a Workspace cap immediately gates new reservations without rewriting historical `SETTLED` usage or cancelling in-flight `RESERVED` jobs.
- **3. Optimistic Revision Guard:** Missing `workspace_credit_limits` row starts at `revision = 0`; updates verify `expectedRevision` under the parent Agency row lock and increment `revision` (`409 CONFLICT` on stale concurrent save).
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`credit.workspace.{title,unlimited,zeroBlocked,saveCap,staleConflict}` in `src/i18n/locales/{vi,en}/credit.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`pages/credit/components/WorkspaceCreditPanel.tsx`, `WorkspaceCreditRow.tsx`, `WorkspaceCreditForm.tsx`, `CreditAmountForm.tsx` on Web and `src/screens/billing/AgencyCreditScreen.tsx` (`Owner` Workspace cap editor) on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `pages/credit/components/WorkspaceCreditPanel.tsx`, `WorkspaceCreditRow.tsx`, `WorkspaceCreditForm.tsx`, `CreditAmountForm.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/AgencyCreditScreen.tsx` (`Owner` Workspace cap editor)
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/agencies/{agencyId}/credit/workspaces` | Bearer (`Owner, Manager, Creator`) | `WorkspaceCreditController.list()` -> returns Workspace caps, current `revision`, `workspaceUsed`, and `workspaceHeld` |
| `PUT /api/v1/agencies/{agencyId}/credit/workspaces/{workspaceId}/limit` | Bearer (`Owner`) | `WorkspaceCreditController.update()` -> sets `{ cap: number | null, expectedRevision: number }` on `workspace_credit_limits` |
| `PUT /api/v1/agencies/{agencyId}/credit/policy & /members/{memberId}/limit` | Bearer (`Owner`) | `AgencyCreditConfigurationController` -> returns `410 CREDIT_PERSONAL_LIMIT_RETIRED` on deprecated personal-limit writes per Workspace Credit Unification |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.4 — View AI Credit Tracking](../3-9-4-view-ai-credit-tracking/spec.md) · [FR 3.9.5 — Buy Credit](../3-9-5-buy-credit/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
