# UC — Content Writting View

| | |
|---|---|
| FR Code | 3.6.10 |
| Feature | Content Writting View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 5.0 (V5 — Docs/Word hybrid UI redesign + presence/multi-cursor awareness + React Native mobile port, 2026-10-26; V4 — canvas-rendering + Yjs CRDT real-time sync over WebSocket, 2026-10-01) |
| Document Status | Implemented — minimal Task entity (not full FR 3.6.1), core + real-time sync + version history + presence live on web; mobile port (RN TextInput, not canvas) live with the same sync/formatting/version-history/preview feature set; see task.md for what's still pending |

## 1. Objective

Write content the way Google Docs **actually** works (canvas-rendering, not an ordinary DOM-based rich-text editor), auto-convert fonts to the correct standard on publish, keep Content History/Version, and let multiple Creators edit the same content concurrently in real time via Operational Transformation (OT).

## 2. User Story

As a Creator,
I want to write content directly in the system,
without having to copy it through an external tool to fix the font before posting.
If a colleague has the same content open, I want to see their edits almost instantly without losing my own.

## 3. Acceptance Criteria

- **Canvas-based** editor (mirrors the real Google Docs architecture — see §4) — supports basic formatting (bold, italic, list, emoji).
- **Automatic font conversion on publish** — solves the current pain point of having to copy through Unikey/Yantext before posting to social platforms.
- **Content History/Version**: every edit is stored as an operation log entry (not an overwritten snapshot), restorable to a prior snapshot point.
- **Real-time collaborative editing**: 2+ Creators with the same content open see each other's edits almost instantly, with neither side losing data (Operational Transformation).

## 4. UI / UX

- Editor embedded in the Task Detail (Post type), with a Version History sidebar.
- **Page chrome (V5, 2026-10-26)**: the canvas sits on a white "paper" sheet (max-width 816px, matching a Docs/Word page at 96dpi) over a gray "desk" background, with a toolbar that toggles between a **Docs mode** (compact single-row icon bar) and a **Ribbon mode** (Word-style grouped icons with captions under each group) — purely visual, no change to the underlying edit operations or Yjs wiring.
- **Presence (V5, 2026-10-26)**: other Creators currently viewing/editing the document show as small colored avatar initials in the top status bar, and as a colored flag-with-name marker at their live caret position inside the editor (see [plan.md](plan.md) for the awareness-protocol design). Each peer's color is deterministic from their user ID (same color across sessions/devices).
- **Rendering architecture: canvas-based (mirrors the real Google Docs), not an ordinary DOM/contentEditable editor:**
  - Content is drawn pixel-accurately onto a `<canvas>` — no HTML tags are used to display the text. Reason: WYSIWYG fidelity for print/PDF, avoiding line-shift differences across browsers/devices/fonts.
  - A hidden `contenteditable`, pushed off-screen (e.g. `translateX(-10000px)`), captures keyboard/IME events (including Vietnamese input via Unikey/Telex) — it is never shown; it only receives input and forwards it into the canvas editor's internal state.
  - The blinking cursor is a `<div>` animated with CSS, positioned using pixel coordinates computed from the canvas text layout — not the browser's native cursor.
  - Text selection highlighting is also drawn by the canvas itself, not via the native `window.getSelection()`.
  - Virtualization: only the page(s) currently in the viewport get a canvas created/rendered; scrolling reuses existing canvases to draw the new page's content, keeping long documents light.
  - Accessibility: a parallel hidden DOM region (off-screen, `aria-live` or equivalent) holds the real text, since screen readers cannot read canvas pixels.

## 5. API Contract (implemented)

REST for the initial load, snapshot reporting, and version history/restore; STOMP WebSocket for real-time sync between Creators who have the same content open (see §7 Edge Cases).

```
GET /api/v1/workspaces/{id}/tasks/{taskId}/content
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state|null>", "operationsSinceSnapshot": ["<base64 Yjs update>", ...], "sequenceNumber" } }

WS /ws/tasks?token=<JWT>  (STOMP over spring-boot-starter-websocket; JWT via query param, not header)
Client → Server: PUBLISH /app/tasks/{taskId}/content  { "update": "<base64 Yjs update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/content: { "update", "sequenceNumber", "editedBy" }
// The server never decodes the update — it's an opaque Yjs CRDT blob (plan.md §6 direction B, not hand-written OT).

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/snapshot
Body: { "yjsState": "<base64 Yjs state>", "atSequenceNumber" }
// Client-reported: the server has no Yjs runtime to merge updates into a state itself.

Client → Server: PUBLISH /app/tasks/{taskId}/awareness  { "update": "<base64 y-protocols/awareness update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/awareness: { "update" }
// Presence/multi-cursor (added V5, 2026-10-26): same opaque-blob posture as content — the server relays without
// decoding and, unlike content, never persists anything (awareness state is "who's online + their cursor right
// now", not something a reload should restore). A silent client's state is cleared by y-protocols' own built-in
// 30s outdated-state timeout on every other client, so no server-side cleanup job is needed.

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions
→ 200 { "success": true, "data": [{ "snapshotId", "sequenceNumber", "createdAt", "editedBy", "editedByName" }] }
// newest first. editedBy/editedByName = last editor whose operation is included in the snapshot (null if unknown).

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state>", "operationsSinceSnapshot": [], "sequenceNumber" } }
// read-only; the client decodes it to text to render a diff against the previous version.

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state>", "operationsSinceSnapshot": [], "sequenceNumber" } }
// READ-ONLY on the server: returns the old state and writes nothing. A CRDT cannot rewind by merging an older state,
// so the client replaces the live Y.Text with the old content as a normal edit (delete + applyDelta); that update
// is persisted and broadcast over the WebSocket like any other, keeping the log append-only.
```

