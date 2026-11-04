# Test Specification — FR 3.6.26: View Survey Analysis

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.26` |
| **Function Name** | View Survey Analysis |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `SurveyServiceImpl.getAnalysis()` (36 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Aggregate survey response counts, completion rate, option distributions, and free-text answers for a workspace survey |
| **Preconditions** | Can connect with server; Survey exists in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 0, `Failed`: 0, `Untested`: 18) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MANAGER of workspace; Survey has responses | `taskId` = `survey task` | 200 OK - responseCount, questionBreakdown | — | **Untested** |
| `UTCID02` | `N` | Can connect with server; Survey has responses; User is CREATOR of workspace | `taskId` = `survey task` | 200 OK - responseCount, questionBreakdown | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; User is MANAGER of workspace; Survey has responses | `questionType` = `multiple choice` | 200 OK - option counts for chart | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is MANAGER of workspace; Survey has responses | `questionType` = `text` | 200 OK - list of text answers | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is MANAGER of workspace; Survey has responses | `questionType` = `rating` | 200 OK - rating distribution | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is MANAGER of workspace; Survey has responses | `taskId` = `survey task` | 200 OK - responseCount equals stored responses | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; Survey has responses; User is CREATOR of workspace | `taskId` = `survey task with mixed question types` | 200 OK - one breakdown entry per question | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER of workspace; Survey has no responses | `taskId` = `survey task` | 200 OK - responseCount 0, empty breakdown data | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is MANAGER of workspace; Survey has responses | `responses` = `exactly 1 response` | 200 OK - responseCount 1 | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is MANAGER of workspace; Survey has responses | `responses` = `10000 responses` | 200 OK - aggregated counts correct | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is MANAGER of workspace; Survey has responses | `questionType` = `multiple choice with option never chosen` | 200 OK - option count 0 | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is MANAGER of workspace; Survey has no responses | `questions` = `survey with 0 questions answered` | 200 OK - empty questionBreakdown | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; User is MANAGER of workspace | `taskId` = `non-existent task` | TASK_NOT_FOUND (404) | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace | `taskId` = `task not of type survey` | INVALID_TASK_TYPE (400) | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace | `taskId` = `survey task never created` | SURVEY_NOT_FOUND (404) | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; Survey has responses; User is not a member of workspace | `taskId` = `survey task` | WORKSPACE_ACCESS_DENIED (403) | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; Survey has responses; User is CLIENT of workspace | `taskId` = `survey task` | FORBIDDEN (403) | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; User is MANAGER of workspace | `workspaceId` = `workspace of another agency` | WORKSPACE_ACCESS_DENIED (403) | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.26`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
