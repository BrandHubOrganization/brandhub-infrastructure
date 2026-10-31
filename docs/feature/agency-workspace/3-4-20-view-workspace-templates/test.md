# Test Specification — FR 3.4.20: View Workspace Templates

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.20` |
| **Function Name** | View Workspace Templates |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceTemplateServiceImpl.listTemplates()` (16 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTemplateServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | List and view global system default templates and agency-owned workspace configuration templates |
| **Preconditions** | Can connect with server; Caller is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `listTemplates() all` | 200 OK - listTemplates returns agency-owned and global (agencyId=null) templates | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `getTemplate(ownTemplateId)` | 200 OK - Each WorkspaceTemplateResponse includes id, agencyId, name, config, createdAt | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with global+custom`, `templateId` = `listTemplates() all` | 200 OK - configSnapshot JSON parsed into WorkspaceTemplateConfig record | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with global+custom`, `templateId` = `getTemplate(ownTemplateId)` | 200 OK - getTemplate(ownTemplateId) returns full template detail for Owner | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Templates contain JSON configSnapshot (industry, timezone, defaultPlatforms, reportFrequency) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `getTemplate(globalTemplateId)` | 200 OK - getTemplate(globalTemplateId) allows any Owner to view global template | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Templates contain JSON configSnapshot (industry, timezone, defaultPlatforms, reportFrequency) | `currentUser` = `Owner of agency with global+custom`, `templateId` = `getTemplate(globalTemplateId)` | 200 OK - Templates belonging to other agencies excluded from listTemplates | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `listTemplates() all` | 200 OK - Corrupted configSnapshot JSON gracefully falls back to empty WorkspaceTemplateConfig | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `getTemplate(ownTemplateId)` | 200 OK - Soft-deleted agencies ignored when resolving caller's owned agencyId | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Agency has 0 custom templates (only global templates with agencyId=null exist) | `currentUser` = `Owner of agency with 0 custom templates`, `templateId` = `1-template boundary` | 200 OK - Agency with 0 custom templates returns only global templates (or empty list) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Agency has 0 custom templates (only global templates with agencyId=null exist) | `currentUser` = `Owner of agency with 0 custom templates`, `templateId` = `1-template boundary` | 200 OK - Agency with 1 custom template returns list of size 1 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner of agency with custom templates`, `templateId` = `getTemplate(globalTemplateId)` | 200 OK - Template with null sourceWorkspaceId serialized cleanly | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Caller does not own any active agency | `currentUser` = `user owning no active agency`, `templateId` = `listTemplates() all` | AGENCY_NOT_FOUND - 404 Caller does not own any active agency | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Caller does not own any active agency | `currentUser` = `Owner requesting other-agency template`, `templateId` = `listTemplates() all` | TEMPLATE_NOT_FOUND - 404 Workspace template ID does not exist | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller requests getTemplate(templateId) for a template owned by another agency | `currentUser` = `Owner of agency with custom templates`, `templateId` = `listTemplates() all` | FORBIDDEN - 403 Template belongs to another agency (assertCanAccess failed) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `user owning no active agency`, `templateId` = `non-existent templateId` | AGENCY_NOT_FOUND - 404 Caller's only agency is SOFT_DELETED | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of an active (non-SOFT_DELETED) agency; Database contains agency-owned templates (agencyId=own) and global templates (agencyId=null) | `currentUser` = `Owner requesting other-agency template`, `templateId` = `other-agency templateId` | UNAUTHORIZED - 401 Authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.20`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
