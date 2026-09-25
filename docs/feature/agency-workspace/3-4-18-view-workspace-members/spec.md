# 3.4.18 View Workspace Members

| | |
|---|---|
| FR Code | 3.4.18 |
| Feature | View Workspace Members |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 2.3 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when a Workspace member opens the members screen of a Workspace.

## Function Description

- **Actors / Roles:** Workspace members with role MANAGER, CREATOR, or CLIENT.
- **Purpose:** Shows who takes part in the Workspace and the role each member holds.
- **Interface:** Workspace members screen at `/workspaces/:id/members`, listing members with their roles.
- **Data Processing:** The system loads the Workspace, confirms the caller is an active member of that same Workspace, then lists every member of the Workspace together with the display name and email of each member's user or client profile.

## Screen Layout

Figure — Workspace Members Screen:
- A table of members with name, email, role, and the date each member joined.
- Role badges for MANAGER, CREATOR, and CLIENT.
- Active members only; members who have left or were removed do not appear.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** The Workspace record; the caller's active membership row; the Workspace's active membership rows; the user records and client profiles those memberships reference.
- **Output:** The list of members — id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive. Role is one of MANAGER, CREATOR, CLIENT — there is no OWNER at Workspace level, since OWNER exists only at Agency level.

### Business Rules

- **BR-29:** Multi-tenancy — the Workspace must exist and carries its own workspaceId scope, checked before the member list is read; otherwise 404 `WORKSPACE_NOT_FOUND`. A caller with no active membership in that Workspace cannot read it regardless of system role (except ADMIN).
- **BR-30:** The caller must be an active member of the very Workspace being viewed, verified explicitly for the requested Workspace; a caller who is not an active member → 403 `WORKSPACE_ACCESS_DENIED`. This is the same re-check that immediately cuts off access once a member is removed or leaves.
- **BR-31:** The role list at Workspace level is MANAGER, CREATOR, CLIENT; OWNER is not a Workspace role (OWNER exists only at Agency level).
- **BR-35:** Role/permission checks re-read the caller's role from the DB at request time via `@RequireRoleAspect`; `SystemRole.ADMIN` bypasses the membership check.

### Validation

- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`, toast MSG38.
- The caller must hold an active membership in that Workspace; otherwise 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40.

## Functionalities

### Normal Flow

1. Member opens `/workspaces/:id/members`.
2. System loads the Workspace; if it does not exist the request fails with 404 `WORKSPACE_NOT_FOUND`.
3. System confirms the caller holds an active membership in that Workspace; otherwise the request fails with 403 `WORKSPACE_ACCESS_DENIED`.
4. System reads the Workspace's active membership rows and resolves the display name and email of each member from the referenced user record or client profile.
5. Screen renders the member table with each member's role and join date.

### Abnormal Cases

- 2.a1: Workspace does not exist (BR-29) → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 2.a2: The member returns to the Workspace list.
- 3.a1: Caller is not an active member of that Workspace (BR-30) → 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40. 3.a2: The member returns to the Workspace list; the Workspace they tried to view does not appear.
- 4.a1: A member has no linked user account but is attached through a client profile → the client profile's display name is shown and the email is empty. 4.a2: The row renders normally with the remaining columns unaffected.

## Post-Conditions

- No data is changed; the Workspace members are displayed.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
