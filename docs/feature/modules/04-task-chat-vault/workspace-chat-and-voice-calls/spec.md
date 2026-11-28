> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Workspace Realtime Chat Channels, Threads, Mentions, Slash References, Scheduled Messages & 1:1 Voice Calls

| Field | Value |
| :--- | :--- |
| **Module Slug** | `workspace-chat-and-voice-calls` |
| **Category** | `04-task-chat-vault` — Task Workflow, Realtime Workspace Chat & Encrypted S3 Vault |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Consolidated Feature Scopes** | `workspace-chat-collaboration`, `chat-attachments`, `chat-mention-inbox`, `chat-rich-composer`, `chat-scheduled-messages`, `chat-slash-reference`, `chat-thread-layout`, `chat-voice-calls` |
| **Aligned SRS Domains** | [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.28–3.6.31` Workspace Collaboration) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Provide a complete, Slack-caliber realtime Workspace communication hub (`pages/chat/index.tsx` & Mobile `ChatScreen.tsx`) over STOMP/WebSocket + MongoDB (`chat_*` collections): public/private Workspace channels & 1:1 DMs (`ChatChannelController`), resizable reply threads (`chat-thread-layout`), rich Markdown/Twemoji composer (`chat-rich-composer`), `@mention` inbox & Do-Not-Disturb preferences (`chat-mention-inbox`), `/` slash references to Tasks/Campaigns/Materials (`chat-slash-reference`), direct S3 & Repository attachments (`chat-attachments`), scheduled messages (`ChatScheduleController`), and **Agora RTC 1:1 DM Voice Calls** (`ChatCallController`).

## 2. User Stories

- As an `Owner`, `Manager`, `Creator`, or `Client` collaborating inside a Workspace, I want rich realtime channels, resizable message threads, `/` Task/Material cards, scheduled announcements, and 1-click 1:1 DM voice calls without leaving BrandHub for external chat apps.

## 3. Consolidated Acceptance Criteria

1. **Channels, DMs, Reactions, Pins & Resizable Threads (`workspace-chat-collaboration`, `chat-thread-layout`):** `ChatChannelController` and `ChatChannelMessageController` support Workspace channels, 1:1 DMs, emoji reactions (`PUT/DELETE .../reactions/{code}`), message pinning (`PUT/DELETE .../pin`), per-channel read cursors (`chat_channel_reads`), and a user-resizable right-hand thread panel (`ChatResizableThread.tsx`, `ChatThreadWidthMenu.tsx`).
2. **Rich Composer, `@Mentions` & `/` Slash Entity Picker (`chat-rich-composer`, `chat-mention-inbox`, `chat-slash-reference`):** `ChatRichComposer.tsx` supports bold/italic/code/lists, Twemoji picker, `@user` / `@channel` mentions (feeding `user_notifications` + mention filter inbox while respecting `ChatPreferenceController` DND/mute settings), and `ChatSlashMenu.tsx` (`/`) embedding live permission-checked Task, Campaign, and Material cards.
3. **Attachments & Repository References (`chat-attachments`):** `ChatAttachmentController` supports both direct file uploads (`POST .../attachments`) and zero-copy references to existing Workspace Repository materials (`POST .../attachments/repository`) with `ChatMediaLightbox.tsx` preview.
4. **Scheduled Messages (`chat-scheduled-messages`):** `ChatScheduleController` (`POST/GET/PATCH/DELETE .../scheduled-messages`) lets users queue messages for future delivery in Workspace timezone, editable or cancellable prior to dispatch.
5. **1:1 DM Voice Calls (`chat-voice-calls`):** `ChatCallController` (`/api/v1/workspaces/{workspaceId}/chat/calls`, `/{callId}/{accept|decline|cancel|end|connected|heartbeat}`, `/{callId}/token`) manages call state machine (`RINGING -> CONNECTED -> ENDED | MISSED | DECLINED`) in MongoDB `chat_calls`, mints short-lived server-signed RTC audio tokens, and renders `ChatCallBar.tsx` with mic mute & heartbeat timeout cleanup.
6. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`chat.{channels,composer,threads,mentions,slash,scheduled,calls,preferences}.*` in `src/i18n/locales/{vi,en}/chat.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
7. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/chat/index.tsx`, `pages/chat/components/{ChatWorkspace,ChatRichComposer,ChatResizableThread,ChatSlashMenu,ChatAttachmentComposer,ChatRepositoryPicker,ChatScheduledPanel,ChatCallBar}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/screens/chat/ChatScreen.tsx`, `src/components/chat/ChatChannelPicker.tsx`, `src/services/chatService.ts` (`@stomp/stompjs` 7.5)
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/POST/PATCH /api/v1/workspaces/{workspaceId}/chat/channels/**` | Bearer (`Owner, Manager, Creator, Client`) | `ChatChannelController` & `ChatChannelMessageController` -> channels, messages, threads, pins, reactions |
| `POST/GET /api/v1/workspaces/{workspaceId}/chat/channels/{channelId}/attachments[/repository]` | Bearer (`Owner, Manager, Creator, Client`) | `ChatAttachmentController` -> file upload & Material Repository link attachment |
| `POST/GET/PATCH/DELETE /api/v1/workspaces/{workspaceId}/chat/**/scheduled-messages/**` | Bearer (`Owner, Manager, Creator, Client`) | `ChatScheduleController` -> scheduled message lifecycle |
| `GET/PUT /api/v1/workspaces/{workspaceId}/chat/preferences/**` | Bearer (`Owner, Manager, Creator, Client`) | `ChatPreferenceController` -> DND & channel mute preferences |
| `POST/GET /api/v1/workspaces/{workspaceId}/chat/calls/**` | Bearer (`Owner, Manager, Creator, Client`) | `ChatCallController` -> 1:1 DM voice call signaling, heartbeat & RTC token |

## 6. Error Handling, Security & Edge Cases

- **Voice Call Simultaneous Glare / Orphaned Ringing:** Only 1 active call allowed per user (`409` on busy); missed-heartbeat reaper (`> 30s` without `heartbeat`) auto-terminates dropped calls.
- **Private Channel Boundary for `Client`:** `Client` only sees channels where explicitly added as a channel member; `/` slash references verify Workspace/role visibility before rendering previews.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.6 Content & Workflow](../../../srs/05-content-task-workflow/README.md) (`3.6.28–3.6.31` Workspace Collaboration)
- **BA & Architecture References:** [BA 05 Content & Task Workflow](../../../../ba/05-content-task-workflow.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
