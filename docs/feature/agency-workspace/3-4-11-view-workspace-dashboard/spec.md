# 3.4.11 View Workspace Dashboard

| | |
|---|---|
| FR Code | 3.4.11 |
| Feature | View Workspace Dashboard |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 2.2 — 2026-09-23 — rewritten to the standard FR format |
| Document status | **Proposed — not yet implemented** |

## Function Trigger

Begins when a Workspace member opens the dashboard of a Workspace. Proposed — not yet implemented.

## Function Description

- **Actors / Roles:** Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose:** Gives members an overview of the Workspace's activity so they can follow work in progress. Proposed — not yet implemented.
- **Interface:** Workspace dashboard screen at `/workspaces/:id/dashboard`, showing summary counters.
- **Data Processing:** The system aggregates the Workspace's Task counts by status (backlog / in progress / completed), the number of active Clients, and the number of active Campaigns. Proposed — not yet implemented.

## Screen Layout

Figure — Workspace Dashboard Screen (proposed — not yet implemented):
- Header carrying the Workspace name.
- Counter tiles for Task counts by status: backlog, in progress, completed.
- Counter tiles for active Clients and active Campaigns.
- A newly created Workspace with no Package, Campaign, or Task shows every counter as 0.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** Tasks of the Workspace grouped by status; active Client memberships; active Campaigns.
- **Output:** Task counts by status (backlog / in progress / completed), the active Client count, and the active Campaign count.

### Business Rules

- **BR-29:** Multi-tenancy — every workspace-scoped resource carries workspaceId; a user with no active membership cannot read/write the workspace regardless of system role (except ADMIN). Applied here as: only members holding an active membership row in the Workspace (MemberRole MANAGER, CREATOR, or CLIENT) may view its dashboard. There is no Workspace-level OWNER — OWNER exists only at Agency level.
- **BR-03:** The dashboard is read-only and changes no data.
- **BR-04:** An empty Workspace must render all counters as 0 rather than fail. *(Proposed — not yet implemented.)*

No dedicated dashboard service method exists in the codebase. The closest real backing is `getWorkspace(workspaceId, currentUser)`, which resolves the Workspace and checks membership in this exact order: `findWorkspaceOrThrow` (workspace missing → `WORKSPACE_NOT_FOUND`) then `assertMember` (not an active member → `WORKSPACE_ACCESS_DENIED`). This FR's Abnormal Cases are based on that guard order as an assumption, since no dashboard-aggregation method exists to confirm the counter logic against.

### Validation

- Caller must be an active member of the Workspace; otherwise 403 `WORKSPACE_ACCESS_DENIED`.
- Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`.
- A Workspace with no Package, Campaign, or Task must render every counter as 0.

## Functionalities

### Normal Flow

1. Member opens the dashboard of a Workspace.
2. System resolves the Workspace and confirms the caller holds an active membership in it (BR-29), following `getWorkspace`'s guard order: not-found check first, then access-denied check.
3. System aggregates Task counts by status, the active Client count, and the active Campaign count.
4. Screen renders the counters; a Workspace with no data shows all zeros.

### Abnormal Cases

- 2.a1: The Workspace does not exist (closest real backing: `findWorkspaceOrThrow`) → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 2.a2: The member returns to the Workspace list (3.4.10).
- 2.b1: Caller is not an active member of the Workspace (BR-29; closest real backing: `assertMember`) → 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40. 2.b2: The member returns to the Workspace list (3.4.10).
- 3.a1: Workspace has no Package, Campaign, or Task yet (BR-04) → every counter displays 0. 3.a2: The member continues viewing the dashboard normally.
- Dashboard has not been implemented yet → the screen is unavailable until the feature ships.

## Post-Conditions

- No data is changed; the Workspace summary counters are displayed.

## Out of Scope

- Time-series charts of activity over time (possible later extension).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
