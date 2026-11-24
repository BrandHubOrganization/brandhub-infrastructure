> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.13: Update Material Repository

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator` enforcing `BR-36`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `MaterialController.updateMaterial() / promoteDraft(), MaterialFolderController.rename() / move() / moveFile(), MaterialVersionController.list() / restore() / delete()` |
| **Services** | `brandhub-business-service` | `MaterialUpdateService, MaterialUpdatePolicy, MaterialFilenamePolicy, MaterialFolderService, MaterialVersionService` |
| **Repositories / Stores** | `brandhub-business-service` | MaterialMongoRepository (MongoDB `materials`, `material_folders`, `material_versions`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/library/components/{MaterialMetadataEditForm,MaterialFolderPicker,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/services/materialService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `materials` (`title`, `tags`, `type`, `purpose`, `visibility`, `clientProfileId`, `folderId`, `versionNumber`, `revision`), `material_folders`, `material_versions`.
- **Consolidated Technical Design:**
  - Folds in `update-material-repository` and `s3-folder-vault-security`: updates material metadata (`title`, sanitized filename via `MaterialFilenamePolicy`, `tags`, processing `type` `RAW` -> `RETOUCHED` -> `WATERMARKED`, `purpose`, and `visibility` / `clientProfileId` audience controls, `BR-36`), moves files/folders across nested directories with cycle prevention, and manages multi-version file history (`v1, v2, v3...` version listing, version restore, and old-version cleanup freeing S3 quota).
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator`) invokes **Update Material Repository** via `src/pages/library/components/{MaterialMetadataEditForm,MaterialFolderPicker,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/services/materialService.ts` (Web) or `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator`).
3. **Domain Policy & Validation:** `MaterialUpdateService, MaterialUpdatePolicy, MaterialFilenamePolicy, MaterialFolderService, MaterialVersionService` validates payload constraints, `BR-36` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 VALIDATION_ERROR` / `FOLDER_CYCLE_DETECTED`, `403 FORBIDDEN`, `404 MATERIAL_NOT_FOUND`, `409 MATERIAL_REVISION_CONFLICT` / `DUPLICATE_NAME_IN_FOLDER` (`BR-36`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `materials` (`title`, `tags`, `type`, `purpose`, `visibility`, `clientProfileId`, `folderId`, `versionNumber`, `revision`), `material_folders`, `material_versions` and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`library.edit.* / library.versions.* / library.folders.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.13` — Update Material Repository |
| **HTTP / WS Endpoints** | `PATCH /api/v1/workspaces/{workspaceId}/materials/{materialId} · POST /{materialId}/move · POST /{materialId}/promote · PATCH /folders/{folderId} · POST /folders/{folderId}/move · GET|POST|DELETE /materials/{materialId}/versions/*` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator` |
| **Controller -> Service** | `MaterialController.updateMaterial() / promoteDraft(), MaterialFolderController.rename() / move() / moveFile(), MaterialVersionController.list() / restore() / delete()` -> `MaterialUpdateService, MaterialUpdatePolicy, MaterialFilenamePolicy, MaterialFolderService, MaterialVersionService` |
| **Persistence / Cache Targets** | MongoDB `materials` (`title`, `tags`, `type`, `purpose`, `visibility`, `clientProfileId`, `folderId`, `versionNumber`, `revision`), `material_folders`, `material_versions` |
| **Business Rule Invariants** | `BR-36` |
| **Error Code Contract** | `400 VALIDATION_ERROR` / `FOLDER_CYCLE_DETECTED`, `403 FORBIDDEN`, `404 MATERIAL_NOT_FOUND`, `409 MATERIAL_REVISION_CONFLICT` / `DUPLICATE_NAME_IN_FOLDER` (`BR-36`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/library/components/{MaterialMetadataEditForm,MaterialFolderPicker,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/services/materialService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `library.edit.* / library.versions.* / library.folders.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
