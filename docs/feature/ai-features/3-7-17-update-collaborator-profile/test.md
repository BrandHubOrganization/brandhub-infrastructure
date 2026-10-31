# Test Specification — FR 3.7.17: Update Collaborator Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.17` |
| **Function Name** | Update Collaborator Profile |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `DirectoryPartnerService.update()` (7 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/DirectoryPartnerServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Update collaborator profile details (partnerName, partnerType, contactInfo, notes) with optimistic expectedVersion concurrency check |
| **Preconditions** | Can connect with server; Collaborator profile exists in agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `existing KOL partner UUID (v0)`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | 200 OK - DirectoryPartnerResponse updated with new partnerName, partnerType, contactInfo, notes | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `existing KOL partner UUID (v0)`, `payload` = `expectedVersion=2, contactInfo={email,phone,website}, notes` | 200 OK - Optimistic lock version verified before applying changes | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `linked campaign partner UUID (v2)`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | 200 OK - updatedAt timestamp refreshed and entity flushed via saveAndFlush | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `linked campaign partner UUID (v2)`, `payload` = `expectedVersion=2, contactInfo={email,phone,website}, notes` | 200 OK - Partner linked to campaign retains canDelete=false and deleteBlockedReason='USED' | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; payload.expectedVersion matches partner.getVersion() | `id` = `existing KOL partner UUID (v0)`, `payload` = `CampaignCollaboratorService.update(linkId, status)` | 200 OK - Unlinked partner retains canDelete=true after profile update | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; payload.expectedVersion matches partner.getVersion() | `id` = `linked campaign partner UUID (v2)`, `payload` = `CampaignCollaboratorService.update(linkId, status)` | 200 OK - CampaignCollaboratorService.update transitions campaign cooperationStatus | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `existing KOL partner UUID (v0)`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | 200 OK - CampaignCollaboratorService.update is idempotent when status is unchanged | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `existing KOL partner UUID (v0)`, `payload` = `expectedVersion=2, contactInfo={email,phone,website}, notes` | 200 OK - Contact info JSON re-validated and re-serialized cleanly | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; expectedVersion is 0 (initial version boundary) or partial fields updated | `id` = `boundary partner UUID (v0)`, `payload` = `expectedVersion=0, minimal field update` | 200 OK - Boundary expectedVersion=0 accepted on first update after creation | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; expectedVersion is 0 (initial version boundary) or partial fields updated | `id` = `boundary partner UUID (v0)`, `payload` = `expectedVersion=0, minimal field update` | 200 OK - Clearing optional notes to null succeeds cleanly | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `existing KOL partner UUID (v0)`, `payload` = `CampaignCollaboratorService.update(linkId, status)` | 200 OK - Monotonic microsecond updatedAt enforced on CampaignCollaborator status change | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; Collaborator does not exist, expectedVersion < 0, or expectedVersion mismatches partner.version | `id` = `non-existent or other-agency partner UUID`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | COLLABORATOR_NOT_FOUND - 404 Collaborator not found in caller's agency | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; Collaborator does not exist, expectedVersion < 0, or expectedVersion mismatches partner.version | `id` = `stale-version partner UUID`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | COLLABORATOR_VERSION_CONFLICT - 409 expectedVersion does not match current partner version | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not the Owner | `id` = `existing KOL partner UUID (v0)`, `payload` = `expectedVersion=0, partnerName='Updated KOL', partnerType='KOL'` | FORBIDDEN - 403 Caller is not the Owner of the agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `non-existent or other-agency partner UUID`, `payload` = `expectedVersion=-1 or missing` | VALIDATION_ERROR - 400 expectedVersion is missing, non-integer, or negative (< 0) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency that owns the collaborator; ThirdPartyCollaborator exists in the agency and is locked via partners.lockScoped | `id` = `stale-version partner UUID`, `payload` = `expectedVersion=99 (version conflict)` | COOPERATION_VERSION_CONFLICT - 409 Campaign link expectedUpdatedAt mismatch or invalid fields | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.17`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
