# Workspace chat collaboration

## Objective and user story

Upgrade `/workspaces/:id/chat` in the real `brandhub-web` frontend into an efficient workspace communication surface while preserving authenticated REST/STOMP delivery and BrandHub's visual identity. Members need to navigate conversations, find messages and recover failed sends without losing the business context.

## Acceptance criteria

1. Keep existing MANAGER/CREATOR/CLIENT route and backend access checks. OWNER access does not change.
2. Desktop shows a conversation sidebar, message timeline and an optional message details panel. Mobile uses accessible sheets and leaves room for the app's bottom navigation. Closing a sheet restores keyboard focus to the control that opened it, or to visible chat navigation if that control was removed; transferring between sheets must not steal focus from the newly opened sheet.
3. Sidebar lists persisted public/private channels and direct conversations. Selecting a conversation uses its authenticated backend history and access rules.
4. Context URLs keep `contextType` and `contextId`; selecting a context filters its messages and sends using the same context. Optimistic and failed messages must match the selected context too. Unknown or missing context identifiers never cause an unscoped send.
5. Search queries saved channel history by content or sender, with cursor pagination. Pinned-message and thread views use the same channel access checks.
6. Messages use readable, left-aligned collaborative rows, clear sender/time/context and accessible copy/details/retry actions. Copy reports success only after the clipboard operation succeeds.
7. Failed sends can be retried using the original `clientMessageId`; another attempt does not duplicate optimistic rows. Send exceptions restore a failed state. Canonical messages are deduplicated by sender plus client ID and sorted by timestamp plus ID.
8. Switching workspace or authenticated account cannot retain previous messages, drafts or stale asynchronous results. Incoming events from disposed connections are ignored.
9. Reading history or receiving messages while hidden does not automatically mark unseen messages as read; only visible messages in the active view advance read state.
10. Loading, empty, history failure with retry, disconnected, sending and failed-send states remain actionable.
11. All labels use parallel `vi/chat.json` and `en/chat.json` keys under `chat.title`, `chat.loadOlder`, `chat.connection.*`, `chat.empty.*`, `chat.context.*`, `chat.delivery.*`, `chat.composer.*`, `chat.errors.*`, `chat.ui.*`, `chat.actions.*`, `chat.reactions.*`, `chat.search.*`, `chat.thread.*` and `chat.channels.*`.
12. Use existing semantic theme tokens, typography and shared controls. Verify light/dark, keyboard access and 375/768/1440px widths.

## API contract

Authenticated channel REST APIs below are the source of truth; STOMP events invalidate channel queries. Preserve legacy general history, read/unread and STOMP contracts without exposing non-general messages. Do not persist server state in localStorage.

## Errors and edge cases

Preserve loaded messages on pagination/reconnect failure. Prevent concurrent duplicate history requests. Ignore stale requests after account/workspace changes, including A→B→A transitions. Different senders can legitimately reuse a client message ID. A failed optimistic message may later receive its canonical acknowledgement. Search/context filtering must not strand pagination or silently alter composer context. Render message content as plain text.

## Backend and collaboration scope

Deliver persisted PUBLIC/PRIVATE channels, two-person DIRECT conversations, thread replies, reactions, pins, server-side search and channel member/settings management in the real frontend and backend.

- The default `general` channel reuses the existing workspace history. Existing legacy endpoints must exclude non-general messages, including unread counts and read acknowledgements. No historical messages are deleted.
- MANAGER and CREATOR can create channels; CLIENT can use general, explicitly invited channels and DMs with active workspace members. Public non-general channels are discoverable by internal members; CLIENT must be explicitly invited. Private channels and DMs require explicit membership even for managers.
- Creator or an admitted MANAGER manages a channel. Direct participants are fixed; default general cannot be archived or restricted. Posting can be limited to channel managers; archived channels retain read access and reject all writes except manager restoration/settings.
- Channel creation and DM creation are idempotent through stable request IDs/deterministic DM identity. Concurrent membership changes and settings changes use atomic field updates rather than whole-document replacement.
- Replies reference a root in the same workspace/channel. Nested replies resolve to the original root. Sending retains the existing workspace context validation and sender-scoped idempotency; conflicting reuse of a client ID is rejected.
- Reactions use an allowlisted code and atomic add/remove; pins use idempotent PUT/DELETE. Search is scoped to an admitted channel, uses escaped literal text, is bounded and cursor-paged. Threads and pins use the same membership checks as message history.
- New realtime channel topics are guarded on SUBSCRIBE and every outbound MESSAGE against current workspace plus channel membership. Revoked members stop receiving events. Legacy topics never receive private-channel content.
- Frontend automatically reloads channel settings/history after reconnect, handles removed membership with an accessible error and never continues showing previous private-channel data as the selected channel.
- Mentioning a member is plain-text `@name` insertion from an authorized directory; this pass does not claim notification delivery, presence or attachment upload. Huddles, video, external integrations, custom role systems and offline push are outside this pass.

### New contracts

`/api/v1/workspaces/{workspaceId}/chat/channels`: list/create; `/{channelId}`: update; `/{channelId}/members/{userId}`: PUT/DELETE; `/directory`: bounded active-member directory. Channel message APIs live under `/{channelId}/messages` with `before`, `q`, `root`, and `pinned` filters. POST creates messages/replies; `/{messageId}/reactions/{code}` and `/{messageId}/pin` use PUT/DELETE; `/{channelId}/read` persists read state. STOMP notifications use `/topic/workspaces/{workspaceId}/chat/channels/{channelId}` after persistence.

## Definition of done

Frontend typecheck/build and changed-file lint pass; browser fixture checks verify primary workflows, responsive themes and stale-response protection. Report fixture coverage separately from actual multi-user backend testing.
