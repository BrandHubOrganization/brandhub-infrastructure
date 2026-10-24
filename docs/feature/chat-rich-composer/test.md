# Tests

Nested lists: Tab nests an eligible item, Shift+Tab lifts it. Toolbar controls
do the same and disable invalid actions. Three ordered levels show decimal/alpha/
roman; bullets show disc/circle/square, both before and after send. Five-level
limit prevents invalid depth. Verify Shift+Enter stays at current nesting,
Enter sends, undo/redo, and Tab outside lists still navigates focus. vi/en labels.

Plain old messages/requests remain unchanged. Rich message send/read/realtime/retry
preserves marks, lists and mentions. Plain text must match rich document extraction.
Reject javascript/data links, arbitrary HTML nodes, forged mention IDs, >4000 text,
>500 nodes, >12 levels, >32KB JSON; duplicate request with different formatting=409.

Browser: select text -> bold persists after send; links open safely; undo/redo;
mention typing/filter/arrow/Enter/Escape/backspace; emoji at caret; paste HTML must
not execute scripts or import unsupported nodes. IME Enter never sends; Shift+Enter
line break, Enter in lists/code sends. Failed-send retry retains JSON.
No state loss when channel is temporarily unavailable. Both thread and main composer.
List-specific regression: Shift+Enter produces 3 sibling list items without sending;
Shift+Enter on empty item exits list; Enter sends the rich list. Verify
numbered and bullet variants and their keyboard hints in vi/en, including after
moving the selection between list, code and plain paragraph.

Migration regression: existing validator={} is supported without importing fresh-
init required fields. DRY_RUN changes nothing; APPLY only types richContent and
keeps documents/indexes untouched. Repeated APPLY is idempotent. Invalid rich rows
block. Missing collection and unsupported non-empty validators block without writes.
Existing required/properties and validationLevel/Action remain unchanged.

Keyboard labels, popup focus and vi/en at 375/768/1440 in light/dark. Artifacts and
new test harnesses stay in keep-local-only. No shared DB seed/APPLY, no auto commit.

## Executed 2026-10-24

- Nested list fixture passed: Tab/Shift+Tab, indent/outdent buttons, three-level
  ordered/bullet markers in editor and sent renderer, five-level cap and send.
  Baseline composer fixture passed IME/mention/emoji/link and responsive themes.
  TypeScript and targeted lint passed. No live API messages or DB changes.

- Updated keyboard contract: browser fixture passed numbered/bullet continuation
  with Shift+Enter, empty-item exit with a second Shift+Enter, and Enter sending
  both within lists and plain paragraphs. IME/mention/emoji/soft-break regressions
  passed; TypeScript and targeted hook lint passed. No shared chat writes.

- Maven compile passed; targeted ChatChannelInterceptorTest + MongoDataSeederTest:
  36 tests passed, including rich JSON/plain compatibility, unsafe links, unknown
  nodes, mention consistency and size/node bounds. Existing tracked tests extended.
- Web TypeScript and production build passed; targeted lint run (final delivery).
- Playwright fixture: bold survives send/render, @mention inserts atomic chip with
  exact recipient ID, emoji inserts at caret, Shift+Enter newline, IME Enter does
  not send, 4001 chars disables send, unsafe link refused. No page errors or
  horizontal overflow at 375/768/1440 with both themes. vi/en labels available.
- Disposable Mongo 7: full init, DRY_RUN, repeat APPLY, plain rows unchanged,
  valid rich document accepted, string richContent rejected, init/migration parity.
- No Atlas writes. Real API send/reload, thread and failed request retry have not
  been exercised against the user's running services in this turn.
- Migration fallback regression passed on disposable Mongo 7: absent validator,
  DRY_RUN no writes, repeated APPLY, old rows/indexes unchanged, invalid rich field
  blocked, existing required fields and moderate/warn settings preserved. Missing
  collection and unsupported non-empty validators block safely.

Migration: execute the WHOLE 2026-10-24-chat-rich-content.js script with
`globalThis.BRANDHUB_CHAT_RICH_APPLY = false;` first; switch to true only after clean
preflight. Existing schema permits additive fields; migration adds explicit typing.
Restart Business before testing the new composer so richContent is not ignored by
an old server. No collection reset/backfill or PostgreSQL changes are needed.
