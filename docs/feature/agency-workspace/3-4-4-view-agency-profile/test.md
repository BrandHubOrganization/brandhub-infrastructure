# Test Specification — FR 3.4.4: View Agency Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.4` |
| **Function Name** | View Agency Profile |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AgencyServiceImpl.getAgency()` (18 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Return agency profile details (name, logo, cover, description, industry, contact info) for members and Clients |
| **Preconditions** | Can connect with server; Agency exists and is active |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=OWNER) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of agency (not owner); Member role MANAGER | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=MANAGER) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of agency (not owner); Member role CREATOR | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=CREATOR) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CLIENT in a workspace of agency | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=null) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Agency has all profile fields | `agencyId` = `existing id` | 200 - AgencyResponse with all fields | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Owner has no agency_members row | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=OWNER fallback) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CLIENT in 2 workspaces of agency | `agencyId` = `existing id` | 200 - AgencyResponse(myRole=null) | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is OWNER of agency; Agency has only mandatory fields | `agencyId` = `existing id` | 200 - AgencyResponse, optional fields null | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of agency (not owner); Member is the only non-owner member | `agencyId` = `existing id` | 200 - AgencyResponse | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User has client profile but no active workspace membership | `agencyId` = `existing id` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User has client profile in another agency only | `agencyId` = `existing id` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User has no client profile and no membership | `agencyId` = `existing id` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Client workspace membership inactive | `agencyId` = `existing id` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Request without valid token | `agencyId` = `existing id`, `currentUser` = `null` | 401 UNAUTHORIZED - authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
