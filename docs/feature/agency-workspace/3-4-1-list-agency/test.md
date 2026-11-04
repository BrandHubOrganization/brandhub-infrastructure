# Test Specification — FR 3.4.1: List Agency

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.1` |
| **Function Name** | List Agency |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AgencyServiceImpl.listMyAgencies()` (18 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List all active agencies where the authenticated user is Owner or an active agency member |
| **Preconditions** | Can connect with server; User is authenticated |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User owns 1 active agency | `currentUser` = `owner user` | 200 - [AgencyResponse(myRole=OWNER)] | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is member of 1 agency | `currentUser` = `member user` | 200 - [AgencyResponse(myRole=role of membership)] | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User owns 1 agency and is member of another | `currentUser` = `mixed user` | 200 - 2 AgencyResponse items | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User owns agency with owner membership row | `currentUser` = `owner user` | 200 - agency listed once (ids deduplicated) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is member with role MANAGER | `currentUser` = `manager user` | 200 - [AgencyResponse(myRole=MANAGER)] | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is member with role CREATOR | `currentUser` = `creator user` | 200 - [AgencyResponse(myRole=CREATOR)] | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User owns 3 agencies | `currentUser` = `owner user` | 200 - 3 AgencyResponse items | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User has no agency and no membership | `currentUser` = `new user` | 200 - empty list | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User owns exactly 1 agency | `currentUser` = `owner user` | 200 - list size 1 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User owns 1 agency, status ACTIVE | `currentUser` = `owner user` | 200 - agency included | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is member of 1 agency only | `currentUser` = `member user` | 200 - list size 1 | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User owns 1 SOFT_DELETED agency only | `currentUser` = `owner user` | 200 - empty list (soft-deleted filtered) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is member of a SOFT_DELETED agency | `currentUser` = `member user` | 200 - deleted agency excluded | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Owned agency soft-deleted, another active | `currentUser` = `owner user` | 200 - only active agency returned | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User has only CLIENT workspace access | `currentUser` = `client user` | 200 - empty list (clients have no agency_members row) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Request without valid token | `currentUser` = `null` | 401 UNAUTHORIZED - authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
