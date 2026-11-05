# Test Specification — FR 3.7.16: Create Collaborator Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.16` |
| **Function Name** | Create Collaborator Profile |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `DirectoryPartnerService.create()` (8 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/DirectoryPartnerServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Create a new third-party collaborator profile in the agency directory with validated partnerName, partnerType, contactInfo, and notes |
| **Preconditions** | Can connect with server; Caller is Owner of active agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | 201 Created - DirectoryPartnerResponse returned with active=true and version=0 | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='VnExpress', partnerType='PRESS', notes='Tier 1'` | 201 Created - usageHistoryVerified initialized to true, canDelete=true, deleteBlockedReason=null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(secondAgencyId, ownerUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | 201 Created - partnerType (KOL, KOC, PRESS, AD_CHAN) and trimmed partnerName persisted | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(secondAgencyId, ownerUser)`, `payload` = `partnerName='VnExpress', partnerType='PRESS', notes='Tier 1'` | 201 Created - contactInfo serialized to JSON and returned as Map<String, Object> | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; PartnerContactValidation passes for phone, email, website, and social links in contactInfo | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='Ad Network', partnerType='AD_CHAN'` | 201 Created - createdBy set to scope.user().getId() and agencyId set to scope.agencyId() | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; PartnerContactValidation passes for phone, email, website, and social links in contactInfo | `scope` = `Scope(secondAgencyId, ownerUser)`, `payload` = `partnerName='Ad Network', partnerType='AD_CHAN'` | 201 Created - CampaignCollaboratorService.assign links active partner to campaign idempotently | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | 201 Created - Optional notes trimmed and saved on ThirdPartyCollaborator | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='VnExpress', partnerType='PRESS', notes='Tier 1'` | 201 Created - Partner saved and flushed via ThirdPartyCollaboratorRepository.saveAndFlush | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload has minimal required fields (partnerName + partnerType, empty contactInfo/notes) | `scope` = `Scope(boundaryAgencyId, ownerUser)`, `payload` = `minimal payload (partnerType='KOC', notes=null)` | 201 Created - Minimal payload with empty contactInfo and null notes accepted | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload has minimal required fields (partnerName + partnerType, empty contactInfo/notes) | `scope` = `Scope(boundaryAgencyId, ownerUser)`, `payload` = `minimal payload (partnerType='KOC', notes=null)` | 201 Created - Partner name and notes at maximum allowed character length accepted | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='Ad Network', partnerType='AD_CHAN'` | 201 Created - Creating partner with same name in another agency is allowed | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload has unknown fields, blank/overlong partnerName, invalid partnerType, or invalid contactInfo | `scope` = `Scope(nonExistentAgencyId, ownerUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | AGENCY_NOT_FOUND - 404 Agency does not exist or is SOFT_DELETED | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload has unknown fields, blank/overlong partnerName, invalid partnerType, or invalid contactInfo | `scope` = `Scope(activeAgencyId, managerOrClientUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | FORBIDDEN - 403 Only the Owner can create directory partners | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not the Owner or agency does not exist | `scope` = `Scope(activeAgencyId, ownerUser)`, `payload` = `partnerName='KOL A', partnerType='KOL', contactInfo={email,phone}` | UNAUTHORIZED - 401 Caller is unauthenticated (scope.user() == null) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(nonExistentAgencyId, ownerUser)`, `payload` = `blank partnerName or invalid partnerType` | VALIDATION_ERROR - 400 partnerName is blank/too long or partnerType is invalid | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of an ACTIVE agency; Payload contains valid partnerName, partnerType (KOL, KOC, PRESS, AD_CHAN), contactInfo, notes | `scope` = `Scope(activeAgencyId, managerOrClientUser)`, `payload` = `invalid email/phone/URL in contactInfo` | VALIDATION_ERROR - 400 Invalid contactInfo fields or unexpected payload property | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.16`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
