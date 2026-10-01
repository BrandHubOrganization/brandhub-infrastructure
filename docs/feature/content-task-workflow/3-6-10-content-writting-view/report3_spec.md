**3.6.10 Content Writing View**

**Function Trigger**

Proposed — not yet implemented. The intended trigger is a Creator opening the Content editor inside a Task Detail of type Post. No Task Detail screen exists in the current system.

**Function Description**

- **Actors / Roles**: Creator. Proposed — not yet implemented.
- **Purpose**: Let Creators write post content directly in the system using a canvas-based editor that mirrors Google Docs' real rendering technique, with automatic font conversion on publish, a version history built from an operation log, and real-time collaborative editing between multiple Creators (Operational Transformation over WebSocket).
- **Interface**: Canvas-rendered content editor embedded in the Task Detail page, with a Version History sidebar — proposed; not yet implemented.
- **Data Processing**: The system would store every edit as a small operation (insert/delete/format at a position) in an append-only log, periodically compacted into snapshots. Concurrent edits from multiple Creators are reconciled server-side (OT transform, or CRDT merge if the Yjs direction in `plan.md` §6 is chosen) and broadcast in real time over WebSocket. None of this exists today — there is no Task entity to attach the editor to, and no WebSocket infrastructure in `brandhub-business-service`.

**Screen Layout**

Figure — Content Writing View:

- Canvas-rendered editor (not DOM/contentEditable) embedded in the Task Detail page — text, cursor, and selection are all drawn pixel-accurately on `<canvas>`.
- A hidden offscreen input captures keystrokes (IME-aware for Vietnamese input methods); a CSS-animated div renders the blinking cursor at the canvas-computed position.
- Version History sidebar — list of past snapshots with editor and timestamp, each restorable.
- Proposed — not yet implemented; the layout is indicative only.

**Function Details**
- **Data Specifications**
    - **Input required**: the Task identifier (taskId); for each edit, an operation (`opType`, `position`, `payload`, `baseSequenceNumber`).
    - **Input optional**: none.
    - **System data**: the Task record (type must be `post`), the caller's edit rights on that Task, the operation log and periodic snapshots for that Task's content. No existing table backs any of this yet.
    - **Output**: proposed — on open, the latest snapshot plus tail operations; on edit, the transformed operation broadcast to every connected client; on restore, the content at the chosen snapshot. Not yet implemented.

- **Business Rules**
    - Only a Task of type `post` accepts content writing — otherwise 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING`.
    - Only the assigned Creator or a Manager of the Workspace may edit the content — otherwise 403 FORBIDDEN (approximated, mirrors the general Task-edit access rule since no Content-Writing-specific BR exists yet).
    - Every edit is an append-only operation; no version is ever overwritten in place.
    - Concurrent edits from different Creators are reconciled through Operational Transformation (or CRDT merge) rather than locking — both Creators' edits are preserved and the documents converge to the same final state.
    - Font/encoding is auto-converted to the platform-correct standard at publish time, removing the need to copy through an external tool (Unikey/Yantext) beforehand.

- **Validation**
    - Task does not exist → Display: generic not-found toast (no MSG code assigned yet).
    - Task is not of type `post` → Display: generic validation toast (no MSG code assigned yet).
    - Caller lacks edit rights on the Task → Display: generic forbidden toast (no MSG code assigned yet); WebSocket handshake is rejected outright for the same reason.
    - Client's `baseSequenceNumber` is older than the oldest retained operation (server already compacted) → client is required to reload the latest snapshot before resubmitting.

**Functionalities**
- **Normal Flow**
    1. A Creator opens the Content editor inside a Task Detail. (Proposed — not yet implemented.)
    2. The client fetches the latest snapshot and tail operations, renders the canvas, and opens a WebSocket connection.
    3. As the Creator types, the client creates local operations, renders them optimistically, and streams them to the system over WebSocket.
    4. The system transforms each incoming operation against any operations committed since the client's last known state, persists it, and broadcasts the transformed operation to every connected client (including other Creators editing the same content).
    5. Each connected client applies incoming operations to its local state and re-renders the affected canvas region, so all Creators converge to the same document.

- **Abnormal Cases**
    - 2.a1: Task does not exist → 404 TASK_NOT_FOUND. 2.a2: The caller returns to the Task list.
    - 2.b1: Task is not of type `post` → 400 INVALID_TASK_TYPE_FOR_CONTENT_WRITING. 2.b2: The caller is told Content Writing only applies to Post tasks.
    - 2.c1: Caller is not the assigned Creator or a Manager → 403 FORBIDDEN, WebSocket handshake rejected. 2.c2: The caller returns to the Task list.
    - 3.a1: Client loses WebSocket connectivity mid-edit → operations are queued locally (IndexedDB) and resent on reconnect, in order. 3.a2: If the server has since compacted past the client's last known sequence number, the client reloads the latest snapshot before resubmitting queued operations.
    - 4.a1: Two Creators edit at nearly the same position at the same time → both operations are transformed against each other server-side; neither edit is lost, and both clients converge to the same result (no defined "winner" needed, unlike last-write-wins).

**Post-Conditions**

- New operations would be appended to the Task's content log, and periodically compacted into a snapshot. (Proposed — not yet implemented.)
