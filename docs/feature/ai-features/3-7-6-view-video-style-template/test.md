# Test Specification — FR 3.7.10: View Video Style Template

> Note: This specification maps to official **FR 3.7.10 — View Video Style Template** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-10-view-video-style-template/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.10` |
| **Function Name** | View Video Style Template |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `AiVideoService.styles()` (24 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AiVideoServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Return curated AI video style and camera-motion templates (Pan, Zoom, Orbit, Cinematic) for short-form social video generation |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 15** (`Passed`: 15, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID15`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Video style templates exist | `category` = `null` | 200 - list of {id, name, previewUrl} | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Video style templates exist | `category` = `anime` | 200 - only anime templates | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Video style templates exist | `category` = `spring` | 200 - only spring templates | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Video style templates exist; User is CREATOR of workspace | `category` = `null` | 200 - list returned to CREATOR | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Video style templates exist; User is MANAGER of workspace | `category` = `null` | 200 - list returned to MANAGER | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Video style templates exist | `category` = `null` | 200 - each item has previewUrl short clip | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Video style templates exist | `category` = `null` | 200 - item id usable as styleTemplateId in generate video | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Exactly 1 template exists | `category` = `null` | 200 - single-item list | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; 100 templates exist | `category` = `null` | 200 - all 100 templates returned | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Template has no preview clip | `category` = `null` | 200 - previewUrl null for that item | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; No templates configured | `category` = `null` | 200 - empty list, no error | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Video style templates exist | `category` = `unknown` | 200 - empty list | — | **Passed** |
| `UTCID13` | `A` | User is not authenticated | `category` = `null` | 401 UNAUTHORIZED | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Video style templates exist; Template is inactive | `category` = `null` | 200 - inactive template excluded | — | **Passed** |
| `UTCID15` | `A` | User has no workspace access | `category` = `null` | 403 FORBIDDEN | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.10`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
