**3.4.20 Update Workspace Member Role**

**Function Trigger**

Begins when the MANAGER of a Workspace changes the role of one of its members.

**Function Description**

- **Actors / Roles**: The MANAGER of the Workspace, and only that role.
- **Purpose**: Lets the MANAGER adjust a member's role to match the work actually being done, including handing over the MANAGER role.
- **Interface**: A role selector in the member table, offering MANAGER, CREATOR, and CLIENT.
- **Data Processing**: The system loads the member, applies the single-MANAGER guards, updates the role, and returns the updated member.

**Screen Layout**

Figure - Update Member Role Screen:

- The member table on the members screen.
- A role selector per member with the values MANAGER, CREATOR, CLIENT.
- A blocked state with a clear message when the change would leave the Workspace without a MANAGER or would create a second one.

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the member identifier; the new role.
    - **Input optional**: none.
    - **System data**: the caller's role in the Workspace; the member record and its current role; the count of active MANAGERs in the Workspace; the member's user record for building the response.
    - **Output**: the updated member - id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive, carrying the new role.

- **Business Rules**
    - **BR-35**: The role check re-reads the caller's role from the DB at request time; SystemRole.ADMIN bypasses the check. Only MANAGER may change roles; any other caller -> 403 FORBIDDEN. This runs before any service-level guard.
    - **BR-33**: A role change affects the current Workspace only - it does not carry over to the same member's roles in other Workspaces of the Agency.
    - **BR-83**: Last-MANAGER guard on demotion - if the member is the only active MANAGER of the Workspace and the new role is not MANAGER, the request is blocked with 409 LAST_MANAGER_CANNOT_BE_REMOVED; another MANAGER must be in place first. Checked before the duplicate-MANAGER guard.
    - **BR-87**: Duplicate-MANAGER guard on promotion, checked second - if the new role is MANAGER and the member is not currently a MANAGER, the request is blocked with 409 MANAGER_ALREADY_ASSIGNED when the Workspace already has another active MANAGER.
    - **BR-29**: The member lookup is scoped to the Workspace; a member that does not exist, is not active, or belongs to another Workspace -> 404 NOT_FOUND.
    - **BR-31**: The assignable workspace roles are MANAGER, CREATOR, CLIENT; there is no Workspace-level OWNER.
    - **BR-82**: role must be one of the enum values; any other value is rejected.
    - There is no exception for changing one's own role - a MANAGER acting on themselves is subject to the same guards as any other member.

- **Validation**
    - Caller must be the MANAGER of that Workspace; otherwise 403 FORBIDDEN. Toast **MSG39**.
    - role empty -> Display: **MSG02**.
    - The member must exist, be active, and belong to that Workspace; otherwise 404 NOT_FOUND. Toast **MSG38**.
    - The new role must be one of MANAGER, CREATOR, CLIENT; otherwise Display: **MSG95**.
    - Demoting the only active MANAGER -> 409 LAST_MANAGER_CANNOT_BE_REMOVED. Toast **MSG96**.
    - Promoting to MANAGER while another active MANAGER exists -> 409 MANAGER_ALREADY_ASSIGNED. Display: **MSG95**.

**Functionalities**
- **Normal Flow**
    1. MANAGER opens the members screen and picks a new role for a member in the role selector.
    2. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 FORBIDDEN.
    3. System loads the member and checks that it exists, is active, and belongs to that Workspace; otherwise the request fails with 404 NOT_FOUND.
    4. System applies the guards in order: the last-MANAGER guard when demoting the only active MANAGER, then the duplicate-MANAGER guard when promoting to MANAGER while another active MANAGER exists.
    5. System stores the new role on the membership and returns the updated member.
    6. Screen refreshes the role shown for that member.

- **Abnormal Cases**
    - 2.a1: Caller is not the MANAGER of that Workspace -> 403 FORBIDDEN, toast **MSG39**. 2.a2: The screen blocks the action.
    - 3.a1: Member does not exist, is not active, or belongs to another Workspace -> 404 NOT_FOUND, toast **MSG38**. 3.a2: The screen refreshes the member list.
    - 4.a1: Demoting the only active MANAGER to CREATOR or CLIENT -> 409 LAST_MANAGER_CANNOT_BE_REMOVED, toast **MSG96**. 4.a2: The MANAGER hands the MANAGER role to another member first, then retries.
    - 4.b1: Promoting a member to MANAGER while the Workspace already has an active MANAGER -> 409 MANAGER_ALREADY_ASSIGNED, Display: **MSG95**. 4.b2: The MANAGER demotes the current MANAGER first, or picks a different role.
    - A MANAGER demotes themselves -> allowed when at least one other MANAGER remains; blocked with 409 LAST_MANAGER_CANNOT_BE_REMOVED when they are the only MANAGER.
    - A role change between CREATOR and CLIENT -> always allowed.
    - Setting the role to the value it already holds -> allowed; no guard blocks a no-op change.

**Post-Conditions**

- The member holds the new role in this Workspace only.
- The Workspace still has exactly one active MANAGER.
