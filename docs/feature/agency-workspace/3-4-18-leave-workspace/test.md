# Test Specification — FR 3.4.18: Leave Workspace

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.18` |
| **Function Name** | Leave Workspace |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceServiceImpl.leaveWorkspace()` (28 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow a workspace member to leave a workspace while remaining in the agency, blocking if they are the last active Manager |
| **Preconditions** | Can connect with server; Caller is an active workspace member |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR | `workspaceId` = `valid workspace id`, `currentUser` = `CREATOR` | void; membership isActive=false | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active member of workspace; Caller role is CLIENT | `workspaceId` = `valid workspace id`, `currentUser` = `CLIENT` | void; membership isActive=false | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is active member of workspace; Caller role is MANAGER; Another active MANAGER exists | `workspaceId` = `valid workspace id`, `currentUser` = `MANAGER`, `managerCount` = `2` | void; membership isActive=false | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR | `workspaceId` = `valid workspace id` | void; updatedAt set on membership | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR | `workspaceId` = `valid workspace id` | void; membership row kept (soft delete) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR | `workspaceId` = `valid workspace id` | void; agency membership unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is active member of workspace; Caller role is CREATOR; Workspace has other members | `workspaceId` = `valid workspace id` | void; other members unaffected | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller left earlier and was re-added | `workspaceId` = `valid workspace id` | void; new active membership deactivated | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is active member of workspace; Caller role is MANAGER; Another active MANAGER exists | `workspaceId` = `valid workspace id`, `managerCount` = `2` | void; leaves successfully (exactly 2 MANAGER rows) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is active member of workspace; Caller role is MANAGER; Only active MANAGER | `workspaceId` = `valid workspace id`, `managerCount` = `1` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is active member of workspace; Caller role is CREATOR; Caller is last member | `workspaceId` = `valid workspace id` | void; membership isActive=false | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is active member of workspace; Caller role is CREATOR; Only MANAGER is another user | `workspaceId` = `valid workspace id`, `managerCount` = `1` | void; leaves (guard applies to MANAGER only) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is not member of workspace | `workspaceId` = `valid workspace id`, `currentUser` = `non-member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller membership already inactive | `workspaceId` = `valid workspace id`, `currentUser` = `former member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server | `workspaceId` = `non-existent id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is active member of workspace; Caller role is MANAGER; Only active MANAGER | `workspaceId` = `valid workspace id`, `currentUser` = `sole MANAGER` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is member of other workspace only | `workspaceId` = `valid workspace id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller has only CLIENT membership via clientProfile | `workspaceId` = `valid workspace id`, `currentUser` = `client without userId row` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.18`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
