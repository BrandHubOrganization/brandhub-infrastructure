# Test Specification — FR 3.4.23: View Workspace Members

> Note: This specification maps to official **FR 3.4.23 — View Workspace Members** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-23-view-workspace-members/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.23` |
| **Function Name** | View Workspace Members |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceServiceImpl.listMembers()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List all active members of a workspace with fullName, email, avatar, workspace role (MANAGER, CREATOR, CLIENT), and joinedAt |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is active member of workspace; Workspace has MANAGER, CREATOR members | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List<WorkspaceMemberResponse> with fullName, email, role | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active member of workspace; Workspace has CLIENT member | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List includes CLIENT row; fullName=client displayName, email=null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is active member of workspace; Workspace has mixed roles | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List contains all 3 roles together | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR | `workspaceId` = `valid workspace id`, `currentUser` = `CREATOR` | List<WorkspaceMemberResponse> | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is CLIENT via clientProfile | `workspaceId` = `valid workspace id`, `currentUser` = `CLIENT` | List<WorkspaceMemberResponse> | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is active member of workspace; Member has left workspace | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List excludes members with isActive=false | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is active member of workspace; Member removed from workspace | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List excludes removed member | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is active member of workspace | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | Each item has id, workspaceId, userId, clientProfileId, role, joinedAt, isActive=true | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is active member of workspace; Caller is only active member | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List with 1 item | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is active member of workspace; Workspace has 100 members | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List with 100 items | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is active member of workspace; Only CLIENT members besides caller | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | List with caller and CLIENT rows | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is active member of workspace; Member userId row missing in users table | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | Item with fullName=null, email=null | — | **Passed** |
| `UTCID13` | `A` | Can connect with server | `workspaceId` = `non-existent id`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server | `workspaceId` = `null`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace is soft-deleted | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is not member of workspace | `workspaceId` = `valid workspace id`, `currentUser` = `non-member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User membership isActive=false (left) | `workspaceId` = `valid workspace id`, `currentUser` = `former member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; CLIENT profile not linked to workspace | `workspaceId` = `valid workspace id`, `currentUser` = `client of other workspace` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.23`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
