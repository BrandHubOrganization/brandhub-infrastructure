# Test Specification — FR 3.6.4: List Task View

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.4` |
| **Function Name** | List Task View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceTaskReader.list()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTaskReaderTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | List workspace tasks in tabular format with pagination, status, assignee, priority, platform, and dueDate sorting |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 5, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `sort` = `dueDate`, `order` = `asc`, `page` = `0`, `size` = `20` | 200 OK - tasks sorted by dueDate asc | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace | `view` = `list`, `sort` = `dueDate`, `order` = `desc`, `page` = `0`, `size` = `20` | 200 OK - tasks sorted by dueDate desc | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace | `view` = `list`, `page` = `0`, `size` = `20` | 200 OK - rows(id,title,type,assigneeName,status,dueDate) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `sort` = `title`, `order` = `asc`, `page` = `0`, `size` = `20` | 200 OK - sorted by title | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `sort` = `status`, `order` = `asc`, `page` = `0`, `size` = `20` | 200 OK - sorted by status | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has no assignee | `view` = `list`, `page` = `0`, `size` = `20` | 200 OK - assigneeName null for backlog task | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; 25 tasks in workspace | `view` = `list`, `page` = `1`, `size` = `20` | 200 OK - second page with 5 tasks | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; 25 tasks in workspace | `view` = `list`, `page` = `0`, `size` = `20` | 200 OK - 20 tasks, totalElements=25 | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Exactly 20 tasks in workspace | `view` = `list`, `page` = `0`, `size` = `20` | 200 OK - 20 tasks, 1 page | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `page` = `0`, `size` = `1` | 200 OK - 1 task | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; 25 tasks in workspace | `view` = `list`, `page` = `99`, `size` = `20` | 200 OK - empty page | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has no tasks | `view` = `list`, `page` = `0`, `size` = `20` | 200 OK - empty list (empty state) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace has tasks; User is not a member of workspace | `view` = `list` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `sort` = `unknownField` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `order` = `sideways` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `page` = `-1`, `size` = `20` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `list`, `page` = `0`, `size` = `0` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Workspace does not exist | `view` = `list` | 404 WORKSPACE_NOT_FOUND - Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
