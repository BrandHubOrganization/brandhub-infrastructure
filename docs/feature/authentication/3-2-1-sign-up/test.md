# Test Specification — FR 3.2.1: Sign Up

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.2.1` |
| **Function Name** | Sign Up |
| **Functional Domain** | Authentication |
| **Canonical Actors / Roles** | `Guest` |
| **Target Class & Method** | `AuthServiceImpl.register()` (28 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AuthServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Register a new account with email, password and fullName, store bcrypt password hash, and send a 6-digit OTP email |
| **Preconditions** | Can connect with server; Email not registered |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - RegisterResponse(userId) | OTP email sent to new@brandhub.vn | **Passed** |
| `UTCID02` | `N` | Can connect with server; Email not registered | `email` = `Mixed@BrandHub.VN`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - email stored lowercase and trimmed | OTP email sent | **Passed** |
| `UTCID03` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Tran B` | 201 Created - fullName stored trimmed | OTP email sent | **Passed** |
| `UTCID04` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - password saved as bcrypt hash, not plaintext | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - UserSystemRole USER saved, emailVerifiedAt null | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - OTP expiry set to now + 10 minutes | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | 201 Created - unverified user cannot login until OTP verified | OTP email sent | **Passed** |
| `UTCID08` | `B` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abcdef12`, `fullName` = `Nguyen Van A` | 201 Created - password exactly 8 chars with 1 digit accepted | OTP email sent | **Passed** |
| `UTCID09` | `B` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abcdefg1`, `fullName` = `N` | 201 Created - fullName 1 char accepted | OTP email sent | **Passed** |
| `UTCID10` | `B` | Can connect with server; Email not registered | `email` = `new@brandhub.vn`, `password` = `Abcdef1`, `fullName` = `Nguyen Van A` | VALIDATION_ERROR - Password must be at least 8 characters (7 chars) | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Email already registered | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | EMAIL_ALREADY_EXISTS - 409 This email is already associated with another account | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Email already registered | `email` = `NEW@BrandHub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | EMAIL_ALREADY_EXISTS - case-insensitive duplicate, no new account, no OTP resend | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Email already registered but unverified | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | EMAIL_ALREADY_EXISTS - unverified account not re-registered | — | **Passed** |
| `UTCID14` | `A` | Can connect with server | `email` = `new@brandhub.vn`, `password` = `Abcdefgh`, `fullName` = `Nguyen Van A` | VALIDATION_ERROR - Password must contain at least one number | — | **Passed** |
| `UTCID15` | `A` | Can connect with server | `email` = `not-an-email`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | VALIDATION_ERROR - email invalid format | — | **Passed** |
| `UTCID16` | `A` | Can connect with server | `email` = `null`, `password` = `Abc@12345`, `fullName` = `Nguyen Van A` | VALIDATION_ERROR - email must not be blank | — | **Passed** |
| `UTCID17` | `A` | Can connect with server | `email` = `new@brandhub.vn`, `password` = `null`, `fullName` = `Nguyen Van A` | VALIDATION_ERROR - password must not be blank | — | **Passed** |
| `UTCID18` | `A` | Can connect with server | `email` = `new@brandhub.vn`, `password` = `Abc@12345`, `fullName` = `empty` | VALIDATION_ERROR - fullName must not be blank | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.2.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
