# Test Specification — FR 3.6.27: Generate Meeting Link

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.27` |
| **Function Name** | Generate Meeting Link |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MeetingServiceImpl.generateMeetingLink()` (28 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Generate an online meeting room link (Google Meet / Jitsi) for a workspace or task and notify invited workspace members |
| **Preconditions** | Can connect with server; Caller is Manager, Creator, or Client in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 0, `Failed`: 0, `Untested`: 18) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `survey task` | 201 Created - meetingUrl | Meet link created | **Untested** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `post task` | 201 Created - meetingUrl | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `task without meeting link` | 201 Created - meetingUrl attached to task | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `task with existing meeting link` | 201 Created - new meetingUrl replaces old | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `calls` = `2 calls in same session` | 201 Created - new link each time unless session cache | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `valid task` | 201 Created - meetingUrl starts with https://meet.google.com | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `task with assignee` | 201 Created - link saved on task | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `valid task` | 201 Created - Calendar event created via API | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `calls` = `first call for task` | 201 Created - first link generated | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `calls` = `10 consecutive calls` | 201 Created - 10 distinct links | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskTitle` = `1 char` | 201 Created - event title fallback | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskTitle` = `255 chars` | 201 Created - event title accepted | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API down | `taskId` = `valid task` | GOOGLE_MEET_UNAVAILABLE (502) | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `non-existent task` | TASK_NOT_FOUND (404) | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `soft-deleted task` | TASK_NOT_FOUND (404) | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; Task exists in workspace; Google Meet API available; User is not a member of workspace | `taskId` = `valid task` | WORKSPACE_ACCESS_DENIED (403) | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; Task exists in workspace; Google Meet API available; User is CLIENT of workspace | `taskId` = `valid task` | FORBIDDEN (403) | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR of workspace; Task exists in workspace; Google Meet API available | `taskId` = `null` | VALIDATION_ERROR (400) | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.27`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
