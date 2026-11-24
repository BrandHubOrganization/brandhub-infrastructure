> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.34: View Content History

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator` enforcing `BR-35`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `TaskController.listVersions() / getVersion() / restoreVersion(), TaskSectionController.versions() / version() / restore()` |
| **Services** | `brandhub-business-service` | `TaskContentService, SectionService, AiCaptionService (generation history)` |
| **Repositories / Stores** | `brandhub-business-service` | TaskContentSnapshotRepository, TaskContentOperationRepository (PostgreSQL), SectionStore (MongoDB `task_section_versions`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/task-editor/index.tsx`, `src/components/task-sections/{SectionVersionDrawer,lineDiff.ts}`, `src/pages/ai-studio/video.tsx` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/content-writing/VersionHistory.tsx`, `src/screens/more/AiVideoHistoryScreen.tsx` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** PostgreSQL `task_content_snapshots`, `task_content_operations`; MongoDB `task_section_versions`, `video_auto_edits`, `materials`.
- **Consolidated Technical Design:**
  - Lets `Owner, Manager, Creator` inspect timestamped content snapshots, line-by-line diffs (`lineDiff.ts`), section versions, and previously generated AI captions/images/videos, and restore any historical version into the active editor without re-deducting AI Credits (`BR-35`).
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator`) invokes **View Content History** via `src/pages/task-editor/index.tsx`, `src/components/task-sections/{SectionVersionDrawer,lineDiff.ts}`, `src/pages/ai-studio/video.tsx` (Web) or `src/screens/content-writing/VersionHistory.tsx`, `src/screens/more/AiVideoHistoryScreen.tsx` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator`).
3. **Domain Policy & Validation:** `TaskContentService, SectionService, AiCaptionService (generation history)` validates payload constraints, `BR-35` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `403 FORBIDDEN`, `404 SNAPSHOT_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-35`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to PostgreSQL `task_content_snapshots`, `task_content_operations`; MongoDB `task_section_versions`, `video_auto_edits`, `materials` and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`editor.history.* / taskSections.versions.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.34` — View Content History |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/content/versions · GET /versions/{snapshotId} · POST /versions/{snapshotId}/restore · GET /sections/{sectionKey}/versions · POST /sections/{sectionKey}/restore/{versionNo}` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator` |
| **Controller -> Service** | `TaskController.listVersions() / getVersion() / restoreVersion(), TaskSectionController.versions() / version() / restore()` -> `TaskContentService, SectionService, AiCaptionService (generation history)` |
| **Persistence / Cache Targets** | PostgreSQL `task_content_snapshots`, `task_content_operations`; MongoDB `task_section_versions`, `video_auto_edits`, `materials` |
| **Business Rule Invariants** | `BR-35` |
| **Error Code Contract** | `403 FORBIDDEN`, `404 SNAPSHOT_NOT_FOUND` / `TASK_NOT_FOUND`, `409 TASK_REVIEW_CONTENT_LOCKED` (`BR-35`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/task-editor/index.tsx`, `src/components/task-sections/{SectionVersionDrawer,lineDiff.ts}`, `src/pages/ai-studio/video.tsx`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/content-writing/VersionHistory.tsx`, `src/screens/more/AiVideoHistoryScreen.tsx`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `editor.history.* / taskSections.versions.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
