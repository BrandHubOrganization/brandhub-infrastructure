# Rich chat composer

Scope confirmed 2026-10-24: basic formatting, links, lists, emoji and inline
@mentions. No uploads, scheduling, audio/video messages. Existing permissions,
thread/context, rate limits and retry identity remain unchanged.

Scheduling is added separately by `../chat-scheduled-messages/spec.md` (2026-10-26),
including DM, channel and thread replies; the original composer scope above is historical.

WYSIWYG editor supports bold/italic/underline/strike, inline code, code block,
blockquote, bullet/numbered lists and HTTP(S) links. Enter sends in every block;
Shift+Enter inserts a line break. IME and mention selection must never send.
In a list, Shift+Enter splits to the next item; on an empty item it exits the list
to a normal paragraph. Shift+Enter in code inserts a code line. Keyboard guidance
must reflect these list/code contexts.
Per the 2026-10-27 UI request, keyboard guidance is screen-reader-only in every
layout; it must not occupy space in the composer footer, including thread panels.
Lists support nesting with Tab/Shift+Tab and indent/outdent toolbar controls.
Outside lists, Tab keeps normal focus navigation. Invalid indent actions are
disabled; nesting is bounded to five levels to preserve the JSON depth limit.
Composer and sent messages share depth-based markers (1/a/i and disc/circle/square).
Emoji are message content, not structural UI icons. Mentions are atomic chips.

Keep `content` plain text (max 4000) for existing clients/search/notifications.
Optional `richContent` is an allowlisted JSON document, not arbitrary HTML. Plain
messages without richContent remain unchanged. Reject unsafe links, unknown nodes,
oversized/deep documents and inconsistent plain text/mention recipients. No backfill.
If chat_messages has no validator, migration installs only the optional richContent
constraint, not the full fresh-init required fields. Existing constraints and index
definitions must never be replaced or weakened. Missing collection still blocks.

Toolbar/picker labels use parallel vi/en `chat.rich.*` keys and existing composer
keys. Semantic theme tokens, keyboard accessible controls and 375/768/1440 layouts.
Preserve local changes already present in chat UI; do not modify publish/editor.
