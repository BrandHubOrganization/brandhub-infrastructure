> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.4.13: View Workspace Dashboard

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-15, BR-20`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `JwtAuthFilterGatewayFilterFactory.java`, `InboundSecurityWebFilter.java`, `GatewayConfig.java` (`/api/v1/**`) |
| **Controller** | `brandhub-business-service` | `WorkspaceController.getDashboard(), DashboardAnalyticsController.workspace() / workspaceOverview() / workspaceItems()` |
| **Service** | `brandhub-business-service` | `WorkspaceServiceImpl.getDashboard(), DashboardAnalyticsService` |
| **Repositories** | `brandhub-business-service` | WorkspaceRepository, WorkspaceMemberRepository, WorkspaceMediaPackageRepository, MediaCampaignRepository, TaskMongoRepository, PostMongoRepository, CreditAccountingStore |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceIsolationHelper.java`, `WorkspaceAccessService.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/workspace/dashboard.tsx`, `src/pages/workspace/components/dashboard/{WorkspaceDashboardHeader,DashboardTabSwitcher,RoleWorkspaceOverview,WorkspaceAnalyticsTab}.tsx`, `src/components/dashboard/{DetailDrawer,AttentionStrip,NextUpCard}.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/workspace/WorkspaceDetailScreen.tsx`, `src/screens/dashboard/DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts` |

## 2. Data Model, Schema & Indexes

- **Primary Stores:** PostgreSQL `workspaces`, `workspace_members`, `workspace_media_packages`, `media_campaigns`; MongoDB `tasks`, `posts`.
- **Key Architectural Details:**
  - Combines Workspace summary metadata (`GET /workspaces/{workspaceId}/dashboard`) with the 2-tab Role-Based Workspace Dashboard (`Overview` + `Analytics` via `/api/v1/analytics/workspaces/{workspaceId}/*`), tailoring KPIs, Next-Up cards, attention alerts, and drill-down task/post drawers to `Owner`, `Manager`, `Creator`, and `Client`.
  - **Multi-Tenant Indexing:** Foreign-key and composite lookup indexes on `agencies(owner_id, status)`, `agency_members(agency_id, user_id)`, `workspaces(agency_id, status)`, `workspace_members(workspace_id, user_id, is_active)`, and `workspace_invitations` / `agency_invitations(token, status, expires_at)` ensure single-digit millisecond ACL and listing queries.
  - **Canonical Timezone Source:** Workspace timezone reads/writes use `workspaces.timezone_config` (default `Asia/Ho_Chi_Minh`) mirrored cleanly in `WorkspaceResponse.settings.timezone`.

## 3. End-to-End Execution Flow

1. **Client Invocation:** Authorized actor (`Owner, Manager, Creator, Client`) initiates **View Workspace Dashboard** from `src/pages/workspace/dashboard.tsx`, `src/pages/workspace/components/dashboard/{WorkspaceDashboardHeader,DashboardTabSwitcher,RoleWorkspaceOverview,WorkspaceAnalyticsTab}.tsx`, `src/components/dashboard/{DetailDrawer,AttentionStrip,NextUpCard}.tsx` (Web) or `src/screens/workspace/WorkspaceDetailScreen.tsx`, `src/screens/dashboard/DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts` (Mobile).
2. **Gateway & Principal Resolution:** `brandhub-api-gateway` validates Bearer JWT signature and Redis blacklist status (`jwt:blacklist:{jti}`), forwarding `X-Request-Id` and principal headers to `brandhub-business-service`.
3. **Authorization & Business Rule Validation:** `WorkspaceController.getDashboard(), DashboardAnalyticsController.workspace() / workspaceOverview() / workspaceItems()` validates DTO constraints (`@Valid`) and delegates to `WorkspaceServiceImpl.getDashboard(), DashboardAnalyticsService`, which verifies live DB role/ownership (`Owner, Manager, Creator, Client`) and domain rules (`BR-15, BR-20`).
4. **Atomic Persistence / Aggregation:** Executes `@Transactional` queries/updates across PostgreSQL `workspaces`, `workspace_members`, `workspace_media_packages`, `media_campaigns`; MongoDB `tasks`, `posts`, mapping domain violations deterministically to `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`.
5. **Client State Synchronization:** Returns `ApiResponse<T>`; frontend invalidates scoped TanStack Query keys (`agency` / `workspaces` / `dashboard`), updates Zustand active org/workspace context when applicable, and renders localized (`workspace.dashboard.* / dashboard.*`) feedback.

## 4. Security, Concurrency & Operational Guards

- **Zero Client-Trusted Role Claims:** Every Workspace/Agency check re-queries PostgreSQL (`agency.ownerId` or active `workspace_members` row via `@RequireRoleAspect` / `WorkspaceAccessService`) so revoked members lose access immediately without waiting for JWT expiry.
- **Race-Condition Protection:** Database uniqueness constraints (`UNIQUE(agency_id, user_id)`, active single-Manager check, idempotent `duplication_request_id`, and atomic invitation status transitions) prevent duplicate records on double-clicks or concurrent admin actions.
- **No Mock Fallback in Production:** Empty lists and backend errors render explicit localized empty/retry states rather than synthetic placeholder rows.

## 5. Cross-References

- **Specification & Test Suite:** [spec.md](./spec.md) · [task.md](./task.md) · [test.md](./test.md)
- **BA & Architecture Docs:** [03-agency-workspace.md](../../../../ba/03-agency-workspace.md) · [Module Specs Index](../../../modules/README.md)

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.4.13` — View Workspace Dashboard |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/dashboard · GET /api/v1/analytics/workspaces/{workspaceId}[/overview|/items]` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `WorkspaceController.getDashboard(), DashboardAnalyticsController.workspace() / workspaceOverview() / workspaceItems()` -> `WorkspaceServiceImpl.getDashboard(), DashboardAnalyticsService` |
| **Persistence / Cache Targets** | PostgreSQL `workspaces`, `workspace_members`, `workspace_media_packages`, `media_campaigns`; MongoDB `tasks`, `posts` |
| **Business Rule Invariants** | `BR-15, BR-20` |
| **Error Code Contract** | `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/workspace/dashboard.tsx`, `src/pages/workspace/components/dashboard/{WorkspaceDashboardHeader,DashboardTabSwitcher,RoleWorkspaceOverview,WorkspaceAnalyticsTab}.tsx`, `src/components/dashboard/{DetailDrawer,AttentionStrip,NextUpCard}.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/workspace/WorkspaceDetailScreen.tsx`, `src/screens/dashboard/DashboardScreen.tsx`, `src/services/dashboardAnalyticsService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `workspace.dashboard.* / dashboard.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
