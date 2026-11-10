# 3.4.15 Delete Workspace

| | |
|---|---|
| FR Code | 3.4.15 |
| Feature | Delete Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | Agency OWNER ⚠ implemented per this reading, not formally confirmed by team |
| Version | 2.4 — 2026-09-25 — resolved cascade-claim BA conflict: no cascade exists, documented as a known gap |
| Document status | **Implemented** |

## Function Trigger

Begins when an Agency owner confirms deletion of a Workspace by opening Workspace settings and typing the Workspace name in the danger-zone confirmation dialog.

## Function Description

- **Actors / Roles:** Agency OWNER. ⚠ Implemented per this spec's Agency-OWNER reading (see `WorkspaceServiceImpl.deleteWorkspace`/`restoreWorkspace`, which use the Agency-OWNER precedent from `AgencyServiceImpl.removeAgency` because `@RequireRole` only knows WorkspaceMember roles, not Agency ownership); confirm with team if this was intended vs a different gate (e.g. workspace MANAGER).
- **Purpose:** Lets the owner remove a Workspace that is no longer used while keeping it recoverable for 30 days.
- **Interface:** A "Danger Zone" block inside Workspace settings (`detail.tsx`), visible only when `canManage` is true, with a Delete button that opens a confirmation dialog requiring the user to type the Workspace name before the destructive action is enabled. **There is currently no Restore entry point in the frontend** — `restoreWorkspace` exists only as a backend endpoint (`POST /api/v1/workspaces/{workspaceId}/restore`); no UI calls it today.
- **Data Processing:** The system marks the Workspace as soft-deleted (`status = SOFT_DELETED`, `deletedAt = now()`); restoring within 30 days reverses this (`status = ACTIVE`, `deletedAt = null`). `deleteWorkspace` only flips the Workspace's own status/timestamp fields — it does not cascade to Task/Campaign/Material records; those remain `ACTIVE` and are not automatically hidden. Access is not revoked mid-session either (BR-26 gates the delete action itself, not ongoing access to already-loaded data). Confirmed no cascade write in code this pass — this is a known gap, not just an unconfirmed claim.

## Screen Layout

Figure — Delete Workspace Dialog:
- A destructive confirmation dialog opened from the Danger Zone in Workspace settings, visible to the owner only (`canManage`).
- The dialog requires the user to type the Workspace name before the destructive action ("Confirm Delete") is enabled; a Cancel button closes it without action.
- On success, a success toast is shown and the user is navigated to `/workspace`; on failure, an error toast is shown from the caught error message.
- ⚠ No restore screen exists in the frontend today — `workspaceService.restoreWorkspace` is defined in the FE service layer but nothing in the UI calls it. The "matching restore entry" described below is backend-only capability, not a shipped screen.

## Function Details

### Data Specifications

- **Input required:** The Workspace identifier; the caller's authenticated identity; the typed Workspace name confirming the action.
- **Input optional:** None.
- **System data:** The Workspace record with its status and deletion timestamp; the deletion window allowed for restoration.
- **Output:** Confirmation that the Workspace has been soft-deleted; on restore, the restored Workspace profile.

### Business Rules

