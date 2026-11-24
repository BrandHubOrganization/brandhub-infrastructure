> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Dual-Line Subscription Catalog (Personal Studio & Business Agency Plans) & Admin Plan Editor

| Field | Value |
| :--- | :--- |
| **Module Slug** | `studio-and-agency-plan-catalog` |
| **Category** | `02-agency-studio-plans` — Agency, Personal Studio, Dashboards & Realtime Notifications |
| **Canonical Actors / Roles** | `Guest, Owner, Admin` |
| **Consolidated Feature Scopes** | `studio-personal-plans`, `personal-workspace-mode`, `personal-agency-transition`, `agency-subscription`, `agency-plus-renewal`, `agency-plus-style`, `subscription-four-plan-catalog`, `subscription-catalog-api-ui`, `admin-plan-editor` |
| **Aligned SRS Domains** | [FR 3.9.1 — Upgrade Plan](../../../srs/08-subscription-billing/3-9-1-upgrade-plan/spec.md) · [FR 3.4.1–3.4.5 Agency & Workspace](../../../srs/03-agency-workspace/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Define and govern BrandHub's complete database-backed **2-Product-Line × 6-Plan Subscription Catalog** with `1 / 3 / 6 / 12-month` billing cycles, Personal Studio solo-creator mode (`company_type = PERSONAL`, single-user invariant, seamless `PERSONAL -> AGENCY` transition), Agency Plus renewal & visual badge styling, and the live **Admin Plan Editor** (`/admin?view=plans`).

## 2. User Stories

- As a solo creator `Owner`, I want a streamlined **Personal Studio** experience (`STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO`) without multi-member bureaucracy, with the ability to transition my organization to a full **Business Agency** (`BASIC`, `PLUS`, `ENTERPRISE`) as my team grows.
- As an `Admin`, I want to edit plan entitlements, multi-cycle VND prices (`1/3/6/12` months), and promotional sales on `/admin?view=plans` with full version history (`billing_plan_change_log`).

## 3. Consolidated Acceptance Criteria

1. **2-Product-Line × 6-Plan Matrix (`studio-personal-plans`, `subscription-four-plan-catalog`, `subscription-catalog-api-ui`):**
   - **Personal Studio Line (`company_type = PERSONAL`, `maxMembers = 1`, `3` on `STUDIO_PRO`):** `STUDIO_FREE`, `STUDIO_PLUS`, `STUDIO_PRO` (tailored solo workspace limits, S3 vault quota, AI credit grants, self-approval workflow `POST /tasks/{id}/self-approve`, `POST /api/v1/workspaces/personal/bootstrap`).
   - **Business Agency Line (`company_type = AGENCY`):** `BASIC`, `PLUS`, `ENTERPRISE` (multi-workspace, multi-member `Owner / Manager / Creator / Client` collaboration, full 3-tier approval).
2. **Multi-Cycle Pricing & Renewal (`1 / 3 / 6 / 12` Months, `agency-plus-renewal`, `agency-plus-style`):** `billing_plan_cycle_prices` stores exact cycle prices per plan; active `PLUS` / `STUDIO_PLUS` / `STUDIO_PRO` subscribers can renew early (extending `current_period_end` without losing remaining days) and display semantic `Plus`/`Pro` tier badges.
3. **Personal-to-Agency Transition (`personal-agency-transition`):** A `PERSONAL` Studio `Owner` can upgrade/convert `company_type` from `PERSONAL` to `AGENCY`, unlocking multi-member invitations (`agency_invitations`) and mapping studio entitlements cleanly to the Business Agency catalog without losing Workspaces, Materials, or Posts.
4. **Admin Plan Editor (`/admin?view=plans`, `admin-plan-editor`):** `AdminPlanController` (`GET /api/v1/admin/billing/plans`, `PUT /{code}`, `POST /{code}/sale`, `GET /{code}/history`) enables `Admin` to update display names, limits, `1/3/6/12`-month cycle prices, and time-bounded promotional sales, appending immutable versions in `billing_plan_versions` and `billing_plan_change_log` without mutating already-purchased active subscription snapshots.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`subscription.studio.*`, `subscription.plans.*`, `agency.companyType.*`, `admin.plans.*` in `src/i18n/locales/{vi,en}/{subscription,agency,admin}.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/agency/components/CompanyTypeChooser.tsx`, `CompanyPlanSelector.tsx`, `pages/workspace/components/PersonalQuickLaunchpad.tsx`, `pages/admin/components/AdminPlansPanel.tsx`, `AdminPlanEditDialog.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/billing/SubscriptionPlansScreen.tsx`, `src/components/billing/StudioPlanCard.tsx`, `SubscriptionPlanCard.tsx` (`studioPlans.test.ts`)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/public/billing/plans & GET /api/v1/billing/plans?agencyId={id}` | Guest / Bearer (`Owner`) | `PublicBillingPlanController` & `BillingPlanController` -> live DB catalog filtered by `company_type` |
| `POST /api/v1/workspaces/personal/bootstrap` | Bearer (`Owner`) | `WorkspaceController` -> idempotently bootstraps Solo Studio Workspace for `PERSONAL` mode |
| `GET /api/v1/admin/billing/plans & PUT /{code} & POST /{code}/sale & GET /{code}/history` | Bearer (`Admin`) | `AdminPlanController` -> live catalog editing, promotional sale scheduling & `billing_plan_change_log` audit |

## 6. Error Handling, Security & Edge Cases

- **Member Cap on `PERSONAL` Studio (`2026-11-22-studio-single-user.sql`, `2026-11-24-studio-pro-members.sql`):** `STUDIO_FREE` and `STUDIO_PLUS` are one user; `STUDIO_PRO` allows 3 internal members (owner + 2). Clients are never allowed in a `PERSONAL` company (`maxClients = 0`). Inviting beyond the cap rejects with `403/409` instructing transition to `AGENCY` mode first.
- **Active Subscriber Isolation on Admin Price Edit:** Editing a plan's price on `/admin?view=plans` affects new orders/renewals only; active `agency_subscription_periods` retain their contracted price and entitlements until period end.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.9.1 — Upgrade Plan](../../../srs/08-subscription-billing/3-9-1-upgrade-plan/spec.md) · [FR 3.4.1–3.4.5 Agency & Workspace](../../../srs/03-agency-workspace/README.md)
- **BA & Architecture References:** [BA 03 Agency & Workspace](../../../../ba/03-agency-workspace.md) · [BA 08 Subscription & Billing](../../../../ba/08-subscription-billing.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
