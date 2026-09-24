# Sequence Flow — Create Workspace

> Companion to `spec.md` (FR 3.4.12). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly. It does not restate business rules — see `spec.md` for those.
>
> Updated: 2026-09-23.

## Actors

- **Client** — a member of the Agency, and the creator of the Workspace.
- **System** — the application service handling the request.
- **Database** — the persistent store holding Workspace, membership, Agency membership, and user records.
- **Notification service** — dispatches any transactional email triggered during creation.

---

## Flow A — Create a Workspace without member assignment

1. Client → System: open the Create Workspace form inside an Agency and fill in the name, the Agency, and any optional fields.
2. System: validate the request — `name` empty or `agencyId` missing is rejected with 400 `VALIDATION_ERROR`.
3. System → Database: read the caller's Agency membership for the target Agency; a missing membership is rejected with 403 `NOT_AGENCY_OWNER`.
4. System → Database: insert the Workspace row, with default settings and the caller recorded as its creator.
5. System → Database: insert the creator's membership row with role MANAGER and active status, in the same transaction.
6. Database → System: the created Workspace.
7. System → Client: the created Workspace summary.
8. Client: navigate into the new Workspace.

## Flow B — Create a Workspace with member assignment and MANAGER transfer

1. Client → System: fill in the form and add assignment entries, one of them naming a different user as MANAGER.
2. System: validate the request as in Flow A.
3. System → Database: read the caller's Agency membership; a missing membership is rejected with 403 `NOT_AGENCY_OWNER`.
4. System: note that another user was chosen as MANAGER, so the creator will not hold that role.
5. System → Database: insert the Workspace row.
6. System → Database: insert the creator's membership row with role CREATOR.
7. System: process each assignment entry:
   - System → Database: read the Agency membership of the entry's user; a missing membership is rejected with 403 `NOT_AGENCY_MEMBER`.
   - System → Database: check for an existing active membership for that user in the Workspace; if one exists, skip the entry without error.
   - System → Database (when the entry requests MANAGER): count the active MANAGERs in the Workspace; a count above zero is rejected with 409 `MANAGER_ALREADY_ASSIGNED`.
   - System → Database: read the user record; a missing user raises `USER_NOT_FOUND`.
   - System → Database: insert the membership row for that entry.
8. System → Client: the created Workspace summary.
9. Client: navigate into the new Workspace, whose MANAGER is the designated user.

---

## Error paths

| Step | Failure condition | Status | Error code |
|---|---|---|---|
| Create | `name` empty | 400 | `VALIDATION_ERROR` |
| Create | `agencyId` missing | 400 | `VALIDATION_ERROR` |
| Create | Caller is not a member of the target Agency | 403 | `NOT_AGENCY_OWNER` |
| Create (assignment) | An entry's user is not an Agency member | 403 | `NOT_AGENCY_MEMBER` |
| Create (assignment) | An entry requests MANAGER while the Workspace already has an active MANAGER | 409 | `MANAGER_ALREADY_ASSIGNED` |
| Create (assignment) | An entry's user does not exist in the user records | — | `USER_NOT_FOUND` |

## Notes

- The Workspace row and the creator's membership row are written in a single transaction; assignment entries are applied immediately afterwards.
- The creator is MANAGER by default and is demoted to CREATOR when the MANAGER role is handed to another user, so the Workspace always ends up with exactly one active MANAGER.
- An assignment entry for a user who is already an active member of the new Workspace is skipped without error.
