> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.3: Add Comments on Task

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-20`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `TaskCommentController.list() / create() / members() / upload() / content()` |
| **Services** | `brandhub-business-service` | `TaskCommentService, TaskCommentAccess, TaskCommentUploads, TaskCommentImageValidator, TaskCommentOutbox, TaskNotificationWorker` |
| **Repositories / Stores** | `brandhub-business-service` | TaskCommentStore (MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`), WorkspaceMemberRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/tasks/components/TaskDetailPanel.tsx`, `src/pages/tasks/hooks/{useTaskCommentComposer,useTaskCommentMembers,useTaskCommentRichEditor}.ts`, `src/pages/tasks/utils/{TaskCommentMentionNode,taskCommentMention,taskCommentRichText}.ts`, `src/pages/tasks/services/taskCommentService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`; PostgreSQL `workspace_members`, `user_notifications`; AWS S3 (`task-comments/`).
- **Consolidated Technical Design:**
  - Provides chronological/cursor-paginated discussion threads strictly separated from formal approval notes (`task_approvals`), supporting rich text, inline `@mentions` validated against active Workspace members (`/comment-members`), private authenticated image attachments (`/comment-uploads` validated by `TaskCommentImageValidator`), and durable `TASK_COMMENTED` / mention inbox notifications (`BR-20`).
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **Add Comments on Task** via `src/pages/tasks/components/TaskDetailPanel.tsx`, `src/pages/tasks/hooks/{useTaskCommentComposer,useTaskCommentMembers,useTaskCommentRichEditor}.ts`, `src/pages/tasks/utils/{TaskCommentMentionNode,taskCommentMention,taskCommentRichText}.ts`, `src/pages/tasks/services/taskCommentService.ts` (Web) or `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `TaskCommentService, TaskCommentAccess, TaskCommentUploads, TaskCommentImageValidator, TaskCommentOutbox, TaskNotificationWorker` validates payload constraints, `BR-20` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND` (`BR-20`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`; PostgreSQL `workspace_members`, `user_notifications`; AWS S3 (`task-comments/`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`tasks.comments.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.3` — Add Comments on Task |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/comments · POST /comments · GET /comment-members · POST /comment-uploads · GET /comment-uploads/{uploadId}/content` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `TaskCommentController.list() / create() / members() / upload() / content()` -> `TaskCommentService, TaskCommentAccess, TaskCommentUploads, TaskCommentImageValidator, TaskCommentOutbox, TaskNotificationWorker` |
| **Persistence / Cache Targets** | MongoDB `task_comments`, `task_comment_uploads`, `task_notification_outbox`; PostgreSQL `workspace_members`, `user_notifications`; AWS S3 (`task-comments/`) |
| **Business Rule Invariants** | `BR-20` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `INVALID_FILE_TYPE` / `FILE_TOO_LARGE`, `403 WORKSPACE_ACCESS_DENIED`, `404 TASK_NOT_FOUND` (`BR-20`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/tasks/components/TaskDetailPanel.tsx`, `src/pages/tasks/hooks/{useTaskCommentComposer,useTaskCommentMembers,useTaskCommentRichEditor}.ts`, `src/pages/tasks/utils/{TaskCommentMentionNode,taskCommentMention,taskCommentRichText}.ts`, `src/pages/tasks/services/taskCommentService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/content/TaskDetailScreen.tsx`, `src/services/taskService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `tasks.comments.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
