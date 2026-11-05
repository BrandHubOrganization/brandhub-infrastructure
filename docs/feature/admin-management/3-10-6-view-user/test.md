# Test Specification — FR 3.10.6: View User

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.6` |
| **Function Name** | View User |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminAccountQueryService.list()` (28 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminAccountQueryServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | List and filter system users with pagination, keyword search by email or fullName, system role filter, and account status filter |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 4 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `20`, `search` = `null` | 200 OK - data(page of users), page=1, size=20, total | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role; User with email alice@brandhub.vn exists | `page` = `1`, `size` = `20`, `search` = `alice` | 200 OK - data contains matching user | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role; User with fullName Alice exists | `page` = `1`, `size` = `20`, `search` = `Alice` | 200 OK - data contains matching user | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role; 25 users exist | `page` = `2`, `size` = `20`, `search` = `null` | 200 OK - data has 5 users, page=2, total=25 | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role; 25 users exist | `page` = `1`, `size` = `10`, `search` = `null` | 200 OK - data has 10 users, total=25 | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `20`, `search` = `no match text` | 200 OK - data=[], total=0 | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `20`, `search` = `empty` | 200 OK - search ignored, all users returned | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `20`, `search` = `blank spaces` | 200 OK - search ignored, all users returned | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role; No users exist | `page` = `1`, `size` = `20`, `search` = `null` | 200 OK - data=[], total=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role; 25 users exist | `page` = `1`, `size` = `25`, `search` = `null` | 200 OK - data has all 25 users | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has ADMIN system role; 25 users exist | `page` = `3`, `size` = `10`, `search` = `null` | 200 OK - data has last 5 users | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller has ADMIN system role; 25 users exist | `page` = `4`, `size` = `10`, `search` = `null` | 200 OK - data=[] (page beyond last) | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `1`, `search` = `null` | 200 OK - data has exactly 1 user | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `0`, `size` = `20`, `search` = `null` | IllegalArgumentException - Page index must not be less than zero | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `1`, `size` = `0`, `search` = `null` | IllegalArgumentException - Page size must not be less than one | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role; Users exist | `page` = `-1`, `size` = `20`, `search` = `null` | IllegalArgumentException - Page index must not be less than zero | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller does not have ADMIN system role | `page` = `1`, `size` = `20`, `search` = `null` | BusinessException(FORBIDDEN) - Your role does not have permission to perform this action | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
