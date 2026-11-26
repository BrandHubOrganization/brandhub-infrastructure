> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.9.4 — View AI Credit Tracking

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.9.4` |
| **Use Case ID** | `UC-125` |
| **Feature** | View AI Credit Tracking |
| **Domain** | Subscription & Billing (`3.9`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Business Rules** | `BR-20, BR-65` |
| **Message Codes** | `MSG01, MSG02, MSG03, MSG07` |
| **Status** | Implemented — Production Verified (Consolidates `ai-credit-balance`, `credit-unification`, `workspace-credit-unification`, `member-credit`, `local-credit-seed`) |

## 1. Objective & Business Value

Provide real-time, `BIGINT`-safe AI Credit balance and per-period consumption tracking across the Sidebar/AI Studio widget (`AiCreditBalance.tsx`), Agency Credit Console (`/agency/:agencyId/credit`), and Workspace AI headers. Unifies reporting on the single Agency wallet (`agency_credit_wallets`, `credit_grants`: `PLAN`, `PURCHASED`, `DEV_SEED`) and Workspace period budgets (`workspace_credit_limits`, `workspace_credit_usage`, `ai_credit_reservations`).

## 2. User Story

As an authorized `Owner, Manager, Creator`, I want to execute **View AI Credit Tracking** with strong ACID financial/administrative guarantees, deterministic concurrency protection, and complete audit logging so that BrandHub's operations strictly satisfy `BR-20, BR-65` without manual database intervention.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Security:** Server-side authorization enforces `Owner, Manager, Creator` on every request (`Admin` verified against live DB `user_system_roles`; `Owner`/`Manager`/`Creator` verified against live `agencies` / `workspace_members`). Unauthorized callers receive `403 FORBIDDEN` (`MSG07`) or scoped `404 NOT_FOUND` on IDOR probes.
2. **Core Domain & Financial Invariants:**
- **1. Effective Balance & Eligibility (`ai-credit-balance`, `workspace-credit-unification`):** `Client` and outsiders are denied (`403`). `Owner` sees full Agency active grant balance (`PLAN` consumed before non-expiring `PURCHASED`, then local-only `DEV_SEED`); `Manager`/`Creator` see effective minimum of Agency available balance and their active Workspace remaining cap (`limit - used - held`). Sidebar widget displays `visible = true` only when eligible and never fabricates plan allowance as wallet balance.
- **2. Four Billable Operations vs Free Actions (`DA-974`):** Only `CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, and `VIDEO_GENERATE` consume Admin-configured credits (`ai_credit_operation_prices`). `CAPTION_VARIANTS` (including refine/adapt), `HASHTAG_GENERATE`, and `CHARACTER_SHEET` persist `unit_credits = 0` (`FREE_V1`).
- **3. Held vs Settled Precision:** `RESERVED` jobs (e.g., pending `VIDEO_GENERATE` or unknown-outcome timeouts awaiting reconciliation) report under `held` (`creditsHeld`), distinct from `SETTLED` (`used`), serialized as strings where needed for JavaScript `BIGINT` safety.
3. **Auditability & Idempotency:** Every mutation records correlation `requestId` and structured audit evidence (`audit_logs` / `billing_audit_events` / `admin_account_operations`), and supports safe retry without duplicate financial side effects.
4. **Internationalization (`vi.json` + `en.json`):** All headings, table columns, status pills, dialogs, validation hints, and error banners use key-parallel translations (`subscription.credits.*`, `credit.balance.*`, `credit.usage.*`, `credit.workspace.*` in `src/i18n/locales/{vi,en}/subscription.json` & `credit.json`) on `brandhub-web` and `tr()` on `brandhub-mobile-app` — zero hardcoded Vietnamese or English text in JSX/TSX.
5. **Light & Dark Mode Compliance:** All components (`components/billing/AiCreditBalance.tsx`, `pages/credit/index.tsx` (`CreditBalancePanel.tsx`, `CreditUsagePanel.tsx`, `WorkspaceCreditPanel.tsx`, `OwnerCreditView.tsx`) on Web and `src/screens/billing/AgencyCreditScreen.tsx`, `src/services/creditService.ts` on Mobile) use semantic CSS variables / Tailwind `dark:` variants and `useAppPreferences().palette` tokens with WCAG AA contrast across Light and Dark modes.

