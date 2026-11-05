# Test Specification — FR 3.10.7: Create User

> Note: This specification maps to official **FR 3.10.7 — Create User** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-10-7-create-user/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.7` |
| **Function Name** | Create User |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminUserProvisioningService.create()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminUserProvisioningServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to provision a new user account with unique email, bcrypt password hash, system role, and activation email |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 6, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | 201 Created - (id, email) | Set-password email sent to user | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Nguyen Van A`, `initialPlan` = `PRO` | 201 Created - (id, email), subscription=PRO | Set-password email sent to user | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Nguyen Van A` | 201 Created - (id, email), default plan FREE | Set-password email sent to user | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `Upper@BrandHub.vn`, `fullName` = `Demo Account`, `initialPlan` = `FREE` | 201 Created - (id, email), email stored lowercase | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Ten Co Dau (unicode)`, `initialPlan` = `FREE` | 201 Created - (id, email) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | 201 Created - (id, email), password stored hashed | Temporary password generated | **Passed** |
| `UTCID07` | `B` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `1 char name`, `initialPlan` = `FREE` | 201 Created - (id, email) | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `max length name`, `initialPlan` = `FREE` | 201 Created - (id, email) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `email at 254 chars`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | 201 Created - (id, email) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `email at 255 chars`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Caller does not have ADMIN system role | `email` = `valid unused email`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(FORBIDDEN) - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role; Email already registered | `email` = `existing email`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(EMAIL_ALREADY_EXISTS) - This email is already associated with another account | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role; Email registered but soft-deleted | `email` = `deleted user email`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(EMAIL_ALREADY_EXISTS) - This email is already associated with another account | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller has ADMIN system role | `email` = `null`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role | `email` = `invalid email format`, `fullName` = `Nguyen Van A`, `initialPlan` = `FREE` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role | `email` = `valid unused email`, `fullName` = `empty`, `initialPlan` = `FREE` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller has ADMIN system role; Email not registered | `email` = `valid unused email`, `fullName` = `Nguyen Van A`, `initialPlan` = `UNKNOWN_PLAN` | BusinessException(PLAN_NOT_FOUND) - Plan not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
