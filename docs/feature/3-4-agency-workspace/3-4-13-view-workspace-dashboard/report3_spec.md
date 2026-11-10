**3.4.11 View Workspace Dashboard**

**Function Trigger**

Begins when a Workspace member opens the Dashboard of a Workspace.

**Function Description**

- **Actors / Roles**: Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose**: Gives members an overview of the Workspace's members, campaigns, package negotiation status, and the parent Agency's AI credit usage.
- **Interface**: Workspace dashboard screen, showing summary cards.
- **Data Processing**: The system resolves the Workspace, confirms the caller is an active member, then aggregates active member count and role breakdown, campaign count and status breakdown, the current package negotiation status, and the parent Agency's AI credit usage for the current calendar month.
- No Task or Material entity exists in this codebase, so the dashboard does not show a Task summary. AI credit usage is Agency-wide, not per-Workspace, and is labeled as Agency-scoped.

**Screen Layout**

Figure - Workspace Dashboard Screen:

- Header carrying the Workspace name.
- Four stat cards in a row: Active members, Total campaigns, Package status (or "No package"), Agency AI credits used this month.
- Two breakdown cards: Members by role, Campaigns by status - each an empty list if the Workspace has none yet.
- A newly created Workspace with no package/campaign shows member counts as normal, campaign count as 0, package status as "No package".

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the caller's authenticated identity.
    - **Input optional**: none.
    - **System data**: active WorkspaceMember rows; the Workspace's WorkspaceMediaPackage (if any) and its MediaCampaign rows; the parent Agency's AiCreditLedger row for the current month.
    - **Output**: the full Workspace profile, active member count and role breakdown, campaign count and status breakdown, package negotiation status (nullable), the Agency id, the current month string, and the Agency's AI credits used this month.

- **Business Rules**
    - **BR-29**: Only members holding an active membership row in the Workspace may view its dashboard, enforced both at the controller and inside the service. There is no Workspace-level OWNER - OWNER exists only at Agency level.
    - **BR-03**: The dashboard is read-only and changes no data.
    - **BR-04**: An empty Workspace (no package, no campaigns) renders member counts normally and campaign/package fields as empty/zero/null rather than failing.

- **Validation**
    - Caller must be an active member of the Workspace; otherwise 403 WORKSPACE_ACCESS_DENIED or 403 FORBIDDEN.
    - Workspace must exist; otherwise 404 WORKSPACE_NOT_FOUND.
    - A Workspace with no package/campaigns must render without error.

**Functionalities**
- **Normal Flow**
    1. Member opens the Dashboard of a Workspace.
    2. System resolves the Workspace and confirms active membership (BR-29).
    3. System aggregates active member count/role breakdown, campaign count/status breakdown, package negotiation status, and the Agency's current-month AI credit usage.
    4. Screen renders the stat cards and breakdown lists; an empty Workspace shows zeros/empty lists without error.

- **Abnormal Cases**
    - 2.a1: The Workspace does not exist -> 404 WORKSPACE_NOT_FOUND, toast **MSG38**. 2.a2: The member returns to the Workspace list.
    - 2.b1: Caller is not an active member of the Workspace -> 403 WORKSPACE_ACCESS_DENIED or FORBIDDEN, toast **MSG40**. 2.b2: The member returns to the Workspace list.
    - 3.a1: Workspace has no package yet -> packageNegotiationStatus is null, totalCampaigns is 0. 3.a2: The member continues viewing the dashboard normally.

**Post-Conditions**

- No data is changed; the Workspace's member, campaign, package, and Agency AI credit summary is displayed.
