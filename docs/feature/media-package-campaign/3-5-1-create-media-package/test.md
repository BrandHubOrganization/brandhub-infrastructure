# Test Specification — FR 3.5.1: Create Media Package

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.1` |
| **Function Name** | Create Media Package |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `MediaPackageServiceImpl.createCustomPackage()` (52 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaPackageServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Allow Owner or Manager to create a custom or template media package with duration, budget, and platform deliverable counts |
| **Preconditions** | Can connect with server; Caller is Owner or Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Starter`, `type` = `BY_DURATION`, `durationWeeks` = `4.0`, `budgetAmount` = `null`, `sourceTemplateId` = `null` | MediaPackageResponse(isTemplate=false, agencyId, availableToWorkspaces=true) | Package saved | **Passed** |
| `UTCID02` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Budget Pack`, `type` = `BY_BUDGET`, `durationWeeks` = `null`, `budgetAmount` = `5000.0`, `sourceTemplateId` = `null` | MediaPackageResponse(packageType=BY_BUDGET, budgetAmount=5000.00) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Full Pack`, `type` = `FULL_DELEGATION`, `durationWeeks` = `null`, `budgetAmount` = `null`, `sourceTemplateId` = `null` | MediaPackageResponse(packageType=FULL_DELEGATION) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Agency exists; User is OWNER of agency; Source template is a system template | `agencyId` = `existing agency`, `name` = `From Template`, `type` = `BY_DURATION`, `durationWeeks` = `8.0`, `sourceTemplateId` = `valid template id` | MediaPackageResponse(sourceTemplateId set, isTemplate=false) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Padded`, `type` = `FULL_DELEGATION`, `scopeDescription` = `scope text` | name trimmed to 'Padded', scopeDescription trimmed | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Blank Scope`, `type` = `FULL_DELEGATION`, `scopeDescription` = `blank` | MediaPackageResponse(scopeDescription=null) | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Agency exists; User is MANAGER of workspace; Workspace belongs to the agency | `agencyId` = `existing agency`, `name` = `Mgr Pack`, `type` = `FULL_DELEGATION`, `workspaceId` = `workspace of same agency` | MediaPackageResponse(createdBy=manager id) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Owner With Ws`, `type` = `FULL_DELEGATION`, `workspaceId` = `any (ignored)` | Owner path skips workspace check; package created | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `A`, `type` = `BY_DURATION`, `durationWeeks` = `1.0` | MediaPackageResponse(durationWeeks=1) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Zero Budget`, `type` = `BY_BUDGET`, `budgetAmount` = `0.0` | MediaPackageResponse(budgetAmount=0) - no range check in service | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Dur+Budget`, `type` = `BY_DURATION`, `durationWeeks` = `4.0`, `budgetAmount` = `1000.0` | Created; extra budgetAmount persisted (only required field checked) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Dur Missing`, `type` = `BY_DURATION`, `durationWeeks` = `null` | INVALID_MEDIA_PACKAGE_CONFIGURATION: Media package fields do not match its type | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Budget Missing`, `type` = `BY_BUDGET`, `budgetAmount` = `null` | INVALID_MEDIA_PACKAGE_CONFIGURATION: Media package fields do not match its type | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Agency exists; User is OWNER of agency; Source id refers to non-template package | `agencyId` = `existing agency`, `name` = `Bad Src`, `type` = `FULL_DELEGATION`, `sourceTemplateId` = `custom package id` | MEDIA_PACKAGE_TEMPLATE_REQUIRED: Source media package must be a system template | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Agency exists; User is OWNER of agency | `agencyId` = `existing agency`, `name` = `Unknown Src`, `type` = `FULL_DELEGATION`, `sourceTemplateId` = `non-existent id` | MEDIA_PACKAGE_NOT_FOUND: Media package not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server | `agencyId` = `non-existent agency`, `name` = `X`, `type` = `FULL_DELEGATION` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Agency exists; User is not owner of agency | `agencyId` = `existing agency`, `name` = `X`, `type` = `FULL_DELEGATION`, `workspaceId` = `null` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Agency exists; User is MANAGER of another agency workspace | `agencyId` = `existing agency`, `name` = `X`, `type` = `FULL_DELEGATION`, `workspaceId` = `workspace of other agency` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Agency exists; User is CLIENT member only | `agencyId` = `existing agency`, `name` = `X`, `type` = `FULL_DELEGATION`, `workspaceId` = `own workspace of same agency` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Agency exists; User is not owner of agency | `agencyId` = `existing agency`, `name` = `X`, `type` = `FULL_DELEGATION`, `workspaceId` = `non-existent workspace` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.1`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test - FR 3.5.1

| Case | Expected result |
|---|---|
| List templates | Only `is_template=true` records are returned. |
| Create Agency package | `is_template=false`, the path `agencyId`, optional `sourceTemplateId`, and default availability are persisted. |
| Invalid agency/non-permitted role | Request is rejected; no package is created. |
| Template constraint | A template cannot retain an `agencyId`. |
| Client package selection UI | Client can select an available same-Agency package; global templates, hidden packages, and cross-Agency packages are rejected. |
| Owner Agency management | Owner opens `/agency/{agencyId}/media-packages`, reloads persisted packages, reviews global templates, and controls availability. |
| Owner custom form | A valid standalone or template-derived package creates an Agency-scoped package; invalid values show inline errors. |
| Existing selection after hide | A selected package remains readable and negotiable after the Owner hides it from future selections. |
| Dashboard before package approval | Redirect to Package negotiation; Client retains Package/Chat, Manager additionally retains settings; creative features are gated. |
| Scheduled reminder | No scheduled reminder is required; no timer/scheduler is introduced by this slice. |
| Role visibility | Workspace selection is Client-only; the Agency management route is Owner-only. |
| Responsive and theme | Cards/dialog remain usable at 375px, 768px, and 1440px in light and dark mode. |
| Language switch | Vietnamese and English render from parallel `mediaPackage` keys without layout breakage. |
