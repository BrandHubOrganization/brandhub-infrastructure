> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Plan — FR 3.6.35: Chat Realtime

> Implements [spec.md](./spec.md) for canonical roles `Owner, Manager, Creator, Client` enforcing `BR-20, BR-43`.

## 1. Technical Component Map

| Layer | Repository / Package | Concrete Classes & Files |
| :--- | :--- | :--- |
| **API Gateway** | `brandhub-api-gateway` | `GatewayConfig.java` (`/api/v1/**`, `/ws/**`, public `/api/v1/public/surveys/**`), `JwtAuthFilterGatewayFilterFactory.java` |
| **Controllers** | `brandhub-business-service` | `ChatMessageController, ChatController, ChatChannelController, ChatChannelMessageController, ChatAttachmentController, ChatScheduleController, ChatPreferenceController, ChatCallController` |
| **Services** | `brandhub-business-service` | `ChatService, ChatCollaborationService, ChatInboundChannelInterceptor, ChatOutboundChannelInterceptor, WsJwtHandshakeInterceptor, ChatRepositoryReferences` |
| **Repositories / Stores** | `brandhub-business-service` | ChatMessageRepository, ChatMessageQueryRepository, ChatReadStateRepository (MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`) |
| **Security / ACL** | `brandhub-business-service` | `RequireRoleAspect.java`, `WorkspaceAccessService.java`, `MaterialAccessPolicy.java`, `ChatInboundChannelInterceptor.java` |
| **Web Frontend** | `brandhub-web` | `src/pages/chat/*`, `src/services/{chatService,chatCollaborationService}.ts` |
| **Mobile App** | `brandhub-mobile-app` | `src/screens/chat/ChatScreen.tsx`, `src/services/chatService.ts`, `src/utils/chat.ts` |

## 2. Persistence, Storage & Indexing Architecture

- **Primary Data Stores:** MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`; Redis rate-limiter; AWS S3 (`chat-attachments/`).
- **Consolidated Technical Design:**
  - Folds in all 8 chat collaboration modules (`workspace-chat-collaboration`, `chat-rich-composer`, `chat-thread-layout`, `chat-attachments`, `chat-mention-inbox`, `chat-scheduled-messages`, `chat-slash-reference`, `chat-voice-calls`): delivers Workspace-isolated realtime messaging (`BR-20`, `BR-43`) across `PUBLIC`, `PRIVATE`, and `DIRECT` channels with inbound/outbound STOMP membership re-verification, `clientMessageId` idempotency, reply threads, emoji reactions, message pins, inline `@mentions` (up to 20 recipients routed to durable inbox), `/task` & `/material` contextual slash references, encrypted file uploads (JPEG/PNG/WebP/PDF <= 10 MiB, max 5/msg) + pinned-version Material Repository attachments, scheduled messages, Workspace DND & channel mute preferences, and Agora RTC voice calls.
  - **Index & Query Discipline:** All MongoDB (`tasks`, `task_sections`, `task_comments`, `materials`, `material_folders`, `surveys`, `chat_messages`) and PostgreSQL (`hashtags`, `task_content_snapshots`, `audit_logs`) queries include `workspaceId` (`workspace_id`) as the leading filter predicate with stable `(timestamp, _id)` cursor/page tie-breakers.
  - **Storage & Encryption Hygiene:** Binary uploads validate MIME + magic bytes up front, enforce quota/size ceilings, and stream through private capability or presigned endpoints rather than exposing raw bucket keys.

## 3. End-to-End Execution Flow

1. **User Action:** Authenticated actor (`Owner, Manager, Creator, Client`) invokes **Chat Realtime** via `src/pages/chat/*`, `src/services/{chatService,chatCollaborationService}.ts` (Web) or `src/screens/chat/ChatScreen.tsx`, `src/services/chatService.ts`, `src/utils/chat.ts` (Mobile).
2. **Edge & Tenant Verification:** `brandhub-api-gateway` validates JWT (or STOMP `CONNECT` Bearer header); `brandhub-business-service` verifies live PostgreSQL Workspace membership and object-level ACL (`Owner, Manager, Creator, Client`).
3. **Domain Policy & Validation:** `ChatService, ChatCollaborationService, ChatInboundChannelInterceptor, ChatOutboundChannelInterceptor, WsJwtHandshakeInterceptor, ChatRepositoryReferences` validates payload constraints, `BR-20, BR-43` business rules, revision/lease concurrency tokens, and quota/reference guards, mapping violations to `400 CHAT_MESSAGE_INVALID` / `ATTACHMENT_LIMIT_EXCEEDED`, `403 WORKSPACE_ACCESS_DENIED` / `CHANNEL_ACCESS_DENIED`, `429 CHAT_RATE_LIMIT_EXCEEDED` (`BR-20`, `BR-43`).
4. **Atomic Persistence & Outbox Side Effects:** Commits state updates to MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`; Redis rate-limiter; AWS S3 (`chat-attachments/`) and enqueues asynchronous notifications/workers (`task_notification_outbox`, `DriveFolderImportService`, `GoogleSheetsService`, or STOMP topic broadcast) after durable persistence.
5. **Client Cache & Realtime Update:** Frontend reconciles TanStack Query / Zustand / WebSocket state, preserves unsaved form drafts on conflict, and displays localized (`chat.* / chat.channels.* / chat.calls.* / chat.scheduled.*`) status feedback.

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
| **FR / Feature** | `FR 3.6.35` — Chat Realtime |
| **HTTP / WS Endpoints** | `WS /ws/chat (`/app/workspaces/{workspaceId}/chat.send` -> `/topic/workspaces/{workspaceId}/chat`) · GET|POST /api/v1/workspaces/{workspaceId}/chat/channels/* · GET|POST|PUT|DELETE /channels/{channelId}/messages/* · POST|GET /attachments/* · POST|GET|PATCH|DELETE /scheduled-messages/* · GET|PUT /preferences/* · POST|GET /calls/*` |
| **Authorized Canonical Roles** | `Owner, Manager, Creator, Client` |
| **Controller -> Service** | `ChatMessageController, ChatController, ChatChannelController, ChatChannelMessageController, ChatAttachmentController, ChatScheduleController, ChatPreferenceController, ChatCallController` -> `ChatService, ChatCollaborationService, ChatInboundChannelInterceptor, ChatOutboundChannelInterceptor, WsJwtHandshakeInterceptor, ChatRepositoryReferences` |
| **Persistence / Cache Targets** | MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`; Redis rate-limiter; AWS S3 (`chat-attachments/`) |
| **Business Rule Invariants** | `BR-20, BR-43` |
| **Error Code Contract** | `400 CHAT_MESSAGE_INVALID` / `ATTACHMENT_LIMIT_EXCEEDED`, `403 WORKSPACE_ACCESS_DENIED` / `CHANNEL_ACCESS_DENIED`, `429 CHAT_RATE_LIMIT_EXCEEDED` (`BR-20`, `BR-43`) |

## Frontend Cache, i18n & Theme Architecture

- **Web State & Query Management (`brandhub-web`):**
  - Components & Hooks: `src/pages/chat/*`, `src/services/{chatService,chatCollaborationService}.ts`.
  - Query Keys & Cache Invalidation: Scoped by authenticated `userId`, `agencyId`, or `workspaceId` so switching tenants or logging out never leaks cached records across boundaries.
  - Conflict & Error Recovery: Preserves in-progress user form state on `400`/`409` responses, disables duplicate in-flight submissions, and never falls back to hardcoded mock data.
- **Mobile Parity (`brandhub-mobile-app`):**
  - Screens & Services: `src/screens/chat/ChatScreen.tsx`, `src/services/chatService.ts`, `src/utils/chat.ts`.
  - Uses shared REST/WS contract, `expo-secure-store` Bearer token injection, and mobile `workspaceStore` / `authStore` synchronization.
- **Localization & Theme Standards:**
  - Key-parallel Vietnamese (`vi`) and English (`en`) locale entries under `chat.* / chat.channels.* / chat.calls.* / chat.scheduled.*` with zero hardcoded strings.
  - Semantic CSS variables / Tailwind `dark:` variants on Web and `useTheme()` semantic tokens on Mobile verified across Light and Dark modes.
- **Observability & Audit Correlation:**
  - Propagates `X-Request-Id` from `brandhub-api-gateway` into `ApiResponse.requestId` and structured backend logs / `audit_logs` where security-sensitive mutations occur.
- **BA & Module Traceability:** [BA Domain Spec](../../../../ba/05-content-task-workflow.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md).
