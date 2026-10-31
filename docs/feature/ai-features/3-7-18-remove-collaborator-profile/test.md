# Test Specification — FR 3.7.18: Remove Collaborator Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.7.18` |
| **Function Name** | Remove Collaborator Profile |
| **Functional Domain** | AI Features |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `DirectoryPartnerService.delete()` (18 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/DirectoryPartnerServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Delete an unused collaborator profile (or deactivate an active one) while blocking deletion if already linked to a campaign |
| **Preconditions** | Can connect with server; Collaborator profile exists in agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unused verified partner UUID`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | 204 No Content - delete() permanently removes unused, history-verified partner from DB | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unused verified partner UUID`, `expectedVersion` = `deactivate(scope, id, expectedVersion=1)` | 200 OK - deactivate() sets active=false and refreshes updatedAt on active partner | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `active partner UUID (for deactivate)`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | 200 OK - Deactivating a campaign-linked partner succeeds and preserves campaign history | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `active partner UUID (for deactivate)`, `expectedVersion` = `deactivate(scope, id, expectedVersion=1)` | 200 OK - Deactivated partner returns active=false in DirectoryPartnerResponse | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; For delete(): partner has firstUsedAt == null, no campaign links, and usageHistoryVerified == true | `id` = `unused verified partner UUID`, `expectedVersion` = `deactivate on already inactive partner` | 200 OK - Idempotent deactivate() on already inactive partner returns 200 OK without version check failure | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; For delete(): partner has firstUsedAt == null, no campaign links, and usageHistoryVerified == true | `id` = `active partner UUID (for deactivate)`, `expectedVersion` = `deactivate on already inactive partner` | 204 No Content - partners.delete(partner) and partners.flush() executed inside transaction | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unused verified partner UUID`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | 200 OK - Deactivated partner is excluded from CampaignCollaboratorService.options() | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unused verified partner UUID`, `expectedVersion` = `deactivate(scope, id, expectedVersion=1)` | 200 OK - Deletion eligibility accurately reflects links.existsByCollaboratorId(id) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; For deactivate(): partner is active (or already inactive for idempotent repeat call) | `id` = `already inactive partner UUID`, `expectedVersion` = `boundary expectedVersion=0` | 204 No Content - Boundary expectedVersion=0 accepted when deleting newly created partner | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; For deactivate(): partner is active (or already inactive for idempotent repeat call) | `id` = `already inactive partner UUID`, `expectedVersion` = `boundary expectedVersion=0` | 200 OK - Boundary expectedVersion=0 accepted when deactivating newly created partner | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unused verified partner UUID`, `expectedVersion` = `deactivate on already inactive partner` | 200 OK - Deactivating partner with usageHistoryVerified=false succeeds cleanly | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; Partner is linked to a campaign (firstUsedAt != null), has unverified history, or version conflicts | `id` = `campaign-used partner UUID`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | COLLABORATOR_USED - 409 Cannot delete partner that has been used in a campaign | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; Partner is linked to a campaign (firstUsedAt != null), has unverified history, or version conflicts | `id` = `unverified-history or non-existent UUID`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | COLLABORATOR_HISTORY_UNVERIFIED - 409 Cannot delete partner with unverified usage history | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not the Owner | `id` = `unused verified partner UUID`, `expectedVersion` = `delete(scope, id, expectedVersion=0)` | FORBIDDEN - 403 Caller is not the Owner of the agency | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `campaign-used partner UUID`, `expectedVersion` = `expectedVersion=-1 (negative)` | VALIDATION_ERROR - 400 expectedVersion must be non-negative (>= 0) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of the ACTIVE agency; ThirdPartyCollaborator exists in the agency and matches expectedVersion | `id` = `unverified-history or non-existent UUID`, `expectedVersion` = `expectedVersion=99 (stale version)` | COLLABORATOR_VERSION_CONFLICT - 409 expectedVersion does not match current partner version | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.7.18`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