## 4. UI / UX & Screen States

- **Web Surfaces (`brandhub-web`):** `components/billing/AiCreditBalance.tsx`, `pages/credit/index.tsx` (`CreditBalancePanel.tsx`, `CreditUsagePanel.tsx`, `WorkspaceCreditPanel.tsx`, `OwnerCreditView.tsx`)
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/AgencyCreditScreen.tsx`, `src/services/creditService.ts`
- **UI States:**
  - **Loading / Busy:** Skeleton placeholders on initial query; disabled submit button + spinner during in-flight mutation to prevent double-submit races.
  - **Empty:** Contextual localized empty state (e.g. zero invoices/moderation items/users matching filter) with zero fabricated mock data.
  - **Success:** Scoped `TanStack Query` cache invalidation, updated KPI/row state, and localized confirmation toast.
  - **Conflict / Error:** Explicit `409` stale-revision reload prompt or localized validation banner preserving user draft inputs.

## 5. API Contract

| Method & Endpoint | Auth / Guard | Controller & Service Handler |
| :--- | :--- | :--- |
| `GET /api/v1/billing/agencies/{agencyId}/credits/summary?workspaceId={wid}` | Bearer (`Owner, Manager, Creator`) | `CreditBalanceController.summary()` -> `REPEATABLE_READ` snapshot returning `visible`, Agency available/held, and effective Workspace remaining |
| `GET /api/v1/agencies/{agencyId}/credit/balance` | Bearer (`Owner`) | `CreditUsageController.balance()` -> breakdown of `planAvailable`, `purchasedAvailable`, `developmentAvailable`, `totalAvailable`, and `held` |
| `GET /api/v1/agencies/{agencyId}/credit/workspaces` | Bearer (`Owner, Manager, Creator`) | `WorkspaceCreditController.list()` -> `Owner` sees all Agency Workspaces; `Manager`/`Creator` see only their active Workspaces (`workspaceLimit`, `workspaceUsed`, `workspaceHeld`) |
| `GET /api/v1/agencies/{agencyId}/credit/usage/me & /members/{memberId}/usage` | Bearer (`Owner, Manager, Creator`) | `CreditUsageController` -> actor-attributed consumption & per-operation breakdown (`CONTENT_GENERATE`, `AMBASSADOR_GENERATE`, `COMMERCIAL_IMAGE`, `VIDEO_GENERATE`) |
| `GET /api/v1/workspaces/{workspaceId}/ai/credits` | Bearer (`Owner, Manager, Creator`) | `AiCaptionController` -> Editor/Studio workspace credit readiness snapshot |

## 6. Error Handling & Edge Cases

- `FORBIDDEN` (`403`, `MSG07`): Caller lacks `Owner, Manager, Creator` permission or attempts cross-Agency/cross-Workspace access.
- `CONFLICT` (`409`, `MSG03`): Stale `expectedRevision` / `rowVersion`, duplicate idempotency key with mutated payload, or prohibited self-sanction/last-Admin demotion.
- `BAD_REQUEST` / `PAYLOAD_TOO_LARGE` (`400` / `413`, `MSG02` / `MSG14`): Invalid date range, negative/unsafe integer amount, malformed CSV, or de-scoped operation (e.g., plan downgrade or non-SePay provider).

## 7. Related Specifications & References

- **Related SRS FRs & Modules:** [FR 3.9.5 — Buy Credit](../3-9-5-buy-credit/spec.md) · [FR 3.9.6 — Set Credit](../3-9-6-set-credit/spec.md) · [FR 3.10.10 — View AI Credit Price List](../../09-admin-functions/3-10-10-view-ai-credit-price-list/spec.md)
- **BA Domain Baseline:** [BA Specification](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Verified via JUnit 5 + isolated PostgreSQL/MongoDB integration tests, TypeScript/Playwright Web checks, Jest Mobile tests, `vi.json`/`en.json` key parity, and Light/Dark theme audit ([test.md](./test.md)).
- **Out of Scope:** De-scoped capabilities (subscription plan downgrade, PayOS/VNPay/Stripe gateways, or copyright/plagiarism moderation).
