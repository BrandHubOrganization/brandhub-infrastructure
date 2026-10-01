# UC — Content Writting View

| | |
|---|---|
| FR Code | 3.6.10 |
| Feature | Content Writting View |
| Domain | Content & Workflow (FR 3.6) |
| Role | CREATOR |
| Version | 4.0 (V4 — implemented: canvas-rendering + Yjs CRDT real-time sync over WebSocket, 2026-10-01) |
| Document Status | Implemented — minimal Task entity (not full FR 3.6.1), core + real-time sync + version history live; see task.md for what's still pending |

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

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions
→ 200 { "success": true, "data": [{ "snapshotId", "sequenceNumber", "createdAt" }] }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore
→ 200 { "success": true, "data": { "snapshot": "<base64 Yjs state>", "operationsSinceSnapshot": [], "sequenceNumber" } }
```

## 6. Error Handling

- Task is not of type `post` → 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING`.
- WebSocket handshake without a valid JWT → connection rejected with 401 (`WsJwtHandshakeInterceptor`).
- Stale-sequence rejection (`STALE_SEQUENCE_NUMBER`) is defined as an error code but **not yet wired to any check** — there is no compaction job that prunes old operations in this implementation (`task_content_operations` only grows), so the condition it would guard against cannot currently occur.

## 7. Edge Cases

- **Two Creators editing the same content concurrently (e.g. QC + the original Creator both have edit rights) — resolved via Yjs CRDT merge, not locking or last-write-wins (implemented; plan.md §6 direction B, not hand-written OT):**

  The real Google Docs does **not** save/sync a document as a text blob that gets overwritten on every save — it uses Operational Transformation (OT): a central `transform(opA, opB)` step reconciles concurrent edits. This implementation reaches the same outcome (nobody loses an edit, no lock needed) via a different algorithm: **Yjs**, a CRDT (Conflict-free Replicated Data Type) library. Each client mutates a local `Y.Doc`; Yjs updates merge automatically and commutatively on every client and the server — no central transform step is needed, which is also why the server never has to decode what an update contains (see §5's WS contract).

  Google Docs' real transport is Long Polling (an HTTP `bind` endpoint, for historical reasons dating back to 2006). This feature uses **WebSocket** (STOMP over `spring-boot-starter-websocket`) instead — the same real-time, bidirectional effect on more modern infrastructure.

  Implementation details and the hand-written-OT vs. CRDT-library trade-off this decision was based on — see [plan.md §6 Technical Risks](plan.md#6-technical-risks).

- **Vietnamese IME through the off-screen hidden input**: typing diacritics (Unikey, Telex, VNI) through the off-screen `contenteditable` must work correctly with `compositionstart`/`compositionupdate`/`compositionend` — raw keystrokes must not be forwarded into the canvas state before composition ends, or diacritics will render incorrectly. **Implemented and browser-verified.**

- **Offline / WebSocket disconnect mid-session**: **not implemented in this pass** (see task.md) — edits made while disconnected are not queued; `useTaskContentSync` simply reconnects (`reconnectDelay: 3000`) and resumes subscribing. A disconnected client's local Yjs edits are not lost in memory, but are not persisted/broadcast until the connection is back.

## 8. Definition of Done

- The canvas editor renders correctly; input/cursor/selection work through the offscreen input; Vietnamese IME types diacritics correctly.
- Font auto-conversion works correctly on publish.
- Version History is stored (operation log + periodic snapshots) and restores correctly.
- Two Creators with the same content open, editing concurrently over WebSocket, converge to the same result with no data loss (correct OT transform).
- Screen readers can read the content through the hidden DOM layer that runs in parallel with the canvas.

## Out of Scope

- Showing avatars/colored cursors of who is typing where (multi-cursor presence UI) — not confirmed in the CSV; only convergent content via OT is required, not a UI showing "who is typing where."
- Comment/suggestion mode (like Google Docs "Suggesting") — not in the CSV.
- Pagination/page breaks to A4 print standards — the CSV only requires writing content for social posts, not PDF export/printing.

## BA Reference

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
