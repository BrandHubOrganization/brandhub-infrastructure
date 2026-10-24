# Implementation plan

1. Preserve legacy general chat and route contracts. Introduce authenticated channel services, types and conversation selection under `src/pages/chat/`.
2. Split the UI into a sidebar, header/search controls, message timeline/actions, details panel and composer. Keep `index.tsx` as an orchestrator below 150 lines. Use current theme tokens and shared Button/Input/Sheet controls. Keep explicit opener references for controlled sheets, restore only a visible connected control, and avoid restoring navigation focus when a second sheet is opening.
3. Replace `useWorkspaceChat` with `useChatChannels`, `useChannelMessages` and `useChatRealtime`. Scope TanStack Query keys by account/workspace/channel/filters, cancel obsolete queries, deduplicate by sender and client ID, retry with original IDs, guard realtime parsing and explicitly acknowledge only visible messages.
4. Query server history for search/context/pinned/thread filters and retain cursor pagination. Apply the active context and root filters to optimistic/failed rows as well as canonical messages. Render load failures with retry. Key the workspace/conversation/composer by account, workspace, channel and context to isolate drafts; reconnect does not reset the composer.
5. Update both `src/i18n/locales/vi/chat.json` and `src/i18n/locales/en/chat.json`; preserve key parity.
6. Verify with the installed TypeScript, ESLint, production build and real-browser automation using isolated fixture accounts and intercepted HTTP/STOMP. No live messages are sent to other users during verification.

## Confirmed backend implementation

Use Mongo `chat_channels` and `chat_channel_reads`, extend existing `chat_messages` with nullable channel/thread fields, pin and bounded reactions. Null channel identifies legacy general messages. Add an idempotent infrastructure migration for supporting compound indexes and partial channel-name uniqueness. Keep legacy queries strictly general. Add channel access/directory, channel administration, message query/write services and thin controllers. Reuse existing JWT authentication, membership/context validation and rate limiter. Guard new websocket topics inbound and outbound. Backend unit tests cover private isolation, cross-workspace roots, archive/posting rules, idempotency and atomic updates; add query filter regressions.

Frontend uses new authenticated services for persisted channels/messages and keeps `general` history available through the new facade. Compose channel/sidebar, form, settings/member management, thread panel, message actions, pinned view, search and mention picker. Server data is held in session-owned hooks, never localStorage.

## Risks

Every path that reads a message must scope workspace and channel. Existing workspace member-list endpoints require management permissions; expose a dedicated minimal chat directory with membership checks. Deploy the infrastructure indexes before production use; migration does not run against shared databases automatically. Preserve uncertainty about unexecuted live multi-user tests.
