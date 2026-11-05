# Test Specification — FR 3.4.5: Update Agency Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.5` |
| **Function Name** | Update Agency Profile |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `AgencyServiceImpl.updateAgency()` (36 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to update agency name, description, website, contact info, and logo/banner assets |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `new valid name` | 200 - AgencyResponse(myRole=OWNER) with updated name | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `description` = `new description` | 200 - description updated | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `category` = `valid category`, `companySize` = `valid size` | 200 - category and size updated | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `website` = `https://brandhub.vn`, `phone` = `valid phone`, `location` = `valid location` | 200 - contact fields updated | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `bannerUrl` = `new banner url` | 200 - bannerUrl replaced | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `bannerUrl` = `null` | 200 - existing bannerUrl kept unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `padded name` | 200 - name trimmed | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `brandColor` = `#00AAFF`, `logoIcon` = `icon`, `tagline` = `new tagline` | 200 - branding updated | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `facebookUrl` = `valid url`, `linkedinUrl` = `valid url`, `instagramUrl` = `valid url` | 200 - social links updated | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `1 char name` | 200 - name updated | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `description` = `null`, `logoUrl` = `null` | 200 - logoUrl and description set to null | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `valid name`, `foundedYear` = `1900.0` | 200 - foundedYear updated | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `null` | 400 MethodArgumentNotValidException - name must not be blank | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `existing id`, `name` = `empty` | 400 MethodArgumentNotValidException - name must not be blank | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id`, `name` = `valid name` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of agency (not owner) | `agencyId` = `existing id`, `name` = `valid name` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id`, `name` = `valid name` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
