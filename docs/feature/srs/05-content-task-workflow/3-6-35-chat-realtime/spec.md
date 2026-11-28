> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.6.35 — Chat Realtime

| Field | Value |
| :--- | :--- |
| **FR Code** | `3.6.35` |
| **Use Case ID** | `UC-087` |
| **Feature** | Chat Realtime |
| **Domain** | Content & Workflow (`FR 3.6`) |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Business Rules** | `BR-20, BR-43` |
| **Document Status** | Implemented & Verified |

## 1. Objective & Functional Scope

Nhắn tin trao đổi trực tuyến thời gian thực giữa các thành viên trong từng kênh Workspace (Chat Realtime — /workspaces/:id/chat). Sử dụng kết nối WebSocket (STOMP) để gửi/nhận tin nhắn văn bản, tệp đính kèm, trạng thái đã xem và lịch sử trò chuyện được cô lập bảo mật tuyệt đối theo từng Workspace (BR-20, BR-43).

**Consolidated Implementation Scope:** Folds in all 8 chat collaboration modules (`workspace-chat-collaboration`, `chat-rich-composer`, `chat-thread-layout`, `chat-attachments`, `chat-mention-inbox`, `chat-scheduled-messages`, `chat-slash-reference`, `chat-voice-calls`): delivers Workspace-isolated realtime messaging (`BR-20`, `BR-43`) across `PUBLIC`, `PRIVATE`, and `DIRECT` channels with inbound/outbound STOMP membership re-verification, `clientMessageId` idempotency, reply threads, emoji reactions, message pins, inline `@mentions` (up to 20 recipients routed to durable inbox), `/task` & `/material` contextual slash references, encrypted file uploads (JPEG/PNG/WebP/PDF <= 10 MiB, max 5/msg) + pinned-version Material Repository attachments, scheduled messages, Workspace DND & channel mute preferences, and Agora RTC voice calls.

## 2. User Story

As an authorized actor (`Owner, Manager, Creator, Client`), I want to execute **Chat Realtime** within my active Workspace with strict role/audience isolation, version/concurrency safety, and responsive feedback, so that content production workflows satisfy `BR-20, BR-43` across Web and Mobile.

## 3. Acceptance Criteria

