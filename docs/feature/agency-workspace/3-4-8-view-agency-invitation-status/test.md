# Test Specification — FR 3.4.8: View Agency Invitation Status

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.8` |
| **Function Name** | View Agency Invitation Status |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `AgencyServiceImpl.listInvitations()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/AgencyServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List agency invitations with effective status (PENDING, ACCEPTED, REVOKED, EXPIRED) and 72-hour expiration timestamps |
| **Preconditions** | Can connect with server; User is Owner or invited user |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 4 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency; Agency has PENDING invitation not expired | `agencyId` = `existing id` | 200 - [AgencyInvitationResponse(status=PENDING)] | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency; Agency has ACCEPTED invitation | `agencyId` = `existing id` | 200 - [AgencyInvitationResponse(status=ACCEPTED)] | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency; Agency has REVOKED invitation | `agencyId` = `existing id` | 200 - [AgencyInvitationResponse(status=REVOKED)] | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency; Agency has PENDING invitation past expiresAt | `agencyId` = `existing id` | 200 - status derived as EXPIRED (DB unchanged) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Invitation has workspaceId | `agencyId` = `existing id` | 200 - response includes workspaceName | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Invitation has no workspaceId | `agencyId` = `existing id` | 200 - workspaceName=null | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is OWNER of agency; Agency has invitations of mixed statuses | `agencyId` = `existing id` | 200 - all invitations returned with their statuses | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is OWNER of agency; Invitation has note and role | `agencyId` = `existing id` | 200 - response includes note and role | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency; Agency has no invitations | `agencyId` = `existing id` | 200 - empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency; Agency has exactly 1 invitation | `agencyId` = `existing id` | 200 - list size 1 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency; Invitation expiresAt just passed | `agencyId` = `existing id` | 200 - status EXPIRED | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is OWNER of agency; Invitation expiresAt just in future | `agencyId` = `existing id` | 200 - status PENDING | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is OWNER of agency; ACCEPTED invitation past expiresAt | `agencyId` = `existing id` | 200 - status stays ACCEPTED (not expired) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Agency does not exist | `agencyId` = `non-existing id` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role MANAGER | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of agency (not owner); Member role CREATOR | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not related to agency | `agencyId` = `existing id` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
