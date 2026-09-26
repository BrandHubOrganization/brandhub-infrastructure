**3.4.6 Remove Agency**

**Function Trigger**

The Owner of an Agency selects Remove in the Agency settings and confirms the removal dialog; or later selects Restore on an Agency removed within the last 30 days.

**Function Description**

- **Actors / Roles**: Agency Owner.
- **Purpose**: Let the Owner take an Agency out of use without losing it, so it can be restored within 30 days.
- **Interface**: Remove action in Agency settings, behind a two-step confirmation dialog that asks the Owner to type the Agency name and states the consequences, including that the Workspaces of the Agency are affected too. Restore is available on removed Agencies within the 30-day window. On the FE, a danger-zone section groups the Remove and Restore actions.
- **Data Processing**: The system loads the Agency, confirms the caller is its Owner, marks the Agency soft-deleted with a removal timestamp, and marks every Workspace of that Agency the same way with the same timestamp. Restoring marks the Agency active again, clears the removal timestamp, and does the same for the Workspaces removed in that same batch — Workspaces already removed on their own keep their removed state.

**Screen Layout**

Figure — Remove Agency dialog:

- A two-step confirmation: the Owner types the Agency name to confirm.
- The dialog lists the consequences, notably that the Workspaces of the Agency are removed along with it.
- A danger-zone section in the Agency settings groups the Remove action and, for a removed Agency, the Restore action, available for 30 days after removal.

**Function Details**
- **Data Specifications**
    - **Input required**: the Agency identifier (agencyId) and a signed-in session as its Owner.
    - **Input optional**: none.
    - **System data**: the status and removal timestamp of the Agency (ACTIVE / SOFT_DELETED) and the status and removal timestamp of every Workspace belonging to the Agency.
    - **Output**: removal leaves no profile to show. Restore returns the Agency profile with status ACTIVE.

- **Business Rules**
    - **BR-26 (analogous)**: delete Agency is Owner-only, mirroring the rule that delete Workspace is OWNER-only. Anybody else is refused with 403 NOT_AGENCY_OWNER.
    - Removal is soft: the Agency is marked SOFT_DELETED and stamped with the removal time. Nothing is erased, and the Agency can be restored.
    - Removal cascades to the Workspaces of the Agency: each is marked SOFT_DELETED with the same removal time as the Agency.
    - Restore is allowed only on an Agency currently SOFT_DELETED; otherwise 400 AGENCY_NOT_DELETED.
    - Restore is allowed only within 30 days of the removal timestamp; beyond that, 410 RESTORE_WINDOW_EXPIRED.
    - Restore marks the Agency ACTIVE with the removal timestamp cleared, and does the same for the Workspaces whose removal timestamp matches the removal batch exactly. A Workspace already removed on its own beforehand keeps its removed state.
    - When the 30-day window passes without a restore, the Agency may eventually be erased for good by a periodic clean-up, designed separately and not part of this feature today.

- **Validation**
    - Caller is not the Agency Owner → Display: **MSG39**
    - Agency does not exist → Display: **MSG38**
    - Restore called on an Agency that was never removed → 400 AGENCY_NOT_DELETED.
    - Restore attempted more than 30 days after removal → 410 RESTORE_WINDOW_EXPIRED.

**Functionalities**
- **Normal Flow**
    1. The Owner selects Remove in the Agency settings danger zone.
    2. The confirmation dialog states the consequences and asks the Owner to type the Agency name.
    3. The Owner confirms.
    4. The system loads the Agency and confirms the caller is its Owner.
    5. The system marks the Agency SOFT_DELETED with the current time.
    6. The system marks every Workspace of the Agency SOFT_DELETED with the same removal time; toast **MSG93**.
    7. The client shows a confirmation and takes the user back to the Agency list.
    8. Within 30 days, the Owner selects Restore in the danger zone.
    9. The system confirms the caller is the Owner, that the Agency is SOFT_DELETED, and that the removal happened less than 30 days ago.
    10. The system marks the Agency ACTIVE with the removal timestamp cleared, and does the same for the Workspaces removed in that same batch.

- **Abnormal Cases**
    - 4.a1: Agency does not exist → 404 AGENCY_NOT_FOUND, toast **MSG38**. 4.a2: The Owner returns to the Agency list.
    - 4.b1: Caller is not the Agency Owner → 403 NOT_AGENCY_OWNER, toast **MSG39**; nothing changes. 4.b2: The caller returns to the Agency list.
    - 9.a1: Restore called on an Agency never removed → 400 AGENCY_NOT_DELETED, toast **MSG38** (closest fit). 9.a2: The Owner reloads the Agency list, which shows it as already active.
    - 9.b1: Restore attempted after the 30-day window → 410 RESTORE_WINDOW_EXPIRED, toast **MSG38** (closest fit). 9.b2: The Owner accepts the Agency stays removed, or creates a new one.
    - 10.a1: The Owner restores within 30 days after a mistaken removal → Workspaces removed in that same batch become ACTIVE again; no error. 10.a2: The Owner continues working in the restored Agency and its Workspaces.
    - 10.b1: A Workspace had already been removed on its own beforehand → it is not brought back when the Agency is restored, since its removal timestamp differs from the removal batch; no error. 10.b2: The Owner restores that Workspace separately if still within its own window.

**Post-Conditions**

- After removal: the Agency and its Workspaces carry the SOFT_DELETED status and the same removal timestamp. Nothing is erased.
- After a restore within the window: the Agency is ACTIVE with no removal timestamp, and Workspaces from the same removal batch are ACTIVE again, while Workspaces removed on their own stay removed.
