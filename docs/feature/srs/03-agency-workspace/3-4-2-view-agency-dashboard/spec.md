> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.2 — View Agency Dashboard

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.2` |
| **Use Case ID** | `UC-015` |
| **Feature** | View Agency Dashboard |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner` |
| **Business Rules** | `BR-15, BR-20` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Xem bảng điều khiển tổng quan của công ty (Agency Dashboard — /agency/:id/dashboard). Hiển thị các chỉ số KPI toàn Agency: tổng số Workspace đang hoạt động, số thành viên, tiến độ các chiến dịch truyền thông (Media Campaigns), hiệu suất hoàn thành công việc theo tuần/tháng, và mức tiêu thụ hạn mức gói cước / AI Credit.

**Implementation Summary:** Implements the 2-tab Role-Based Agency Dashboard (Overview + Analytics with 7/30/90-day comparison windows, 0–100 workspace efficiency ranking, Owner-only financial spend & approved package contract value, interactive drill-down DetailDrawer, attention strip for overdue/stalled-review tasks, and `.xlsx` export).

## 2. User Story

As an authorized actor (`Owner`), I want to execute **View Agency Dashboard** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-15, BR-20` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner` within the target Agency/Workspace scope may invoke `GET /api/v1/agencies/{agencyId}/stats · GET /api/v1/analytics/agencies/{agencyId}[/overview|/items|/export.xlsx]`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-15, BR-20`):** Backend service logic (`AgencyServiceImpl.getStats(), DashboardAnalyticsService (Agency & Role-Based Dashboard aggregation)`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `agencies`, `agency_members`, `workspaces`, `workspace_members`, `transactions`, `workspace_media_packages`; MongoDB `tasks`, `posts` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`403 FORBIDDEN` (`MSG07`), `404 AGENCY_NOT_FOUND` (`MSG01`)) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`agency.dashboard.* / dashboard.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/agency/dashboard/index.tsx`, `src/pages/agency/dashboard/components/{AgencyWorkspaceSection,AgencyTaskSection}.tsx`, `src/components/dashboard/{OverviewTop,AnalyticsTab,KpiStrip,AttentionStrip,ComparisonTable,DetailDrawer}.tsx`, `src/services/dashboardAnalyticsService.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/dashboard/{DashboardScreen,HomeDashboardScreen}.tsx`, `src/services/dashboardAnalyticsService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `GET /api/v1/agencies/{agencyId}/stats · GET /api/v1/analytics/agencies/{agencyId}[/overview|/items|/export.xlsx]`
- **Controller & Service (`brandhub-business-service`):** `AgencyController.getStats(), DashboardAnalyticsController.agency() / agencyOverview() / agencyItems() / agencyExport()` -> `AgencyServiceImpl.getStats(), DashboardAnalyticsService (Agency & Role-Based Dashboard aggregation)`
- **Repositories & Stores:** AgencyRepository, AgencyMemberRepository, WorkspaceRepository, WorkspaceMemberRepository, TaskMongoRepository, TransactionRepository, WorkspaceMediaPackageRepository
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `403 FORBIDDEN` (`MSG07`), `404 AGENCY_NOT_FOUND` (`MSG01`).
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
