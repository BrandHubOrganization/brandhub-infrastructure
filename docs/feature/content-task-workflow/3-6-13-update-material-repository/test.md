# Test Specification — FR 3.6.13: Update Material Repository

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.13` |
| **Function Name** | Update Material Repository |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialUpdateService.update()` (36 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialUpdateServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Update material title, tags, description, or transition status from RAW to Retouched after post-processing |
| **Preconditions** | Can connect with server; Material exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `retouched`, `note` = `Final retouch done` | 200 OK - updated material (type=retouched, note) | Material updated | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `raw` | 200 OK - updated material (type=raw, note unchanged) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `note` = `New note only` | 200 OK - updated material (note changed, type unchanged) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `retouched`, `note` = `Done` | 200 OK - file url unchanged | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Material exists in workspace; User is CLIENT with permission | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `retouched` | 200 OK - updated material | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace; Material already used by a Task as raw | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `retouched` | 200 OK - past Task usage history unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - material returned unchanged (empty patch) | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `note` = `empty` | 200 OK - note cleared | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `note` = `max length note` | 200 OK - note saved | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `note` = `max length + 1 chars` | 400 VALIDATION_ERROR (note too long) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Material exists in workspace; User is not the uploader and has no permission | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `retouched` | 403 FORBIDDEN | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is the uploader of the material; Material does not exist | `workspaceId` = `valid`, `materialId` = `non-existent` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is the uploader of the material; Material is soft-deleted | `workspaceId` = `valid`, `materialId` = `deleted` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `type` = `unknown_type` | 400 VALIDATION_ERROR (invalid type) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is the uploader of the material; Workspace does not exist | `workspaceId` = `non-existent`, `materialId` = `valid` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is the uploader of the material; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid`, `file` = `new file` | 400 VALIDATION_ERROR (file cannot be changed) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Material belongs to another workspace | `workspaceId` = `valid`, `materialId` = `other workspace material` | 404 MATERIAL_NOT_FOUND | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
