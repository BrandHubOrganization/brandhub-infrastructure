# Scheduled chat messages

## Objective and scope

Workspace members can schedule a rich-text message in a DM, channel or thread
(confirmed 2026-10-26). Keep existing channel/context permissions, mentions,
notifications, unread tracking and immediate-send behavior. No uploads, recurring
messages or edits to scheduled content in this iteration; pending content can be
cancelled and composed again. Users can change the send time or cancel a pending
or failed item. No automatic migration/seed on shared databases.

## Acceptance criteria

- A split Send control opens tomorrow 09:00, next Monday 09:00 and custom date/time.
  Enter still sends immediately; scheduling requires an explicit action.
- Dates use the browser's IANA time zone, displayed before confirmation, and are
  stored as UTC Instants plus the original zone. Technical bounds: at least 60
  seconds ahead and at most 120 days at creation/reschedule.
- Clear the draft only after the API confirms persistence. Retain its content
  and retry identity after failure; prevent sending/scheduling it twice in flight.
  An idempotent retry returning FAILED/CANCELLED retains the draft and directs the
  user to the queue; SENT is acknowledged as already sent, never as a new schedule.
- A private Scheduled panel shows only the current user's items in this Workspace,
  including channel/thread context, due time, status and safe error reason. Support
  cursor pagination, refresh, time changes and cancel; no native alert/confirm.
- Above the channel/DM composer, show a compact notice when the current user has
  PENDING/SENDING items in that conversation (including its threads). Show the
  earliest scheduled time, or an honest waiting/sending state for overdue work,
  and a one-click action opening the existing private Scheduled panel. Do not show
  other users' drafts, failed/completed/cancelled items or stale data after errors.
  Read the next item on the server, independently of the queue's pagination. Refresh
  after schedule mutations and periodically while visible. Text uses matching
  vi/en keys noticeScheduled, noticeWaiting, noticeSending and viewAll under
  chat.schedule; use existing light/dark tokens and wrap on small screens.
- Scheduling itself creates no chat message, mention notification, unread count
  or recipient event. Only successful delivery has the usual chat effects.
- Validate sender, channel, mention recipients, thread root and linked context at
  scheduling and again at delivery. Permission loss, archived/read-only channel,
  invalid context or missing root must fail safely, without posting.
  Recheck the sender's account eligibility using AccountAccessPolicy; a valid
  Workspace membership never overrides account suspension/deactivation/deletion.
- The server sends while the browser is closed. Recover overdue work after restart;
  temporary DB/rate-limit failures retry with backoff, at most eight delivery attempts before
  an actionable FAILED state. Never silently drop an item or label it SENT early.
- Mongo transaction commits the actual message, its notification intent and the
  SENT transition together. Stable server delivery IDs and the existing unique
  chat-message index prevent duplicate messages on retry or uncertain commit.
  A durable broadcastPending intent retries channel events after uncertain commit
  or broker failure. Realtime events are at-least-once; clients deduplicate by
  message ID. Replaying an event never inserts another message/notification intent.
- Atomic leases fence workers. Changes/cancel require the expected revision and
  cannot race an item already SENDING; return a conflict and refresh instead.
- All new text uses parallel vi/en `chat.schedule.*` keys. Reuse existing semantic
  colors, dropdown, input, button and responsive side-panel/focus patterns. Support
  light/dark, keyboard navigation, loading/error/empty/conflict states.

## API

- POST `/api/v1/workspaces/{ws}/chat/channels/{channel}/scheduled-messages`:
  `{message: ChatChannelSendRequest, scheduledAt: ISO8601, timeZone: IANA}`.
  `message.clientMessageId` is the creation retry key, not the delivery identity.
- GET `/api/v1/workspaces/{ws}/chat/scheduled-messages`: own items, optional cursor,
  bounded limit and includeCompleted flag; defaults to PENDING/SENDING/FAILED.
- GET `/api/v1/workspaces/{ws}/chat/channels/{channel}/scheduled-messages/upcoming`:
  own earliest PENDING/SENDING item after channel access checks; return only
  `{scheduledAt, timeZone, status}`, with null fields when empty. No content/identity
  data and no new database schema are needed for the conversation notice.
- PATCH `.../scheduled-messages/{id}`: `{revision, scheduledAt, timeZone}`.
- DELETE `.../scheduled-messages/{id}?revision=...`: cancel; preserve audit metadata.

Structured CHAT_SCHEDULE errors cover missing schema/replica-set support, invalid
time, not found/access denied and conflicting revision/state. Only the owner can
view/change/cancel a schedule; Manager role does not grant access to others' drafts.

## Database and rollout

Add only `chat_scheduled_messages`; preserve existing message data/validators/indexes.
MongoDB must support transactions (replica set/Atlas). Add guarded, idempotent
Playground-compatible DRY_RUN/APPLY migration and mirror metadata in fresh init.
Update ChatSampleSeeder with cancelled-only optional examples, never live scheduled
sends. Feature schema readiness is scoped; missing migration must not break normal
chat, startup or other modules.
