# Test Specification — FR 3.2.8: Logout

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.8` |
| **Function Name** | Logout |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `AuthServiceImpl.logout()` (25 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Blacklist current JWT access and refresh tokens in Redis and record LOGOUT audit log entry |
| **Preconditions** | Can connect with server; User logged in with valid tokens |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 2, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - both tokens blacklisted | Audit LOGOUT saved with ip and userAgent | **Passed** |
| `UTCID02` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - blacklisted access token rejected afterwards | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - blacklisted refresh token rejected on /refresh | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `null` | 204 No Content - only access token blacklisted | Audit LOGOUT saved | **Passed** |
| `UTCID05` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `empty` | 204 No Content - blank refresh token ignored | Audit LOGOUT saved | **Passed** |
| `UTCID06` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `blank spaces` | 204 No Content - whitespace refresh token ignored | Audit LOGOUT saved | **Passed** |
| `UTCID07` | `N` | Can connect with server; Access token expired, refresh token valid | `accessToken` = `expired access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - refresh token still blacklisted, no audit log | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - audit row has resourceType USER, resourceId=userId | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Logout called twice | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - idempotent second call | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - ipAddress/userAgent null accepted | Audit LOGOUT saved | **Passed** |
| `UTCID11` | `B` | Can connect with server; Access token expires in 1 second | `accessToken` = `valid access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - blacklisted with minimal TTL | — | **Passed** |
| `UTCID12` | `A` | Can connect with server | `accessToken` = `malformed access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - JwtException swallowed, refresh still blacklisted, no audit | — | **Passed** |
| `UTCID13` | `A` | Can connect with server | `accessToken` = `expired access JWT`, `refreshToken` = `null` | 204 No Content - nothing revoked, no audit (idempotent) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User logged in with valid tokens | `accessToken` = `valid access JWT`, `refreshToken` = `malformed refresh JWT` | 204 No Content - JwtException on refresh ignored, access blacklisted | Audit LOGOUT saved | **Passed** |
| `UTCID15` | `A` | Can connect with server | `accessToken` = `null`, `refreshToken` = `null` | UNAUTHORIZED - 401 no access token supplied, rejected at filter | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Access token signed with wrong key | `accessToken` = `forged access JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - treated as invalid, no audit | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
