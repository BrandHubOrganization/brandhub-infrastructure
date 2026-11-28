> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.13 — View Workspace Dashboard

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.4.13` |
| **Use Case ID** | `UC-026` |
| **Feature** | View Workspace Dashboard |
| **Domain** | Agency & Workspace (`FR 3.4`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-15, BR-20` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Scope

Xem bảng điều khiển tổng quan của từng Workspace (Workspace Dashboard — /workspaces/:id/dashboard). Hiển thị thống kê tiến độ công việc theo trạng thái (Backlog, In Progress, In Review, Approved, Published), lịch đăng bài sắp tới, tiến độ chiến dịch truyền thông và lượng AI Credit đã sử dụng của Workspace.

**Implementation Summary:** Combines Workspace summary metadata (`GET /workspaces/{workspaceId}/dashboard`) with the 2-tab Role-Based Workspace Dashboard (`Overview` + `Analytics` via `/api/v1/analytics/workspaces/{workspaceId}/*`), tailoring KPIs, Next-Up cards, attention alerts, and drill-down task/post drawers to `Owner`, `Manager`, `Creator`, and `Client`.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **View Workspace Dashboard** with strict multi-tenant authorization and real-time state consistency, so that organizational governance and role-scoped workflows satisfy `BR-15, BR-20` across Web and Mobile.

## 3. Acceptance Criteria

1. **Canonical Role & Tenant Gate:** Only authenticated users holding `Owner, Manager, Creator, Client` within the target Agency/Workspace scope may invoke `GET /api/v1/workspaces/{workspaceId}/dashboard · GET /api/v1/analytics/workspaces/{workspaceId}[/overview|/items]`; unauthorized callers are rejected (`401` / `403`).
2. **Business Rule Enforcement (`BR-15, BR-20`):** Backend service logic (`WorkspaceServiceImpl.getDashboard(), DashboardAnalyticsService`) enforces all domain invariants, uniqueness constraints, and soft-delete / single-Manager / TTL rules before committing state changes.
3. **Standardized Envelope & Persistence:** Reads and mutations against PostgreSQL `workspaces`, `workspace_members`, `workspace_media_packages`, `media_campaigns`; MongoDB `tasks`, `posts` return `ApiResponse<T>` with deterministic `ErrorCode` mappings (`403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`) and `X-Request-Id` correlation.
4. **Internationalization (`vi` / `en`):** All UI labels, empty states, dialogs, and toast notifications use parallel locale keys (`workspace.dashboard.* / dashboard.*`) in `vi` and `en` bundles — zero hardcoded strings in JSX/TSX.
5. **Semantic Light/Dark Theme:** All cards, tables, badges, drawers, and confirmation modals use semantic CSS variables / Tailwind `dark:` tokens (`brandhub-web`) and `useTheme()` tokens (`brandhub-mobile-app`) with WCAG-compliant contrast.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/workspace/dashboard.tsx`, `src/pages/workspace/components/dashboard/{WorkspaceDashboardHeader,DashboardTabSwitcher,RoleWorkspaceOverview,WorkspaceAnalyticsTab}.tsx`, `src/components/dashboard/{DetailDrawer,AttentionStrip,NextUpCard}.tsx`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/workspace/WorkspaceDetailScreen.tsx`, `src/screens/dashboard/DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts`
- **Interactive States:**
  - **Loading:** Skeleton cards/rows and disabled in-flight submit buttons preventing duplicate requests.
  - **Empty State:** Contextual empty state with localized guidance and primary CTA where permitted by role.
  - **Success:** TanStack Query cache invalidation + localized confirmation toast without full-page reload.
  - **Error / Recovery:** Inline field validation or retryable `DataErrorState` banner mapped from backend `ErrorCode` — never silently falling back to mock data.

## 5. API Contract

- **Endpoints:** `GET /api/v1/workspaces/{workspaceId}/dashboard · GET /api/v1/analytics/workspaces/{workspaceId}[/overview|/items]`
- **Controller & Service (`brandhub-business-service`):** `WorkspaceController.getDashboard(), DashboardAnalyticsController.workspace() / workspaceOverview() / workspaceItems()` -> `WorkspaceServiceImpl.getDashboard(), DashboardAnalyticsService`
- **Repositories & Stores:** WorkspaceRepository, WorkspaceMemberRepository, WorkspaceMediaPackageRepository, MediaCampaignRepository, TaskMongoRepository, PostMongoRepository, CreditAccountingStore
- **Authentication:** `Authorization: Bearer <accessToken>` verified by `JwtAuthFilterGatewayFilterFactory` (`brandhub-api-gateway`) and `JwtAuthenticationFilter` / `@RequireRoleAspect` (`brandhub-business-service`).

## 6. Error Handling & Edge Cases

- **Error Codes:** `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`.
- **Tenant Boundary Isolation:** Soft-deleted Agencies/Workspaces (`EntityStatus.SOFT_DELETED`) and deactivated memberships (`is_active = false`) are excluded from operational reads and rejected on mutations.
- **Concurrency & Idempotency:** Transactional persistence (`@Transactional`) and database unique constraints prevent duplicate memberships, duplicate active Managers, or partial writes under concurrent requests.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints and service logic verified against [test.md](./test.md), Web & Mobile UI wired to live APIs, `vi`/`en` locale parity verified, and Light/Dark mode verified.
- **Out of Scope:** Adjacent Agency/Workspace operations covered by sibling FRs in `3.4.1–3.4.26`.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [Organization Structure](../../../../ba/01-organization-structure.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
