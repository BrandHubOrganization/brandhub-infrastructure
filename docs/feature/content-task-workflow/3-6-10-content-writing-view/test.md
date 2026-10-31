# Test Specification — FR 3.6.10: Content Writing View

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.10` |
| **Function Name** | Content Writing View |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `TaskContentServiceImpl.restoreVersion()` (48 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/TaskContentServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Save rich social post drafts with Unicode font styling, track version history, and restore previous content versions |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 5 operations logged | `workspaceId` = `valid`, `taskId` = `valid`, `snapshotId` = `valid snapshot` | 200 OK - TaskContentResponse(snapshot=old state, ops=[], sequenceNumber=6) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 120 operations logged | `snapshotId` = `valid snapshot` | 200 OK - new snapshot sequenceNumber=121 | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Task type is POST; Snapshot exists for task, 5 operations logged; User is MANAGER of workspace | `snapshotId` = `valid snapshot` | 200 OK - restored state returned | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has 2 snapshots | `snapshotId` = `oldest snapshot` | 200 OK - old yjsState restored, new snapshot appended | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has 2 snapshots | `snapshotId` = `latest snapshot` | 200 OK - same state re-appended as new snapshot | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 5 operations logged | `snapshotId` = `valid snapshot`, `note` = `restore twice` | 200 OK - two new snapshots, history preserved | — | **Passed** |
| `UTCID07` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, no operations logged | `snapshotId` = `valid snapshot` | 200 OK - sequenceNumber=1 | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot exists for task, 1 operation logged | `snapshotId` = `valid snapshot` | 200 OK - sequenceNumber=2 | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot at sequenceNumber 1 | `snapshotId` = `first snapshot` | 200 OK - restored | — | **Passed** |
| `UTCID10` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST | `snapshotId` = `non-existing id` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST; Snapshot belongs to another task | `snapshotId` = `foreign snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST | `snapshotId` = `null` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR of workspace; Task does not exist | `taskId` = `non-existing task`, `snapshotId` = `valid snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace; Task belongs to another workspace | `workspaceId` = `other workspace`, `snapshotId` = `valid snapshot` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Task type is SURVEY | `snapshotId` = `valid snapshot` | 400 INVALID_TASK_TYPE_FOR_CONTENT_WRITING - Content writing only applies to Post tasks | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace; Task type is SURVEY | `snapshotId` = `valid snapshot` | 400 INVALID_TASK_TYPE_FOR_CONTENT_WRITING - Content writing only applies to Post tasks | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR of workspace; Task type is POST; Task has no snapshots | `snapshotId` = `any id` | 404 TASK_NOT_FOUND - Task not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
