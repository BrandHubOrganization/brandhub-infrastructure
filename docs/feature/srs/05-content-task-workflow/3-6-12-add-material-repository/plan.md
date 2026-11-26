> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.12: Add Material Repository

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-36`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `MaterialController.uploadMaterial() / createUploadSession() / createMultipartUploadSession() / nextUploadParts() / confirmUploadSession() / cancelUploadSession(), MaterialFolderController.create(), RepositoryEncryptedMediaController.upload(), ClientVaultController.folder() / share()` |
| **Services** | `brandhub-business-service` | `MaterialUploadCoordinator, MaterialUploadPolicy, MaterialContentValidator, RepositoryEnvelopeCrypto, StorageQuotaService, MaterialFolderService, MaterialVersionService, ClientVaultService` |
| **Repositories / Stores** | `brandhub-business-service` | MaterialMongoRepository, MaterialSessionStore, StorageQuotaService |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/library/components/{MediaUploadButton,MaterialUploadForm,MaterialUploadFields,MaterialAudienceFields,MaterialFolderPicker,DuplicateResolutionModal}.tsx`, `src/services/materialService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/content/{UploadScreen,TaskUploadScreen,CameraRecordScreen}.tsx`, `src/screens/more/MediaLibraryScreen.tsx`, `src/services/uploadService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `materials` (`sha256`, `folderId`, `versionNumber`, `encryptionMetadata`, `visibility`, `clientProfileId`), `material_folders`, `material_versions`, `client_vault_shares`; AWS S3 (`SYSTEM_S3`).
- **Consolidated Technical Design:**
  - Folds in `add-material-repository`, `pre-s3-encryption`, `mp4-upload-detection`, `s3-folder-vault-security`, and `client-folder-sharing`: validates magic-byte signatures (including ISO-BMFF `ftyp` box inspection for `.mp4`/`.mov` video detection), enforces the 5 GB free S3 quota + monthly storage add-on limits (`StorageQuotaService`), encrypts payloads with per-object AES-256-GCM DEKs wrapped before S3 storage (`RepositoryEnvelopeCrypto`), creates nested folders, detects SHA-256 content / same-folder filename collisions (`Skip` / `Keep Both` / `Overwrite as v2..vN`), auto-tags `Client` uploads as `BRAND_REFERENCE` scoped to `clientProfileId`, and supports sharing `Client` Personal Vault folders across Workspaces without duplicating S3 bytes.
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **Add Material Repository** via `src/pages/library/components/{MediaUploadButton,MaterialUploadForm,MaterialUploadFields,MaterialAudienceFields,MaterialFolderPicker,DuplicateResolutionModal}.tsx`, `src/services/materialService.ts` (Web) or `src/screens/content/{UploadScreen,TaskUploadScreen,CameraRecordScreen}.tsx`, `src/screens/more/MediaLibraryScreen.tsx`, `src/services/uploadService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `MaterialUploadCoordinator, MaterialUploadPolicy, MaterialContentValidator, RepositoryEnvelopeCrypto, StorageQuotaService, MaterialFolderService, MaterialVersionService, ClientVaultService` validates payload constraints, `BR-36` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 INVALID_FILE_TYPE` / `FILENAME_INVALID`, `403 FORBIDDEN`, `409 DUPLICATE_MATERIAL_DETECTED`, `413 FILE_TOO_LARGE` / `STORAGE_QUOTA_EXCEEDED` (`BR-36`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `materials` (`sha256`, `folderId`, `versionNumber`, `encryptionMetadata`, `visibility`, `clientProfileId`), `material_folders`, `material_versions`, `client_vault_shares`; AWS S3 (`SYSTEM_S3`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`library.upload.* / library.folders.* / library.duplicate.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.12` — Add Material Repository |
| **HTTP / WS Endpoints** | `POST /api/v1/workspaces/{workspaceId}/materials · POST /upload-session · POST /upload-session/multipart · POST /upload-session/{sessionId}/parts · POST /upload-session/confirm · DELETE /upload-session/{sessionId} · POST /folders · PUT /api/v1/repository-media · POST /api/v1/client-vault/folders · POST /api/v1/workspaces/{workspaceId}/client-vault/shares` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `MaterialController.uploadMaterial() / createUploadSession() / createMultipartUploadSession() / nextUploadParts() / confirmUploadSession() / cancelUploadSession(), MaterialFolderController.create(), RepositoryEncryptedMediaController.upload(), ClientVaultController.folder() / share()` -> `MaterialUploadCoordinator, MaterialUploadPolicy, MaterialContentValidator, RepositoryEnvelopeCrypto, StorageQuotaService, MaterialFolderService, MaterialVersionService, ClientVaultService` |
| **Persistence / Cache Targets** | MongoDB `materials` (`sha256`, `folderId`, `versionNumber`, `encryptionMetadata`, `visibility`, `clientProfileId`), `material_folders`, `material_versions`, `client_vault_shares`; AWS S3 (`SYSTEM_S3`) |
| **Business Rule Invariants** | `BR-36` |
| **Error Code Contract** | `400 INVALID_FILE_TYPE` / `FILENAME_INVALID`, `403 FORBIDDEN`, `409 DUPLICATE_MATERIAL_DETECTED`, `413 FILE_TOO_LARGE` / `STORAGE_QUOTA_EXCEEDED` (`BR-36`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/library/components/{MediaUploadButton,MaterialUploadForm,MaterialUploadFields,MaterialAudienceFields,MaterialFolderPicker,DuplicateResolutionModal}.tsx`, `src/services/materialService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/content/{UploadScreen,TaskUploadScreen,CameraRecordScreen}.tsx`, `src/screens/more/MediaLibraryScreen.tsx`, `src/services/uploadService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `library.upload.* / library.folders.* / library.duplicate.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
