# Sequence Flow — Content Writing View

> Companion to `spec.md` (FR 3.6.10). **Implemented** — canvas-rendering editor with Yjs CRDT real-time sync over STOMP WebSocket (plan.md §6 direction B, not hand-written OT). Minimal `Task` entity only (not the full FR 3.6.1 scope).
>
> Updated 2026-10-01.

## Actors

- **Creator A, Creator B** — two users editing the same Task's content concurrently, each via `CanvasTextEditor` + `useTaskContentSync` in `brandhub-web-dashboard`.
- **TaskController** — `GET /api/v1/workspaces/{id}/tasks/{taskId}/content`, `@RequireRole({MANAGER, CREATOR})`.
- **WsJwtHandshakeInterceptor** — validates the JWT (query param `?token=`) at the WebSocket upgrade for `/ws/tasks`, reusing `JwtUtil.parseToken`.
- **TaskContentWebSocketController** — `@MessageMapping("/tasks/{taskId}/content")`, persists and broadcasts Yjs updates.
- **TaskContentServiceImpl** — `getContent`, `appendOperation`, `reportSnapshot`, `listVersions`, `restoreVersion`.
- **Database** — PostgreSQL `task_content_operations` (append-only, opaque base64 Yjs updates) and `task_content_snapshots`.

## Normal Flow — opening content

1. Creator A → Client A: opens `/workspaces/:id/content-writing`. If the URL has no `?taskId`, the page first creates a minimal draft Task via `POST /tasks` (dev-convenience — there is no Task list UI yet).
2. Client A → TaskController: `GET /tasks/{taskId}/content`.
3. TaskController → TaskContentServiceImpl: `findPostTaskOrThrow` — confirms the Task exists, belongs to the Workspace, and is type `POST`; `@RequireRole` confirms the caller is MANAGER or CREATOR.
4. TaskContentServiceImpl: loads the latest `TaskContentSnapshot` (if any) and every `TaskContentOperation` committed after it.
5. TaskController → Client A: `{ snapshot, operationsSinceSnapshot[], sequenceNumber }`.
6. Client A (`useTaskContentSync`): `Y.applyUpdate(yDoc, snapshot)` then replays each tail operation — reconstructs the shared `Y.Doc`.
7. Client A: opens a STOMP WebSocket to `/ws/tasks?token=<JWT>`.
8. `WsJwtHandshakeInterceptor`: validates the token; on success, `PrincipalHandshakeHandler` (in `WebSocketConfig`) binds the resolved `AuthenticatedUser` to the STOMP session.
9. Client A: subscribes to `/topic/tasks/{taskId}/content`.
10. (In parallel) Creator B repeats steps 1-9 for the same Task.

## Normal Flow — real-time editing (CRDT merge, not OT transform)

11. Creator A types. The offscreen `contenteditable` captures the keystroke (composition-aware for Vietnamese IME).
12. `CanvasTextEditor`: calls `yText.insert()`/`delete()` at the local caret — a local Yjs mutation. The canvas re-renders immediately (optimistic, no wait for the server).
13. `useTaskContentSync`: the `Y.Doc` `update` event fires (origin not `"remote"`) → publishes to `/app/tasks/{taskId}/content` with `{ update: base64 }`.
14. `TaskContentWebSocketController` → `TaskContentServiceImpl.appendOperation`: assigns the next `sequenceNumber` (`count(taskId) + 1`).
15. Persists the opaque base64 Yjs update into `task_content_operations` — the server never decodes it; Yjs itself is the CRDT/operation log.
16. Broadcasts `{ update, sequenceNumber, editedBy }` to every subscriber of `/topic/tasks/{taskId}/content`, including Client A itself (confirms the update's official `sequenceNumber`).
17. Client B receives the broadcast, applies `Y.applyUpdate(yDoc, update, "remote")`. Yjs merges the concurrent edit automatically — no central transform step. The canvas re-renders the affected region.
18. Symmetric: when Creator B edits, steps 11-17 run identically with A and B swapped. Both `Y.Doc`s converge to the same state regardless of order (the CRDT convergence guarantee).

## Normal Flow — client-reported snapshot

19. Once a client's `operationsSinceSnapshot` count crosses 200 (`useTaskContentSync`'s `SNAPSHOT_THRESHOLD`), it posts `POST /tasks/{taskId}/content/snapshot` with `{ yjsState: base64(Y.encodeStateAsUpdate(yDoc)), atSequenceNumber }`.
20. `TaskContentServiceImpl.reportSnapshot`: if a snapshot already exists at or beyond `atSequenceNumber` (e.g. another client reported first), skips — first reporter wins.
21. Otherwise inserts a new `task_content_snapshots` row.
22. `TaskContentSnapshotJob` (server, `@Scheduled` every 5 minutes) cannot capture a snapshot itself — the server never decodes Yjs updates, so it has no merged state to save. It only logs which Tasks have crossed the threshold, as a signal that a connected client should report one soon.

## Normal Flow — version history / restore

23. `VersionHistorySidebar` → `GET /tasks/{taskId}/content/versions` → lists `{ snapshotId, sequenceNumber, createdAt }`.
24. On Restore click → `POST /tasks/{taskId}/content/versions/{snapshotId}/restore`.
25. `TaskContentServiceImpl.restoreVersion`: appends a **new** snapshot carrying the old `yjsState` at a fresh `sequenceNumber` — operations are append-only, so restoring doesn't rewind history, it adds a checkpoint that returns the document to that prior state.
26. Returns the restored content; the client reloads its `Y.Doc` from it.

## Error Paths

| Step | Failure condition | HTTP / WS | Error code |
|---|---|---|---|
| Open content | Task does not exist, or belongs to a different Workspace | 404 | `TASK_NOT_FOUND` |
| Open content | Task is not of type `POST` | 400 | `INVALID_TASK_TYPE_FOR_CONTENT_WRITING` |
| Open content | Caller is not MANAGER or CREATOR | 403 | `FORBIDDEN` (`@RequireRole`) |
| WS handshake | Token missing or invalid | handshake rejected | 401 |
| Restore | `snapshotId` not found or belongs to a different Task | 404 | `TASK_NOT_FOUND` |

## Notes

- This is a minimal `Task` entity (FR 3.6.10 scope only) — not the full FR 3.6.1 Identify Task Detail (no assignee, due date, comments).
- `plan.md` originally sketched hand-defined `opType`/`position`/`payload` operations (direction A); the actual implementation stores raw Yjs updates instead (direction B) — Yjs's CRDT algorithm replaces the need for a hand-written `transform()` function. See `plan.md` §6 for the trade-off.
- Out of scope in this pass (see `task.md`): accessibility shadow-DOM layer beyond the existing `aria-live` mirror, virtualization for multi-page documents, offline IndexedDB queue, font auto-conversion on publish.
