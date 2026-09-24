# Sequence Flow — Update Workspace Member Role

> Companion to `spec.md` (FR 3.4.20). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — the MANAGER of the Workspace, changing the role.
- **System** — the application service handling the request.
- **Database** — the persistent store holding membership and user records.

---

## Flow A — Change a member's role (no MANAGER involvement)

1. Client → System: on `/workspaces/:id/members`, choose a new role for a member in the role selector — for example CREATOR to CLIENT.
2. System: check the caller's role in the Workspace before handling the request — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System → Database: look up the member; a member that does not exist, is not active, or belongs to another Workspace is rejected with 404 `NOT_FOUND`.
4. System: apply the guards — the last-MANAGER guard does not trigger because the current role is not MANAGER, and the duplicate-MANAGER guard does not trigger because the new role is not MANAGER.
5. System: store the new role on the membership and record the update timestamp.
6. System → Database: write the updated membership and read the member's user record to build the response.
7. System → Client: the updated member entry carrying the new role.
8. Client: refresh the role shown for that member.

## Flow B — Demote the only MANAGER (blocked)

1. Client → System: change the role of the only MANAGER to CREATOR.
2. System: the caller holds the MANAGER role, so the role check passes.
3. System → Database: look up the member — it exists and is active.
4. System: the current role is MANAGER and the new role is not MANAGER, so the last-MANAGER guard runs — it counts the Workspace's active MANAGERs and blocks the change when the count is one or fewer.
5. System → Client: the change is rejected with 409 `LAST_OWNER_CANNOT_BE_REMOVED`; no update is applied.
6. Client: show the error and ask the MANAGER to hand the role over to someone else first.

## Flow C — Promote to MANAGER while another MANAGER exists (blocked)

1. Client → System: change a member who is currently CREATOR to MANAGER, while the Workspace already has another active MANAGER.
2. System → Database: look up the member — it exists, is active, and currently holds CREATOR.
3. System: the current role is not MANAGER, so the last-MANAGER guard does not run.
4. System: the new role is MANAGER and the current role is not, so the duplicate-MANAGER guard runs — it counts the Workspace's active MANAGERs and blocks the change when the count is above zero.
5. System → Client: the change is rejected with 409 `MANAGER_ALREADY_ASSIGNED`; no update is applied.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Update role | Caller is not the MANAGER of the Workspace | 403 | `FORBIDDEN` |
| Update role | Member does not exist, is not active, or belongs to another Workspace | 404 | `NOT_FOUND` |
| Update role | Member is the only MANAGER and the new role is not MANAGER | 409 | `LAST_OWNER_CANNOT_BE_REMOVED` |
| Update role | New role is MANAGER while the Workspace already has another active MANAGER | 409 | `MANAGER_ALREADY_ASSIGNED` |

## Notes

- The last-MANAGER guard is shared with FR 3.4.16 Leave Workspace and FR 3.4.21 Remove Workspace Member, and the MANAGER count is shared with the invite and assign paths of FR 3.4.19 — so every path keeps the Workspace at exactly one active MANAGER.
- There is no exception for a MANAGER acting on their own membership; the same guards apply.
- A role change affects only the current Workspace.
