# Test Specification — FR 3.6.12: Add Material Repository

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.12` |
| **Function Name** | Add Material Repository |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialServiceImpl.uploadMaterial()` (52 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Upload image, video, or brand asset files to S3 and register metadata and category (RAW, Retouched, Brand Reference) in workspace |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace | `file` = `valid jpg image`, `type` = `raw` | 201 Created - MaterialResponse(id,url,type=raw) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace | `file` = `valid png image`, `type` = `retouched` | 201 Created - MaterialResponse(type=retouched) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace | `file` = `valid mp4 video`, `type` = `raw` | 201 Created - MaterialResponse(type=raw) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CLIENT of workspace | `file` = `valid jpg image`, `endpoint` = `brand-collection` | 201 Created - saved into Brand Collection | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; File with same name already exists | `file` = `same name as existing`, `type` = `raw` | 201 Created - new record, auto-renamed, old kept | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace | `type` = `raw`, `files` = `3 valid images` | 201 Created - 3 MaterialResponse records | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR of workspace | `file` = `valid jpg image`, `type` = `retouched` | 201 Created - material appears in list immediately | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR of workspace | `file` = `size = max allowed`, `type` = `raw` | 201 Created - MaterialResponse | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace | `file` = `size = max allowed + 1 byte`, `type` = `raw` | 400 FILE_TOO_LARGE - File exceeds the maximum allowed size | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR of workspace | `file` = `1 byte image`, `type` = `raw` | 201 Created - MaterialResponse | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR of workspace | `file` = `0 bytes`, `type` = `raw` | 400 NO_FILE_PROVIDED - No file was provided | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `pdf document`, `type` = `raw` | 400 INVALID_FILE_TYPE - File type is not allowed | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `exe file`, `type` = `raw` | 400 INVALID_FILE_TYPE - File type is not allowed | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `null`, `type` = `raw` | 400 NO_FILE_PROVIDED - No file was provided | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `valid jpg image`, `type` = `null` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `valid jpg image`, `type` = `unknown` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER of workspace | `file` = `valid jpg image`, `type` = `raw` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is not a member of workspace | `file` = `valid jpg image`, `type` = `raw` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is CREATOR of workspace | `file` = `unreadable stream`, `type` = `raw` | 400 FILE_READ_ERROR - Failed to read uploaded file | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
