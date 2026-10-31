# Test Specification — FR 3.7.15: View Collaborator Directory

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.15` |
| **Function Name** | View Collaborator Directory |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `DirectoryPartnerService.list()` (15 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/DirectoryPartnerServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | List and filter agency third-party collaborators (KOL, KOC, PRESS, AD_CHAN) with pagination and deletion eligibility flags |
| **Preconditions** | Can connect with server; Caller is Owner of active agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | 200 OK - list() returns PartnerPage<DirectoryPartnerResponse> for the agency | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `detail(scope, partnerId)` | 200 OK - detail() returns DirectoryPartnerResponse with parsed contact Map | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(agencyWithUsedPartners, ownerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | 200 OK - Unused partner with usageHistoryVerified=true has canDelete=true, deleteBlockedReason=null | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(agencyWithUsedPartners, ownerUser)`, `filter` = `detail(scope, partnerId)` | 200 OK - Partner linked to campaign or with firstUsedAt!=null has canDelete=false, reason='USED' | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Some partners are linked to campaigns (used) or have usageHistoryVerified=false | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=10, search='Tech', active=null, type=PRESS)` | 200 OK - Partner with usageHistoryVerified=false has canDelete=false, reason='HISTORY_UNVERIFIED' | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Some partners are linked to campaigns (used) or have usageHistoryVerified=false | `scope` = `Scope(agencyWithUsedPartners, ownerUser)`, `filter` = `Filter(page=0, size=10, search='Tech', active=null, type=PRESS)` | 200 OK - Filter by active status, CollaboratorType, and search keyword applied via partners.directory | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | 200 OK - CampaignCollaboratorService.list returns CampaignPartnerContext for workspace members | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `detail(scope, partnerId)` | 200 OK - CampaignCollaboratorService.options returns active collaborator options for workspace | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory has 0 matching collaborators for the filter | `scope` = `Scope(emptyAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=50, search=100-char max)` | 200 OK - Empty agency directory returns PartnerPage with items=[], totalElements=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory has 0 matching collaborators for the filter | `scope` = `Scope(emptyAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=50, search=100-char max)` | 200 OK - Boundary size=1 and size=50 with 100-character search string accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=10, search='Tech', active=null, type=PRESS)` | 200 OK - Page 0 with 1 item returns totalPages=1 | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Filter parameters (page < 0, size < 1 or > 50, search > 100 chars) are invalid | `scope` = `Scope(nonExistentAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | AGENCY_NOT_FOUND - 404 Agency not found or status is not ACTIVE | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Filter parameters (page < 0, size < 1 or > 50, search > 100 chars) are invalid | `scope` = `Scope(ownAgencyId, nonOwnerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | FORBIDDEN - 403 Caller is not the Owner of the agency | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is null, agency is not ACTIVE/not found, or caller is not the Owner | `scope` = `Scope(ownAgencyId, ownerUser)`, `filter` = `Filter(page=0, size=20, search='', active=true, type=KOL)` | UNAUTHORIZED - 401 AuthenticatedUser is null | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(nonExistentAgencyId, ownerUser)`, `filter` = `Filter(page=-1 or size=51)` | VALIDATION_ERROR - 400 page < 0 or size < 1 or size > 50 | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency (DirectoryPartnerService.owner); Agency directory contains ThirdPartyCollaborator records (KOL, KOC, PRESS, AD_CHAN) | `scope` = `Scope(ownAgencyId, nonOwnerUser)`, `filter` = `Filter(search=101 chars)` | VALIDATION_ERROR - 400 search length exceeds 100 characters (or COLLABORATOR_NOT_FOUND on detail) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.15`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
