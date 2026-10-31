# Test Specification — FR 3.3.1: View User Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.3.1` |
| **Function Name** | View User Profile |
| **Functional Domain** | Profile |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `UserServiceImpl.getUserProfile()` (32 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/UserServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Return the authenticated user's profile including identity, role, timezone, language preferences, and 2FA status |
| **Preconditions** | Can connect with server; User exists |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 4, `Abnormal (A)`: 3 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User exists | `currentUser` = `valid user id` | 200 OK - UserProfileResponse with fullName, email, phone | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User exists; Preferences JSON contains timezone | `currentUser` = `valid user id` | 200 OK - timezone read from preferences | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User exists; Preferences JSON contains notificationPreferences | `currentUser` = `valid user id` | 200 OK - notificationPreferences map returned | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User exists; Skills and portfolioUrls stored as JSON | `currentUser` = `valid user id` | 200 OK - skills and portfolioUrls parsed to lists | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User exists; Avatar and banner uploaded | `currentUser` = `valid user id` | 200 OK - avatarUrl and bannerUrl returned | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User exists; User has system role ADMIN | `currentUser` = `valid user id` | 200 OK - role included in response | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User exists; User in workspace as MANAGER | `currentUser` = `valid user id` | 200 OK - workspace role/permissions included | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User exists; Social URLs set | `currentUser` = `valid user id` | 200 OK - linkedin/facebook/instagram/tiktok URLs returned | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User exists | `currentUser` = `valid user id` | 200 OK - response has no passwordHash or totpSecret | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User exists; Preferences is null | `currentUser` = `valid user id` | 200 OK - default empty preferences, no error | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User exists; Skills JSON is null/empty | `currentUser` = `valid user id` | 200 OK - skills returns empty list | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User exists; Skills JSON malformed | `currentUser` = `valid user id` | 200 OK - parseStringList falls back to empty list | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User exists; New user, all optional fields null | `currentUser` = `valid user id` | 200 OK - optional fields null, no NPE | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User deleted but token still valid | `currentUser` = `unknown user id` | USER_NOT_FOUND - 404 User not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User exists | `currentUser` = `null` | UNAUTHORIZED - 401 Authentication required to access this resource | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Access token expired | `currentUser` = `expired token` | TOKEN_EXPIRED - 401 Authentication token has expired | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.3.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