1. **Workspace & Role Authorization:** Only authenticated actors holding `Owner, Manager, Creator, Client` in the target Workspace (plus `Guest` solely on public survey token endpoints in `3.6.25`) may invoke `WS /ws/chat (`/app/workspaces/{workspaceId}/chat.send` -> `/topic/workspaces/{workspaceId}/chat`) · GET|POST /api/v1/workspaces/{workspaceId}/chat/channels/* · GET|POST|PUT|DELETE /channels/{channelId}/messages/* · POST|GET /attachments/* · POST|GET|PATCH|DELETE /scheduled-messages/* · GET|PUT /preferences/* · POST|GET /calls/*`; revoked or cross-workspace callers are rejected (`401` / `403`).
2. **Core Domain & Security Invariants (`BR-20, BR-43`):** `ChatService, ChatCollaborationService, ChatInboundChannelInterceptor, ChatOutboundChannelInterceptor, WsJwtHandshakeInterceptor, ChatRepositoryReferences` enforces all state-machine locks, audience visibility filters (`INTERNAL` vs per-`clientProfileId` `CLIENT`), storage/file validation rules, and Workspace timezone boundaries (`Asia/Ho_Chi_Minh` default).
3. **Persistence & Envelope Contract:** Operations on MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`; Redis rate-limiter; AWS S3 (`chat-attachments/`) return standardized `ApiResponse<T>` payloads (or authenticated binary/WebSocket frames where applicable) with deterministic `ErrorCode` mappings (`400 CHAT_MESSAGE_INVALID` / `ATTACHMENT_LIMIT_EXCEEDED`, `403 WORKSPACE_ACCESS_DENIED` / `CHANNEL_ACCESS_DENIED`, `429 CHAT_RATE_LIMIT_EXCEEDED` (`BR-20`, `BR-43`)).
4. **Internationalization (`vi` / `en`):** Every label, badge, filter pill, modal prompt, empty state, and error toast uses parallel translation keys (`chat.* / chat.channels.* / chat.calls.* / chat.scheduled.*`) in `src/i18n/locales/vi/*.json` and `en/*.json` — zero hardcoded UI text.
5. **Semantic Light/Dark Theme & Accessibility:** Web (`src/pages/chat/*`, `src/services/{chatService,chatCollaborationService}.ts`) and Mobile (`src/screens/chat/ChatScreen.tsx`, `src/services/chatService.ts`, `src/utils/chat.ts`) components use semantic CSS variables / `dark:` Tailwind tokens and `useTheme()` tokens, supporting keyboard navigation (`Enter`/`Escape`/focus return) and mobile viewports.

## 4. UI / UX & Screen States

- **Web Surface (`brandhub-web`):** `src/pages/chat/*`, `src/services/{chatService,chatCollaborationService}.ts`
- **Mobile Surface (`brandhub-mobile-app`):** `src/screens/chat/ChatScreen.tsx`, `src/services/chatService.ts`, `src/utils/chat.ts`
- **Required UI States:**
  - **Loading / Pending:** Skeleton placeholders, progress indicators for uploads/imports, and disabled duplicate-submit triggers.
  - **Empty State:** Clear localized explanation with role-appropriate CTA — never substituting synthetic mock items.
  - **Conflict / Warning:** Preserves unsaved user drafts on `409` conflicts and surfaces inline warnings (such as `RAW` unedited photo badges or compliance warnings).
  - **Error / Retry:** Actionable inline/banner error state with retry capability.

## 5. API & Realtime Contract

- **Endpoints / Channels:** `WS /ws/chat (`/app/workspaces/{workspaceId}/chat.send` -> `/topic/workspaces/{workspaceId}/chat`) · GET|POST /api/v1/workspaces/{workspaceId}/chat/channels/* · GET|POST|PUT|DELETE /channels/{channelId}/messages/* · POST|GET /attachments/* · POST|GET|PATCH|DELETE /scheduled-messages/* · GET|PUT /preferences/* · POST|GET /calls/*`
- **Controllers (`brandhub-business-service`):** `ChatMessageController, ChatController, ChatChannelController, ChatChannelMessageController, ChatAttachmentController, ChatScheduleController, ChatPreferenceController, ChatCallController`
- **Services:** `ChatService, ChatCollaborationService, ChatInboundChannelInterceptor, ChatOutboundChannelInterceptor, WsJwtHandshakeInterceptor, ChatRepositoryReferences`
- **Repositories / Stores:** ChatMessageRepository, ChatMessageQueryRepository, ChatReadStateRepository (MongoDB `chat_channels`, `chat_messages`, `chat_attachments`, `chat_channel_reads`, `chat_read_states`, `chat_scheduled_messages`, `chat_calls`)

## 6. Error Handling & Edge Cases

- **Domain Error Codes:** `400 CHAT_MESSAGE_INVALID` / `ATTACHMENT_LIMIT_EXCEEDED`, `403 WORKSPACE_ACCESS_DENIED` / `CHANNEL_ACCESS_DENIED`, `429 CHAT_RATE_LIMIT_EXCEEDED` (`BR-20`, `BR-43`).
- **Audience & Removed-Member Isolation:** Removed or deactivated Workspace members lose read/write/WebSocket access immediately on the next request or STOMP frame; `Client` actors never see `INTERNAL`-only materials or other `ClientProfile` assets.
- **Idempotency & Concurrency:** Optimistic revision checks (`workflowRevision`, `revision`, `clientMessageId`, `DriveOperationLease`) prevent race-condition overwrites and duplicate records on retry.

## 7. Definition of Done & Cross-References

- **Definition of Done:** Backend endpoints/handlers verified by automated tests ([test.md](./test.md)), Web & Mobile UI integrated against live APIs, `vi`/`en` locale parity verified, and Light/Dark themes verified.
- **Out of Scope:** Adjacent workflow capabilities covered by sibling FRs in `3.6.1–3.6.35` and social publishing execution in `3.8.1–3.8.15`.
- **Related Documentation:** [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md) · [State Machines](../../../../ba/12-state-machines.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).
