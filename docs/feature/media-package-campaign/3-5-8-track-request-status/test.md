# Test Specification — FR 3.5.11: Track Request Status

> Note: This specification maps to official **FR 3.5.11 — Track Request Status** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-5-11-track-request-status/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.11` |
| **Function Name** | Track Request Status |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `ContentRequestReviewService.accept()` (48 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ContentRequestReviewServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Transition content request status (PENDING -> IN_PROGRESS -> ACCEPTED/DENIED) and atomically insert a linked task on acceptance |
| **Preconditions** | Can connect with server; Caller is Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 21** (`Passed`: 21, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID21`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status PENDING | `newStatus` = `IN_PROGRESS` | 200 - status=IN_PROGRESS | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status PENDING | `newStatus` = `ACCEPTED` | 200 - ACCEPTED; one backlog task created, campaignId=null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status IN_PROGRESS | `newStatus` = `ACCEPTED` | 200 - ACCEPTED; one backlog task created | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status PENDING | `newStatus` = `DENIED` | 200 - DENIED; no task created | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status IN_PROGRESS | `newStatus` = `DENIED` | 200 - DENIED; no task created | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Content request exists; Status PENDING; User is OWNER of agency | `newStatus` = `IN_PROGRESS` | 200 - Owner (agency manager) transition allowed | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status PENDING | `newStatus` = `ACCEPTED`, `op` = `checkTask` | Task has sourceType=CONTENT_REQUEST, sourceRefId, copied type/dueDate | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace; Status ACCEPTED, task exists | `newStatus` = `ACCEPTED` | Idempotent - no second task created | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Content request exists; User is CLIENT of workspace; Creator of request | `op` = `read` | 200 - request status readable by Client | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; Content request exists; User is MANAGER of workspace | `op` = `list` | 200 - list of workspace requests with status | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Content request exists; User is MANAGER of workspace; Status PENDING | `newStatus` = `PENDING` | REQUEST_STATE_CONFLICT (409); no task created | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Content request exists; User is MANAGER of workspace; Mongo task already exists for sourceRefId | `newStatus` = `ACCEPTED` | Upsert on sourceRefId; still exactly one task | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Content request exists; User is MANAGER of workspace; Status IN_PROGRESS | `newStatus` = `PENDING` | Rejected - cannot move backwards | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Content request exists; User is MANAGER of workspace; Status ACCEPTED | `newStatus` = `PENDING` | Invalid transition: terminal state (409) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Content request exists; User is MANAGER of workspace; Status DENIED | `newStatus` = `IN_PROGRESS` | Invalid transition: terminal state (409) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Content request exists; User is MANAGER of workspace; Status DENIED | `newStatus` = `ACCEPTED` | Invalid transition: terminal state (409) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Content request exists; User is CLIENT of workspace | `newStatus` = `ACCEPTED` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Content request exists; User is MANAGER of workspace | `newStatus` = `INVALID` | Validation error: unknown status | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Content request exists; User is MANAGER of workspace | `newStatus` = `null` | Validation error: status required | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Content request exists; User not a workspace member | `newStatus` = `IN_PROGRESS` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID21` | `A` | Can connect with server | `newStatus` = `IN_PROGRESS`, `requestId` = `non-existent` | REQUEST_NOT_FOUND: Content request not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.11`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
