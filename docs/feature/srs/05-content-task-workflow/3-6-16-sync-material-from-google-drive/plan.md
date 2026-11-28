> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.16: Sync Material from Google Drive

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Client` enforcing `BR-36, BR-37`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `DriveFolderImportController.start() / status() / cancel()` |
| **Services** | `brandhub-business-service` | `DriveFolderImportService, CustomerDriveSyncService, CustomerDriveImportStore, RepositoryEnvelopeCrypto, StorageQuotaService` |
| **Repositories / Stores** | `brandhub-business-service` | CustomerDriveImportStore, MaterialMongoRepository (`materials`, `material_folders`), StorageQuotaService |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/library/components/CustomerDrivePanel.tsx`, `src/components/common/BackgroundTaskDock.tsx`, `src/services/materialService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/MediaLibraryScreen.tsx`, `src/services/mediaSyncService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `materials`, `material_folders`, `drive_import_jobs`; AWS S3 (`SYSTEM_S3`).
- **Consolidated Technical Design:**
  - Folds in `client-drive-workspace-sync`, `client-drive-overflow`, and `s3-folder-vault-security`: executes asynchronous, cancellable one-time Google Drive folder-tree import jobs (`DriveFolderImportService`) that recursively recreate nested sub-folders in `material_folders`, validate supported media MIME/magic bytes, pre-encrypt files with `RepositoryEnvelopeCrypto` into `SYSTEM_S3`, enforce remaining S3 storage quota (`413 STORAGE_QUOTA_EXCEEDED` graceful overflow handling without partial corruption), and track real-time job progress (`importedCount`, `skippedCount`, `failedCount`, `BR-36`, `BR-37`).
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Client`) invokes **Sync Material from Google Drive** via `src/pages/library/components/CustomerDrivePanel.tsx`, `src/components/common/BackgroundTaskDock.tsx`, `src/services/materialService.ts` (Web) or `src/screens/more/MediaLibraryScreen.tsx`, `src/services/mediaSyncService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Client`).
3. **Domain Policy & Validation:** `DriveFolderImportService, CustomerDriveSyncService, CustomerDriveImportStore, RepositoryEnvelopeCrypto, StorageQuotaService` validates payload constraints, `BR-36, BR-37` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 INVALID_DRIVE_FOLDER`, `403 FORBIDDEN`, `409 DRIVE_IMPORT_ALREADY_RUNNING`, `413 STORAGE_QUOTA_EXCEEDED` (`BR-36`, `BR-37`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `materials`, `material_folders`, `drive_import_jobs`; AWS S3 (`SYSTEM_S3`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`library.drive.import.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.16` — Sync Material from Google Drive |
| **HTTP / WS Endpoints** | `POST /api/v1/workspaces/{workspaceId}/materials/drive-import · GET /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId} · POST /api/v1/workspaces/{workspaceId}/materials/drive-import/{jobId}/cancel` |
| **Authorized Canonical Roles** | `Owner, Manager, Client` |
| **Controller -> Service** | `DriveFolderImportController.start() / status() / cancel()` -> `DriveFolderImportService, CustomerDriveSyncService, CustomerDriveImportStore, RepositoryEnvelopeCrypto, StorageQuotaService` |
| **Persistence / Cache Targets** | MongoDB `materials`, `material_folders`, `drive_import_jobs`; AWS S3 (`SYSTEM_S3`) |
| **Business Rule Invariants** | `BR-36, BR-37` |
| **Error Code Contract** | `400 INVALID_DRIVE_FOLDER`, `403 FORBIDDEN`, `409 DRIVE_IMPORT_ALREADY_RUNNING`, `413 STORAGE_QUOTA_EXCEEDED` (`BR-36`, `BR-37`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/library/components/CustomerDrivePanel.tsx`, `src/components/common/BackgroundTaskDock.tsx`, `src/services/materialService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/MediaLibraryScreen.tsx`, `src/services/mediaSyncService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `library.drive.import.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
