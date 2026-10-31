# Test Specification — FR 3.5.13: Cancel Request

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.13` |
| **Function Name** | Cancel Request |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Client` |
| **Target Class & Method** | `ContentRequestService.cancel()` (18 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ContentRequestServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Allow the creator Client to cancel a PENDING content request into terminal CANCELLED status with optimistic version check |
| **Preconditions** | Can connect with server; Content request is in PENDING status |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid` | 200/204 - status=CANCELLED | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid`, `op` = `checkRecord` | Record retained (no hard delete) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid`, `op` = `checkTask` | No task created or changed | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid`, `op` = `checkTimestamps` | cancelledAt / updatedAt set | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid`, `op` = `list` | Cancelled request still visible in history list | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING, other requests exist | `requestId` = `valid` | Other requests unaffected | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status CANCELLED | `requestId` = `valid` | REQUEST_NOT_CANCELLABLE (409) when already CANCELLED | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `requestId` = `valid`, `op` = `audit` | Cancellation audit entry recorded | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING, due date today | `requestId` = `valid` | 200 - cancel allowed regardless of due date | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Content request exists; User is creator Client of request; Manager moves to IN_PROGRESS concurrently | `requestId` = `valid` | Conditional write: one wins, loser gets REQUEST_NOT_CANCELLABLE | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Content request exists; User is creator Client of request; Just created request | `requestId` = `valid` | 200 - cancel immediately after create | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status IN_PROGRESS | `requestId` = `valid` | REQUEST_NOT_CANCELLABLE (409) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status ACCEPTED | `requestId` = `valid` | REQUEST_NOT_CANCELLABLE (409) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status DENIED | `requestId` = `valid` | REQUEST_NOT_CANCELLABLE (409) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Content request exists; Status PENDING; User is another Client | `requestId` = `valid` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Content request exists; Status PENDING; User is MANAGER of workspace | `requestId` = `valid` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Content request exists; User not a workspace member | `requestId` = `valid` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server | `requestId` = `non-existent` | REQUEST_NOT_FOUND: Content request not found | — | **Passed** |
| `UTCID19` | `A` | Can connect with server | `requestId` = `null` | REQUEST_NOT_FOUND: Content request not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
