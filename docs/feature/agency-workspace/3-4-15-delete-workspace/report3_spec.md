**3.4.15 Delete Workspace**

**Function Trigger**

Begins when an Agency owner confirms deletion of a Workspace by opening Workspace settings and typing the Workspace name in the danger-zone confirmation dialog.

**Function Description**

- **Actors / Roles**: Agency OWNER.
- **Purpose**: Lets the owner remove a Workspace that is no longer used while keeping it recoverable for 30 days.
- **Interface**: A "Danger Zone" block inside Workspace settings, visible only when the caller can manage, with a Delete button that opens a confirmation dialog requiring the user to type the Workspace name before the destructive action is enabled. There is currently no Restore entry point in the frontend - restore exists only as a backend endpoint.
- **Data Processing**: The system marks the Workspace as soft-deleted (status = SOFT_DELETED, deletedAt = now()); restoring within 30 days reverses this. Deleting only flips the Workspace's own status/timestamp fields - it does not cascade to Task/Campaign/Material records; those remain ACTIVE and are not automatically hidden. Access is not revoked mid-session either.

**Screen Layout**

Figure - Delete Workspace Dialog:

- A destructive confirmation dialog opened from the Danger Zone in Workspace settings, visible to the owner only.
- The dialog requires the user to type the Workspace name before "Confirm Delete" is enabled; a Cancel button closes it without action.
- On success, a success toast is shown and the user is navigated to the Workspace list; on failure, an error toast is shown.
- No restore screen exists in the frontend today - the restore capability is backend-only.

**Function Details**
- **Data Specifications**
    - **Input required**: the Workspace identifier; the caller's authenticated identity; the typed Workspace name confirming the action.
    - **Input optional**: none.
    - **System data**: the Workspace record with its status and deletion timestamp; the deletion window allowed for restoration.
    - **Output**: confirmation that the Workspace has been soft-deleted; on restore, the restored Workspace profile.

- **Business Rules**
    - **BR-26**: Delete workspace is OWNER-only, implemented here as Agency OWNER. Soft-delete vs hard-delete, and the interaction with an active paid subscription, remain TBD - the implemented code only ever soft-deletes.
    - A caller who is not the Agency OWNER, including the Workspace MANAGER -> 403 FORBIDDEN.
    - Restoring later than 30 days after deletion -> 410 RESTORE_WINDOW_EXPIRED.
    - Restoring a Workspace whose status is not SOFT_DELETED -> 400 WORKSPACE_NOT_DELETED.
    - Known gap: deleteWorkspace only sets the Workspace's own status/deletedAt - there is no cascade write to Task/Campaign/Material records. Member/Client access is not revoked mid-session; the deleted Workspace simply no longer appears in the Workspace list. If cascading to inactive is required, it needs new code.

- **Validation**
    - The typed Workspace name must match the Workspace being deleted before the action is enabled.
    - The caller must be the Agency OWNER; otherwise 403 FORBIDDEN, toast **MSG39**.
    - The Workspace must exist; otherwise 404 WORKSPACE_NOT_FOUND, toast **MSG38**.
    - The caller must belong to the Workspace's Agency; otherwise toast **MSG40**.
    - Restore is allowed only when the Workspace's status is SOFT_DELETED and within 30 days of the deletion timestamp.

**Functionalities**
- **Normal Flow**
    1. Owner opens Workspace settings and chooses Delete in the Danger Zone.
    2. Dialog asks the owner to type the Workspace name to confirm; the Confirm Delete button stays disabled until the typed value matches.
    3. System confirms the caller is the Agency OWNER; otherwise the request fails with 403 FORBIDDEN.
    4. System marks the Workspace as soft-deleted and records the deletion timestamp.
    5. Task/Campaign/Material records inside the Workspace are left as-is - no cascade occurs.
    6. The Workspace disappears from active listings; success toast shown, user navigated to the Workspace list. It becomes restorable for 30 days via the backend endpoint only.

- **Abnormal Cases**
    - 3.a1: Caller is not the Agency OWNER, even when they manage the Workspace -> 403 FORBIDDEN, toast **MSG39**. 3.a2: The caller returns to Workspace settings without deleting.
    - 3.b1: The Workspace does not exist -> 404 WORKSPACE_NOT_FOUND, toast **MSG38**. 3.b2: The caller returns to the Workspace list.
    - 3.c1: The caller does not belong to this Workspace's Agency -> toast **MSG40**. 3.c2: The caller is returned to their own Workspace list.
    - Restoring a Workspace that is not currently soft-deleted -> 400 WORKSPACE_NOT_DELETED.
    - Restoring after the 30-day window -> 410 RESTORE_WINDOW_EXPIRED.

**Post-Conditions**

- The Workspace is marked soft-deleted and is hidden from active listings.
- The Workspace's Task/Campaign/Material records are unaffected - no cascade exists today.
- The Workspace remains restorable for 30 days via the backend restore endpoint (no FE screen currently exposes this).
