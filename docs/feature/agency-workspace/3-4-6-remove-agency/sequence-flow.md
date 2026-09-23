# Sequence Flow — Remove Agency

> Companion to `spec.md` (FR 3.4.6). This file lists each actor → action → system step in enough detail to draw the sequence diagram directly. Business explanation lives in `spec.md`.
>
> Updated 2026-09-23, matching the system as built today.

## Actors

- **Owner**
- **Client** — the BrandHub web application.
- **System** — the BrandHub service.
- **Database** — PostgreSQL (`agencies`, `workspaces`).

---

## Flow A — Remove an Agency (cascading to its Workspaces)

1. Owner → Client: selects Remove in the Agency settings → a two-step confirmation dialog asks the Owner to type the Agency name and states the consequences, including that the Workspaces of the Agency are affected.
2. Client → System: submits the removal (`DELETE /api/v1/agencies/{agencyId}`).
3. System — remove:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   c. Marks the Agency SOFT_DELETED with the current time.
   d. Cascades: loads every Workspace belonging to the Agency and marks each one SOFT_DELETED with the same removal time.
4. System → Client: no data, the removal is done.
5. Client: shows a confirmation and takes the user back to the Agency list.

## Flow B — Restore an Agency (within 30 days, cascading to its Workspaces)

1. Owner → Client: opens the removed Agencies or follows a direct link, and selects Restore.
2. Client → System: submits the restore (`POST /api/v1/agencies/{agencyId}/restore`).
3. System — restore:
   a. Loads the Agency by its identifier — not found → `404 AGENCY_NOT_FOUND`.
   b. Confirms the caller is the Owner of the Agency — otherwise `403 NOT_AGENCY_OWNER`.
   c. Confirms the Agency is currently SOFT_DELETED — otherwise `400 AGENCY_NOT_DELETED`.
   d. Confirms a removal time is recorded and that no more than 30 days have passed since it — otherwise `410 RESTORE_WINDOW_EXPIRED`.
   e. Marks the Agency ACTIVE, clears its removal time and refreshes its update timestamp.
   f. Cascades: loads every Workspace belonging to the Agency and marks ACTIVE, with the removal time cleared and the update timestamp refreshed, only those Workspaces whose removal time matches the removal batch of the Agency. A Workspace whose removal time differs — because it was removed on its own beforehand — is left untouched.
4. System → Client: the Agency profile with the status ACTIVE.
5. Client: shows a confirmation and refreshes the screen.

---

## Error paths

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Remove | Agency does not exist | 404 | `AGENCY_NOT_FOUND` |
| Remove | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Restore | Agency does not exist | 404 | `AGENCY_NOT_FOUND` |
| Restore | Caller is not the Owner | 403 | `NOT_AGENCY_OWNER` |
| Restore | Agency was never removed | 400 | `AGENCY_NOT_DELETED` |
| Restore | More than 30 days have passed since the removal | 410 | `RESTORE_WINDOW_EXPIRED` |

## Notes

- **Correction applied:** an earlier revision recorded that the removal and the restore acted on the Agency alone, with no effect on its Workspaces. That no longer holds. The removal marks every Workspace of the Agency SOFT_DELETED with the same removal time, and the restore marks ACTIVE again the Workspaces whose removal time matches the removal batch.
- Remaining risk, by design rather than a defect: a Workspace that had already been removed on its own beforehand is recognised by its different removal time and is not brought back when the Agency is restored. Workspaces removed together with the Agency do come back.
