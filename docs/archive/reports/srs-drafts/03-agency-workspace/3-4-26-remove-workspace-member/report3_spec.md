**3.4.21 Remove Workspace Member**

**Function Trigger**

Begins when the MANAGER of a Workspace confirms removal of a member from that Workspace.

**Function Description**

- **Actors / Roles**: The MANAGER of the Workspace, and only that role.
- **Purpose**: Lets the MANAGER take a member out of the Workspace while the member stays in the Agency and can still join other Workspaces.
- **Interface**: A Remove action per member in the member table, followed by a confirmation dialog.
- **Data Processing**: The system loads the member, applies the last-MANAGER guard, and marks the membership inactive without touching the member's Agency membership.

**Screen Layout**

Figure - Remove Member Dialog:

- A Remove action per member in the members table.
- A confirmation dialog naming the member being removed.
- A blocked state with a clear message when the member is the only active MANAGER of the Workspace.

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the member identifier; the caller's authenticated identity.
    - **Input optional**: none.
    - **System data**: the caller's role in the Workspace; the member record and its role; the count of active MANAGERs in the Workspace.
    - **Output**: confirmation that the membership has been deactivated; no other data is returned.

- **Business Rules**
    - **BR-35**: The role check re-reads the caller's role from the DB at request time; SystemRole.ADMIN bypasses the check. Only MANAGER may remove a member; any other caller -> 403 FORBIDDEN. Runs before any service-level guard.
    - **BR-28**: Remove member - only MANAGER may remove; the last remaining active MANAGER cannot be removed or changed away from MANAGER; removal is a soft-delete (isActive=false), not a row deletion. The member's Agency membership is never modified.
    - **BR-30**: A removed member loses access immediately because every scoped query re-checks membership.
    - **BR-28 (last-MANAGER guard)**: removing a member whose role is MANAGER is blocked with 409 LAST_MANAGER_CANNOT_BE_REMOVED when that member is the only active MANAGER of the Workspace. The same guard is shared with FR 3.4.16 Leave Workspace and FR 3.4.20 Update Workspace Member Role.
    - **BR-29**: The member lookup is scoped to the Workspace; a member that does not exist, is not active, or belongs to another Workspace -> 404 NOT_FOUND.

- **Validation**
    - Caller must be the MANAGER of that Workspace; otherwise 403 FORBIDDEN. Toast **MSG39**.
    - The member must exist, be active, and belong to that Workspace; otherwise 404 NOT_FOUND. Toast **MSG38**.
    - Removing the only active MANAGER of the Workspace -> 409 LAST_MANAGER_CANNOT_BE_REMOVED. Toast **MSG37**.

**Functionalities**
- **Normal Flow**
    1. MANAGER opens the members screen and chooses Remove for a member.
    2. MANAGER confirms in the dialog.
    3. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 FORBIDDEN.
    4. System loads the member and checks that it exists, is active, and belongs to that Workspace; otherwise the request fails with 404 NOT_FOUND.
    5. System applies the last-MANAGER guard: members who are not MANAGER pass, and a MANAGER passes only when another active MANAGER exists.
    6. System marks the membership inactive; the member disappears from the active member list; toast **MSG36**.
    7. The member's Agency membership is untouched - they remain in the Agency and in any other Workspace they take part in.

- **Abnormal Cases**
    - 3.a1: Caller is not the MANAGER of that Workspace -> 403 FORBIDDEN, toast **MSG39**. 3.a2: The screen blocks the action.
    - 4.a1: Member does not exist, is not active, or belongs to another Workspace -> 404 NOT_FOUND, toast **MSG38**. 4.a2: The screen refreshes the member list.
    - 5.a1: Removing the only active MANAGER of the Workspace -> 409 LAST_MANAGER_CANNOT_BE_REMOVED, toast **MSG37**. 5.a2: The MANAGER assigns another member as MANAGER first, then retries the removal.

**Post-Conditions**

- The member's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The member's Agency membership is untouched; they remain in the Agency and in their other Workspaces.
- The Workspace still has exactly one active MANAGER.
