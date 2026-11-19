# Chat slash reference picker

## Objective and acceptance criteria

Typing `/` in the chat composer (same editor as `chat-rich-composer`) opens a
merged, single-list search picker across four entity kinds: Task (including
`TaskType: POST` rows, labelled as content/ấn phẩm in the UI), Media Campaign
(`media_campaigns` / `MediaCampaignController`), and the existing repository
file picker already delivered by `chat-attachments`. The fourth kind reuses
that existing picker instead of a new one. Typing after `/` filters by name
across all kinds at once — no kind must be chosen first. Arrow/Enter/Escape
behave like the existing `@` mention picker (`useChatRichEditor`); `/` and `@`
triggers are independent and mutually exclusive at the same caret position.

A selected result inserts a new atomic, non-editable `reference` rich-content
node (sibling of the existing `mention` node), carrying `refType`
(`TASK` | `MEDIA_CAMPAIGN`), `refId`, and a denormalized `label` snapshot for
plain-text/search fallback — mirroring how `mention` nodes snapshot
`label`. File references continue to use the existing attachment flow and
are out of scope for the new node type.

Sent messages render the `reference` node as a rich preview card (title,
status badge, thumbnail/avatar where applicable) instead of plain text,
fetched by `refId` through each domain's existing viewer-scoped read API
(`GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}`,
`GET /api/v1/media-campaigns/{campaignId}`). Preview data is fetched live at
render time per the current viewer's access, never cached into the stored
message — same "deny without leaking name/thumbnail" rule as
`chat-attachments`. A referenced entity the viewer cannot access renders a
generic "no access" placeholder, not an error and not the real title.

Clicking a preview card navigates to that Task or Media Campaign's own page.
That page in turn shows a backlink list of channel messages that reference
it (bidirectional), fetched through a new scoped endpoint — see API section.
Backlinks are message pointers (channel/thread id + message id), not copies
of message content; the list resolves current channel access same as
existing deep-link behavior.

Preview cards expose a small set of inline quick actions matching what the
viewer could already do on that entity's own page under their existing
role/permission rules — no action is newly grantable from chat. Scope for
v1: Task status transition (reusing the existing allowed-transition rule)
and Media Campaign approval action, both already present as standalone APIs.
Actions call the existing domain APIs directly; chat has no bespoke
mutation path. A failed or forbidden action shows the existing domain error,
not a generic chat error.

When a message containing a `reference` node is sent, the referenced
entity's assignee (Task) is notified through a new delivery path parallel to
`chat-mention-inbox`'s existing inbox (same DND/mute, dedup against being
both assignee and a `mention` recipient in the same message, same 20-
recipient technical cap shared across mentions+references, no backfill for
old messages). Media Campaign references do not notify — campaigns have no
single assignee field; this may be revisited later. This is additive to the
existing mention inbox, not a replacement.

## Non-goals

No new "Content/Post" domain — `POST`-typed tasks are Task rows and use the
Task read API. No campaign-detail domain fields beyond what
`MediaCampaignController` already exposes. No write-back from chat to the
referenced entity beyond the two quick actions named above. No offline/
cached preview. `WorkspaceCampaignController`'s `campaigns` resource is a
different resource and is not used here.

## API and scope

- Reuse: `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}`,
  `GET /api/v1/media-campaigns/{campaignId}` for preview card data — add
  only the slimmed preview fields the card needs if the existing DTOs are
  heavier than needed for a list of many simultaneous cards in a timeline.
- New: `GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}/references` and
  the Media Campaign equivalent — returns paginated backlink pointers
  (channelId/threadRootId, messageId, snippet-free) for messages that embed
  a `reference` node pointing at that entity, scoped to the viewer's
  existing channel access.
- New: merged search endpoint (or client-side fan-out to existing Task list
  / Media Campaign list endpoints filtered by `search`) — decide in planning
  whether one new aggregate endpoint or parallel calls fits existing
  pagination/perf conventions better.
- Extend `chat_messages` richContent JSON schema/validator to allowlist the
  new `reference` node alongside existing `mention`, mirroring the
  migration approach already used for `richContent` (only add the new node
  to the constraint, never replace/weaken existing constraints or indexes).
- Extend `chat-mention-inbox`'s delivery path with a reference-notification
  variant keyed off `refType = TASK`'s assignee; same preferences API
  surface (no new preference endpoints), same actor-scoped-only access rule.

## Frontend

New `ChatReferenceNode` TipTap node beside `ChatMentionNode` in
`chatRichContent.ts`; picker UI extends `useChatRichEditor`'s existing
suggestion state machine (same `box`/`listId`/`active` pattern) keyed off
`/` instead of `@`, with a kind icon per result row but a single merged,
ranked list. Preview card component is new; quick actions reuse existing
Task/Media Campaign mutation hooks already used on their own pages — no new
mutation hooks. i18n: `chat.rich.reference.*` parallel vi/en keys. No
emoji icons — `lucide-react` per project icon rule.

## Risks / open items for planning

- Confirm whether the merged search is one new backend aggregate endpoint
  or a client-side fan-out; affects latency and whether ranking is
  server- or client-side.
- Confirm the 20-recipient cap is genuinely shared between mention and
  reference notifications in one message, or counted separately.
- Confirm Media Campaign's "approval" quick action maps to an existing
  single API call or a multi-step flow that doesn't fit an inline card.
