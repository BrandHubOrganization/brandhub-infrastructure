# Sequence Flow — Remove Member

> Companion to `spec.md` (FR 3.4.9). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Owner**
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agency_members`).

---

## Flow A — A member is removed successfully

1. Owner → Client: opens the Member list of the Agency, selects Remove on a member row other than their own, and confirms.
2. Client → System: submits the removal with the member record identifier (`DELETE /api/v1/agencies/{agencyId}/members/{memberId}`). The identifier is the member record of the Agency, not the person's user identifier.
3. System — remove:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   c. Finds the member record by identifier inside that Agency — not found → `404 NOT_FOUND`.
   d. Confirms the record is not the Owner's own — if it is → `409 CANNOT_REMOVE_OWNER`.
   e. Removes the member record.
4. System → Client: no data, the removal is done.
5. Client: drops the row and shows a confirmation. The person loses access to the Agency and to every one of its Workspaces immediately, because access everywhere rests on the member record that has just been removed.
6. The resources that person created — tasks, materials, content and the like — are neither removed nor reassigned. They stay with the Workspace and the Agency.

## Flow B — The Owner's own record is targeted (refused)

1. Owner → Client: selects Remove on the Owner row, when the Client does not hide that action, or submits the removal directly with the Owner's member record identifier.
2. Client → System: submits the removal (`DELETE /api/v1/agencies/{agencyId}/members/{memberId}`).
3. System: runs steps 3.a to 3.c of Flow A as usual, then reaches 3.d — the record is the Owner's own, so the removal is refused with `409 CANNOT_REMOVE_OWNER`.
4. System → Client: the refusal, `409 CANNOT_REMOVE_OWNER`.
5. Client: shows the failure and removes nothing.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Remove | Caller is not the Owner of the Agency | 403 | `NOT_AGENCY_OWNER` |
| Remove | The member record does not exist or belongs to another Agency | 404 | `NOT_FOUND` |
| Remove | The member record is the Owner's own | 409 | `CANNOT_REMOVE_OWNER` |

## Notes

- **Correction applied:** an earlier revision recorded the attempt to remove the Owner as refused with `403 FORBIDDEN`. The system now answers with its own code, `CANNOT_REMOVE_OWNER` at `409`, meaning the request conflicts with the state of the Agency rather than being forbidden outright. The correction is closed.
