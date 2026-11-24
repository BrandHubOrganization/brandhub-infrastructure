> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.8: View Task Filter

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-20, BR-33`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `TaskController.getTasks()` |
| **Services** | `brandhub-business-service` | `TaskServiceImpl, WorkspaceTaskReader (`TaskListQuery`)` |
| **Repositories / Stores** | `brandhub-business-service` | TaskMongoRepository (MongoDB `tasks`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/tasks/components/{TaskFilterBar,TaskCategoryBar,TaskMultiSelectFilter}.tsx`, `src/pages/tasks/hooks/{useTaskFilters,useFilterCategoriesStorage}.ts`, `src/pages/tasks/utils/taskFilterUtils.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/content/{TaskListScreen,TaskKanbanScreen}.tsx` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `tasks` (compound indexes on `workspaceId + status + type + assigneeId + dueDate + createdAt`).
- **Consolidated Technical Design:**
  - Executes server-side `AND`-combined MongoDB filtering (`status`, `type`, literal escaped `search` on title/description, `campaignId`, `assignee`, `due` overdue/upcoming presets, `from`/`to` instants, and whitelisted `sort` keys) synchronized into URL query parameters (powering direct drill-down links from Role-Based Dashboards) and persisted across List, Kanban, Calendar, and Timeline switches.
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **View Task Filter** via `src/pages/tasks/components/{TaskFilterBar,TaskCategoryBar,TaskMultiSelectFilter}.tsx`, `src/pages/tasks/hooks/{useTaskFilters,useFilterCategoriesStorage}.ts`, `src/pages/tasks/utils/taskFilterUtils.ts` (Web) or `src/screens/content/{TaskListScreen,TaskKanbanScreen}.tsx` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `TaskServiceImpl, WorkspaceTaskReader (`TaskListQuery`)` validates payload constraints, `BR-20, BR-33` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 VALIDATION_ERROR` (invalid ISO date / page bounds), `403 WORKSPACE_ACCESS_DENIED`.
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `tasks` (compound indexes on `workspaceId + status + type + assigneeId + dueDate + createdAt`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`tasks.filters.*`) status feedback.

## 4. Security, Concurrency & Operational Resilience

- **Strict Multi-Tenant & Per-Client Isolation:** `WorkspaceAccessService` and `MaterialAccessPolicy` re-verify active membership on every request; `Client` queries are additionally restricted to their own `clientProfileId` where audience-scoped.
- **Optimistic Concurrency & Idempotency:** CAS revision counters, unique `(workspaceId, senderUserId, clientMessageId)` indexes, and `DriveOperationLease` locks prevent duplicate side effects under network retries or multi-tab edits.
- **Graceful Degradation:** External provider hiccups (Google Drive, Google Sheets, AI moderation) return explicit retryable error codes without corrupting local MongoDB/PostgreSQL state.

## 5. Cross-References

- **Lifecycle Artefacts:** [spec.md](./spec.md) · [task.md](./task.md) · [test.md](./test.md)
- **BA & Module References:** [05-content-task-workflow.md](../../../../ba/05-content-task-workflow.md) · [12-state-machines.md](../../../../ba/12-state-machines.md) · [Module Specs Index](../../../modules/README.md)

## Endpoint, Authorization & Error Mapping Matrix

| Aspect | Specification |
| :--- | :--- |
| **FR / Feature** | `FR 3.6.8` — View Task Filter |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/tasks?status=&type=&search=&campaignId=&from=&to=&assignee=&due=&sort=&direction=&page=&size=` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `TaskController.getTasks()` -> `TaskServiceImpl, WorkspaceTaskReader (`TaskListQuery`)` |
| **Persistence / Cache Targets** | MongoDB `tasks` (compound indexes on `workspaceId + status + type + assigneeId + dueDate + createdAt`) |
| **Business Rule Invariants** | `BR-20, BR-33` |
| **Error Code Contract** | `400 VALIDATION_ERROR` (invalid ISO date / page bounds), `403 WORKSPACE_ACCESS_DENIED` |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/tasks/components/{TaskFilterBar,TaskCategoryBar,TaskMultiSelectFilter}.tsx`, `src/pages/tasks/hooks/{useTaskFilters,useFilterCategoriesStorage}.ts`, `src/pages/tasks/utils/taskFilterUtils.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/content/{TaskListScreen,TaskKanbanScreen}.tsx`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `tasks.filters.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
