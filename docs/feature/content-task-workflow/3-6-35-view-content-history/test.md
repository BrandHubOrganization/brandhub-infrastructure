# Test Specification — FR 3.6.34: View Content History

> Note: This specification maps to official **FR 3.6.34 — View Content History** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-34-view-content-history/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.34` |
| **Function Name** | View Content History |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `ContentHistoryServiceImpl.getHistory()` (28 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | List historical content versions and previously generated AI assets of a task/workspace for zero-credit reuse |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 0, `Failed`: 0, `Untested`: 17) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `workspaceId` = `valid workspace` | 200 OK - list id, type, createdBy, createdAt, reusedCount | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; Workspace exists; Content history exists in workspace; User is CREATOR of workspace | `workspaceId` = `valid workspace` | 200 OK - list of history | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; Workspace exists; Content history exists in workspace; User is CLIENT of workspace | `workspaceId` = `valid workspace` | 200 OK - list of history | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `filter type` = `IMAGE` | 200 OK - only image items | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `filter createdBy` = `creator A` | 200 OK - only items by creator A | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `action` = `reuse existing AI image` | 200 OK - reusedCount +1, AICreditLedger unchanged | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `action` = `reuse existing content twice` | 200 OK - reusedCount 2, no extra credit | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER of workspace; Workspace exists; Reused content was soft-deleted | `workspaceId` = `valid workspace` | 200 OK - item still listed in history | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists | `history` = `0 items` | 200 OK - data [] | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `history` = `1 item` | 200 OK - 1 item | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `history` = `1000 items` | 200 OK - all or paged list | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `reusedCount` = `0` | 200 OK - reusedCount 0 for never reused | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; Workspace exists; User is not a member of workspace | `workspaceId` = `valid workspace` | FORBIDDEN (403) | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace | `workspaceId` = `non-existent workspace` | WORKSPACE_NOT_FOUND (404) | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `filter type` = `unsupported type` | VALIDATION_ERROR (400) | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace exists; Content history exists in workspace | `action` = `reuse non-existent content` | CONTENT_NOT_FOUND (404) | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace | `workspaceId` = `null` | VALIDATION_ERROR (400) | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.34`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
