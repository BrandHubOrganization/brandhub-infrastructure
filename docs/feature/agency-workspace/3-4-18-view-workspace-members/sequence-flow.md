# Sequence Flow — View Workspace Members

> Companion to `spec.md` (FR 3.4.18). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — an active member of the Workspace (MANAGER, CREATOR, CLIENT).
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace, membership, user, and client profile records.

---

## Flow A — View the Workspace member list

1. Client → System: open `/workspaces/:id/members`.
2. System → Database: look up the Workspace by its identifier; a missing Workspace is rejected with 404 `WORKSPACE_NOT_FOUND`.
3. System → Database: read the caller's active membership row for that same Workspace; a missing row is rejected with 403 `WORKSPACE_ACCESS_DENIED`.
4. System → Database: read the Workspace's active membership rows.
5. System: collect the referenced user identifiers and load the matching user records.
6. System: collect the referenced client profile identifiers and load the matching client profiles.
7. System: map each membership to a member entry — taking the full name and email from the user record when one is linked, or the client profile display name with an empty email when the member was attached through a client profile.
8. System → Client: the member list — id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive.
9. Client: render the member table with each member's role.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| List members | Workspace does not exist | 404 | `WORKSPACE_NOT_FOUND` |
| List members | Caller is not an active member of that Workspace | 403 | `WORKSPACE_ACCESS_DENIED` |

## Notes

- The membership check is performed explicitly for the Workspace named in the request, rather than through a generic role check.
- A member attached through a client profile has no linked user record, so the display name comes from the client profile and the email is empty.
- The flow is read-only.
