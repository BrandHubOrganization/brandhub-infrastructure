# 3.4.15 Delete Workspace

| | |
|---|---|
| FR Code | 3.4.15 |
| Feature | Delete Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency OWNER (proposed — not yet confirmed) |
| Version | 2.2 — 2026-09-23 — rewritten to the standard FR format |
| Document status | **Proposed — not yet implemented** |

## Function Trigger

Begins when an Agency owner confirms deletion of a Workspace. Proposed — not yet implemented.

## Function Description

- **Actors / Roles:** Agency OWNER (proposed — not yet confirmed; the exact role gate is still open).
- **Purpose:** Lets the owner remove a Workspace that is no longer used while keeping it recoverable for 30 days. Proposed — not yet implemented.
- **Interface:** Delete action inside Workspace settings, shown only to the owner, followed by a confirmation dialog that requires typing the Workspace name.
- **Data Processing:** The system marks the Workspace as soft-deleted with the deletion timestamp; every member and Client immediately loses access and all data inside the Workspace becomes inactive without being physically removed. Proposed — not yet implemented.

## Screen Layout

Figure — Delete Workspace Dialog (proposed — not yet implemented):
- A destructive confirmation dialog opened from Workspace settings, visible to the owner only.
- The dialog requires the user to type the Workspace name before the destructive action is enabled.
- A matching restore entry appears in the list of deleted Workspaces for 30 days.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity; the typed Workspace name confirming the action.
- **Input optional:** None.
- **System data:** The Workspace record with its status and deletion timestamp; the deletion window allowed for restoration.
- **Output:** Confirmation that the Workspace has been soft-deleted; on restore, the restored Workspace profile.

### Business Rules

- **BR-01:** Deletion is a soft delete — the Workspace status becomes SOFT_DELETED and the deletion timestamp is set; the record is not physically removed.
- **BR-02:** Only the Agency OWNER may delete a Workspace — the Workspace MANAGER may not, unlike Update Workspace Profile which the MANAGER may perform.
- **BR-03:** A caller who is not the Agency OWNER, including the Workspace MANAGER → 403 `FORBIDDEN`.
- **BR-04:** Restoring later than 30 days after deletion → 410 `RESTORE_WINDOW_EXPIRED`.
- **BR-05:** Every member and Client of the Workspace immediately loses access once it is deleted.
- **BR-06:** All data inside the Workspace (Task, Campaign, Material and similar) becomes inactive rather than being deleted. *(Proposed — not yet implemented.)*

### Validation

- The typed Workspace name must match the Workspace being deleted before the action is enabled.
- The caller must be the Agency OWNER; otherwise 403 `FORBIDDEN`.
- Restore is allowed only within 30 days of the deletion timestamp; otherwise 410 `RESTORE_WINDOW_EXPIRED`.

## Functionalities

### Normal Flow

1. Owner opens Workspace settings and chooses Delete.
2. Dialog asks the owner to type the Workspace name to confirm.
3. System confirms the caller is the Agency OWNER; otherwise the request fails with 403 `FORBIDDEN`.
4. System marks the Workspace as soft-deleted and records the deletion timestamp.
5. Every member and Client loses access immediately; all data inside the Workspace becomes inactive.
6. The Workspace disappears from active listings and becomes restorable for 30 days.

### Abnormal Cases

- Caller is not the Agency OWNER, even when they manage the Workspace → 403 `FORBIDDEN`.
- Restoring after the 30-day window → 410 `RESTORE_WINDOW_EXPIRED`.
- The Workspace holds Tasks in progress or awaiting Client review when deleted → all become inactive; a restore must bring back exactly their previous statuses rather than resetting them to backlog.
- The feature has not been implemented yet → the delete action is unavailable until it ships.

## Post-Conditions

- The Workspace is marked soft-deleted with a deletion timestamp and is hidden from active listings.
- Every member and Client has lost access, and the Workspace's data is inactive.
- The Workspace remains restorable for 30 days.

## Out of Scope

- Immediate permanent deletion (only soft deletion is in scope).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