- **BR-26:** Delete workspace is OWNER-only (Section5 appendix: "Delete workspace is `OWNER`-only"; implemented here as Agency OWNER — ⚠ see role-gate flag above). Soft-delete vs hard-delete, and the interaction with an active paid subscription, remain TBD (team decision) — invoices/payments are financial records that are likely not to be hard-deleted; the implemented code only ever soft-deletes.
- A caller who is not the Agency OWNER, including the Workspace MANAGER → 403 `FORBIDDEN` (checked in `WorkspaceServiceImpl.deleteWorkspace`/`restoreWorkspace` against `agency.getOwnerId()`, not via `@RequireRole`).
- Restoring later than 30 days after deletion (`WORKSPACE_RESTORE_WINDOW_DAYS = 30`) → 410 `RESTORE_WINDOW_EXPIRED`.
- Restoring a Workspace whose status is not `SOFT_DELETED` → 400 `WORKSPACE_NOT_DELETED`.
- **Known gap (not yet implemented):** `deleteWorkspace` only sets the Workspace's own `status`/`deletedAt` — there is no cascade write to Task/Campaign/Material records, and no other code path was found that hides them based on the parent Workspace's status. Member/Client access is not revoked mid-session; it is simply that the deleted Workspace no longer appears in `listMyWorkspaces` (soft-deleted rows are still excluded there — see FR 3.4.10's known SOFT_DELETED-filter gap for the caveat on that). If cascading Task/Campaign/Material to inactive is required, it needs new code.

### Validation

- The typed Workspace name must match the Workspace being deleted before the action is enabled (FE-only gate in `detail.tsx`, button `disabled` until `confirmName === name`).
- The caller must be the Agency OWNER (BR-26); otherwise 403 `FORBIDDEN`, toast MSG39.
- The Workspace must exist; otherwise 404 `WORKSPACE_NOT_FOUND`, toast MSG38.
- The caller must belong to the Workspace's Agency; otherwise toast MSG40.
- Restore is allowed only when the Workspace's status is `SOFT_DELETED` (otherwise 400 `WORKSPACE_NOT_DELETED`) and within 30 days of the deletion timestamp (otherwise 410 `RESTORE_WINDOW_EXPIRED`).

## Functionalities

### Normal Flow

1. Owner opens Workspace settings (`detail.tsx`) and chooses Delete in the Danger Zone.
2. Dialog asks the owner to type the Workspace name to confirm; the Confirm Delete button stays disabled until the typed value matches.
3. FE calls `DELETE /api/v1/workspaces/{workspaceId}` (`workspaceService.deleteWorkspace`); System confirms the caller is the Agency OWNER (BR-26); otherwise the request fails with 403 `FORBIDDEN`.
4. System marks the Workspace as soft-deleted (`status = SOFT_DELETED`) and records the deletion timestamp (`deletedAt = now()`).
5. Task/Campaign/Material records inside the Workspace are left as-is (`ACTIVE`) — no cascade occurs; see Known gap under Business Rules.
6. The Workspace disappears from active listings; toast success message shown, user navigated to `/workspace`. It becomes restorable for 30 days via the backend endpoint only (no FE restore screen exists — see Screen Layout flag).

### Abnormal Cases

- 3.a1: Caller is not the Agency OWNER, even when they manage the Workspace (BR-26) → 403 `FORBIDDEN`, toast MSG39. 3.a2: The caller returns to Workspace settings without deleting.
- 3.b1: The Workspace does not exist (already deleted or invalid id) → 404 `WORKSPACE_NOT_FOUND`, toast MSG38. 3.b2: The caller returns to the Workspace list.
- 3.c1: The caller does not belong to this Workspace's Agency → toast MSG40. 3.c2: The caller is returned to their own Workspace list.
- Restoring a Workspace that is not currently soft-deleted → 400 `WORKSPACE_NOT_DELETED`.
- Restoring after the 30-day window → 410 `RESTORE_WINDOW_EXPIRED`.
- The Workspace holds Tasks in progress or awaiting Client review when deleted → their statuses are untouched by delete/restore (no cascade — see Known gap under Business Rules); a restore simply flips the Workspace back to `ACTIVE`.

## Post-Conditions

- The Workspace is marked soft-deleted (`status = SOFT_DELETED`, `deletedAt` set) and is hidden from active listings.
- The Workspace's Task/Campaign/Material records are unaffected (still `ACTIVE`) — no cascade exists today; see Known gap under Business Rules.
- The Workspace remains restorable for 30 days via the backend `restoreWorkspace` endpoint (no FE screen currently exposes this).

## Out of Scope

- Immediate permanent deletion (only soft deletion is in scope).
- A frontend Restore screen/entry point (backend capability exists; not yet surfaced in the UI — flag for product/FE to schedule).

## References

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
