> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.11: View Material Repository

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-36`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `MaterialFolderController.browse(), MaterialController.listMaterials() / getMaterial() / preview() / storageUsage() / listBrandAssets(), RepositoryEncryptedMediaController.read(), ClientVaultController.personal() / shared()` |
| **Services** | `brandhub-business-service` | `MaterialReadService, MaterialFolderService, MaterialPageQuery, MaterialAccessPolicy, RepositoryEnvelopeCrypto, RepositoryPlaintextCache, ClientVaultService, MaterialStorageUsageService` |
| **Repositories / Stores** | `brandhub-business-service` | MaterialMongoRepository (MongoDB `materials`, `material_folders`, `material_versions`, `client_vault_shares`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/library/index.tsx`, `src/pages/library/components/{MediaTab,MaterialFolderSection,MaterialRepositoryCard,MaterialBadges,MediaDetailPanel,MaterialPreview,MaterialToolbar,MaterialTrashList}.tsx`, `src/services/materialService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/{repositoryLoader,repositoryFilters}.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `materials` (`MaterialDocument`), `material_folders` (`MaterialFolderDocument`), `client_vault_shares`; AWS S3 (`SYSTEM_S3` AES-256-GCM envelope-encrypted objects).
- **Consolidated Technical Design:**
  - Folds in `view-material-repository`, `s3-folder-vault-security`, `material-preview-recovery`, and `library-simple-ux`: renders a two-zone hierarchical browser (`--- folder` above `--- file`) with Vietnamese-collation sorting (`newest`, `oldest`, `name_asc`, `name_desc`), `mediaKind` (`IMAGE`, `VIDEO`, `FILE`), `type` (`RAW`, `RETOUCHED`, `WATERMARKED` with non-blocking `"Ảnh chưa chỉnh sửa"` warning badge on `RAW` photos, `BR-36`), `purpose` (`MATERIAL` vs `BRAND_REFERENCE`), strict per-`clientProfileId` audience isolation (`INTERNAL` vs `CLIENT`), `Client` Personal Vault shared folders, zero-N+1 short-lived encrypted capability preview URLs (`/api/v1/repository-media` with automatic expired-URL recovery), and 5 GB S3 quota meter (`/storage-usage`) — with `SystemRole.ADMIN` blocked from viewing tenant media.
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **View Material Repository** via `src/pages/library/index.tsx`, `src/pages/library/components/{MediaTab,MaterialFolderSection,MaterialRepositoryCard,MaterialBadges,MediaDetailPanel,MaterialPreview,MaterialToolbar,MaterialTrashList}.tsx`, `src/services/materialService.ts` (Web) or `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/{repositoryLoader,repositoryFilters}.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `MaterialReadService, MaterialFolderService, MaterialPageQuery, MaterialAccessPolicy, RepositoryEnvelopeCrypto, RepositoryPlaintextCache, ClientVaultService, MaterialStorageUsageService` validates payload constraints, `BR-36` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 VALIDATION_ERROR`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` (`BR-20`, `BR-36`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `materials` (`MaterialDocument`), `material_folders` (`MaterialFolderDocument`), `client_vault_shares`; AWS S3 (`SYSTEM_S3` AES-256-GCM envelope-encrypted objects) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`library.* / materials.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.11` — View Material Repository |
| **HTTP / WS Endpoints** | `GET /api/v1/workspaces/{workspaceId}/materials/browser · GET /api/v1/workspaces/{workspaceId}/materials · GET /{materialId} · POST /{materialId}/preview · GET /storage-usage · GET /api/v1/repository-media · GET /api/v1/client-vault/browser · GET /api/v1/workspaces/{workspaceId}/client-vault/browser` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `MaterialFolderController.browse(), MaterialController.listMaterials() / getMaterial() / preview() / storageUsage() / listBrandAssets(), RepositoryEncryptedMediaController.read(), ClientVaultController.personal() / shared()` -> `MaterialReadService, MaterialFolderService, MaterialPageQuery, MaterialAccessPolicy, RepositoryEnvelopeCrypto, RepositoryPlaintextCache, ClientVaultService, MaterialStorageUsageService` |
| **Persistence / Cache Targets** | MongoDB `materials` (`MaterialDocument`), `material_folders` (`MaterialFolderDocument`), `client_vault_shares`; AWS S3 (`SYSTEM_S3` AES-256-GCM envelope-encrypted objects) |
| **Business Rule Invariants** | `BR-36` |
| **Error Code Contract** | `400 VALIDATION_ERROR`, `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` (`BR-20`, `BR-36`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/library/index.tsx`, `src/pages/library/components/{MediaTab,MaterialFolderSection,MaterialRepositoryCard,MaterialBadges,MediaDetailPanel,MaterialPreview,MaterialToolbar,MaterialTrashList}.tsx`, `src/services/materialService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`, `src/utils/{repositoryLoader,repositoryFilters}.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `library.* / materials.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
