> **Navigation:** [← Domain Index](../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# FR 3.4.18 — Leave Workspace

| | |
|---|---|
| FR Code | 3.4.18 |
| Feature | Leave Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Owner, Manager, Creator, Client |
| Version | 3.1 — 2026-09-23 — rewritten to the standard FR format |
| Document status | Implemented |

## Function Trigger

Begins when an active member of a Workspace confirms leaving that Workspace.

## Function Description

- **Actors / Roles:** `Owner, Manager, Creator, Client`.
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

- **BR-29:** Multi-tenancy — the caller identity always comes from the session principal and the action applies only to the caller's own membership row in that workspace; no other member can be targeted.
- **BR-28 / BR-30:** Leaving is a soft delete (`isActive=false`, not a row deletion): the caller's membership is marked inactive; a member who leaves loses access immediately because every scoped query re-checks membership. The caller's Agency membership is never modified, so they remain in the Agency and in their other Workspaces. BR-28's last-manager protection also applies to leaving: a MANAGER cannot leave if they are the last active MANAGER of the Workspace; the MANAGER role must be handed over first through FR 3.4.20 Update workspace member Role.
- **BR-31:** The Workspace role set is OWNER, MANAGER, CREATOR, CLIENT (`MemberRole` enum); at Workspace level only MANAGER, CREATOR, CLIENT are assignable, and the last-MANAGER guard applies only when the membership being deactivated carries the MANAGER role.

### Validation

- The caller must hold an active membership in that Workspace; otherwise 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40.
- The caller must not be the only active MANAGER of the Workspace (BR-28); otherwise 409 `LAST_MANAGER_CANNOT_BE_REMOVED`, toast MSG37.

## Functionalities

### Normal Flow

1. Member opens Workspace settings or the members screen and chooses "Leave Workspace".
2. Member confirms in the dialog.
3. System looks up the caller's own active membership in the Workspace; if none exists the request fails with 403 `WORKSPACE_ACCESS_DENIED`.
4. System applies the last-MANAGER guard (BR-28): members who are not MANAGER pass, and a MANAGER passes when another active MANAGER exists.
5. System marks the membership inactive (BR-28/BR-30 soft delete).
6. The member is taken out of the Workspace back to the Workspace list, while remaining in the Agency and in their other Workspaces; toast MSG36.

### Abnormal Cases

- 3.a1: Caller has no active membership in that Workspace (BR-29) → 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40. 3.a2: The caller returns to the Workspace list; the Workspace they tried to leave does not appear.
- 4.a1: Caller is the only active MANAGER of the Workspace (BR-28) → 409 `LAST_MANAGER_CANNOT_BE_REMOVED`, toast MSG37. 4.a2: Another MANAGER must be assigned first through FR 3.4.20 Update workspace member Role, then the caller retries leaving.
- 4.b1: A CREATOR or CLIENT leaves while other members remain (BR-28 does not apply to non-MANAGER roles) → the request always succeeds. 4.b2: The member is removed from the Workspace and returned to the Workspace list.
- 3.b1: The action is invoked twice in a row → the second call finds no active membership and fails with 403 `WORKSPACE_ACCESS_DENIED`, toast MSG40. 3.b2: The caller is already out of the Workspace, so no further action is needed.

## Post-Conditions

- The caller's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The caller's Agency membership is untouched; they remain in the Agency and in their other Workspaces.

## Out of Scope

- Automatically choosing a replacement MANAGER when the only MANAGER leaves (the handover must be done beforehand through FR 3.4.20).

## References

[01-organization-structure.md](../../../../ba/01-organization-structure.md), [03-agency-workspace-management.md](../../../../ba/03-agency-workspace.md)

## Cross-Platform UI, i18n & Theme Acceptance Criteria

- **Endpoints & Implementation:** `DELETE /api/v1/workspaces/{workspaceId}/leave` (`WorkspaceController.leaveWorkspace()` -> `WorkspaceServiceImpl.leaveWorkspace()`). Allows `Creator` and `Client` members to deactivate their own `WorkspaceMember` record freely, while blocking the sole active `Manager` (`BR-21`, `BR-23`) until a replacement `Manager` is assigned.
- **Internationalization (`vi` / `en`):** All labels, buttons, empty states, and error/confirmation toasts use key-parallel locale entries (`workspace.leave.*`) in both `vi` and `en` bundles — zero hardcoded UI text.
- **Semantic Light/Dark Theme:** Web (`src/pages/workspace/detail.tsx`, `src/pages/workspace/components/LeaveWorkspaceDialog.tsx`, `src/pages/workspace/services/workspaceService.ts`) and Mobile (`src/screens/settings/WorkspaceSettingsScreen.tsx`, `src/services/workspaceService.ts`) surfaces use semantic theme tokens with WCAG-compliant contrast in both Light and Dark modes.
- **Related Documentation:** [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md) · [BA Overview](../../../../ba/README.md) · [Module Specs Index](../../../modules/README.md) · [Test Suite](./test.md).