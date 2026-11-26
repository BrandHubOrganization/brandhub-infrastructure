> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.6.5: Calendar Task View

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.5` |
| **Function Name** | Calendar Task View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `PostServiceImpl.getSchedule()` (42 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Return tasks and scheduled posts grouped by day/week/month in the workspace timezone and support drag-and-drop rescheduling |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 5, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `calendar`, `month` = `2026-09` | 200 OK - tasks with dueDate in 2026-09 | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace | `view` = `calendar`, `month` = `2026-09` | 200 OK - tasks in month | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace | `view` = `calendar`, `month` = `2026-09` | 200 OK - tasks in month (read only) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; No task due in month | `view` = `calendar`, `month` = `2026-01` | 200 OK - empty list | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has dueDate | `taskId` = `valid task`, `dueDate` = `future date` | 200 OK - dueDate updated | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace; Task has dueDate | `taskId` = `valid task`, `dueDate` = `future date` | 200 OK - dueDate updated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has dueDate | `taskId` = `valid task`, `dueDate` = `past date`, `confirm` = `true` | 200 OK - dueDate updated after user confirmation | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task due on last day of month | `view` = `calendar`, `month` = `2026-09` | 200 OK - task on 30th included | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task due on first day of month | `view` = `calendar`, `month` = `2026-09` | 200 OK - task on 1st included | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `calendar`, `month` = `2028-02` | 200 OK - leap month handled, 29th included | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task due on first day of next month | `view` = `calendar`, `month` = `2026-09` | 200 OK - next month task excluded | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks; Task has dueDate | `taskId` = `valid task`, `dueDate` = `same as current dueDate` | 200 OK - dueDate unchanged | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace has tasks; User is CLIENT of workspace; Task has dueDate | `taskId` = `valid task`, `dueDate` = `future date` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `calendar`, `month` = `2026-13` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `view` = `calendar`, `month` = `abc` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `taskId` = `valid task`, `dueDate` = `null` | 400 DATE_REQUIRED - A required date parameter is missing | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `taskId` = `valid task`, `dueDate` = `invalid format` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `taskId` = `non-existing task`, `dueDate` = `future date` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Workspace has tasks; User is not a member of workspace | `view` = `calendar`, `month` = `2026-09` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.6.5`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `GET /api/v1/workspaces/{workspaceId}/tasks · GET /api/v1/workspaces/{workspaceId}/posts/schedule` (`TaskController.getTasks(), PostController.getSchedule()`) returns standardized `ApiResponse` envelopes and accurate `ErrorCode` mappings.
- **Workspace & Audience Isolation:** Verified cross-workspace and unauthorized role requests are rejected (`403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale bundles and `Light` / `Dark` semantic theme contrast across Web and Mobile surfaces.
- **Traceability:** Aligned with [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md).
