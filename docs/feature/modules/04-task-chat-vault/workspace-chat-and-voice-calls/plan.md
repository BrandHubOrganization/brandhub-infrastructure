> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Workspace Realtime Chat Channels, Threads, Mentions, Slash References, Scheduled Messages & 1:1 Voice Calls (`workspace-chat-and-voice-calls`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `workspace-chat-collaboration`, `chat-attachments`, `chat-mention-inbox`, `chat-rich-composer`, `chat-scheduled-messages`, `chat-slash-reference`, `chat-thread-layout`, `chat-voice-calls` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/workspaces/*/chat/**` + STOMP WebSocket `/ws/**`) |
| **Backend / Worker Services** | `ChatController.java`, `ChatChannelController.java`, `ChatChannelMessageController.java`, `ChatAttachmentController.java`, `ChatPreferenceController.java`, `ChatScheduleController.java`, `ChatCallController.java` |
| **Persistence, Cache & Brokers** | MongoDB `chat_channels`, `chat_messages`, `chat_channel_reads`, `chat_read_states`, `chat_attachments`, `chat_scheduled_messages`, `chat_calls`; AWS S3 chat attachments; PostgreSQL `user_notifications` |
| **Web Frontend (`brandhub-web`)** | `pages/chat/index.tsx`, `pages/chat/components/{ChatWorkspace,ChatRichComposer,ChatResizableThread,ChatSlashMenu,ChatAttachmentComposer,ChatRepositoryPicker,ChatScheduledPanel,ChatCallBar}.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/screens/chat/ChatScreen.tsx`, `src/components/chat/ChatChannelPicker.tsx`, `src/services/chatService.ts` (`@stomp/stompjs` 7.5) |
| **i18n & Theme Assets** | `chat.{channels,composer,threads,mentions,slash,scheduled,calls,preferences}.*` in `src/i18n/locales/{vi,en}/chat.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Channel-Scoped STOMP Topics + MongoDB Persistence:** Messages persist to `chat_messages` first, then fan out over `/topic/workspaces/{workspaceId}/channels/{channelId}` with deterministic message IDs.
- **Server-Authoritative Call State Machine:** Signaling travels over STOMP + REST heartbeats while media audio streams over ephemeral RTC tokens minted per `callId`.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Owner, Manager, Creator, Client`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across MongoDB `chat_channels`, `chat_messages`, `chat_channel_reads`, `chat_read_states`, `chat_attachments`, `chat_scheduled_messages`, `chat_calls`; AWS S3 chat attachments; PostgreSQL `user_notifications` using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `chat.{channels,composer,threads,mentions,slash,scheduled,calls,preferences}.*` in `src/i18n/locales/{vi,en}/chat.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Scheduled Message Sender Removed Before Send Time:** Dispatcher re-validates Workspace & channel membership at fire time; if removed, cancels scheduled message without posting.
