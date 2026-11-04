# Test Specification — FR 3.6.7: Kanban Board Task View

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.7` |
| **Function Name** | Kanban Board Task View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskServiceImpl.getKanbanBoard()` (40 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Group workspace tasks into Kanban columns (by Status, Assignee, or Platform) and validate drag-and-drop status transitions |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 0, `Failed`: 0, `Untested`: 18) — `Normal (N)`: 9, `Boundary (B)`: 2, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `kanban`, `groupBy` = `status` | 200 OK - columns Backlog/Assigned/In Progress/Review/Completed | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `kanban`, `groupBy` = `assignee` | 200 OK - one column per assignee | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `kanban`, `groupBy` = `type` | 200 OK - columns Post/Video/Survey | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `kanban`, `groupBy` = `campaign` | 200 OK - one column per campaign | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace | `view` = `kanban`, `groupBy` = `status` | 200 OK - read only board | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is ASSIGNED | `taskId` = `valid task`, `targetColumn` = `In Progress` | 200 OK - status=IN_PROGRESS | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace; Task status is ASSIGNED, user is assignee | `taskId` = `valid task`, `targetColumn` = `In Progress` | 200 OK - status=IN_PROGRESS | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace; Task in CLIENT_REVIEW | `taskId` = `valid task`, `targetColumn` = `Completed` | 200 OK - client approve, status=COMPLETED | — | **Untested** |
| `UTCID09` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace; Task in CLIENT_REVIEW | `taskId` = `valid task`, `targetColumn` = `Reject` | 200 OK - maps to reject, status=ASSIGNED | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has no tasks | `view` = `kanban`, `groupBy` = `status` | 200 OK - all columns empty | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has no assignee | `view` = `kanban`, `groupBy` = `assignee` | 200 OK - task placed in Unassigned column | — | **Untested** |
| `UTCID12` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is ASSIGNED | `taskId` = `valid task`, `targetColumn` = `Completed` | 409 INVALID_STATUS_TRANSITION | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is BACKLOG | `taskId` = `valid task`, `targetColumn` = `Review` | 409 INVALID_STATUS_TRANSITION | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; Workspace has tasks; User is CLIENT of workspace; Task status is ASSIGNED | `taskId` = `valid task`, `targetColumn` = `In Progress` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; Workspace has tasks; User is CLIENT of workspace; Task in QC_REVIEW | `taskId` = `valid task`, `targetColumn` = `Completed` | 403 WRONG_APPROVAL_STEP | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `kanban`, `groupBy` = `unknown` | 400 VALIDATION_ERROR - Request validation failed | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `taskId` = `non-existing task`, `targetColumn` = `In Progress` | 404 TASK_NOT_FOUND - Task not found | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; Workspace has tasks; User is not a member of workspace | `view` = `kanban`, `groupBy` = `status` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
