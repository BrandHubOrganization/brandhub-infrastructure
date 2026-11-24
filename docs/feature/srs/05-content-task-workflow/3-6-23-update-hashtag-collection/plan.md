> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.23: Update Hashtag Collection

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator` enforcing `BR-39`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `HashtagController.update() / replace()` |
| **Services** | `brandhub-business-service` | `HashtagService, HashtagMapper` |
| **Repositories / Stores** | `brandhub-business-service` | HashtagRepository (PostgreSQL `hashtags`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/hashtag-groups/components/{HashtagEntryGrid,AddHashtagDialog}.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/services/hashtagService.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** PostgreSQL `hashtags` (`tag`, `normalized_tag`, `group_name`, `purpose`, `campaign_id`, `updated_at`).
- **Consolidated Technical Design:**
  - Updates hashtag spelling, group label, `HashtagPurpose`, or linked `campaignId` (`BR-39`) for `Owner, Manager, Creator`, re-validating `normalized_tag` uniqueness within the Workspace without retroactively altering already-published social posts.
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator`) invokes **Update Hashtag Collection** via `src/pages/hashtag-groups/components/{HashtagEntryGrid,AddHashtagDialog}.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts` (Web) or `src/services/hashtagService.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator`).
3. **Domain Policy & Validation:** `HashtagService, HashtagMapper` validates payload constraints, `BR-39` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 INVALID_HASHTAG_FORMAT`, `403 FORBIDDEN`, `404 HASHTAG_NOT_FOUND`, `409 DUPLICATE_HASHTAG` (`BR-39`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to PostgreSQL `hashtags` (`tag`, `normalized_tag`, `group_name`, `purpose`, `campaign_id`, `updated_at`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`hashtags.edit.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.23` — Update Hashtag Collection |
| **HTTP / WS Endpoints** | `PATCH /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId} · PUT /api/v1/workspaces/{workspaceId}/hashtags/{hashtagId}` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator` |
| **Controller -> Service** | `HashtagController.update() / replace()` -> `HashtagService, HashtagMapper` |
| **Persistence / Cache Targets** | PostgreSQL `hashtags` (`tag`, `normalized_tag`, `group_name`, `purpose`, `campaign_id`, `updated_at`) |
| **Business Rule Invariants** | `BR-39` |
| **Error Code Contract** | `400 INVALID_HASHTAG_FORMAT`, `403 FORBIDDEN`, `404 HASHTAG_NOT_FOUND`, `409 DUPLICATE_HASHTAG` (`BR-39`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/hashtag-groups/components/{HashtagEntryGrid,AddHashtagDialog}.tsx`, `src/pages/hashtag-groups/services/hashtagService.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/services/hashtagService.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `hashtags.edit.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
