> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.19: Download Material

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-20`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `MaterialController.download(), MaterialVersionController.download(), RepositoryEncryptedMediaController.read()` |
| **Services** | `brandhub-business-service` | `MaterialReadService, MaterialAccessPolicy, MaterialAuditDelivery, RepositoryEnvelopeCrypto, MaterialVersionService` |
| **Repositories / Stores** | `brandhub-business-service` | MaterialMongoRepository (MongoDB `materials`, `material_versions`), AuditLogRepository |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/library/components/{MaterialDetailActions,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/components/common/DownloadFormatDropdown.tsx`, `src/services/materialService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `materials`, `material_versions`; PostgreSQL `audit_logs`; AWS S3 (`SYSTEM_S3`).
- **Consolidated Technical Design:**
  - Folds in `download-material` and `s3-folder-vault-security`: enforces Workspace membership and per-`clientProfileId` visibility (`MaterialAccessPolicy`, blocking `SystemRole.ADMIN` and cross-client downloads, `BR-20`), rejects soft-deleted Trash items, issues short-lived capability-signed streaming URLs (`Content-Disposition: attachment; filename*=UTF-8...` decrypting AES-256-GCM S3 envelopes on the fly via `RepositoryEncryptedMediaController`) for current or historical file versions, and records download audit events (`MaterialAuditDelivery`).
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **Download Material** via `src/pages/library/components/{MaterialDetailActions,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/components/common/DownloadFormatDropdown.tsx`, `src/services/materialService.ts` (Web) or `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `MaterialReadService, MaterialAccessPolicy, MaterialAuditDelivery, RepositoryEnvelopeCrypto, MaterialVersionService` validates payload constraints, `BR-20` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` / `MATERIAL_IN_TRASH` (`BR-20`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `materials`, `material_versions`; PostgreSQL `audit_logs`; AWS S3 (`SYSTEM_S3`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`library.download.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.19` — Download Material |
| **HTTP / WS Endpoints** | `POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/download · POST /api/v1/workspaces/{workspaceId}/materials/{materialId}/versions/{versionId}/download · GET /api/v1/repository-media` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `MaterialController.download(), MaterialVersionController.download(), RepositoryEncryptedMediaController.read()` -> `MaterialReadService, MaterialAccessPolicy, MaterialAuditDelivery, RepositoryEnvelopeCrypto, MaterialVersionService` |
| **Persistence / Cache Targets** | MongoDB `materials`, `material_versions`; PostgreSQL `audit_logs`; AWS S3 (`SYSTEM_S3`) |
| **Business Rule Invariants** | `BR-20` |
| **Error Code Contract** | `403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`, `404 MATERIAL_NOT_FOUND` / `MATERIAL_IN_TRASH` (`BR-20`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/library/components/{MaterialDetailActions,MaterialVersionHistoryPanel,MediaDetailPanel}.tsx`, `src/components/common/DownloadFormatDropdown.tsx`, `src/services/materialService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/more/MediaLibraryScreen.tsx`, `src/services/materialService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `library.download.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
