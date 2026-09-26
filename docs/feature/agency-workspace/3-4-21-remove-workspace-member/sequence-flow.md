# Sequence Flow — Remove Workspace Member

> Companion to `spec.md` (FR 3.4.21). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — the MANAGER of the Workspace, removing the member.
- **System** — the application service handling the request.
- **Database** — the persistent store holding membership records.

---

## Flow A — Remove a member from the Workspace

1. Client → System: on `/workspaces/:id/members`, choose Remove for a member and confirm in the dialog.
2. System: check the caller's role in the Workspace before handling the request — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System → Database: look up the member; a member that does not exist, is not active, or belongs to another Workspace is rejected with 404 `NOT_FOUND`.
4. System: apply the last-MANAGER guard:
   - When the member's role is not MANAGER, continue.
   - When the member's role is MANAGER, count the Workspace's active MANAGERs; a count of one or fewer is rejected with 409 `LAST_MANAGER_CANNOT_BE_REMOVED`.
5. System: mark the membership inactive and record the update timestamp.
6. System → Database: write the deactivated membership.
7. System → Client: confirmation that the membership has been deactivated.
8. Client: refresh the member table; the member disappears from the active list. The member's Agency membership is untouched, so they remain in the Agency and in any other Workspace they take part in.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Remove | Caller is not the MANAGER of the Workspace | 403 | `FORBIDDEN` |
| Remove | Member does not exist, is not active, or belongs to another Workspace | 404 | `NOT_FOUND` |
| Remove | Member is the only active MANAGER of the Workspace | 409 | `LAST_MANAGER_CANNOT_BE_REMOVED` |

## Notes

- The last-MANAGER guard (`assertNotLastManager` in `WorkspaceServiceImpl`) is shared with FR 3.4.16 Leave Workspace (`leaveWorkspace`) and FR 3.4.20 Update Workspace Member Role (`updateMemberRole`). `ErrorCode.java` also defines an unused `LAST_OWNER_CANNOT_BE_REMOVED` (409) that no code path throws.
- Removal is a soft delete; the membership row is retained with an inactive flag.
- The member's Agency membership is never touched.
