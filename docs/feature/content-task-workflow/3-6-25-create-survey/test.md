# Test Specification — FR 3.6.25: Create Survey

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.25` |
| **Function Name** | Create Survey |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `SurveyServiceImpl.createSurvey()` (42 LOC) |
| **Unit Test File** | `Pending (Unimplemented in current release)` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Create an interactive campaign survey form with single/multi-choice, rating, and open-text questions and a public share link |
| **Preconditions** | Can connect with server; Caller is Manager or Creator in workspace |
| **Overall Status** | **Untested (Pending Implementation)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 0, `Failed`: 0, `Untested`: 19) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `3 valid questions (text, multiple choice, rating)` | 201 Created - surveyId, publicLink | Survey created | **Untested** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `1 text question` | 201 Created - surveyId, publicLink | — | **Untested** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `multiple choice question with 4 options` | 201 Created - surveyId, publicLink | — | **Untested** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `rating question` | 201 Created - surveyId, publicLink | — | **Untested** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `questions with timeSlot 0:10, 15:20, 21:30` | 201 Created - questions ordered by time slot | — | **Untested** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `question without timeSlot` | 201 Created - timeSlot optional | — | **Untested** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `valid questions` | 201 Created - publicLink is unique per survey | — | **Untested** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `valid questions` | 201 Created - task survey reference set | — | **Untested** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `exactly 1 question` | 201 Created - minimum question count | — | **Untested** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `100 questions` | 201 Created - large survey stored | — | **Untested** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `label with 1 char` | 201 Created | — | **Untested** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `label with 500 chars` | 201 Created | — | **Untested** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR of workspace; Task type is not survey | `questions` = `valid questions` | INVALID_TASK_TYPE (400) | — | **Untested** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `empty list` | SURVEY_MUST_HAVE_QUESTIONS (400) | — | **Untested** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `null` | SURVEY_MUST_HAVE_QUESTIONS (400) | — | **Untested** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR of workspace | `taskId` = `non-existent task` | TASK_NOT_FOUND (404) | — | **Untested** |
| `UTCID17` | `A` | Can connect with server; Task type is survey; User is not a member of workspace | `questions` = `valid questions` | WORKSPACE_ACCESS_DENIED (403) | — | **Untested** |
| `UTCID18` | `A` | Can connect with server; Task type is survey; User is CLIENT of workspace | `questions` = `valid questions` | FORBIDDEN (403) | — | **Untested** |
| `UTCID19` | `A` | Can connect with server; User is CREATOR of workspace; Task type is survey | `questions` = `question with unsupported type` | VALIDATION_ERROR (400) | — | **Untested** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.25`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
