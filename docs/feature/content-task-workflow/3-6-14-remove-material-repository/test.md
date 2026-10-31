# Test Specification — FR 3.6.14: Remove Material Repository

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.14` |
| **Function Name** | Remove Material Repository |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialTrashService.delete()` (28 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialTrashServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Soft-delete a material from the active workspace repository while preserving references in historical posts and tasks |
| **Preconditions** | Can connect with server; Material exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - success=true, data=null | Material soft-deleted | **Passed** |
| `UTCID02` | `N` | Can connect with server; Material exists in workspace; User is CLIENT with permission | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - success=true, data=null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material; Material used in a COMPLETED Task | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - removed, Task reference kept | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material; Material used in an IN_PROGRESS Task | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - removed from Repository | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - material no longer in repository list | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material; Material is a watermarked copy | `workspaceId` = `valid`, `materialId` = `watermarked copy` | 200 OK - copy removed, original untouched | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Material exists in workspace; User is the uploader of the material | `workspaceId` = `valid`, `materialId` = `valid`, `confirm` = `true` | 200 OK - status=deleted | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is the uploader of the material; Workspace has exactly 1 material | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - repository becomes empty | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Material exists in workspace; User is the uploader of the material; Material referenced by many Tasks | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - all Task references kept | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Material exists in workspace; User is the uploader of the material | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - deletedAt set once | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Material exists in workspace; User is not the uploader and has no permission | `workspaceId` = `valid`, `materialId` = `valid` | 403 FORBIDDEN | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is the uploader of the material; Material does not exist | `workspaceId` = `valid`, `materialId` = `non-existent` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is the uploader of the material; Material is already soft-deleted | `workspaceId` = `valid`, `materialId` = `deleted` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace does not exist | `workspaceId` = `non-existent`, `materialId` = `valid` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Material exists in workspace; User is MANAGER without permission | `workspaceId` = `valid`, `materialId` = `valid` | 403 FORBIDDEN | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Material belongs to another workspace | `workspaceId` = `valid`, `materialId` = `other workspace material` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Material exists in workspace; User not authenticated | `workspaceId` = `valid`, `materialId` = `valid` | 401 UNAUTHORIZED | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
