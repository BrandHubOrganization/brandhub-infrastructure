# Test Specification — FR 3.6.11: View Material Repository

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.11` |
| **Function Name** | View Material Repository |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `MaterialReadService.list()` (32 LOC) |
| **Unit Test File** | `brandhub-media-service/src/test/java/com/brandhub/media/service/MaterialReadServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | List and filter workspace creative materials by category (RAW with warning badge, Retouched/Final, Brand Reference), type, and tag |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Workspace has raw and retouched materials | `type` = `raw` | 200 OK - only raw materials with raw warning badge flag | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Workspace has raw and retouched materials | `type` = `retouched` | 200 OK - only retouched materials | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Workspace has raw and retouched materials | `type` = `null (all)` | 200 OK - all materials (id,url,type,uploadedBy,uploadedAt) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Workspace has raw and retouched materials; User is CLIENT of workspace | `type` = `retouched` | 200 OK - retouched materials | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; Brand Collection has 3 items | `tab` = `brand-collection` | 200 OK - items(id,url,uploadedByClientId,note) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CLIENT of workspace; Brand Collection has 3 items | `tab` = `brand-collection` | 200 OK - items(id,url,uploadedByClientId,note) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR of workspace; Workspace has raw and retouched materials | `tab` = `materials` | 200 OK - Brand Collection items not mixed in | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR of workspace; Raw material used in submitted task | `type` = `raw`, `taskId` = `valid task` | 200 OK - raw usage warning shown, submit not blocked | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace; Workspace has no materials | `type` = `raw` | 200 OK - empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR of workspace; Workspace has 1 material | `type` = `null (all)` | 200 OK - list of 1 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR of workspace; Brand Collection is empty | `tab` = `brand-collection` | 200 OK - empty list | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR of workspace; Workspace has only retouched materials | `type` = `raw` | 200 OK - empty list | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace has raw and retouched materials; User is MANAGER of workspace | `type` = `raw` | 403 FORBIDDEN - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace has raw and retouched materials; User is not a member of workspace | `type` = `raw` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Workspace has raw and retouched materials | `type` = `unknown` | 400 VALIDATION_ERROR - Request validation failed | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace; Workspace does not exist | `type` = `raw` | 404 WORKSPACE_NOT_FOUND - Workspace not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Brand Collection has 3 items; User is not a member of workspace | `tab` = `brand-collection` | 403 WORKSPACE_ACCESS_DENIED - You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR of workspace; Material is soft-deleted | `type` = `null (all)` | 404 MATERIAL_NOT_FOUND | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.11`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
