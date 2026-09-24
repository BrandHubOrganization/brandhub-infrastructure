# 3.4.20 Update Workspace Member Role

| | |
|---|---|
| FR Code | 3.4.20 |
| Feature | Update Workspace Member Role |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER |
| Version | 3.1 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when the MANAGER of a Workspace changes the role of one of its members.

## Function Description

- **Actors / Roles:** The MANAGER of the Workspace, and only that role.
- **Purpose:** Lets the MANAGER adjust a member's role to match the work actually being done, including handing over the MANAGER role.
- **Interface:** A role selector in the member table at `/workspaces/:id/members`, offering MANAGER, CREATOR, and CLIENT.
- **Data Processing:** The system loads the member, applies the single-MANAGER guards, updates the role, and returns the updated member.

## Screen Layout

Figure — Update Member Role Screen:
- The member table on `/workspaces/:id/members`.
- A role selector per member with the values MANAGER, CREATOR, CLIENT.
- A blocked state with a clear message when the change would leave the Workspace without a MANAGER or would create a second one.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the member identifier; the new role.
- **Input optional:** None.
- **System data:** The caller's role in the Workspace; the member record and its current role; the count of active MANAGERs in the Workspace; the member's user record for building the response.
- **Output:** The updated member — id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive, carrying the new role.

### Business Rules

- **BR-01:** Only the MANAGER of the Workspace may change roles; any other caller → 403 `FORBIDDEN`.
- **BR-02:** A role change affects the current Workspace only — it does not carry over to the same member's roles in other Workspaces of the Agency.
- **BR-03:** Last-MANAGER guard on demotion — if the member is the only active MANAGER of the Workspace and the new role is not MANAGER, the request is blocked with 409 `LAST_OWNER_CANNOT_BE_REMOVED`; another MANAGER must be in place first.
- **BR-04:** Duplicate-MANAGER guard on promotion — if the new role is MANAGER and the member is not currently a MANAGER, the request is blocked with 409 `MANAGER_ALREADY_ASSIGNED` when the Workspace already has another active MANAGER, since a Workspace has exactly one active MANAGER.
- **BR-05:** A member that does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- **BR-06:** The role values at Workspace level are MANAGER, CREATOR, CLIENT; OWNER is not a Workspace role, since OWNER exists only at Agency level.
- **BR-07:** There is no exception for changing one's own role — a MANAGER acting on themselves is subject to the same guards as any other member.

### Validation

- Caller must be the MANAGER of that Workspace; otherwise 403 `FORBIDDEN`.
- The member must exist, be active, and belong to that Workspace; otherwise 404 `NOT_FOUND`.
- The new role must be one of MANAGER, CREATOR, CLIENT.
- Demoting the only active MANAGER → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.
- Promoting to MANAGER while another active MANAGER exists → 409 `MANAGER_ALREADY_ASSIGNED`.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/members` and picks a new role for a member in the role selector.
2. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 `FORBIDDEN`.
3. System loads the member and checks that it exists, is active, and belongs to that Workspace; otherwise the request fails with 404 `NOT_FOUND`.
4. System applies the guards: the last-MANAGER guard when the member is the only active MANAGER and is being demoted, and the duplicate-MANAGER guard when promoting to MANAGER while another active MANAGER exists.
5. System stores the new role on the membership and returns the updated member.
6. Screen refreshes the role shown for that member.

### Abnormal Cases

- Caller is not the MANAGER of that Workspace → 403 `FORBIDDEN`.
- Member does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- Demoting the only active MANAGER to CREATOR or CLIENT → 409 `LAST_OWNER_CANNOT_BE_REMOVED`; the MANAGER role must be handed over first.
- Promoting a member to MANAGER while the Workspace already has an active MANAGER → 409 `MANAGER_ALREADY_ASSIGNED`.
- A MANAGER demotes themselves → allowed when at least one other MANAGER remains in the Workspace; blocked with 409 when they are the only MANAGER, with no exception for self-changes.
- A role change between CREATOR and CLIENT → always allowed, since neither guard triggers unless the old or new role is MANAGER.
- Setting the role to the value it already holds → allowed; no guard blocks a no-op change.

## Post-Conditions

- The member holds the new role in this Workspace only.
- The Workspace still has exactly one active MANAGER.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
