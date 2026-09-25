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

- **BR-35:** `@RequireRoleAspect` re-reads the caller's role from the DB at request time; `SystemRole.ADMIN` bypasses the check. Only MANAGER may remove a member; any other caller → 403 `FORBIDDEN`. This role check runs before any service-level guard.
- **BR-28:** Remove member — only MANAGER may remove (enforced by `@RequireRole({MANAGER})` at the controller); the last remaining active MANAGER cannot be removed/changed away from MANAGER; removal is a soft-delete (`isActive=false`), not a row deletion. The member's Agency membership is never modified, so the removed member remains in the Agency and in their other Workspaces. ⚠ BA conflict (needs team decision): `Section5_Requirement_Appendix.md` BR-28 still says "only OWNER/MANAGER" and "the last remaining OWNER cannot be removed" — stale wording from before OWNER moved to the Agency level; the actual `WorkspaceServiceImpl.removeMember`/`assertNotLastManager` guard is MANAGER-only, with no OWNER role at Workspace level.
- **BR-30:** A removed member loses access immediately (no token revocation needed) because every scoped query re-checks membership.
- **BR-28 (last-MANAGER guard, checked after the lookup, method `assertNotLastManager` in `WorkspaceServiceImpl`):** Removing a member whose role is MANAGER is blocked with 409 `LAST_MANAGER_CANNOT_BE_REMOVED` (`ErrorCode.LAST_MANAGER_CANNOT_BE_REMOVED`) when that member is the only active MANAGER of the Workspace. The same guard method is shared with FR 3.4.16 Leave Workspace (`leaveWorkspace`) and FR 3.4.20 Update Workspace Member Role (`updateMemberRole`, BR-83) — all three call `assertNotLastManager`.
- **BR-29:** Multi-tenancy — the member lookup is scoped to the Workspace; a member that does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- Code defines both `LAST_OWNER_CANNOT_BE_REMOVED` (409) and `LAST_MANAGER_CANNOT_BE_REMOVED` (409) in `ErrorCode.java`; `removeMember`'s actual guard throws `LAST_MANAGER_CANNOT_BE_REMOVED` — `LAST_OWNER_CANNOT_BE_REMOVED` is not used by this path.

### Validation

- Caller must be the MANAGER of that Workspace; otherwise 403 `FORBIDDEN` (BR-35). Toast MSG39.
- The member must exist, be active, and belong to that Workspace (BR-29); otherwise 404 `NOT_FOUND`. Toast MSG38.
- Removing the only active MANAGER of the Workspace (BR-28) → 409 `LAST_MANAGER_CANNOT_BE_REMOVED`. Toast MSG37.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/members` and chooses Remove for a member.
2. MANAGER confirms in the dialog.
3. System confirms the caller holds the MANAGER role in that Workspace (BR-35); otherwise the request fails with 403 `FORBIDDEN`.
4. System loads the member and checks that it exists, is active, and belongs to that Workspace (BR-29); otherwise the request fails with 404 `NOT_FOUND`.
5. System applies the last-MANAGER guard (BR-28): members who are not MANAGER pass, and a MANAGER passes only when another active MANAGER exists in the Workspace.
6. System marks the membership inactive (BR-28, BR-30); the member disappears from the active member list; toast MSG36.
7. The member's Agency membership is untouched — they remain in the Agency and in any other Workspace they take part in.

### Abnormal Cases

- 3.a1: Caller is not the MANAGER of that Workspace (BR-35) → 403 `FORBIDDEN`, toast MSG39. 3.a2: The screen blocks the action; the caller cannot remove members without the MANAGER role.
- 4.a1: Member does not exist, is not active, or belongs to another Workspace (BR-29) → 404 `NOT_FOUND`, toast MSG38. 4.a2: The screen refreshes the member list, since the target row no longer applies.
- 5.a1: Removing the only active MANAGER of the Workspace (BR-28) → 409 `LAST_MANAGER_CANNOT_BE_REMOVED`, toast MSG37. 5.a2: The MANAGER assigns another member as MANAGER first, then retries the removal.
- The removed member still has Tasks in progress in this Workspace → those Tasks are not automatically unassigned; this behaviour is not yet confirmed for the Workspace scope.

## Post-Conditions

- The member's membership in the Workspace is inactive and the Workspace no longer appears in their list.
- The member's Agency membership is untouched; they remain in the Agency and in their other Workspaces.
- The Workspace still has exactly one active MANAGER.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
