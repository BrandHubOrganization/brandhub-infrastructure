# Sequence Flow — Add Workspace Member

> Companion to `spec.md` (FR 3.4.19). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — the MANAGER of the Workspace, adding the member.
- **System** — the application service handling the request.
- **Database** — the persistent store holding invitation, membership, Agency membership, and user records.
- **Notification service** — sends the invitation email.

---

## Flow A — Invite by email

1. Client → System: on `/workspaces/:id/members`, choose "Add Member", open the "Invite by email" tab, and fill in the email, the role, and an optional note.
2. System: check the caller's role in the Workspace before handling the request — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System: validate the request — a missing or malformed email, or a missing role, is rejected with 400 `VALIDATION_ERROR`.
4. System: normalise the email address.
5. System → Database: check whether the email already belongs to an active member of the Workspace; if so, reject with 409 `ALREADY_IN_WORKSPACE`.
6. System → Database: check whether a pending, unexpired invitation already exists for that email in the Workspace; if so, reject with 409 `INVITATION_ALREADY_PENDING`.
7. System → Database (when the role is MANAGER): count the Workspace's active MANAGERs; a count above zero is rejected with 409 `MANAGER_ALREADY_ASSIGNED`.
8. System → Database: insert the invitation with a pending status, a random token, and an expiry.
9. System → Notification service: send the invitation email carrying the Workspace name, the token, and the note.
10. System → Client: confirmation that the invitation has been sent — no invitation details are returned.

### Sub-flow — Accept the invitation

1. Invitee follows the email link; Client → System: submit the invitation token.
2. System: validate the token, its status, its expiry, and that it matches the invitee; when the invitation carries the MANAGER role and the Workspace already has an active MANAGER, reject with 409 `MANAGER_ALREADY_ASSIGNED`; when the email is already an active member, reject with 409 `ALREADY_IN_WORKSPACE`.
3. System → Database: insert the membership row with the invited role and mark the invitation accepted.
4. System → Client: the created member entry.

## Flow B — Assign directly

1. Client → System: open the "Assign from Agency" tab, pick one or more existing Agency members, and choose a role for each.
2. System: check the caller's role — a caller who is not the Workspace MANAGER is rejected with 403 `FORBIDDEN`.
3. System: validate the request — an empty member list is rejected with 400 `VALIDATION_ERROR`.
4. System: for each entry:
   - System → Database: check the entry's user is an Agency member; if not, reject with 403 `NOT_AGENCY_MEMBER`.
   - System → Database: check whether the user already has an active membership in the Workspace; if so, add the identifier to the skipped list and move on without error.
   - System → Database (when the entry requests MANAGER): count the Workspace's active MANAGERs; a count above zero is rejected with 409 `MANAGER_ALREADY_ASSIGNED`.
   - System → Database: read the user record; a missing user raises `USER_NOT_FOUND`.
   - System → Database: insert the membership row as active immediately, and add it to the added list.
5. System → Client: the members added together with the identifiers that were skipped because those users were already active members.
6. Client: refresh the member table with the members added and show a notice for the skipped users.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Invite / Assign | Caller is not the MANAGER of the Workspace | 403 | `FORBIDDEN` |
| Invite | Email already belongs to an active member | 409 | `ALREADY_IN_WORKSPACE` |
| Invite | A pending invitation already exists for the email | 409 | `INVITATION_ALREADY_PENDING` |
| Invite / Assign | MANAGER role requested while the Workspace already has an active MANAGER | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Assign | Entry's user is not an Agency member | 403 | `NOT_AGENCY_MEMBER` |
| Assign | Entry's user does not exist | — | `USER_NOT_FOUND` |
| Invite | Email missing or malformed, or role missing | 400 | `VALIDATION_ERROR` |
| Assign | Member list empty | 400 | `VALIDATION_ERROR` |

## Notes

- The invitation path does not create a membership — the invitee must accept before becoming a member; the assignment path creates active memberships immediately.
- Both paths enforce the single-MANAGER rule, so a Workspace never has more than one active MANAGER.
- Users who are already active members are reported in the skipped list rather than silently ignored; the rest of the batch is still processed.
