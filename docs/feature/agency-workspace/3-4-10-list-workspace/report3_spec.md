**3.4.10 List Workspace**

**Function Trigger**

Begins when a signed-in user opens the Workspace list screen.

**Function Description**

- **Actors / Roles**: Any Workspace member (MANAGER, CREATOR, or CLIENT).
- **Purpose**: Shows every Workspace the current user belongs to, so the user can pick one to work in.
- **Interface**: Workspace list screen of the current user - a list of Workspace entries, not scoped under an Agency route.
- **Data Processing**: The system reads the current user's active Workspace memberships, loads the Workspace records those memberships point to, and maps each one to a Workspace summary.

**Screen Layout**

Figure - Workspace List Screen:

- A single grid screen titled with the user's Workspaces.
- Each card shows an initials badge, the Workspace name, and its slug; clicking a card opens the Workspace settings screen.
- An empty state message is shown when the user belongs to no Workspace.
- A "Create Workspace" button navigates to the create form (FR 3.4.12).

**Function Details**
- **Data Specifications**
    - **Input required**: the caller's authenticated identity.
    - **Input optional**: none.
    - **System data**: active Workspace membership rows of the current user; the Workspace records those memberships reference.
    - **Output**: the Workspaces the user belongs to - id, name, agencyId, slug, ownerId, settings, industry, companySize, website, phone, location, description, branding fields, social links, isActive, createdAt. The list card only renders name and slug.

- **Business Rules**
    - **BR-29**: A Workspace is returned when either the current user has an active membership in it (MANAGER, CREATOR, CLIENT), or the current user is the Owner of the Agency that Workspace belongs to.
    - **BR-03**: The listing is read-only; the only failure is a missing session, rejected with 401.
    - Known gap: soft-deleted Workspaces are not excluded from this list - the query has no status filter, so a deleted Workspace may still appear until fixed.

- **Validation**
    - Caller must be signed in -> otherwise 401.
    - A user with no Workspace membership receives an empty list, not an error.

**Functionalities**
- **Normal Flow**
    1. User opens the Workspace list screen.
    2. System reads the current user's active Workspace memberships.
    3. System loads the Workspace records referenced by those memberships.
    4. System maps each Workspace to a Workspace summary.
    5. Screen shows the Workspaces the user belongs to; an empty list is shown when the user belongs to none.

- **Abnormal Cases**
    - 5.a1: User belongs to no Workspace -> empty list, HTTP 200. 5.a2: The empty state is displayed.
    - 5.b1: User is not signed in -> 401. 5.b2: The user is redirected to sign in.
    - 5.c1: A soft-deleted Workspace is still referenced by an owned Agency or membership (known gap) -> it is still returned and displayed as active. 5.c2: No client workaround; tracked as a backend fix.

**Post-Conditions**

- No data is changed; the Workspaces the user belongs to are displayed.
