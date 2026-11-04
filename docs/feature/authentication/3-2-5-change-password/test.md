# Test Specification — FR 3.2.5: Change Password

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.5` |
| **Function Name** | Change Password |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `AuthServiceImpl.changePassword()` (25 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Verify current password, reject identical new password, update bcrypt password hash, and invalidate other active sessions |
| **Preconditions** | Can connect with server; User authenticated with password hash |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 2, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | 200 OK - password hash updated | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | 200 OK - lastPasswordChange set, older refresh tokens invalid | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | 200 OK - new hash is bcrypt, differs from old hash | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User has password hash; User has 2FA enabled | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | 200 OK - password changed, 2FA unchanged | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `Brand#Hub2026long` | 200 OK - long password with symbols accepted | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `oldpass123` | 200 OK - differs by case so treated as different | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `OldPass124` | 200 OK - differs by one char accepted | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | 200 OK - password saved via applyPassword with new timestamp | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `Abcdef12` | 200 OK - new password exactly 8 chars accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `Abcdef1` | VALIDATION_ERROR - Password must be at least 8 characters (7 chars) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `WrongPass9`, `newPassword` = `NewPass456` | WRONG_CURRENT_PASSWORD - 400 Current password is incorrect | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `OldPass123` | SAME_AS_CURRENT_PASSWORD - 400 New password must be different from current password | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `Abcdefgh` | VALIDATION_ERROR - Password must contain at least one number | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `empty`, `newPassword` = `NewPass456` | VALIDATION_ERROR - currentPassword must not be blank | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User has password hash | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `empty` | VALIDATION_ERROR - newPassword must not be blank | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User deleted after token issued | `accessToken` = `valid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | USER_NOT_FOUND - 404 User not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server | `accessToken` = `expired/invalid JWT`, `currentPassword` = `OldPass123`, `newPassword` = `NewPass456` | JwtException - token parse fails, 401 TOKEN_INVALID | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
