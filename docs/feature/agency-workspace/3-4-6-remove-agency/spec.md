# 3.4.6 Remove Agency

## Function Trigger
The Owner of an Agency selects Remove in the Agency settings and confirms the removal dialog; or later selects Restore on an Agency that was removed within the last 30 days.

## Function Description
- **Actors / Roles:** Agency Owner.
- **Purpose:** Let the Owner take an Agency out of use without losing it, so it can be brought back if the Owner changes their mind within 30 days.
- **Interface:** Remove action in the Agency settings, behind a two-step confirmation dialog that asks the Owner to type the Agency name and states the consequences, including that the Workspaces of the Agency are affected too. Restore is available on removed Agencies within the 30-day window.
- **Data Processing:** The system loads the Agency, confirms the caller is its Owner, then marks the Agency as soft-deleted with the removal timestamp, and marks every Workspace belonging to that Agency the same way, recording the same removal timestamp on each of them. Restoring marks the Agency active again and clears the removal timestamp, and does the same for the Workspaces that were removed in that same removal batch — Workspaces that had already been removed on their own keep their removed state.

## Screen Layout
Figure — Remove Agency dialog:
- A two-step confirmation: the Owner types the Agency name to confirm.
- The dialog lists the consequences, notably that the Workspaces of the Agency are removed along with it.
- A Restore action on removed Agencies, available for 30 days after the removal.

## Function Details
### Data Specifications
- **Input required:** The Agency identifier (`agencyId`) and a signed-in session as its Owner.
- **Input optional:** None.
- **System data:** The status and removal timestamp of the Agency (EntityStatus: ACTIVE / SOFT_DELETED) and the status and removal timestamp of every Workspace belonging to the Agency.
- **Output:** The removal leaves no profile to show. The restore returns the Agency profile with the status ACTIVE.

### Business Rules
- **BR-01:** Only the Owner of the Agency may remove or restore it. Anybody else is refused with `403 NOT_AGENCY_OWNER`.
- **BR-02:** Removal is soft: the Agency is marked SOFT_DELETED and stamped with the removal time. Nothing is erased, and the Agency can be restored afterwards.
- **BR-03:** Removal cascades to the Workspaces of the Agency: each of them is marked SOFT_DELETED and stamped with the same removal time as the Agency.
- **BR-04:** Restore is allowed only on an Agency that is currently SOFT_DELETED; otherwise `400 AGENCY_NOT_DELETED`.
- **BR-05:** Restore is allowed only within 30 days of the removal timestamp; beyond that window, `410 RESTORE_WINDOW_EXPIRED`.
- **BR-06:** Restore marks the Agency ACTIVE with its removal timestamp cleared, and does the same for the Workspaces whose removal timestamp matches the removal batch exactly. A Workspace that had already been removed on its own beforehand keeps its removed state and is not brought back.
- **BR-07:** When the 30-day window passes without a restore, the Agency may eventually be erased for good by a periodic clean-up. That clean-up is designed separately and is not part of this feature today.

### Validation
- Caller is not the Agency Owner → `403 NOT_AGENCY_OWNER`.
- Agency does not exist → `404 AGENCY_NOT_FOUND`.
- Restore called on an Agency that was never removed → `400 AGENCY_NOT_DELETED`.
- Restore attempted more than 30 days after the removal → `410 RESTORE_WINDOW_EXPIRED`.

## Functionalities
### Normal Flow
1. The Owner selects Remove in the Agency settings.
2. The confirmation dialog states the consequences, including that the Workspaces of the Agency are removed along with it, and asks the Owner to type the Agency name.
3. The Owner confirms.
4. The system loads the Agency and confirms the caller is its Owner.
5. The system marks the Agency SOFT_DELETED with the current time.
6. The system marks every Workspace belonging to the Agency SOFT_DELETED with the same removal time.
7. The client shows a confirmation and takes the user back to the Agency list.
8. Within 30 days, the Owner selects Restore on that Agency.
9. The system loads the Agency and confirms the caller is its Owner, that the Agency is SOFT_DELETED, and that the removal happened less than 30 days ago.
10. The system marks the Agency ACTIVE with the removal timestamp cleared, and does the same for the Workspaces removed in that same batch.

### Abnormal Cases
- Agency does not exist → `404 AGENCY_NOT_FOUND`.
- Caller is not the Agency Owner → `403 NOT_AGENCY_OWNER`, nothing changes.
- Restore called on an Agency that was never removed → `400 AGENCY_NOT_DELETED`.
- Restore attempted after the 30-day window → `410 RESTORE_WINDOW_EXPIRED`.
- The Owner removed the Agency by mistake and restores it within 30 days → the Workspaces removed in that same batch become ACTIVE again.
- A Workspace had already been removed on its own beforehand (3.4.15) → it is not brought back when the Agency is restored, because its removal timestamp differs from the removal batch.

## Post-Conditions
- After removal: the Agency and its Workspaces carry the SOFT_DELETED status and the same removal timestamp. Nothing is erased.
- After a restore within the window: the Agency is ACTIVE with no removal timestamp, and the Workspaces from the same removal batch are ACTIVE again, while Workspaces removed on their own stay removed.
