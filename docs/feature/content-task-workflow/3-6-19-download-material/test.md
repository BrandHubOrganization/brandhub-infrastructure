# Test Specification — FR 3.6.19: Download Material

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.19` |
| **Function Name** | Download Material |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialReadService.download()` (24 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialReadServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Verify workspace membership and generate a pre-signed S3 download URL or stream for a material asset |
| **Preconditions** | Can connect with server; Material exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - binary file stream (original file) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Material exists in workspace; User is CLIENT | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - binary file stream | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Material exists in workspace; User is MANAGER | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - binary file stream | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `watermarked copy` | 200 OK - watermarked file stream | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - Content-Disposition with original filename | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - Content-Type matches file type | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR; Material is in Brand Collection | `workspaceId` = `valid`, `materialId` = `brand collection item` | 200 OK - binary file stream | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR; Material exists in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - original not watermarked by default | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR; Material is 0 bytes | `workspaceId` = `valid`, `materialId` = `empty file` | 200 OK - empty stream | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR; Material at max upload size | `workspaceId` = `valid`, `materialId` = `max size file` | 200 OK - full stream | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR; Material is the only one in workspace | `workspaceId` = `valid`, `materialId` = `valid` | 200 OK - binary file stream | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR; Material does not exist | `workspaceId` = `valid`, `materialId` = `non-existent` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR; Material is soft-deleted | `workspaceId` = `valid`, `materialId` = `deleted` | 404 MATERIAL_NOT_FOUND | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Material exists in workspace; User is not a member of workspace | `workspaceId` = `valid`, `materialId` = `valid` | 403 FORBIDDEN | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Material exists in workspace; User not authenticated | `workspaceId` = `valid`, `materialId` = `valid` | 401 UNAUTHORIZED | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR; Workspace does not exist | `workspaceId` = `non-existent`, `materialId` = `valid` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is CREATOR; Stored file missing in storage | `workspaceId` = `valid`, `materialId` = `orphan record` | 404 MATERIAL_NOT_FOUND | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.19`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
