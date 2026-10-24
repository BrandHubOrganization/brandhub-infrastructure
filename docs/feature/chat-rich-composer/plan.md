# Plan

1. Add optional richContent to chat send/model/response, strict bounded validation
   and idempotency comparison. Leave plain-text requests compatible.
2. Extend Mongo init with optional richContent. Existing validators allow additive
   properties; provide a metadata-only DRY_RUN-first migration for explicit typing.
   Support an existing collection with no validator by adding only richContent
   typing. Preserve an existing direct JSON schema and its validation settings;
   block unsupported non-empty validator shapes for review. No live DB APPLY.
3. Use the already installed Tiptap editor in a chat-only component, with atomic
   mention node, inline suggestions and emoji picker. Reuse thread/general composer.
4. Safe React document renderer (no raw HTML), retry and realtime schema retain JSON.
5. Parallel src/i18n/locales/{vi,en}/chat.json updates; build/security and browser
   fixture tests kept under ignored keep-local-only. Do not commit automatically.
6. Derive keyboard hint from editor selection (list/code/plain), expose it as the
   textbox description, and regression-test Enter/Shift+Enter list behavior.
   Enter sends; Shift+Enter uses splitListItem then liftListItem for empty items,
   newlineInCode for code blocks, and the existing soft break elsewhere.
7. Reuse Tiptap sink/lift commands behind shared bounded list actions. Add labelled
   toolbar controls and list-only Tab handling; scoped CSS styles editor/rendered
   nested markers consistently. No DB/API changes: nested list JSON is supported.