**Snapshots** are client-reported (`POST .../content/snapshot`): when the log since the last snapshot reaches 200
operations, **or** after 20 s without edits, **or** when the editor unmounts. The server ignores a report whose
`atSequenceNumber` is not newer than the latest snapshot.

**Lists** are literal text prefixes (`• `, `1. `) so the published text matches what is displayed; Enter inside an item
continues the list and Enter on an empty item leaves it. **Publish text** (`toPublishText`) NFC-normalizes Vietnamese and
renders bold/italic runs as Unicode Mathematical Sans-Serif letters; see [test.md](test.md) for the verified cases.

## 6. Error Handling

- Task is not of type `post` → 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING`.
- WebSocket handshake without a valid JWT → connection rejected with 401 (`WsJwtHandshakeInterceptor`).
- STOMP SEND `/app/tasks/{id}/content` or SUBSCRIBE `/topic/tasks/{id}/content` by a user who is not an active MANAGER/CREATOR of the task's workspace, or for an unknown task → the frame is rejected with a STOMP ERROR (`ChatInboundChannelInterceptor.authorizeTask`); nothing is persisted or delivered.
- Stale-sequence rejection (`STALE_SEQUENCE_NUMBER`) is defined as an error code but **not yet wired to any check** — there is no compaction job that prunes old operations in this implementation (`task_content_operations` only grows), so the condition it would guard against cannot currently occur.

## 7. Edge Cases

- **Two Creators editing the same content concurrently (e.g. QC + the original Creator both have edit rights) — resolved via Yjs CRDT merge, not locking or last-write-wins (implemented; plan.md §6 direction B, not hand-written OT):**

  The real Google Docs does **not** save/sync a document as a text blob that gets overwritten on every save — it uses Operational Transformation (OT): a central `transform(opA, opB)` step reconciles concurrent edits. This implementation reaches the same outcome (nobody loses an edit, no lock needed) via a different algorithm: **Yjs**, a CRDT (Conflict-free Replicated Data Type) library. Each client mutates a local `Y.Doc`; Yjs updates merge automatically and commutatively on every client and the server — no central transform step is needed, which is also why the server never has to decode what an update contains (see §5's WS contract).

  Google Docs' real transport is Long Polling (an HTTP `bind` endpoint, for historical reasons dating back to 2006). This feature uses **WebSocket** (STOMP over `spring-boot-starter-websocket`) instead — the same real-time, bidirectional effect on more modern infrastructure.

  Implementation details and the hand-written-OT vs. CRDT-library trade-off this decision was based on — see [plan.md §6 Technical Risks](plan.md#6-technical-risks).

- **Vietnamese IME through the off-screen hidden input**: typing diacritics (Unikey, Telex, VNI) through the off-screen `contenteditable` must work correctly with `compositionstart`/`compositionupdate`/`compositionend` — raw keystrokes must not be forwarded into the canvas state before composition ends, or diacritics will render incorrectly. **Implemented and browser-verified.**

- **Offline / WebSocket disconnect mid-session**: **implemented.** `useTaskContentSync` reconnects (`reconnectDelay: 3000`, with a fresh access token via `beforeConnect`). Edits typed while disconnected go into a queue that is also persisted in `localStorage` (`brandhub-content-pending:{taskId}`), so closing the tab does not lose them; the queue is flushed after reconnect (Yjs updates are idempotent, replay is safe). On every reconnect the client re-reads the content log (`GET .../content`) and merges updates broadcast while it was away.

## 8. Definition of Done

- The canvas editor renders correctly; input/cursor/selection work through the offscreen input; Vietnamese IME types diacritics correctly.
- Font auto-conversion works correctly on publish.
- Version History is stored (operation log + periodic snapshots) and restores correctly.
- Two Creators with the same content open, editing concurrently over WebSocket, converge to the same result with no data loss (correct OT transform).
- Screen readers can read the content through the hidden DOM layer that runs in parallel with the canvas.

## Out of Scope

- Comment/suggestion mode (like Google Docs "Suggesting") — not in the CSV.
- Pagination/page breaks to A4 print standards — the CSV only requires writing content for social posts, not PDF export/printing.
- Mobile: component-level RN tests and mobile E2E/device test (no `@testing-library/react-native` harness or Detox/Maestro in this project — not attempted). Image attachment, font/size/color/highlight/link controls, and a Docs/Ribbon toggle were initially deferred but completed the same day on request — see task.md item 16; mobile now has full feature parity with web except the live cursor-position marker (avatar-only presence — RN's `TextInput` has no per-character pixel coordinate API to place one).

> **Superseded (was Out of Scope until V5, 2026-10-26)**: showing avatars/colored cursors of who is typing where (multi-cursor presence UI) — now implemented on web; see §4 and §5's awareness endpoint. On mobile, presence shows as avatar initials only (no live cursor-position marker — not meaningful to render precisely against RN's TextInput, which doesn't expose per-character pixel coordinates the way canvas measurement does on web).

## BA Reference

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
