> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.5.4: Approve Media Package

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.4` |
| **Function Name** | Approve Media Package |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `MediaPackageServiceImpl.approvePackage()` (44 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaPackageServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Record dual Agency and Client approval on the negotiated workspace media package and lock its status as APPROVED |
| **Preconditions** | Can connect with server; Workspace has a selected media package |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is OWNER of agency; Client not yet approved | `workspaceId` = `existing workspace` | approvedByAgencyAt set; status unchanged (not APPROVED) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Client not yet approved; User is MANAGER of workspace | `workspaceId` = `existing workspace` | approvedByAgencyAt set; status unchanged | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Agency not yet approved | `workspaceId` = `existing workspace` | approvedByClientAt set; status unchanged | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Agency already approved same version | `workspaceId` = `existing workspace` | Both timestamps set; status=APPROVED | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is OWNER of agency; Client already approved same version | `workspaceId` = `existing workspace` | Both timestamps set; status=APPROVED | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is MANAGER of workspace; Client already approved same version | `workspaceId` = `existing workspace` | Both timestamps set; status=APPROVED | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Status already APPROVED | `workspaceId` = `existing workspace` | 200 - existing APPROVED response, idempotent, timestamps unchanged | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is OWNER of agency; Status already APPROVED | `workspaceId` = `existing workspace` | 200 - existing APPROVED response, no state change | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Client already approved, agency not | `workspaceId` = `existing workspace` | approvedByClientAt refreshed; still not APPROVED | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Terms changed after earlier approval (approvals reset) | `workspaceId` = `existing workspace` | Only client timestamp set; agency must re-approve | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is CLIENT of workspace; Agency approved, terms version 1 | `workspaceId` = `existing workspace` | Both timestamps; APPROVED at termsVersion=1 | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is OWNER of agency; Status DRAFT, no approvals | `workspaceId` = `existing workspace` | First approval ever: single timestamp, status stays DRAFT | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Workspace exists; Workspace has selected package; User is OWNER of agency; Status AGENCY_COUNTERED, client approval null | `workspaceId` = `existing workspace` | Agency timestamp set; remains AGENCY_COUNTERED | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace exists; User is CLIENT of workspace; Workspace has no selected package | `workspaceId` = `existing workspace` | WORKSPACE_MEDIA_PACKAGE_NOT_FOUND: No media package has been selected for this workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is not a workspace member | `workspaceId` = `existing workspace` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Workspace exists; Workspace has selected package; User is member with other role (e.g. VIEWER) | `workspaceId` = `existing workspace` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Workspace exists | `workspaceId` = `non-existent id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Workspace exists; Workspace has selected package; Workspace's agency missing | `workspaceId` = `existing workspace` | AGENCY_NOT_FOUND: Agency not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.5.4`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `POST /api/v1/workspaces/{workspaceId}/media-package/approve · PUT /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/workspaces/{workspaceId}/media-package/preparation` (`MediaPackageController.approvePackage(), WorkspacePackagePlanningController.save() / status()` -> `MediaPackageService.approvePackage(), WorkspacePackagePlanningService`) enforces `BR-26` and returns standardized `ApiResponse` envelopes (`400 VALIDATION_ERROR`, `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED`, `409 TERMS_VERSION_CONFLICT`).
- **Concurrency & Tenant Isolation:** Verified version conflict guards (`409`) and strict Workspace/Agency membership boundaries (`403`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`mediaPackage.approve.* / mediaPackage.status.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/media-package/index.tsx`, `src/pages/media-package/components/{SelectedMediaPackage,WorkspacePackageOverview,CampaignDraftPanel}.tsx`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md).

