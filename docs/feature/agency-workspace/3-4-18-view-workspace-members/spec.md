# 3.4.18 View Workspace Members

| | |
|---|---|
| FR Code | 3.4.18 |
| Feature | View Workspace Members |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT |
| Version | 3.0 — 2026-10-02 — split into two independent screens, see V2 note |
| Document status | Implemented |

> V2 (2026-10-02): the single `/workspaces/:id/members` screen previously listed MANAGER/CREATOR/CLIENT together with a tab switcher. It is now two fully independent routes sharing the same backend list (`GET /api/v1/workspaces/{id}/members`, unchanged — still returns every role): `/workspaces/:id/members` (internal staff — MANAGER/CREATOR only, filtered client-side) and `/workspaces/:id/clients` (CLIENT collaborators only, with its own "Add client" entry point — see FR 3.4.7 V2). This spec is written for the internal Members screen; CLIENT-specific behavior (the Client list, invite lookup) lives in FR 3.4.7.

## Function Trigger

Begins when a Workspace member opens the Members screen (internal staff) or the Clients screen (CLIENT collaborators) of a Workspace.

## Function Description

- **Actors / Roles:** Workspace members with role MANAGER or CREATOR see the Members screen; Owner/Manager also see the separate Clients screen to manage CLIENT collaborators.
- **Purpose:** Shows who takes part in the Workspace and the role each member holds — internal staff and collaborating clients are kept in two separate lists so each audience sees only what's relevant to them.
- **Interface:** Members screen at `/workspaces/:id/members`, listing MANAGER/CREATOR members with their roles. A separate Clients screen at `/workspaces/:id/clients` lists active CLIENT members (see FR 3.3.3/3.4.7 for its full behavior).
- **Data Processing:** The system loads the Workspace, confirms the caller is an active member of that same Workspace, then lists every active member of the Workspace together with the display name and email of each member's user or client profile. Both screens call the same `GET /api/v1/workspaces/{id}/members` endpoint and filter by role client-side (`role !== "CLIENT"` for Members, `role === "CLIENT"` for Clients) — the backend does not distinguish the two screens.

## Screen Layout

Figure — Workspace Members Screen (`/workspaces/:id/members`):
- A table of MANAGER/CREATOR members with name, email, role, and the date each member joined.
- Role badges for MANAGER and CREATOR only — CLIENT rows are filtered out here.
- Active members only; members who have left or were removed do not appear.

Figure — Workspace Clients Screen (`/workspaces/:id/clients`, see FR 3.3.3/3.4.7):
- A table of active CLIENT members — display name (from the linked Client Profile) and join date.
- "Add client" action (Owner/Manager only) opens the Gmail-based invite dialog with the auto-suggest hint described in FR 3.4.7 V2.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** The Workspace record; the caller's active membership row; the Workspace's active membership rows; the user records and client profiles those memberships reference.
- **Output:** The list of members — id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive. Role is one of MANAGER, CREATOR, CLIENT — there is no OWNER at Workspace level, since OWNER exists only at Agency level.

### Business Rules

- **BR-29:** Multi-tenancy — the Workspace must exist and carries its own workspaceId scope, checked before the member list is read; otherwise 404 `WORKSPACE_NOT_FOUND`. A caller with no active membership in that Workspace cannot read it regardless of system role (except ADMIN).
- **BR-30:** The caller must be an active member of the very Workspace being viewed, verified explicitly for the requested Workspace; a caller who is not an active member → 403 `WORKSPACE_ACCESS_DENIED`. This is the same re-check that immediately cuts off access once a member is removed or leaves.
- **BR-31:** The role list at Workspace level is MANAGER, CREATOR, CLIENT; OWNER is not a Workspace role (OWNER exists only at Agency level). The backend list endpoint always returns all three roles together — the Members/Clients screen split (V2) is a presentation-layer filter, not a backend distinction.
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
