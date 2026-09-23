# Sequence Flow — Leave Workspace

> Companion to `spec.md` (FR 3.4.16). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — an active member of the Workspace (MANAGER, CREATOR, CLIENT) leaving their own membership.
- **System** — the application service handling the request.
- **Database** — the persistent store holding membership records.

---

## Flow A — Leave a Workspace

1. Client → System: open Workspace settings or the members screen, choose "Leave Workspace", and confirm in the dialog.
2. System: accept the request for any signed-in user, since the action can only affect the caller's own membership; the caller identity is taken from the session principal and never from the request.
3. System → Database: read the caller's active membership row for the Workspace; a missing row is rejected with 403 `WORKSPACE_ACCESS_DENIED`.
4. System: apply the last-MANAGER guard:
   - When the caller's role is not MANAGER, continue.
   - When the caller's role is MANAGER, count the Workspace's active MANAGERs; a count of one or fewer is rejected with 409 `LAST_OWNER_CANNOT_BE_REMOVED`.
5. System: mark the caller's membership inactive and record the update timestamp.
6. System → Database: write the deactivated membership.
7. System → Client: confirmation that the membership has been deactivated.
8. Client: return to the Workspace list. The caller's Agency membership is untouched, so they remain in the Agency and in their other Workspaces.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Leave | Caller has no active membership in that Workspace | 403 | `WORKSPACE_ACCESS_DENIED` |
| Leave | Caller is the only active MANAGER of the Workspace | 409 | `LAST_OWNER_CANNOT_BE_REMOVED` |

## Notes

- The last-MANAGER guard is shared with FR 3.4.20 Update Workspace Member Role and FR 3.4.21 Remove Workspace Member.
- Only the membership row of the caller is ever touched; Agency membership is never modified.
- Invoking the action a second time finds no active membership and fails with 403 `WORKSPACE_ACCESS_DENIED`.
