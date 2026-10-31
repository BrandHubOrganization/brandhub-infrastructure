# Test Specification — FR 3.5.10: Create Content Request

> Note: This specification maps to official **FR 3.5.10 — Create Content Request** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-5-10-create-content-request/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.10` |
| **Function Name** | Create Content Request |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Client` |
| **Target Class & Method** | `ContentRequestService.create()` (20 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ContentRequestServiceTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Allow Client to create a PENDING ad-hoc content request (title, description, type, dueDate, targetPlatforms) in an active campaign |
| **Preconditions** | Can connect with server; Caller is Client in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 23** (`Passed`: 23, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 11 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID23`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | 201 Created - ContentRequestResponse(status=PENDING) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `SURVEY`, `dueDate` = `future date` | 201 Created - type=SURVEY | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `SURVEY`, `dueDate` = `future date` | 201 Created - type=SURVEY | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `null`, `type` = `POST`, `dueDate` = `future date` | 201 Created - description optional | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `No task check`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | No task created in Mongo at creation | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace; Client already has pending request | `title` = `Second`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | 201 Created - multiple requests allowed | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Trim me`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | 201 Created - title trimmed | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Owner check`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | createdBy = caller; workspaceId from path | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `today` | 201 Created - due today accepted (if allowed) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `1 char`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | 201 Created - minimum title length | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `max length chars`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | 201 Created - maximum title length | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `max length chars`, `type` = `POST`, `dueDate` = `future date` | 201 Created - maximum description length | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `null`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | Validation error: title required | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `empty`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | Validation error: title blank | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `over max length`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | Validation error: title too long | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `null`, `dueDate` = `future date` | Validation error: type required | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `INVALID`, `dueDate` = `future date` | Validation error: type must be POST\|VIDEO\|SURVEY | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `null` | Validation error: dueDate required | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Workspace has Client member; User is CLIENT of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `past date` | Validation error: dueDate must not be in the past | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Workspace has Client member; User is MANAGER of workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Workspace has Client member; User is OWNER of agency | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Workspace has Client member; External Client not in workspace | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID23` | `A` | Can connect with server | `title` = `Promo post`, `description` = `Describe`, `type` = `POST`, `dueDate` = `future date`, `workspaceId` = `non-existent` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
