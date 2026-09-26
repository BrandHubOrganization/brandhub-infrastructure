**3.4.16 Leave Workspace**

**Function Trigger**

Begins when an active member of a Workspace confirms leaving that Workspace.

**Function Description**

- **Actors / Roles**: Any active member of the Workspace - MANAGER, CREATOR, or CLIENT - acting on their own membership only.
- **Purpose**: Lets a member leave a Workspace they no longer take part in while keeping their Agency membership, so they can still join other Workspaces.
- **Interface**: "Leave Workspace" action in Workspace settings or the members screen, shown only to the signed-in user themselves, followed by a confirmation dialog.
- **Data Processing**: The system locates the caller's own active membership in the Workspace and marks it inactive, without touching the caller's Agency membership.

**Screen Layout**

Figure - Leave Workspace Dialog:

- A "Leave Workspace" action inside Workspace settings or the members screen, visible only to the signed-in user.
- A confirmation dialog explaining that the member leaves this Workspace but remains in the Agency.
- A blocked state with a clear message when the member is the last MANAGER of the Workspace.

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the caller's authenticated identity, taken from the session principal.
    - **Input optional**: none.
    - **System data**: the caller's active membership row in that Workspace; the count of active MANAGERs in the Workspace.
    - **Output**: confirmation that the membership has been deactivated; no other data is returned.

- **Business Rules**
    - **BR-29**: The caller identity always comes from the session principal and the action applies only to the caller's own membership row; no other member can be targeted.
    - **BR-28 / BR-30**: Leaving is a soft delete (isActive=false); the caller loses access immediately because every scoped query re-checks membership. The caller's Agency membership is never modified. A MANAGER cannot leave if they are the last active MANAGER of the Workspace - the MANAGER role must be handed over first through FR 3.4.20.
    - **BR-31**: The Workspace role set assignable at Workspace level is MANAGER, CREATOR, CLIENT (OWNER exists only at Agency level); the last-MANAGER guard applies only when the membership being deactivated carries the MANAGER role.

- **Validation**
    - The caller must hold an active membership in that Workspace; otherwise 403 WORKSPACE_ACCESS_DENIED, toast **MSG40**.
    - The caller must not be the only active MANAGER of the Workspace; otherwise 409 LAST_MANAGER_CANNOT_BE_REMOVED, toast **MSG37**.

**Functionalities**
- **Normal Flow**
    1. Member opens Workspace settings or the members screen and chooses "Leave Workspace".
    2. Member confirms in the dialog.
    3. System looks up the caller's own active membership in the Workspace; if none exists the request fails with 403 WORKSPACE_ACCESS_DENIED.
    4. System applies the last-MANAGER guard: members who are not MANAGER pass, and a MANAGER passes when another active MANAGER exists.
    5. System marks the membership inactive.
    6. The member is taken out of the Workspace back to the Workspace list, while remaining in the Agency and in their other Workspaces; toast **MSG36**.

- **Abnormal Cases**
    - 3.a1: Caller has no active membership in that Workspace -> 403 WORKSPACE_ACCESS_DENIED, toast **MSG40**. 3.a2: The caller returns to the Workspace list; the Workspace they tried to leave does not appear.
    - 4.a1: Caller is the only active MANAGER of the Workspace -> 409 LAST_MANAGER_CANNOT_BE_REMOVED, toast **MSG37**. 4.a2: Another MANAGER must be assigned first through FR 3.4.20, then the caller retries leaving.
    - 4.b1: A CREATOR or CLIENT leaves while other members remain -> the request always succeeds. 4.b2: The member is removed from the Workspace and returned to the Workspace list.

**Post-Conditions**

- The caller's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The caller's Agency membership is untouched; they remain in the Agency and in their other Workspaces.
