# Test Specification — FR 3.7.8: View Image Style Template

> Note: This specification maps to official **FR 3.7.8 — View Image Style Template** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-7-8-view-image-style-template/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.8` |
| **Function Name** | View Image Style Template |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `style_presets.list_style_presets()` (24 LOC) |
| **Unit Test File** | `brandhub-ai-service/tests/unit/routers/test_style_presets.py` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Return curated AI image style presets (Studio Product, Vintage, Minimalist, etc.) with preview thumbnails and prompt parameters |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Image style templates exist | `category` = `null` | 200 - TemplateListResponse(total=N, templates) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Image style templates exist | `category` = `fashion` | 200 - only templates of category fashion | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Image style templates exist | `category` = `food` | 200 - only templates of category food | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Image style templates exist | `category` = `beauty` | 200 - only templates of category beauty | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Image style templates exist | `category` = `empty` | 200 - treated as no filter | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Image style templates exist | `category` = `FASHION` | 200 - result per get_template_library category handling | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Image style templates exist; User is CREATOR of workspace | `category` = `null` | 200 - each template has id, name, thumbnail | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Exactly 1 template exists | `category` = `null` | 200 - total=1, single-item list | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Category has 0 templates | `category` = `unknown_cat` | 200 - total=0, empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; 100 templates exist | `category` = `null` | 200 - total=100, all templates returned | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Image style templates exist | `category` = `256 chars` | 200 - empty list | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; No templates configured | `category` = `null` | 200 - total=0, empty list, no error | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Image style templates exist | `category` = `unknown_cat` | 200 - empty list | — | **Passed** |
| `UTCID14` | `A` | Request has invalid internal API key | `category` = `null` | 403 Forbidden | — | **Passed** |
| `UTCID15` | `A` | Request has no internal API key | `category` = `null` | 403 Forbidden (missing key) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Image style templates exist | `template_id` = `unknown id` | 404 Template 'unknown id' not found | — | **Passed** |
| `UTCID17` | `N` | Can connect with server; Image style templates exist | `template_id` = `valid id` | 200 - single PromptTemplate (get_template) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
