> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Role-Based Navigation Parity, Three-Tier Dashboards & Agency/Workspace Directory

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-agency-workspace` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `mobile-agency-workspace`, `mobile-nav-role-parity`, `role-based-dashboards-mobile` |
| **Aligned SRS Domains** | [3.4 Agency & Workspace](../../../srs/03-agency-workspace/README.md) (`3.4.1–3.4.26`) · [3.10 Admin Functions](../../../srs/09-admin-functions/README.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Unify `brandhub-mobile-app` navigation, role access control, organizational switching, and analytics: **Role-Gated Drawer & Tab Navigation** (`AppNavigator`, `MainDrawerNavigator`, `WorkspaceTabBar`, `navAccess.ts`, `withAccess.tsx`), **Three-Tier Mobile Role-Based Dashboards** (`Personal -> Agency -> Workspace` with `Overview` + `Analytics` tabs, custom `react-native-svg` charts, and quick-action `BottomSheet`), plus complete **Agency, Workspace, Member, Invitation, Mail Template & Mobile Admin Consoles**.

## 2. User Stories

- As an `Owner`, `Manager`, `Creator`, `Client`, or `Admin` on mobile, I want drawer/tab navigation strictly tailored to my role (`navAccess.ts` mirroring Web `access.ts`), a 3-tier `Overview` + `Analytics` dashboard (`HomeDashboardScreen.tsx`) with 1-tap bottom-sheet actions, and full Agency/Workspace/Invitation/Email-Batch workflows.

## 3. Consolidated Acceptance Criteria

1. **Exact Web-Mobile Role Navigation Parity (`mobile-nav-role-parity`):** `src/utils/navAccess.ts` mirrors `brandhub-web/src/routes/access.ts`, hiding disallowed tabs/drawer items (`WorkspaceTabBar.tsx`, `MoreScreen.tsx`) AND wrapping every screen in `navigation/withAccess.tsx` defense-in-depth guard (`Creator` excluded from Content Requests; `Client` sees own Client Profile FR 3.3.3 instead of Clients list; `Admin` routes to `AdminStackNavigator.tsx`).
2. **Three-Tier Role-Based Dashboards (`role-based-dashboards-mobile`):** `HomeDashboardScreen.tsx` and `DashboardScreen.tsx` consume `/api/v1/analytics/{me|agencies/:id|workspaces/:id}` (`/overview` & `/items`), rendering 2×2 KPI grids, card-based comparison lists (expandable metrics + tap-through navigation), custom `react-native-svg` bar/stacked-bar/horizontal-bar/multi-line charts (`components/dashboard/charts/*` using shared 8-series Light/Dark tokens in `theme/tokens.ts`), and quick-action `BottomSheet` (Start, Reassign, Reschedule, Submit for Review).
3. **Agency, Workspace, Collaborator & Mail Hub Screens (`mobile-agency-workspace`):** Full mobile support across `AgencyListScreen`, `AgencyDetailScreen`, `AgencyMembersScreen`, `AgencyInvitationsScreen`, `AcceptInvitationScreen`, `MyInvitationsScreen`, `WorkspacePickerScreen`, `WorkspaceDetailScreen`, `WorkspaceMembersScreen`, `WorkspaceInviteMemberScreen`, `ClientsScreen`, `ClientProfileScreen`, and `MailTemplatesScreen` / `MailSendScreen` / `MailBatchesScreen`.
4. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`nav.*`, `dashboard.*`, `agency.*`, `workspace.*`, `mail.*` in `src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`mobileI18nParity.test.ts`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
5. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `brandhub-web/src/routes/access.ts`, `pages/agency/*`, `pages/workspace/*`, `pages/dashboard/*`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/navigation/{AppNavigator,MainDrawerNavigator,AgencyStackNavigator,DashboardStackNavigator,AdminStackNavigator,MoreStackNavigator,WorkspaceTabBar,withAccess}.tsx`, `src/screens/{agency,workspace,dashboard,admin}/*`, `src/components/dashboard/charts/*`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET /api/v1/analytics/{me|agencies/{id}|workspaces/{id}}[/overview|/items]` | Bearer (`Owner, Manager, Creator, Client`) | `DashboardAnalyticsController` <- `dashboardAnalyticsService.ts` |
| `GET/POST/PUT/DELETE /api/v1/agencies/** & /api/v1/workspaces/**` | Bearer (`Owner, Manager, Creator, Client`) | `AgencyController` & `WorkspaceController` <- `agencyService.ts` & `workspaceService.ts` |
| `GET/POST /api/v1/workspaces/{id}/mail-templates/** & /mail-batches/**` | Bearer (`Owner, Manager, Creator`) | `MailTemplateController`, `MailSendController`, `MailBatchController` <- `mailSendService.ts` |

## 6. Error Handling, Security & Edge Cases

- **Legacy Stats Route Redirect (`legacyDashboardRoutes.tsx`):** Old `AgencyStats` / `AnalyticsOverview` deep links redirect seamlessly to the new `Analytics` tab.
- **Workspace Launch Hint (`workspaceLaunchHint.test.ts`):** Persists last active Agency/Workspace per user ID safely across app relaunches.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.4 Agency & Workspace](../../../srs/03-agency-workspace/README.md) (`3.4.1–3.4.26`) · [3.10 Admin Functions](../../../srs/09-admin-functions/README.md)
- **BA & Architecture References:** [BA 03 Agency & Workspace](../../../../ba/03-agency-workspace.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
