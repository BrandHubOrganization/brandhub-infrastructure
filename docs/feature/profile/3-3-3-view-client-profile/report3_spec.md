**3.3.3 View Client Profile**

> V2 (2026-10-02): ClientProfile reworked — owned by the User, independent of any Agency.

**Function Trigger**

Begins when a user opens their own list of Client Profiles ("My Brand Profiles"), or when an Agency Manager/Owner opens a workspace's Client list to manage collaborating clients.

**Function Description**

- **Actors / Roles**: Any signed-in user, viewing the Client Profiles they personally own; Agency members (Owner/Manager) when viewing a workspace's Client list (`/workspaces/{id}/clients`).
- **Purpose**: Let a user manage the Client Profiles they own — one person may represent several brands (e.g. Nike, Adidas) and hold one profile per brand, none of which belong to any Agency. A profile is reused across every workspace/Agency the user collaborates with.
- **Interface**: The personal screen at /client-profiles lists every Client Profile the signed-in user owns — no Agency context required. A separate Workspace Client list, at /workspaces/{id}/clients, shows every WorkspaceMember with role CLIENT currently linked to that workspace (via client_profile_id).
- **Data Processing**: The system resolves the caller's identity from the access token and returns every Client Profile where userId matches the caller. For the workspace list, the system returns the workspace's active CLIENT members joined with their linked Client Profile for display.

**Screen Layout**

Figure — My Brand Profiles (/client-profiles):

- Center: list of every Client Profile the signed-in user owns — display name, company, contact details, logo.
- Buttons: Create new profile, Edit, Delete (blocked if linked to an active workspace membership).

Figure — Workspace Client List (/workspaces/{id}/clients):

- Center: list of active CLIENT members of this workspace — display name (from the linked Client Profile), joined date, status.
- Buttons: "Add client" (Owner/Manager only) — opens an invite-by-email dialog (see 3.4.7 for the invite flow).

**Function Details**
- **Data Specifications**
    - **Input required**: None beyond the caller's identity (My Brand Profiles); the workspace identifier, for the Workspace Client list.
    - **Input optional**: None.
    - **System data**: client_profiles — id, userId, displayName, company, phone, note, logoUrl, website, industry, location, description, socialLinks, plus brand fields, createdAt, updatedAt. The link to a workspace is client_profile_id on workspace_members, not any field on client_profiles.
    - **Output**: Every Client Profile owned by the caller, or the list of active CLIENT members for one workspace.

- **Business Rules**
    - **BR-41 (reworked)**: A Client Profile belongs to exactly one User and is never scoped to an Agency. One user may hold several independent Client Profiles — one per brand/customer they represent — completely unrelated to how many Agencies or workspaces they collaborate with.
    - The same Client Profile can be linked to any number of workspaces across any number of Agencies simultaneously.
    - A Client Profile is created either explicitly by its owner, or inline during a CLIENT invitation accept flow — never implicitly, and never keyed by an Agency.
    - **BR-38**: Client access is scoped by workspace membership — a client can only see/approve content in workspaces where their Client Profile is actively linked. A Client Profile is independent of the user's own User Profile (3.3.1).

- **Validation**
    - Missing, expired, or invalid access token → Display: **MSG22**.
    - Workspace Client list: missing or invalid workspace identifier → 404 WORKSPACE_NOT_FOUND.

**Functionalities**
- **Normal Flow**
    1. The user opens "My Brand Profiles" (/client-profiles).
    2. The system resolves the caller's identity from the access token.
    3. The system returns every Client Profile where userId matches the caller.
    4. The application renders the list — one card per brand the user represents.
    5. Alternatively, an Agency Manager/Owner opens a workspace's Client list; the system returns that workspace's active CLIENT members, and the application displays them with an "Add client" action.

- **Abnormal Cases**
    - N.a1: Missing, expired, or invalid access token at any step, the system displays **MSG22**. N.a2: The user signs in again at /login (3.2.2).
    - 5.a1: Invalid or missing workspace identifier → 404 WORKSPACE_NOT_FOUND. 5.a2: The application returns to the workspace list.

**Post-Conditions**

- Every Client Profile owned by the caller is displayed with the values currently stored for it, independent of any Agency context.
- The Workspace Client list reflects the workspace's current active CLIENT members only.
- No data is changed; the operation is read-only.
