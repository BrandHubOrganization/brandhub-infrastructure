# Test Specification — FR 3.8.5: Preview Post

> Note: This specification maps to official **FR 3.8.5 — Preview Post** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-5-preview-post/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.5` |
| **Function Name** | Preview Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `PostServiceImpl.get()` (34 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Generate platform-accurate desktop and mobile post preview payload with character limit and aspect-ratio validation for 4 platforms |
| **Preconditions** | Can connect with server; Task or post draft exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type | `taskId` = `valid post task`, `platform` = `facebook` | 200 - previewData for Facebook | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type | `taskId` = `valid post task`, `platform` = `instagram` | 200 - previewData square/4:5 ratio | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type | `taskId` = `valid post task`, `platform` = `tiktok` | 200 - previewData vertical 9:16 | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type | `taskId` = `valid post task`, `platform` = `threads` | 200 - previewData for Threads | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption has hashtags | `taskId` = `valid post task`, `platform` = `instagram` | 200 - hashtags placed per platform format | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type; Task has image media | `taskId` = `valid post task`, `platform` = `facebook` | 200 - image shown with platform aspect ratio | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type; Task has video media | `taskId` = `valid post task`, `platform` = `tiktok` | 200 - video preview rendered | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MEMBER of workspace; Task is post type | `taskId` = `valid post task`, `platform` = `FACEBOOK` | 200 - platform parsed case-insensitively | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption 500 chars | `taskId` = `valid post task`, `platform` = `threads` | 200 - no limit warning | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption 501 chars | `taskId` = `valid post task`, `platform` = `threads` | 200 - preview with over-limit warning, draft still saveable | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption 2200 chars | `taskId` = `valid post task`, `platform` = `instagram` | 200 - no limit warning | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption 2201 chars | `taskId` = `valid post task`, `platform` = `instagram` | 200 - over-limit warning shown | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is MEMBER of workspace; Task is post type; Caption empty | `taskId` = `valid post task`, `platform` = `facebook` | 200 - preview without caption | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of workspace | `taskId` = `valid post task`, `platform` = `myspace` | UNSUPPORTED_PLATFORM: This social platform is not supported | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MEMBER of workspace | `taskId` = `valid post task`, `platform` = `null` | UNSUPPORTED_PLATFORM: This social platform is not supported | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of workspace | `taskId` = `non-existent id`, `platform` = `facebook` | TASK_NOT_FOUND: Task not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MEMBER of workspace; Task is not post type | `taskId` = `non-post task`, `platform` = `facebook` | INVALID_TASK_TYPE: task is not a post | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is not workspace member | `taskId` = `valid post task`, `platform` = `facebook` | FORBIDDEN: access denied | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
