# Chat mention inbox foundation

## Objective and acceptance criteria

Persist mention user IDs with new channel messages, validate every recipient's
current channel access, and deliver a durable inbox entry for mentions and new
DIRECT messages. Exclude the sender and deduplicate a DM plus mention. No automatic
mention inference from display names. Legacy requests may omit mentions. Retry of
the same clientMessageId must preserve mention identity; conflicting reuse fails.
Technical limit: 20 distinct mention recipients per message.

Mute/DND preserve inbox and will suppress alerts, not cancel calls. Persist actor-
owned Workspace DND and per-channel mute using narrow atomic updates. Channel
access is checked at delivery, denied recipients are suppressed; infrastructure
failures are retried, not treated as permission denial. Old messages receive no
notification backfill. No message text is copied into notification previews.

## API and scope

Existing send DTO gains optional mentionUserIds; response returns the saved IDs.
GET /api/v1/workspaces/{workspaceId}/chat/preferences reads own DND.
PUT .../preferences/dnd updates own DND; GET/PUT .../preferences/channels/{channelId}
reads/updates own mute. No route permits choosing another user.

Frontend continuation: selecting a member persists identity, not inferred names;
editing across a mention removes its notification identity. Retry preserves IDs.
Typing @ opens suggestions with arrow/Enter/Escape support. Preferences are saved
through actor-scoped APIs; errors leave previous values and offer retry. Use
chat.notifications.* and chat.composer.noMembers/mentionLimit in vi/en chat.json,
existing semantic tokens for both themes. DND applies to this Workspace only.
Alert delivery, presence,
upload, browser push, channel invitations and voice calls remain subsequent work.
File limits and voice scope remain as confirmed in extension-roadmap.md.

## Sample data

Sender labels use chat.ui.you (vi: Bạn, en: You) for current-user message rows,
without rewriting stored names. Thread timelines acknowledge visible latest replies
through existing channel read API; unread counts remain server-derived and refresh
after acknowledgement, not cleared optimistically for unseen messages.

Reliability: preserve in-memory drafts across transient channel read errors; freeze
send/reaction/thread actions until channel refresh succeeds. Revoke cached view on
401/403/404. Respect account-scoped Retry-After for Chat API, no automatic replay of
writes. Bounded GET retries only; show retry feedback using chat.errors.channelUnavailable.
Deep links fetch the referenced message through the scoped API and offer its thread.
Read acknowledgements retry at most three times. Creator Dashboard does not request
Campaign API forbidden by existing Backend roles. Seed image descriptors use the
existing initials fallback rather than becoming image requests.

QA prerequisite: development quick-login supports local email overrides for old
PostgreSQL seed identities; defaults remain aligned with current SeedScale.
No synthetic JWT, account rename, role change or automatic credential fallback.

Mongo seed adds Chat fixtures only using actual active PostgreSQL Manager/Creator
members. No invented membership, Owner impersonation or Client invitation. Skip
Workspaces with fewer than two eligible people. Create public/private channels,
one two-person DM, root/reply messages with mention IDs and a sample reaction/pin.
No delivery intents, SQL inbox writes, realtime events or preference overrides.
Existing samples are never overwritten; deterministic IDs permit repeated calls.
The existing full Mongo seed remains fresh-development-DB only and keeps its marker.
