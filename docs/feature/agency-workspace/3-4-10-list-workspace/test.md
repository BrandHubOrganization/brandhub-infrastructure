# Test Specification — FR 3.4.12: List Workspace

> Note: This specification maps to official **FR 3.4.12 — List Workspace** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-12-list-workspace/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.12` |
| **Function Name** | List Workspace |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceServiceImpl.listMyWorkspaces()` (32 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List workspaces visible to the caller (all agency workspaces for Owner; assigned workspaces for Manager, Creator, Client) |
| **Preconditions** | Can connect with server; User is authenticated |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User owns agency with 2 workspaces | `currentUser` = `Owner` | 200 - 2 WorkspaceResponse (role OWNER fallback) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active MANAGER in 1 workspace | `currentUser` = `manager user` | 200 - [WorkspaceResponse(myRole=MANAGER)] | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is active CREATOR in 2 workspaces | `currentUser` = `creator user` | 200 - 2 WorkspaceResponse(myRole=CREATOR) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CLIENT via clientProfile in 1 workspace | `currentUser` = `client user` | 200 - [WorkspaceResponse(myRole=CLIENT, clientProfileId set)] | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Owner is also MANAGER member of workspace | `currentUser` = `Owner` | 200 - workspace listed once, myRole=MANAGER (membership wins) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User owns workspace A and is member of B | `currentUser` = `mixed user` | 200 - A and B returned | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User has 2 client profiles in 2 workspaces | `currentUser` = `client user` | 200 - 2 WorkspaceResponse with matching clientProfileId | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Owner has 2 agencies each with workspaces | `currentUser` = `Owner` | 200 - workspaces from both agencies | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User has no workspace | `currentUser` = `new user` | 200 - empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User owns agency with 0 workspaces | `currentUser` = `Owner` | 200 - empty list | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is member of exactly 1 workspace | `currentUser` = `creator user` | 200 - list size 1 | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User has client profile without workspace membership | `currentUser` = `client user` | 200 - empty list | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Owned agency is SOFT_DELETED | `currentUser` = `Owner` | 200 - its workspaces not included | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; One workspace is SOFT_DELETED | `currentUser` = `creator user` | 200 - deleted workspace filtered out | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace membership isActive=false | `currentUser` = `creator user` | 200 - inactive membership workspace excluded | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Client membership isActive=false | `currentUser` = `client user` | 200 - workspace excluded | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Request without valid token | `currentUser` = `null` | 401 UNAUTHORIZED - authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
