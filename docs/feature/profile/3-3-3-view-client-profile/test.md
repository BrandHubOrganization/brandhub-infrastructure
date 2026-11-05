# Test Specification — FR 3.3.3: View Client Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.3.3` |
| **Function Name** | View Client Profile |
| **Functional Domain** | Profile |
| **Canonical Actors / Roles** | `Client, Owner, Manager` |
| **Target Class & Method** | `ClientProfileServiceImpl.listMine()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/ClientProfileServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List and view reusable Client brand profiles owned by the Client or linked to the current agency/workspace |
| **Preconditions** | Can connect with server; Client profile exists |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 4 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User owns 1 client profile | `currentUser` = `valid user id` | 200 OK - list with 1 ClientProfileResponse | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User owns 2 client profiles (Nike, Adidas) | `currentUser` = `valid user id` | 200 OK - list with both profiles, no data mixed | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User owns profiles | `currentUser` = `valid user id` | 200 OK - response has no agencyId and no email | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Profile has socialLinks JSON | `currentUser` = `valid user id` | 200 OK - socialLinks parsed to map | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Profile has brand fields set | `currentUser` = `valid user id` | 200 OK - tagline, foundedYear, budgetRange, taxCode returned | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Other users also have profiles | `currentUser` = `valid user id` | 200 OK - only caller's profiles returned | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User owns profile | `currentUser` = `valid user id`, `profileId` = `own profile id` | 200 OK - getById returns the profile | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Profile linked to workspaces of 2 agencies | `currentUser` = `valid user id` | 200 OK - same single profile listed once | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User has no client profile | `currentUser` = `valid user id` | 200 OK - empty list, not 404 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Profile company/phone/note null | `currentUser` = `valid user id` | 200 OK - null fields returned as null | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Profile socialLinks null | `currentUser` = `valid user id` | 200 OK - socialLinks empty map | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Profile socialLinks malformed JSON | `currentUser` = `valid user id` | 200 OK - parseSocialLinks falls back to empty map | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User owns 50 client profiles | `currentUser` = `valid user id` | 200 OK - all 50 returned | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Profile id does not exist | `currentUser` = `valid user id`, `profileId` = `unknown profile id` | CLIENT_PROFILE_NOT_FOUND - 404 Client profile not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Profile owned by another user | `currentUser` = `valid user id`, `profileId` = `other user's profile id` | CLIENT_PROFILE_NOT_OWNED - 403 This client profile does not belong to you | — | **Passed** |
| `UTCID16` | `A` | Can connect with server | `currentUser` = `null` | UNAUTHORIZED - 401 Authentication required to access this resource | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Access token expired | `currentUser` = `expired token` | TOKEN_EXPIRED - 401 Authentication token has expired | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.3.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
