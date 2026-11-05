# Test Specification — FR 3.4.22: Delete Workspace Template

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.22` |
| **Function Name** | Delete Workspace Template |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceTemplateServiceImpl.deleteTemplate()` (13 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTemplateServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to delete an agency workspace template (or Admin to delete a global template) without affecting applied workspaces |
| **Preconditions** | Can connect with server; Caller is Owner of agency or Admin |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `own agency template UUID`, `currentUser` = `Owner` | 200 OK - Agency-owned WorkspaceTemplate deleted via workspaceTemplateRepository.delete | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `own agency template UUID`, `currentUser` = `Owner (after apply)` | 200 OK - Deleted template no longer returned by listTemplates | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `second agency template UUID`, `currentUser` = `Owner` | 200 OK - Workspaces that previously applied the template remain intact | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `second agency template UUID`, `currentUser` = `Owner (after apply)` | 200 OK - Other templates in the same agency remain unaffected | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template is an agency-owned template (agencyId matches caller's agency) | `templateId` = `own agency template UUID`, `currentUser` = `SystemRole.ADMIN user` | 200 OK - SystemRole.ADMIN user successfully deletes global template (agencyId=null) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template is an agency-owned template (agencyId matches caller's agency) | `templateId` = `second agency template UUID`, `currentUser` = `SystemRole.ADMIN user` | 200 OK - Deleting template with sourceWorkspaceId does not affect source workspace | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `own agency template UUID`, `currentUser` = `Owner` | 200 OK - Owner can save a new template with the same name after deletion | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `own agency template UUID`, `currentUser` = `Owner (after apply)` | 200 OK - Deleting template with large configSnapshot succeeds cleanly | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template is a global template (agencyId=null) and caller has SystemRole.ADMIN | `templateId` = `global template UUID (agencyId=null)`, `currentUser` = `Owner (1 template left)` | 200 OK - Deleting the last custom template in agency leaves 0 custom templates | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template is a global template (agencyId=null) and caller has SystemRole.ADMIN | `templateId` = `global template UUID (agencyId=null)`, `currentUser` = `Owner (1 template left)` | 200 OK - Admin with both ADMIN role and Ownership can delete global template | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `own agency template UUID`, `currentUser` = `SystemRole.ADMIN user` | 200 OK - Deleting never-applied custom template succeeds immediately | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template does not exist in workspace_templates table | `templateId` = `non-existent template UUID`, `currentUser` = `Owner` | TEMPLATE_NOT_FOUND - 404 Workspace template not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); Template does not exist in workspace_templates table | `templateId` = `other-agency template UUID`, `currentUser` = `Owner` | FORBIDDEN - 403 Template belongs to another agency | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller attempts to delete another agency's template or non-Admin deletes global template | `templateId` = `own agency template UUID`, `currentUser` = `Owner` | FORBIDDEN - 403 Non-Admin user cannot delete global template (agencyId=null) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `non-existent template UUID`, `currentUser` = `non-Admin deleting global template` | AGENCY_NOT_FOUND - 404 Caller owns no active agency when deleting custom template | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of an active agency (or ADMIN for global templates); WorkspaceTemplate exists in workspace_templates table | `templateId` = `other-agency template UUID`, `currentUser` = `user without agency` | UNAUTHORIZED - 401 Authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.22`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
