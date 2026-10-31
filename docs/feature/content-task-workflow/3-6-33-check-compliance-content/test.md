# Test Specification — FR 3.6.33: Check Compliance Content

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.33` |
| **Function Name** | Check Compliance Content |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AiCaptionService.moderate()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AiCaptionServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Scan post caption and media for community safety, profanity, hate speech, and restricted keywords and return remediation hints |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `clean text and image` | 200 OK - violations [] | Badge: passed moderation | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `text with hate speech` | 200 OK - violation type=hate_speech, excerpt, severity, suggestion | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `image with violence` | 200 OK - violation type=violence | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `image with obscene content` | 200 OK - violation type=obscene | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Task type is post with content; Moderation service available; User is CLIENT of workspace | `content` = `clean text and image` | 200 OK - violations [] | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `text only, no image` | 200 OK - only text checked | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `image only, no text` | 200 OK - only image checked | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `severe violation` | 200 OK - added to Content Moderation Queue | Moderation queue entry created | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `multiple violations` | 200 OK - violations list with all items | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `1 char text` | 200 OK - violations [] | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `max length text` | 200 OK - violations computed | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `exactly 1 violation` | 200 OK - 1 violation item | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `minor severity only` | 200 OK - not sent to moderation queue | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service down | `content` = `valid content` | COMPLIANCE_SERVICE_UNAVAILABLE (502) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Task type is post with content; Moderation service available | `content` = `empty text and no image` | VALIDATION_ERROR (400) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace; Moderation service available | `taskId` = `task not of type post` | INVALID_TASK_TYPE (400) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR of workspace; Moderation service available | `taskId` = `non-existent task` | TASK_NOT_FOUND (404) | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Task type is post with content; Moderation service available; User is not a member of workspace | `content` = `valid content` | WORKSPACE_ACCESS_DENIED (403) | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Task type is post with content; Moderation service available; User is MANAGER of workspace | `content` = `valid content` | FORBIDDEN (403) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.33`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
