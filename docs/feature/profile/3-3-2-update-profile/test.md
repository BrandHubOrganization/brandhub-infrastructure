# Test Specification — FR 3.3.2: Update User Profile

> Note: This specification maps to official **FR 3.3.2 — Update User Profile** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-3-2-update-user-profile/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.3.2` |
| **Function Name** | Update User Profile |
| **Functional Domain** | Profile |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client, Admin` |
| **Target Class & Method** | `UserServiceImpl.updateUserProfile()` (42 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/UserServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Update own profile fields (fullName, phone, bio, avatar, timezone/language preferences) while keeping primary email immutable |
| **Preconditions** | Can connect with server; User exists |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 11, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `phone` = `0901234567` | 200 OK - fullName and phone updated, other preferences kept | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User exists; Existing notificationPreferences | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `timezone` = `Asia/Ho_Chi_Minh` | 200 OK - timezone merged, notificationPreferences preserved | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `notificationPreferences` = `{email:true}` | 200 OK - notificationPreferences replaced, timezone preserved | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B` | 200 OK - fullName stored trimmed | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User exists; Existing phone | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `phone` = `null` | 200 OK - null phone leaves old phone unchanged | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `skills` = `[Design, Copywriting]`, `portfolioUrls` = `[https://a.com]` | 200 OK - skills and portfolioUrls saved as JSON | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `professionalTitle` = `Content Lead`, `bio` = `10 years in media` | 200 OK - title and bio saved | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `linkedinUrl` = `https://linkedin.com/in/b`, `website` = `https://b.vn` | 200 OK - social URLs and website saved | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `profileVisibility` = `PUBLIC` | 200 OK - profileVisibility stored in preferences | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `location` = `Ha Noi`, `workingLanguage` = `vi`, `yearsOfExperience` = `5` | 200 OK - location, language, experience saved | — | **Passed** |
| `UTCID11` | `N` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B` | 200 OK - email not in request, email unchanged | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `N` | 200 OK - fullName 1 char accepted | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `yearsOfExperience` = `0` | 200 OK - yearsOfExperience 0 saved | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `skills` = `[] (empty list)` | 200 OK - empty skills list saved as [] | — | **Passed** |
| `UTCID15` | `B` | Can connect with server; User exists; Preferences is null | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `timezone` = `UTC` | 200 OK - new preferences map created | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `empty` | VALIDATION_ERROR - Full name is required | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `null` | VALIDATION_ERROR - Full name is required | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User exists | `currentUser` = `valid user id`, `fullName` = `blank spaces` | VALIDATION_ERROR - Full name is required | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User not found | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B` | USER_NOT_FOUND - 404 User not found | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User exists; Preferences serialization fails | `currentUser` = `valid user id`, `fullName` = `Nguyen Van B`, `timezone` = `UTC` | INVALID_REQUEST - 400 Invalid request format or parameters | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.3.2`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
