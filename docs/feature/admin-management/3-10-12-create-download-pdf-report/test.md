# Test Specification — FR 3.10.14: Export Report File PDF

> Note: This specification maps to official **FR 3.10.14 — Export Report File PDF** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-14-export-report-file-pdf/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.14` |
| **Function Name** | Export Report File PDF |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminReportService.create()` (40 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminReportServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Render a REVENUE, USER, or PLATFORM PDF report for a date range, store with 24h SHA-256 token link, or reject if NO_DATA_IN_RANGE |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `create(actor, request)` | 200 OK - create() renders REVENUE PDF via AdminReportPdf and returns AdminReportExportResponse | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `download(actor, id, validToken)` | 200 OK - create() renders USER PDF with user status, role, and strike summary rows | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(USER, from, to, 'UTC')`, `downloadCall` = `create(actor, request)` | 200 OK - create() renders PLATFORM PDF with platform-wide KPI and registration metrics | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(USER, from, to, 'UTC')`, `downloadCall` = `download(actor, id, validToken)` | 200 OK - Only SHA-256 hash of download token is stored in admin_report_exports (24h expiresAt) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Exported PDF is stored in admin_report_exports with SHA-256 token hash and 24h TTL | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `purgeExpired() TTL cleanup` | 200 OK - download(actor, id, validToken) verifies constant-time SHA-256 and returns Download(fileName, pdfBytes) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Exported PDF is stored in admin_report_exports with SHA-256 token hash and 24h TTL | `request` = `AdminReportRequest(USER, from, to, 'UTC')`, `downloadCall` = `purgeExpired() TTL cleanup` | 200 OK - AdminAudit records EXPORT on ADMIN_REPORT with reportType, rowCount, fileName, expiresAt | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `create(actor, request)` | 200 OK - purgeExpired() sets content=null on expired rows while keeping metadata audit trail | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `download(actor, id, validToken)` | 200 OK - Blank timezone defaults to 'Asia/Ho_Chi_Minh' and fileName formatted as BrandHub_Report_<type>_<dates>.pdf | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Period is a single day (from == to) with 1 row or timezone is blank (defaults to Asia/Ho_Chi_Minh) | `request` = `AdminReportRequest(PLATFORM, from, to, null)`, `downloadCall` = `single-day boundary report (1 row)` | 200 OK - Single-day period (from == to) with 1 data row exports valid PDF at boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Period is a single day (from == to) with 1 row or timezone is blank (defaults to Asia/Ho_Chi_Minh) | `request` = `AdminReportRequest(PLATFORM, from, to, null)`, `downloadCall` = `single-day boundary report (1 row)` | 200 OK - Large dataset capped at MAX_ROWS=5000 rows in PDF table section | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `purgeExpired() TTL cleanup` | 200 OK - Download right before 24-hour expiresAt boundary returns PDF bytes | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has 0 rows (NO_DATA_IN_RANGE), token is invalid, or 24h download link expired | `request` = `empty-data date range (0 rows)`, `downloadCall` = `create(actor, request)` | NO_DATA_IN_RANGE - 400 Selected period has 0 rows (raises error instead of empty PDF) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has 0 rows (NO_DATA_IN_RANGE), token is invalid, or 24h download link expired | `request` = `invalid date range (from > to)`, `downloadCall` = `create(actor, request)` | INVALID_REQUEST - 400 Start date is after end date or timezone is invalid | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller does not have ADMIN system role | `request` = `AdminReportRequest(REVENUE, from, to, 'Asia/Ho_Chi_Minh')`, `downloadCall` = `create(actor, request)` | FORBIDDEN - 403 Caller does not have ADMIN system role | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `empty-data date range (0 rows)`, `downloadCall` = `download with wrong/null token` | REPORT_NOT_FOUND - 404 Report ID does not exist or download token SHA-256 mismatches | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role (AdminAccountService.requireAdmin); Selected period has non-zero rows for reportType (REVENUE, USER, or PLATFORM) | `request` = `invalid date range (from > to)`, `downloadCall` = `download after 24h expiry or after purgeExpired` | REPORT_LINK_EXPIRED - 410 Report download link has expired (>24h) or content was purged | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
