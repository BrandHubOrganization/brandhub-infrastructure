# Test Specification — FR 3.6.8: View Task Filter

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.8` |
| **Function Name** | View Task Filter |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceTaskReader.list()` (44 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTaskReaderTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Filter and search workspace tasks across views by keyword, status, assignee, campaign, platform, priority, tag, and date range |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 5, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `type` = `post` | 200 OK - only POST tasks | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `status` = `in_progress` | 200 OK - only IN_PROGRESS tasks | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `assigneeId` = `valid creator` | 200 OK - only tasks of the assignee | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `dueFrom` = `46266.0`, `dueTo` = `46295.0` | 200 OK - tasks due in range | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `campaignId` = `valid campaign` | 200 OK - only campaign tasks | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace has tasks; User is CREATOR of workspace | `search` = `launch` | 200 OK - tasks whose title/description contains keyword | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Workspace has tasks; User is CLIENT of workspace | `search` = `LAUNCH` | 200 OK - search is case-insensitive | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `type` = `post`, `status` = `in_progress`, `search` = `launch` | 200 OK - AND logic, tasks matching all filters | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | Default valid inputs | 200 OK - all tasks, no filter | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `dueFrom` = `46280.0`, `dueTo` = `46280.0` | 200 OK - single-day range | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `search` = `1 char` | 200 OK - matches | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `search` = `empty` | 200 OK - empty search ignored, all tasks | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `type` = `survey`, `status` = `completed`, `search` = `no match` | 200 OK - empty list | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `dueFrom` = `46295.0` | 200 OK - open-ended range, tasks due on/after date | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `type` = `unknown` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `status` = `unknown` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `dueFrom` = `46295.0`, `dueTo` = `46266.0` | 400 INVALID_DATE_RANGE - Date range is invalid | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has tasks | `assigneeId` = `malformed id` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Workspace has tasks; User is not a member of workspace | `type` = `post` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
