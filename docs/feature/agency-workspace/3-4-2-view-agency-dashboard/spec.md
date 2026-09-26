# 3.4.2 View Agency Dashboard

## Function Trigger
Proposed — not yet implemented. The intended trigger is the Owner opening the dashboard of one of their Agencies (`/agencies/:agencyId/dashboard`). No dashboard screen exists in the current system.

## Function Description
- **Actors / Roles:** Agency Owner. Proposed — not yet implemented.
- **Purpose:** Give the Owner an overview of one Agency — how many Workspaces and Members it has, how many Clients it serves, and what happened recently.
- **Interface:** Agency Dashboard page (`/agencies/:agencyId/dashboard`) — proposed; not yet implemented.
- **Data Processing:** The system would count the Members of the Agency, count the Workspaces belonging to it, count the distinct Clients across those Workspaces, and return them with a recent-activity list. Only the Member count can be derived from existing data today; the Workspace and Client counts and the recent-activity list still need to be designed.

## Screen Layout
Figure — Agency Dashboard:
- Summary tiles for Workspace count, Member count and Client count.
- A recent-activity list.
- Proposed — not yet implemented; the layout is indicative only.

## Function Details
### Data Specifications
- **Input required:** The Agency identifier (`agencyId`).
- **Input optional:** None.
- **System data:** Agency profile (see 3.4.1 and 3.4.4), the Agency Member records of the Agency, the Workspaces belonging to the Agency, and the Client Profile records of those Workspaces. Recent activity has no agreed data source yet.
- **Output:** Proposed — a summary holding the Workspace count, the Member count and the Client count, together with a recent-activity list. Not yet implemented.

### Business Rules
- **BR-29 (approximated):** Multi-tenancy — only the Owner of the Agency may view its dashboard; anybody else is refused with `403 FORBIDDEN`, mirroring the workspace-scoped access rule since no Agency-dashboard-specific BR exists yet. *(No exact BR-xx covers a not-yet-implemented dashboard; closest fit noted.)*
- The Agency must exist and must not be soft-deleted; otherwise `404 AGENCY_NOT_FOUND`.
- The Member count covers every Agency Member record of the Agency, whatever the role.
- Proposed — not yet implemented: the Workspace and Client counts, and the recent-activity list, still have to be defined.

### Validation
- Caller is not the Agency Owner → Display: MSG39
- Agency does not exist or is soft-deleted → Display: MSG38

## Functionalities
### Normal Flow
1. The Owner opens the Agency Dashboard. *(Proposed — not yet implemented.)*
2. The client requests the dashboard summary for the Agency.
3. The system confirms that the Agency exists and that the caller is its Owner.
4. The system counts the Members of the Agency, its Workspaces, and the distinct Clients across those Workspaces, and collects the recent activity.
5. The system returns the summary and the client renders it.

### Abnormal Cases
- 3.a1: Caller is not the Agency Owner → `403 FORBIDDEN`, toast MSG39. 3.a2: The caller returns to the Agency list and opens an Agency they own.
- 3.b1: Agency does not exist or is soft-deleted → `404 AGENCY_NOT_FOUND`, toast MSG38. 3.b2: The caller returns to the Agency list.
- 4.a1: Agency just created, with no Workspace yet → every count is returned as zero, which is not an error; no toast shown. 4.a2: The Owner proceeds to create a Workspace to start populating the dashboard.

## Post-Conditions
- No Agency data is created, changed or removed. *(Proposed — not yet implemented.)*
