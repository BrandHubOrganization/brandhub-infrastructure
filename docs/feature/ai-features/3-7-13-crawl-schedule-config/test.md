# Test Specification — FR 3.7.13: Crawl Schedule Config

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.13` |
| **Function Name** | Crawl Schedule Config |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Admin, Owner` |
| **Target Class & Method** | `AdminCrawlConfigService.update()` (32 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminCrawlConfigServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Update cron schedule, target sources, industry keywords, and batch limits for the background AI Trend Crawler |
| **Preconditions** | Can connect with server; Caller is Admin or Owner |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is ADMIN | `method` = `GET` | 200 - {schedule, sourcePages, postsPerRun} | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is ADMIN | `schedule` = `0 */6 * * *` | 200 - updated config with new cron | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is ADMIN | `schedule` = `interval 30m` | 200 - updated config with interval | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is ADMIN | `sourcePages` = `2 pages` | 200 - updated sourcePages | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is ADMIN | `postsPerRun` = `50` | 200 - updated postsPerRun | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is ADMIN | `schedule` = `0 0 * * *`, `sourcePages` = `1 page`, `postsPerRun` = `20` | 200 - all fields updated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is ADMIN | `schedule` = `null`, `sourcePages` = `null`, `postsPerRun` = `null` | 200 - config unchanged (partial patch) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is ADMIN; Crawler is running | `postsPerRun` = `30` | 200 - applied from next run, running job not stopped | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is ADMIN | `postsPerRun` = `1` | 200 - min postsPerRun accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is ADMIN | `postsPerRun` = `max allowed` | 200 - max postsPerRun accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is ADMIN | `sourcePages` = `1 page` | 200 - single source page | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is ADMIN | `schedule` = `invalid cron` | 400 INVALID_SCHEDULE | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is ADMIN | `schedule` = `empty` | 400 INVALID_SCHEDULE | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is ADMIN | `postsPerRun` = `0` | 400 Validation error (postsPerRun must be >= 1) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is ADMIN | `postsPerRun` = `-5` | 400 Validation error (postsPerRun negative) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is ADMIN | `sourcePages` = `empty list` | 400 Validation error (sourcePages empty) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not ADMIN | `schedule` = `0 */6 * * *` | 403 FORBIDDEN | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is not ADMIN | `method` = `GET` | 403 FORBIDDEN | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
