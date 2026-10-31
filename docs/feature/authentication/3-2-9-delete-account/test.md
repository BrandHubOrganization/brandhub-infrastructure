# Test Specification — FR 3.2.9: Delete Account

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.9` |
| **Function Name** | Delete Account |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AuthServiceImpl.deactivate()` (48 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Soft-delete own account after password re-authentication, blocking if user is sole Owner of an active agency, and revoke tokens |
| **Preconditions** | Can connect with server; User authenticated, owns no active agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 2, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - status DEACTIVATED | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - access and refresh tokens blacklisted | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; OAuth-only user (no password); Deactivate OTP valid in Redis | `userId` = `authenticated`, `password` = `null`, `otpCode` = `123456`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - status DEACTIVATED, OTP key deleted | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User has password, owns no active agency; User owns only DELETED/inactive agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - not blocked by inactive agency | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User has password, owns no active agency; User is only member of agencies | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - non-owner member can deactivate | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `null` | 204 No Content - absent refresh token skipped without error | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; OAuth-only user (no password) | `userId` = `authenticated` | 200 OK - sendDeactivateOtp stores 10-min OTP and emails it | OTP email sent | **Passed** |
| `UTCID08` | `N` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `malformed JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - JwtException on blacklist ignored, account deactivated | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; OAuth-only user (no password); Deactivate OTP valid in Redis | `userId` = `authenticated`, `password` = `null`, `otpCode` = `000000`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | 204 No Content - OTP with leading zeros accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User has password, owns no active agency; User owns 1 active agency | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | AGENCY_OWNERSHIP_ACTIVE - 409 transfer ownership before deactivating | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `WrongPass9`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | WRONG_CURRENT_PASSWORD - 400 Current password is incorrect | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User has password, owns no active agency | `userId` = `authenticated`, `password` = `null`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | WRONG_CURRENT_PASSWORD - password missing for password account | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; OAuth-only user (no password); No OTP in Redis | `userId` = `authenticated`, `password` = `null`, `otpCode` = `123456`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | OTP_INVALID - 400 Verification code is invalid or has expired | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; OAuth-only user (no password); Deactivate OTP valid in Redis | `userId` = `authenticated`, `password` = `null`, `otpCode` = `999999`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | OTP_INVALID - 400 wrong OTP | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; OAuth-only user (no password); Deactivate OTP valid in Redis | `userId` = `authenticated`, `password` = `null`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | OTP_INVALID - otpCode null | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User not found | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | USER_NOT_FOUND - 404 User not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User has password, owns no active agency; User owns multiple agencies, one ACTIVE | `userId` = `authenticated`, `password` = `Abc@12345`, `otpCode` = `null`, `accessToken` = `valid JWT`, `refreshToken` = `valid refresh JWT` | AGENCY_OWNERSHIP_ACTIVE - 409 any active owned agency blocks | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Account already DEACTIVATED, then login | `password` = `Abc@12345`, `identifier` = `user@brandhub.vn` | ACCOUNT_DEACTIVATED - 403 Account has been deactivated | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.9`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
