> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.4.21: Apply Workspace Template

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.21` |
| **Function Name** | Apply Workspace Template |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceTemplateServiceImpl.applyTemplate()` (45 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceTemplateServiceImplTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Apply non-null profile fields and WorkspaceSettings (timezone, defaultPlatforms, reportFrequency) from a template to a workspace |
| **Preconditions** | Can connect with server; Caller is Owner of target workspace agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `agency custom template UUID`, `workspaceId` = `active workspace in own agency` | 200 OK - WorkspaceResponse updated with template industry, website, phone, location, description | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `agency custom template UUID`, `workspaceId` = `workspace with existing settings` | 200 OK - Global template (agencyId=null) applied to agency's workspace | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `global template UUID (agencyId=null)`, `workspaceId` = `active workspace in own agency` | 200 OK - Brand fields (brandColor, logoIcon, tagline, foundedYear, social URLs) applied | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `global template UUID (agencyId=null)`, `workspaceId` = `workspace with existing settings` | 200 OK - WorkspaceSettings updated with template timezone, defaultPlatforms, industryFields | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Target workspace exists and belongs to the caller's owned agency | `templateId` = `agency custom template UUID`, `workspaceId` = `workspace with custom brandColor` | 200 OK - Null fields in WorkspaceTemplateConfig preserve existing workspace values without overwrite | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Target workspace exists and belongs to the caller's owned agency | `templateId` = `global template UUID (agencyId=null)`, `workspaceId` = `workspace with custom brandColor` | 200 OK - Valid reportFrequency in REPORT_FREQUENCIES applied to WorkspaceSettings | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `agency custom template UUID`, `workspaceId` = `active workspace in own agency` | 200 OK - Invalid reportFrequency in template ignored, keeping current.reportFrequency() | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `agency custom template UUID`, `workspaceId` = `workspace with existing settings` | 200 OK - workspace.updatedAt refreshed and saved via workspaceRepository.save | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template configSnapshot has partial non-null fields (preserving existing workspace fields) | `templateId` = `partial-config template UUID`, `workspaceId` = `workspace with invalid reportFrequency in template` | 200 OK - Template with all-null config leaves workspace fields and settings intact | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template configSnapshot has partial non-null fields (preserving existing workspace fields) | `templateId` = `partial-config template UUID`, `workspaceId` = `workspace with invalid reportFrequency in template` | 200 OK - Template with only timezone set updates timezone and keeps existing defaultPlatforms | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `agency custom template UUID`, `workspaceId` = `workspace with custom brandColor` | 200 OK - Re-applying same template produces identical WorkspaceResponse idempotently | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Target workspace or template does not exist | `templateId` = `non-existent template UUID`, `workspaceId` = `active workspace in own agency` | TEMPLATE_NOT_FOUND - 404 Workspace template not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Target workspace or template does not exist | `templateId` = `other-agency template UUID`, `workspaceId` = `active workspace in own agency` | AGENCY_NOT_FOUND - 404 Caller does not own an active agency | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Target workspace or template belongs to a different agency | `templateId` = `agency custom template UUID`, `workspaceId` = `active workspace in own agency` | FORBIDDEN - 403 Cannot apply another agency's private template | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `non-existent template UUID`, `workspaceId` = `non-existent workspace UUID` | WORKSPACE_NOT_FOUND - 404 Target workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is authenticated Owner of the agency that owns the target workspace; Template exists (owned by the same agency or global template with agencyId=null) | `templateId` = `other-agency template UUID`, `workspaceId` = `other-agency workspace UUID` | FORBIDDEN - 403 Target workspace does not belong to caller's agency | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.4.21`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `POST /api/v1/workspace-templates/{templateId}/apply/{workspaceId}` (`WorkspaceTemplateController.applyToWorkspace()` -> `WorkspaceTemplateServiceImpl.applyTemplate()`) returns standardized `ApiResponse` payloads and `ErrorCode` statuses (`403 FORBIDDEN`, `404 TEMPLATE_NOT_FOUND` / `WORKSPACE_NOT_FOUND`).
- **Multi-Tenant Isolation:** Verified unauthorized callers and cross-Agency/cross-Workspace requests are rejected (`403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`workspace.templates.apply.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/workspace/templates.tsx`, `src/pages/workspace/create.tsx`, `src/pages/workspace/components/ApplyTemplateDialog.tsx`, `src/services/workspaceTemplateService.ts`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md).
