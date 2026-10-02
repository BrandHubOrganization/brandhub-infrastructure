# Plan — Content Writing View (FR 3.6.10)

> Link: [spec.md](spec.md) — Document Status: **Implemented**. Direction B (Yjs CRDT) from §6 was the one actually built — see §2/§3/§4 below for what the shipped API/data model/flow look like, which differs slightly from the original "hand-written OT" sketch (§6 still documents that trade-off and why B was chosen).
>
> V4 (2026-10-01): canvas-rendering + Yjs CRDT real-time sync over STOMP WebSocket, mirroring the real Google Docs technique's effect (not its OT algorithm — see §6). See [spec.md §4](spec.md#4-ui--ux) and [§7](spec.md#7-edge-cases).

## 1. Technical Scope (implemented)

| Item | Content |
|---|---|
| Repo | `brandhub-business-service` (BE), `brandhub-web-dashboard` (FE) |
| BE | `Task` entity (minimal — see note below), `TaskContentOperation` (append-only, opaque base64 Yjs update log), `TaskContentSnapshot` (client-reported Yjs state checkpoints), `spring-boot-starter-websocket`, `WebSocketConfig` (STOMP endpoint `/ws/tasks`, broker `/topic`), `WsJwtHandshakeInterceptor` (JWT via query param), `TaskContentWebSocketController` (`@MessageMapping`), `TaskContentSnapshotJob` (`@Scheduled`, logs tasks due for a snapshot — can't capture one itself, see §6) |
| FE | `CanvasTextEditor` (hand-written canvas rendering engine, content now backed by a Yjs `Y.Text` instead of plain React state), `useTaskContentSync` hook (REST initial load + STOMP client via `@stomp/stompjs`, client-reported snapshotting), `VersionHistorySidebar` (list/restore), `yjs` + `@stomp/stompjs` added to `package.json` |
| **Minimal `Task`, not full FR 3.6.1** | `id`, `workspaceId`, `type` (`TaskType` enum, only `POST` defined), `title`, `createdBy`, timestamps. No assignee, due date, comments, etc. — those belong to FR 3.6.1 Identify Task Detail, out of this scope. |
| Not implemented this pass | Accessibility shadow-DOM beyond the existing `aria-live` text mirror; virtualization for multi-page documents; offline IndexedDB queue; font auto-conversion on publish; real compaction (old operations are never pruned, only snapshotted) |

## 2. Data Model (implemented)

- `Task` (table `tasks`) — see minimal scope above. Migration: `2026-10-01-create-tasks-table.sql`.
- `TaskContentOperation` (table `task_content_operations`) — append-only: `id`, `taskId`, `sequenceNumber` (bigint, `count(taskId) + 1` per insert), `yjsUpdate` (TEXT, base64-encoded opaque Yjs binary update — **the server never decodes it**, Yjs itself is the CRDT/operation log), `editedBy`, `createdAt`.
- `TaskContentSnapshot` (table `task_content_snapshots`) — `id`, `taskId`, `sequenceNumber`, `yjsState` (TEXT, base64-encoded `Y.encodeStateAsUpdate(yDoc)` — **client-reported**, not server-captured; see §6), `createdAt`.
- Migration: `2026-10-01-create-task-content-tables.sql`.
- This differs from the original sketch (hand-defined `opType`/`position`/`payload` columns) — Yjs updates are opaque binary, so there's nothing to decompose into those fields. See §6 for why.

## 3. API Contract (implemented)

```
GET /api/v1/workspaces/{id}/tasks/{taskId}/content
→ 200 { "success": true, "data": { "snapshot": "<base64|null>", "operationsSinceSnapshot": ["<base64>", ...], "sequenceNumber" } }

WS /ws/tasks?token=<JWT>  (STOMP; JWT via query param — WS clients can't always set an Authorization header on the upgrade request)
Client → Server: PUBLISH /app/tasks/{taskId}/content { "update": "<base64 Yjs update>" }
Server → SUBSCRIBE /topic/tasks/{taskId}/content: { "update", "sequenceNumber", "editedBy" }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/snapshot
Body: { "yjsState": "<base64>", "atSequenceNumber" }
// Client-reported — see §6 "server never decodes Yjs updates".

GET /api/v1/workspaces/{id}/tasks/{taskId}/content/versions
→ 200 { "success": true, "data": [{ "snapshotId", "sequenceNumber", "createdAt" }] }

POST /api/v1/workspaces/{id}/tasks/{taskId}/content/versions/{snapshotId}/restore
→ 200 { "success": true, "data": { "snapshot": "<base64>", "operationsSinceSnapshot": [], "sequenceNumber" } }
```

## 4. Processing Flow (implemented)

**Opening content:**
1. `findPostTaskOrThrow(workspaceId, taskId)` — 404 `TASK_NOT_FOUND` if missing or belongs to a different workspace; 400 `INVALID_TASK_TYPE_FOR_CONTENT_WRITING` if not type `POST`.
2. `@RequireRole({MANAGER, CREATOR})` on `TaskController` — 403 otherwise.
3. REST returns the latest `TaskContentSnapshot` (if any) + every `TaskContentOperation` committed after it.
4. The client (`useTaskContentSync`) applies the snapshot then replays the tail via `Y.applyUpdate`, reconstructing the `Y.Doc`. It then opens a STOMP WS connection to `/ws/tasks?token=<JWT>` and subscribes to `/topic/tasks/{taskId}/content`.

**Real-time editing (Yjs CRDT merge — no central transform step):**
5. The Creator types → the off-screen `contenteditable` captures the event → `CanvasTextEditor` calls `yText.insert()/delete()` at the local caret — a local Yjs mutation, rendered optimistically on the canvas right away.
6. The `Y.Doc`'s `update` event fires locally → `useTaskContentSync` publishes `{ update: base64 }` over STOMP.
7. `TaskContentWebSocketController` → `TaskContentServiceImpl.appendOperation`: assigns the next `sequenceNumber`, persists the opaque update, and broadcasts it to every subscriber of this Task's topic — including the sender (confirms its official `sequenceNumber`).
8. Every receiving client calls `Y.applyUpdate(yDoc, update, "remote")` — Yjs merges the update into its local CRDT state automatically; no server-side transform step exists because none is needed. The canvas re-renders the affected region.

**Publish:**
9. Font auto-conversion on publish is **not implemented** in this pass (see task.md).

**Client-reported snapshot (not a background job — see §6):**
10. Once a client's `operationsSinceSnapshot` count crosses 200, it posts `POST .../content/snapshot` with its current merged Yjs state. `TaskContentServiceImpl.reportSnapshot` skips if a snapshot already exists at/after that sequence (first reporter wins), otherwise inserts a new row.
11. `TaskContentSnapshotJob` runs every 5 minutes server-side but **cannot capture a snapshot itself** (see §6) — it only logs which Tasks have crossed the threshold.

## 5. Dependencies

| Direction | Description |
|---|---|
| Was blocked by | The Task entity did not exist — resolved by building the minimal version in §1, not the full FR 3.6.1 scope. |
| Blocks | None |

## 6. Technical Risks (as realized)

- **Hand-writing OT vs. integrating Yjs (CRDT) — decided: direction B (Yjs) was implemented.**

  | Direction | Description | Chosen? |
  |---|---|---|
  | A. Hand-write OT (as the real Google Docs does) | `transform(opA, opB)` by hand for every operation-type pair | Not chosen — very high risk of document divergence bugs for a team not specialized in real-time editing |
  | **B. Integrate Yjs (CRDT)** | Shared `Y.Doc`/`Y.Text`, updates merge automatically and commutatively on every peer | **Chosen and implemented** |

  Consequence: the server (`TaskContentServiceImpl`) never decodes a Yjs update — it just orders (`sequenceNumber`) and relays opaque blobs. This is why snapshotting had to move from a server-side background job (as originally sketched) to **client-reported** snapshots: there is no Yjs runtime on the Java side to merge updates into a document state. `TaskContentSnapshotJob` only flags which Tasks are overdue; a connected client does the actual capture via `POST .../content/snapshot`.

- **Canvas text layout/measurement** — implemented and browser-verified (`CanvasRenderingContext2D.measureText()`-based line wrapping, click-to-position).

- **Vietnamese IME through the hidden input** — implemented and browser-verified with a synthesized Vietnamese composition sequence (`compositionstart/update/end`).

- **WebSocket infrastructure** — implemented: `spring-boot-starter-websocket`, STOMP broker at `/topic`, `WsJwtHandshakeInterceptor` validates the JWT (query param) at handshake and binds the resolved user as the STOMP session's `Principal` via a custom `DefaultHandshakeHandler`. `SecurityConfig` permits `/ws/tasks/**` at the HTTP filter-chain level since auth happens at the handshake, not via `JwtAuthenticationFilter` (which only reads the `Authorization` header, absent on a WS upgrade request).

- **Offline conflict on reconnect** — **not implemented**. `useTaskContentSync` just reconnects (`reconnectDelay: 3000`); there is no IndexedDB queue, so edits made fully offline (no WS at all, e.g. airplane mode) are not persisted if the tab closes before reconnecting. In-memory Yjs state survives a transient disconnect while the tab stays open.

- **Snapshot/compaction job** — implemented as a log-only warning (`TaskContentSnapshotJob`), not an actual compactor: old `task_content_operations` rows are never deleted/archived, so the log grows unbounded. This was an explicit simplification (lower risk) over building real compaction.

- **Font auto-conversion on publish** — **not implemented** (no publish flow exists yet to hook into; see task.md).
