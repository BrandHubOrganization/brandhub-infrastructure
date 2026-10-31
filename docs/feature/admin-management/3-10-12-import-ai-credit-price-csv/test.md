# Test Specification — FR 3.10.12: Import AI Credit Price CSV

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.12` |
| **Function Name** | Import AI Credit Price CSV |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `CreditPriceImportService.apply()` (56 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/CreditPriceImportServiceTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Preview and atomically apply bulk AI credit price updates from a CSV file verified by SHA-256 and per-operation expectedRevisions |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid benchmark .csv (3 operations)`, `request` = `preview(actor, file)` | 200 OK - preview() returns Preview(sha256, valid=true, rows, issues=[]) without modifying DB | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid benchmark .csv (3 operations)`, `request` = `apply(actor, file, matching sha256 + revisions)` | 200 OK - Preview Row shows proposal, current state (unitCredits, revision, enabled), and changed flag | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid .csv with unchanged + changed rows`, `request` = `preview(actor, file)` | 200 OK - apply() locks operations in sorted order to prevent cross-import deadlocks | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid .csv with unchanged + changed rows`, `request` = `apply(actor, file, matching sha256 + revisions)` | 200 OK - apply() updates changed prices and returns Applied(updated, unchanged) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; For apply(): request.sha256 matches parsed CSV SHA-256 and expectedRevisions match current DB revisions | `file` = `valid benchmark .csv (3 operations)`, `request` = `apply with unchanged unitCredits row` | 200 OK - Operations whose unitCredits equal current price are placed in unchanged list | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; For apply(): request.sha256 matches parsed CSV SHA-256 and expectedRevisions match current DB revisions | `file` = `valid .csv with unchanged + changed rows`, `request` = `apply with unchanged unitCredits row` | 200 OK - AdminAudit records UPDATE on AI_CREDIT_PRICES with source='BENCHMARK_CSV' and sha256 | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid benchmark .csv (3 operations)`, `request` = `preview(actor, file)` | 200 OK - Existing enabled flag of each operation is preserved during CSV import | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid benchmark .csv (3 operations)`, `request` = `apply(actor, file, matching sha256 + revisions)` | 200 OK - preview() on empty or non-.csv file returns valid=false with FILE_EMPTY / FILE_TYPE issue | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; CSV contains unchanged unitCredits rows alongside updated rows | `file` = `boundary 1-row .csv`, `request` = `apply 1-row CSV at revision=0` | 200 OK - Single-row valid CSV applied at initial revision=0 boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; CSV contains unchanged unitCredits rows alongside updated rows | `file` = `boundary 1-row .csv`, `request` = `apply 1-row CSV at revision=0` | 200 OK - Re-importing CSV with identical prices places all operations in unchanged list | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `valid benchmark .csv (3 operations)`, `request` = `apply with unchanged unitCredits row` | 200 OK - Case-insensitive .CSV filename extension accepted by read() | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; File is empty, non-.csv, >MAX_BYTES, has invalid rows, sha256 mismatch, or stale revision | `file` = `empty / non-.csv / invalid-row file`, `request` = `preview(actor, file)` | CREDIT_PRICE_CSV_INVALID - 400 CSV has validation issues, null request, or mismatched operation set | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; File is empty, non-.csv, >MAX_BYTES, has invalid rows, sha256 mismatch, or stale revision | `file` = `oversized file (> CreditPriceCsv.MAX_BYTES)`, `request` = `preview(actor, file)` | CREDIT_PRICE_CSV_TOO_LARGE - 400 Uploaded CSV exceeds CreditPriceCsv.MAX_BYTES | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ADMIN system role | `file` = `valid benchmark .csv (3 operations)`, `request` = `preview(actor, file)` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `empty / non-.csv / invalid-row file`, `request` = `mismatched sha256 (CSV changed)` | CREDIT_PRICE_CSV_CHANGED - 409 Uploaded file SHA-256 does not match previewed request.sha256 | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (accounts.requireAdmin) and active user status; Uploaded MultipartFile is a valid .csv (<= CreditPriceCsv.MAX_BYTES) with valid operation rows | `file` = `oversized file (> CreditPriceCsv.MAX_BYTES)`, `request` = `stale expectedRevisions or missing operation` | CREDIT_CONFIGURATION_STALE - 409 expectedRevision for an operation does not match current revision | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.12`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
