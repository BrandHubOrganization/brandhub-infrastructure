**3.4.13 View Workspace Profile**

**Function Trigger**

Begins when a Workspace member opens the profile of a Workspace.

**Function Description**

- **Actors / Roles**: Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose**: Shows the Workspace's details - timezone configuration and branding/company information - so members understand which timezone the Workspace runs on and how its branding is configured.
- **Interface**: Workspace settings screen - a single combined page that also hosts the update form (FR 3.4.14); there is no separate read-only profile route.
- **Data Processing**: The system loads the Workspace and maps the record to a Workspace profile, parsing the stored settings into timezone, default platforms, and report frequency.

**Screen Layout**

Figure - Workspace Settings Screen:

- Logo block shown only when the caller can manage the Workspace.
- Form pre-filled with name, timezone, default platforms, report frequency, industry, company size, website, phone, location.

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the caller's authenticated identity.
    - **Input optional**: none.
    - **System data**: the Workspace record; the caller's active membership row; the stored settings payload.
    - **Output**: the Workspace profile - id, name, agencyId, slug, ownerId, settings (timezone, defaultPlatforms, reportFrequency), industry, companySize, website, phone, location, description, branding fields, social links, isActive, createdAt.

- **Business Rules**
    - **BR-29**: Every workspace-scoped resource carries workspaceId; a caller with no active membership cannot read it regardless of system role (except ADMIN). Enforced in two layers: a controller-level role check against the caller's global role set, and a service-level membership check scoped to this specific Workspace.
    - Workspace that does not exist -> 404 WORKSPACE_NOT_FOUND.
    - Caller not an active member of that specific Workspace -> 403 WORKSPACE_ACCESS_DENIED.
    - Failure to parse the stored settings falls back to empty settings without raising an error.
    - There is a single Workspace-level timezone configuration - not one per Client or per Task.

- **Validation**
    - The Workspace must exist; otherwise 404 WORKSPACE_NOT_FOUND.
    - The caller must hold an active membership in that Workspace; otherwise 403 WORKSPACE_ACCESS_DENIED.
    - A malformed settings payload must degrade to empty settings rather than fail the request.

**Functionalities**
- **Normal Flow**
    1. Member opens the Workspace settings screen.
    2. System loads the Workspace; if it does not exist, the request fails with 404 WORKSPACE_NOT_FOUND.
    3. System confirms the caller has an active membership in that Workspace; otherwise the request fails with 403 WORKSPACE_ACCESS_DENIED.
    4. System maps the Workspace to its profile, parsing the stored settings into timezone, default platforms, and report frequency.
    5. Screen displays the Workspace profile, including the Workspace timezone.

- **Abnormal Cases**
    - 2.a1: The Workspace does not exist -> 404 WORKSPACE_NOT_FOUND, toast **MSG38**. 2.a2: The member returns to the Workspace list and picks a valid Workspace.
    - 3.a1: The caller has no active membership in that Workspace -> 403 WORKSPACE_ACCESS_DENIED, toast **MSG40**. 3.a2: The member returns to the Workspace list; only Workspaces they belong to are shown.
    - 4.a1: Stored settings are malformed -> the screen shows empty settings instead of failing. 4.a2: The member may ask a MANAGER to re-save the settings.

**Post-Conditions**

- No data is changed; the Workspace profile is displayed.
