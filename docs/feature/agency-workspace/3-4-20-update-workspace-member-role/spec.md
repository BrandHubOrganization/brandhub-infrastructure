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

- **BR-35:** `@RequireRoleAspect` re-reads the caller's role from the DB at request time; `SystemRole.ADMIN` bypasses the check. Only MANAGER may change roles; any other caller → 403 `FORBIDDEN`. This role check runs before any service-level guard.
- **BR-33:** There is an `updateMemberRole` endpoint (`PATCH /{workspaceId}/members/{memberId}/role`) in this codebase for changing an existing member's role without reusing the invite flow — implemented here, not TBD. A role change affects the current Workspace only — it does not carry over to the same member's roles in other Workspaces of the Agency.
- **BR-83:** Last-MANAGER guard on demotion — mirroring BR-28, if the member is the only active MANAGER of the Workspace and the new role is not MANAGER, the request is blocked with 409 `LAST_OWNER_CANNOT_BE_REMOVED`; another MANAGER must be in place first. This guard is checked before the duplicate-MANAGER guard.
- **BR-05 (duplicate-MANAGER guard on promotion, checked second):** If the new role is MANAGER and the member is not currently a MANAGER, the request is blocked with 409 `MANAGER_ALREADY_ASSIGNED` when the Workspace already has another active MANAGER, since a Workspace has exactly one active MANAGER.
- **BR-29:** Multi-tenancy — the member lookup is scoped to the Workspace; a member that does not exist, is not active, or belongs to another Workspace → 404 `NOT_FOUND`.
- **BR-31:** Four workspace roles: OWNER, MANAGER, CREATOR, CLIENT (`MemberRole` enum); OWNER is not assignable at Workspace level here, since these role values are MANAGER, CREATOR, CLIENT.
- **BR-82:** `role` must be one of the enum values; any other value is rejected.
- There is no exception for changing one's own role — a MANAGER acting on themselves is subject to the same guards as any other member.

### Validation

- Caller must be the MANAGER of that Workspace; otherwise 403 `FORBIDDEN` (BR-35). Toast MSG39.
- role empty → Display: MSG02.
- The member must exist, be active, and belong to that Workspace (BR-29); otherwise 404 `NOT_FOUND`. Toast MSG38.
- The new role must be one of MANAGER, CREATOR, CLIENT (BR-31, BR-82); otherwise Display: MSG95.
- Demoting the only active MANAGER (BR-83) → 409 `LAST_OWNER_CANNOT_BE_REMOVED`. Toast MSG96.
- Promoting to MANAGER while another active MANAGER exists (BR-05) → 409 `MANAGER_ALREADY_ASSIGNED`. Display: MSG95.

## Functionalities

### Normal Flow

1. MANAGER opens `/workspaces/:id/members` and picks a new role for a member in the role selector.
2. System confirms the caller holds the MANAGER role in that Workspace (BR-35); otherwise the request fails with 403 `FORBIDDEN`.
3. System loads the member and checks that it exists, is active, and belongs to that Workspace (BR-29); otherwise the request fails with 404 `NOT_FOUND`.
4. System applies the guards in order: the last-MANAGER guard when the member is the only active MANAGER and is being demoted (BR-83), then the duplicate-MANAGER guard when promoting to MANAGER while another active MANAGER exists (BR-05).
5. System stores the new role on the membership and returns the updated member. No dedicated success-toast MSG code exists in the global table for this action (closest is none — gap noted in report; screen simply refreshes silently or reuses a generic confirmation).
6. Screen refreshes the role shown for that member.

### Abnormal Cases

- 2.a1: Caller is not the MANAGER of that Workspace (BR-35) → 403 `FORBIDDEN`, toast MSG39. 2.a2: The screen blocks the action; the caller cannot change roles without the MANAGER role.
- 3.a1: Member does not exist, is not active, or belongs to another Workspace (BR-29) → 404 `NOT_FOUND`, toast MSG38. 3.a2: The screen refreshes the member list, since the target row no longer applies.
- 4.a1: Demoting the only active MANAGER to CREATOR or CLIENT (BR-83) → 409 `LAST_OWNER_CANNOT_BE_REMOVED`, toast MSG96. 4.a2: The MANAGER hands the MANAGER role to another member first, then retries the demotion.
- 4.b1: Promoting a member to MANAGER while the Workspace already has an active MANAGER (BR-05) → 409 `MANAGER_ALREADY_ASSIGNED`, Display: MSG95 (generic role-rejection message; no dedicated MSG code exists for this conflict — see report). 4.b2: The MANAGER demotes the current MANAGER first, or picks a different role.
- A MANAGER demotes themselves → allowed when at least one other MANAGER remains in the Workspace; blocked with 409 `LAST_OWNER_CANNOT_BE_REMOVED` when they are the only MANAGER, with no exception for self-changes.
- A role change between CREATOR and CLIENT → always allowed, since neither guard triggers unless the old or new role is MANAGER.
- Setting the role to the value it already holds → allowed; no guard blocks a no-op change.

## Post-Conditions

- The member holds the new role in this Workspace only.
- The Workspace still has exactly one active MANAGER.

## Out of Scope

- None.

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
