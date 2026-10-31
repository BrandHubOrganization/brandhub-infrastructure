# Test Specification — FR 3.5.12: Update Request

> Note: This specification maps to official **FR 3.5.12 — Update Request** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-5-12-update-request/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.12` |
| **Function Name** | Update Request |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Client` |
| **Target Class & Method** | `ContentRequestService.update()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ContentRequestServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Allow the creator Client to update title, description, type, dueDate, or platforms of a PENDING content request with version check |
| **Preconditions** | Can connect with server; Content request is in PENDING status |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 22** (`Passed`: 22, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 11 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID22`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `New title` | 200 - title updated | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `description` = `New desc` | 200 - description updated | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `New title`, `description` = `New desc` | 200 - both fields updated | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `Trim` | 200 - title trimmed | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `description` = `empty` | 200 - description cleared | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `Same title` | 200 - unchanged value accepted | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `Only title` | type, dueDate and status unchanged | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `Touch` | updatedAt refreshed | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `max length chars` | 200 - maximum title length | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `1 char` | 200 - minimum title length | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Content request exists; User is creator Client of request; Status PENDING | `title` = `null`, `description` = `null` | 200 - unchanged fields preserved with updated version | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status IN_PROGRESS | `title` = `New` | REQUEST_NOT_EDITABLE (409) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status ACCEPTED | `title` = `New` | REQUEST_NOT_EDITABLE (409) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status DENIED | `title` = `New` | REQUEST_NOT_EDITABLE (409) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Content request exists; User is creator Client of request; Status CANCELLED | `title` = `New` | REQUEST_NOT_EDITABLE (409) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Content request exists; User is creator Client of request; Manager moved request to IN_PROGRESS concurrently | `title` = `Stale` | REQUEST_NOT_EDITABLE (409) - conditional write fails | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Content request exists; Status PENDING; User is another Client | `title` = `New` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Content request exists; Status PENDING; User is MANAGER of workspace | `title` = `New` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Content request exists; User is creator Client of request | `title` = `over max length` | Validation error: title too long | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Content request exists; User is creator Client of request | `title` = `empty` | Validation error: title blank | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is creator Client of request | `title` = `New`, `requestId` = `non-existent` | REQUEST_NOT_FOUND: Content request not found | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Content request exists; User not a workspace member | `title` = `New` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
