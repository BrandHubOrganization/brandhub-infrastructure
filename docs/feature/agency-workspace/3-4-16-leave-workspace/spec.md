# 3.4.16 Leave Workspace

| | |
|---|---|
| FR Code | 3.4.16 |
| Feature | Leave Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER / CREATOR / CLIENT (any active member leaving their own Workspace) |
| Version | 3.1 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when an active member of a Workspace confirms leaving that Workspace.

## Function Description

- **Actors / Roles:** Any active member of the Workspace — MANAGER, CREATOR, or CLIENT — acting on their own membership only.
- **Purpose:** Lets a member leave a Workspace they no longer take part in while keeping their Agency membership, so they can still join other Workspaces.
- **Interface:** "Leave Workspace" action in Workspace settings or the members screen, shown only to the signed-in user themselves, followed by a confirmation dialog.
- **Data Processing:** The system locates the caller's own active membership in the Workspace and marks it inactive, without touching the caller's Agency membership.

## Screen Layout

Figure — Leave Workspace Dialog:
- A "Leave Workspace" action inside Workspace settings or the members screen, visible only to the signed-in user.
- A confirmation dialog explaining that the member leaves this Workspace but remains in the Agency.
- A blocked state with a clear message when the member is the last MANAGER of the Workspace.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity (taken from the session principal, never from the request).
- **Input optional:** None.
- **System data:** The caller's active membership row in that Workspace; the count of active MANAGERs in the Workspace.
- **Output:** Confirmation that the membership has been deactivated; no other data is returned.

### Business Rules

- **BR-01:** The action applies only to the caller's own membership — no other member can be targeted, and the caller identity always comes from the session principal.
- **BR-02:** Leaving is a soft delete: the caller's membership is marked inactive; the caller's Agency membership is never modified, so they remain in the Agency and in their other Workspaces.
- **BR-03:** A caller without an active membership in that Workspace → 403 `WORKSPACE_ACCESS_DENIED`.
- **BR-04:** Last-MANAGER guard — if the caller is the only active MANAGER of the Workspace, the request is blocked with 409 `LAST_OWNER_CANNOT_BE_REMOVED`; the MANAGER role must be handed over first through FR 3.4.20 Update Workspace Member Role.
- **BR-05:** No role check is applied to the action, because it can only ever affect the caller's own membership.
- **BR-06:** The last-MANAGER guard applies only when the membership being deactivated carries the MANAGER role.

### Validation

- The caller must hold an active membership in that Workspace; otherwise 403 `WORKSPACE_ACCESS_DENIED`.
- The caller must not be the only active MANAGER of the Workspace; otherwise 409 `LAST_OWNER_CANNOT_BE_REMOVED`.

## Functionalities

### Normal Flow

1. Member opens Workspace settings or the members screen and chooses "Leave Workspace".
2. Member confirms in the dialog.
3. System looks up the caller's own active membership in the Workspace; if none exists the request fails with 403 `WORKSPACE_ACCESS_DENIED`.
4. System applies the last-MANAGER guard: members who are not MANAGER pass, and a MANAGER passes when another active MANAGER exists.
5. System marks the membership inactive.
6. The member is taken out of the Workspace back to the Workspace list, while remaining in the Agency and in their other Workspaces.

### Abnormal Cases

- Caller has no active membership in that Workspace → 403 `WORKSPACE_ACCESS_DENIED`.
- Caller is the only active MANAGER of the Workspace → 409 `LAST_OWNER_CANNOT_BE_REMOVED`; another MANAGER must be assigned first through FR 3.4.20 Update Workspace Member Role.
- A CREATOR or CLIENT leaves while other members remain → always allowed; no guard other than the last-MANAGER guard applies.
- The action is invoked twice in a row → the second call finds no active membership and fails with 403 `WORKSPACE_ACCESS_DENIED`.

## Post-Conditions

- The caller's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The caller's Agency membership is untouched; they remain in the Agency and in their other Workspaces.

## Out of Scope

- Automatically choosing a replacement MANAGER when the only MANAGER leaves (the handover must be done beforehand through FR 3.4.20).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
