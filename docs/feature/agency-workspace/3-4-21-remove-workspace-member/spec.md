# 3.4.21 Remove Workspace Member

| | |
|---|---|
| FR Code | 3.4.21 |
| Feature | Remove Workspace Member |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER |
| Version | 2.3 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when the MANAGER of a Workspace confirms removal of a member from that Workspace.

## Function Description

- **Actors / Roles:** The MANAGER of the Workspace, and only that role.
- **Purpose:** Lets the MANAGER take a member out of the Workspace while the member stays in the Agency and can still join other Workspaces.
- **Interface:** A Remove action per member in the member table at `/workspaces/:id/members`, followed by a confirmation dialog.
- **Data Processing:** The system loads the member, applies the last-MANAGER guard, and marks the membership inactive without touching the member's Agency membership.

## Screen Layout

Figure — Remove Member Dialog:
- A Remove action per member in the table on `/workspaces/:id/members`.
- A confirmation dialog naming the member being removed.
- A blocked state with a clear message when the member is the only active MANAGER of the Workspace.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the member identifier; the caller's authenticated identity.
- **Input optional:** None.
- **System data:** The caller's role in the Workspace; the member record and its role; the count of active MANAGERs in the Workspace.
- **Output:** Confirmation that the membership has been deactivated; no other data is returned.

### Business Rules

- **BR-01:** Only the MANAGER of the Workspace may remove a member; any other caller → 403 `FORBIDDEN`.
- **BR-02:** Removal is a soft delete — the membership is marked inactive and the record is not physically removed.
- **BR-03:** The member's Agency membership is never modified, so the removed member remains in the Agency and in their other Workspaces.
- **BR-04:** The removed member loses access to this Workspace immediately.
- **BR-05:** Last-MANAGER guard — removing a member whose role is MANAGER is blocked with 409 `LAST_OWNER_CANNOT_BE_REMOVED` when that member is the only active MANAGER of the Workspace. The same guard, with the same error code, is shared with FR 3.4.16 Leave Workspace and FR 3.4.20 Update Workspace Member Role.
- **BR-06:** A member that does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- **BR-07:** The error code is named after the owner concept but is applied to the Workspace-level MANAGER context.

### Validation

- Caller must be the MANAGER of that Workspace; otherwise 403 `FORBIDDEN`.
- The member must exist, be active, and belong to that Workspace; otherwise 404 `NOT_FOUND`.
- Removing the only active MANAGER of the Workspace → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/members` and chooses Remove for a member.
2. MANAGER confirms in the dialog.
3. System confirms the caller holds the MANAGER role in that Workspace; otherwise the request fails with 403 `FORBIDDEN`.
4. System loads the member and checks that it exists, is active, and belongs to that Workspace; otherwise the request fails with 404 `NOT_FOUND`.
5. System applies the last-MANAGER guard: members who are not MANAGER pass, and a MANAGER passes only when another active MANAGER exists in the Workspace.
6. System marks the membership inactive; the member disappears from the active member list.
7. The member's Agency membership is untouched — they remain in the Agency and in any other Workspace they take part in.

### Abnormal Cases

- Caller is not the MANAGER of that Workspace → 403 `FORBIDDEN`.
- Member does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- Removing the only active MANAGER of the Workspace → 409 `LAST_OWNER_CANNOT_BE_REMOVED`; another MANAGER must be assigned first.
- The removed member still has Tasks in progress in this Workspace → those Tasks are not automatically unassigned; this behaviour is not yet confirmed for the Workspace scope.

## Post-Conditions

- The member's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The member's Agency membership is untouched; they remain in the Agency and in their other Workspaces.
- The Workspace still has exactly one active MANAGER.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
