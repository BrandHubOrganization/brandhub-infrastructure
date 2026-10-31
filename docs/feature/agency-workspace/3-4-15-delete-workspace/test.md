# Test Specification — FR 3.4.17: Delete Workspace

> Note: This specification maps to official **FR 3.4.17 — Delete Workspace** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-17-delete-workspace/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.17` |
| **Function Name** | Delete Workspace |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceServiceImpl.deleteWorkspace()` (26 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to soft-delete a workspace (status=SOFT_DELETED, 30-day retention window) and block member access |
| **Preconditions** | Can connect with server; Caller is Owner of the workspace agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace is ACTIVE | `workspaceId` = `valid workspace id` | void; status=SOFT_DELETED, deletedAt and updatedAt set | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace has tasks in progress | `workspaceId` = `valid workspace id` | void; workspace soft-deleted, tasks untouched (no cascade) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace has many members | `workspaceId` = `valid workspace id` | void; workspace soft-deleted, memberships untouched | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace is ACTIVE | `workspaceId` = `valid workspace id`, `typedName` = `matches workspace name (FE gate)` | void; success toast, redirect to /workspace | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace soft-deleted 1 day ago | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | WorkspaceResponse(status=ACTIVE, deletedAt=null) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace soft-deleted 29 days ago | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | WorkspaceResponse(status=ACTIVE) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace is ACTIVE | `workspaceId` = `valid workspace id` | void; workspace no longer in active listings | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is Owner of workspace agency; Workspace is ACTIVE | `workspaceId` = `valid workspace id` | void; workspace saved once via repository | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is Owner of workspace agency; Workspace soft-deleted exactly 30 days ago | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | WorkspaceResponse(status=ACTIVE) at window edge | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is Owner of workspace agency; Agency has only 1 workspace | `workspaceId` = `valid workspace id` | void; workspace soft-deleted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is Owner of workspace agency; Workspace just created | `workspaceId` = `valid workspace id` | void; workspace soft-deleted | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller is Owner of workspace agency; Workspace soft-deleted 30 days + 1 min ago | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | RESTORE_WINDOW_EXPIRED (410) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is Owner of workspace agency | `workspaceId` = `non-existent id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace exists but agency row missing | `workspaceId` = `valid workspace id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is agency member but not OWNER | `workspaceId` = `valid workspace id` | FORBIDDEN | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is Manager only | `workspaceId` = `valid workspace id` | FORBIDDEN | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is not in agency | `workspaceId` = `valid workspace id` | FORBIDDEN | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller is Owner of workspace agency; Workspace is ACTIVE | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | WORKSPACE_NOT_DELETED: Workspace is not deleted, nothing to restore | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller is not Owner; Workspace soft-deleted | `workspaceId` = `valid workspace id`, `action` = `restoreWorkspace` | FORBIDDEN | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller is Owner of workspace agency | `workspaceId` = `non-existent id`, `action` = `restoreWorkspace` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.17`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
