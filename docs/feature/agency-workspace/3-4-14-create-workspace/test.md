# Test Specification — FR 3.4.14: Create Workspace

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.14` |
| **Function Name** | Create Workspace |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceServiceImpl.createWorkspace()` (68 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to create a workspace with required Manager assignment, IANA timezone configuration, and initial members |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 22** (`Passed`: 22, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID22`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | WorkspaceResponse(name=Acme Studio); creator saved as MANAGER | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `industry` = `MARKETING`, `companySize` = `18568.0`, `website` = `https://acme.vn`, `phone` = `901234567.0`, `location` = `HCMC` | WorkspaceResponse with extended profile fields | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `brandColor` = `#FF5500`, `logoIcon` = `star`, `tagline` = `We grow brands`, `foundedYear` = `2015.0` | WorkspaceResponse with brand fields | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `facebookUrl` = `valid url`, `linkedinUrl` = `valid url`, `instagramUrl` = `valid url` | WorkspaceResponse with social links | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=B role=CREATOR` | WorkspaceResponse; member B added as CREATOR; creator stays MANAGER | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=B role=MANAGER` | WorkspaceResponse; creator demoted to CREATOR, B is MANAGER | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `2 entries, 1 other user role=MANAGER` | WorkspaceResponse; exactly 1 MANAGER in workspace | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `industryFields` = `[tech, retail]` | WorkspaceResponse; industryFields saved in settings | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `1 char` | WorkspaceResponse(name length 1) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `max length name` | WorkspaceResponse(name at max length) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `empty list` | WorkspaceResponse; only creator as MANAGER | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `null` | WorkspaceResponse; only creator as MANAGER | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `foundedYear` = `boundary year 1900` | WorkspaceResponse(foundedYear=1900) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is not member of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER (not OWNER) of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `non-existent agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is OWNER of agency; Assignee is not agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=outsider role=CREATOR` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is OWNER of agency; Assignee is agency member; Assignee user row missing | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=ghost` | USER_NOT_FOUND | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `2 entries both role=MANAGER, different users` | MANAGER_ALREADY_ASSIGNED: second MANAGER rejected | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `null` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `empty` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `null`, `name` = `Acme Studio` | VALIDATION_ERROR: agencyId required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
