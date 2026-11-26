> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Three-Tier Role-Based Dashboards, Workspace UX, Timezone Consistency & Duplicate Workspace

| Field | Value |
| :--- | :--- |
| **Module Slug** | `role-based-dashboards-and-ux` |
| **Category** | `02-agency-studio-plans` — Agency, Personal Studio, Dashboards & Realtime Notifications |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `role-based-dashboards`, `dashboard-experience`, `agency-profile-presentation`, `agency-invitation-email-language`, `workspace-timezone-consistency`, `navigation-ux-linked-demo-data`, `landing-lab-replaced-apps`, `admin-ui-consistency`, `duplicate-workspace` |
| **Aligned SRS Domains** | [3.4 Agency & Workspace](../../../srs/03-agency-workspace/README.md) (`3.4.1–3.4.26`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify BrandHub's cross-cutting navigation, **3-tier Role-Based Dashboards** (`Personal -> Agency -> Workspace` with `Overview` + `Analytics` tabs and Excel export), live Agency Profile & localized (`vi`/`en`) invitation email previews, Workspace IANA timezone consistency, **Duplicate Workspace** (`DA-1255`), Landing '17 Replaced Apps' interactive showcase, and Admin UI design-system consistency.

## 2. User Stories

- As an `Owner`, `Manager`, `Creator`, or `Client`, I want a role-tailored Dashboard across Personal, Agency, and Workspace levels showing urgent items, approval bottlenecks, and real KPIs (`DashboardAnalyticsController`) with 1-click drill-down drawers.
- As an `Owner`, I want to duplicate a proven Workspace blueprint (`POST /api/v1/workspaces/{workspaceId}/duplicate`), send Agency invitations in `vi` or `en`, and enforce consistent Workspace timezones on Content Request and Post deadlines.

## 3. Consolidated Acceptance Criteria

1. **Three-Tier Role-Based Dashboards (`role-based-dashboards`, `dashboard-experience`):** `DashboardAnalyticsController` (`/api/v1/analytics/me`, `/agencies/{agencyId}`, `/workspaces/{workspaceId}` + `/overview`, `/items`, `/export.xlsx`) powers `Overview` (KPI strip, `AttentionStrip`, `NextUpCard`, `QuickActions`, inline `DetailDrawer`) and `Analytics` (`ComparisonTable`, `ScoreBadge`, multi-range charts) tailored per canonical role (`Owner`, `Manager`, `Creator`, `Client`).
2. **Agency Branding Live Preview & Localized Invitations (`agency-profile-presentation`, `agency-invitation-email-language`):** `AgencyCreateLivePreview.tsx` and `AgencyDetailLivePreview.tsx` mirror branding edits in real time; `POST /api/v1/agencies/{agencyId}/invitations` accepts recipient email language (`vi` | `en`) and renders localized HTML templates matching the live Agency profile.
3. **Workspace Timezone Consistency (`workspace-timezone-consistency`):** Content Request deadlines, Task due dates, and Post schedules evaluate against `workspaces.timezone` (default `Asia/Ho_Chi_Minh`) across validation, persistence, and UI pickers (`TimezoneSelect.tsx`).
4. **Duplicate Workspace (`duplicate-workspace`, `DA-1255`):** `GET /api/v1/workspaces/{workspaceId}/duplicate-options` and `POST /api/v1/workspaces/{workspaceId}/duplicate` allow `Owner` (within plan workspace quota) to clone folder hierarchy, hashtag collections, watermark presets, and optional internal member roles into a new Workspace without copying Client data or published posts.
5. **Landing Showcase & Admin UI Consistency (`landing-lab-replaced-apps`, `admin-ui-consistency`, `navigation-ux-linked-demo-data`):** Interactive landing showcase demonstrates how BrandHub replaces fragmented SaaS tools; Admin panels share standardized `AdminErrorBanner`, `AdminDateRangePicker`, typography, and linked demo seed integrity.
6. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`dashboard.*`, `agency.invite.emailLanguage`, `workspace.duplicate.*`, `landing.replacedApps.*` in `src/i18n/locales/{vi,en}/*.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
7. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/dashboard/index.tsx`, `pages/agency/dashboard/index.tsx`, `pages/workspace/dashboard.tsx`, `components/dashboard/*`, `DuplicateWorkspaceDialog.tsx`, `AgencyDetailLivePreview.tsx`, `TimezoneSelect.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/dashboard/HomeDashboardScreen.tsx`, `DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/analytics/me[/overview|/items] & /agencies/{id}[/overview|/items|/export.xlsx] & /workspaces/{id}[/overview|/items]` | Bearer (`Owner, Manager, Creator, Client`) | `DashboardAnalyticsController` -> 3-tier role-based KPIs, drill-down items & `.xlsx` export |
| `GET /api/v1/workspaces/{workspaceId}/duplicate-options & POST /duplicate` | Bearer (`Owner`) | `WorkspaceController` -> clones Workspace structure within subscription plan quota |
| `POST /api/v1/agencies/{agencyId}/invitations` | Bearer (`Owner`) | `AgencyController` -> dispatches `vi` or `en` localized invitation email |

## 6. Error Handling, Security & Edge Cases

- **Plan Quota Check on Duplicate Workspace:** Rejects `POST /duplicate` (`403/409 PLAN_LIMIT_REACHED`) if Agency active workspace count already equals plan entitlement.
- **Multi-Agency User Context:** Personal tier (`/api/v1/analytics/me`) aggregates across all Agencies/Workspaces where the user is an active member without leaking sibling Workspaces.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.4 Agency & Workspace](../../../srs/03-agency-workspace/README.md) (`3.4.1–3.4.26`)
- **BA & Architecture References:** [BA 03 Agency & Workspace](../../../../ba/03-agency-workspace.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
