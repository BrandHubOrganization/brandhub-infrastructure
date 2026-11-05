# Test Specification — FR 3.6.6: Gantt Timeline Task View

> Note: This specification maps to official **FR 3.6.6 — Gantt Timeline Task View** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-6-gantt-timeline-task-view/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.6` |
| **Function Name** | Gantt Timeline Task View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskServiceImpl.listGanttTasks()` (36 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Return workspace tasks with startDate, dueDate, completion percentage, and stage dependencies for Gantt timeline rendering |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 0, `Failed`: 0, `Untested`: 17) — `Normal (N)`: 7, `Boundary (B)`: 5, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `gantt` | 200 OK - tasks(id,title,startDate,dueDate,progressPercent) | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace | `view` = `gantt` | 200 OK - timeline tasks | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace | `view` = `gantt` | 200 OK - timeline tasks | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Campaign has 3 tasks | `view` = `gantt`, `campaignId` = `valid campaign` | 200 OK - only 3 campaign tasks | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has startDate and dueDate | `view` = `gantt` | 200 OK - bar from startDate to dueDate | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is IN_PROGRESS | `view` = `gantt` | 200 OK - progressPercent mapped from status | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is COMPLETED | `view` = `gantt` | 200 OK - progressPercent=100 | — | **Untested** |
| `UTCID08` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has no startDate | `view` = `gantt` | 200 OK - milestone (startDate null or = dueDate) | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task status is BACKLOG | `view` = `gantt` | 200 OK - progressPercent=0 | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task startDate equals dueDate | `view` = `gantt` | 200 OK - one-day bar | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has no tasks | `view` = `gantt` | 200 OK - empty list | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Campaign has no tasks | `view` = `gantt`, `campaignId` = `empty campaign` | 200 OK - empty list | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; Workspace has tasks; User is not a member of workspace | `view` = `gantt` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `gantt`, `campaignId` = `non-existing campaign` | 404 CAMPAIGN_NOT_FOUND | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `gantt`, `campaignId` = `malformed id` | 400 VALIDATION_ERROR - Request validation failed | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `gantt`, `campaignId` = `foreign campaign` | 404 CAMPAIGN_NOT_FOUND | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Workspace does not exist | `view` = `gantt` | 404 WORKSPACE_NOT_FOUND - Workspace not found | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
