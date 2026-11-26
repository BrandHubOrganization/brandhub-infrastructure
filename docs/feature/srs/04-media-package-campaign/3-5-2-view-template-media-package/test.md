> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.5.2: View Template Media Package

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.2` |
| **Function Name** | View Template Media Package |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `MediaPackageServiceImpl.listTemplates()` (24 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaPackageServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | List and view template media packages (duration-based, fixed-budget, KPI-based) and workspace package details |
| **Preconditions** | Can connect with server; User is authenticated |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 11, `Boundary (B)`: 2, `Abnormal (A)`: 4 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Package type is BY_DURATION | `workspaceId` = `existing workspace` | WorkspaceMediaPackageResponse(packageType=BY_DURATION, durationWeeks, termsVersion=1, status=DRAFT) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Package type is BY_BUDGET | `workspaceId` = `existing workspace` | WorkspaceMediaPackageResponse(packageType=BY_BUDGET, budgetAmount) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Package type is FULL_DELEGATION | `workspaceId` = `existing workspace` | WorkspaceMediaPackageResponse(packageType=FULL_DELEGATION, no duration/budget) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Workspace exists; Workspace has no selected package | `workspaceId` = `existing workspace` | 200 OK - null (no-selection response) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Negotiation status CLIENT_REQUESTED_CHANGE | `workspaceId` = `existing workspace` | Response with status=CLIENT_REQUESTED_CHANGE, finalTerms parsed | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Negotiation status AGENCY_COUNTERED | `workspaceId` = `existing workspace` | Response with status=AGENCY_COUNTERED, approvedByAgencyAt set | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Both parties approved | `workspaceId` = `existing workspace` | Response with status=APPROVED, both approval timestamps set | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Workspace exists; Workspace has selected package; Package hidden by Owner after selection | `workspaceId` = `existing workspace` | Selected package still returned | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Workspace exists; Workspace has selected package; finalTerms edited by negotiation | `workspaceId` = `existing workspace` | Effective terms reflect latest finalTerms and termsVersion | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Workspace exists; Workspace has selected package; termsVersion is 1 | `workspaceId` = `existing workspace` | termsVersion=1 returned | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Workspace exists; Workspace has selected package; finalTerms is invalid JSON | `workspaceId` = `existing workspace` | parseTerms fallback; response returned without error | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Workspace exists | `workspaceId` = `non-existent id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Workspace exists; Workspace has selected package; Linked package row deleted | `workspaceId` = `existing workspace` | MEDIA_PACKAGE_NOT_FOUND: Media package not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace exists | `workspaceId` = `null` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `N` | Can connect with server; Workspace exists; Agency has 2 visible and 1 hidden custom packages | `workspaceId` = `existing workspace`, `op` = `listAvailablePackages` | List of 2 visible agency packages | — | **Passed** |
| `UTCID16` | `N` | Can connect with server; Workspace exists; Agency has only global templates | `workspaceId` = `existing workspace`, `op` = `listAvailablePackages` | Empty list; templates excluded | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Workspace exists | `workspaceId` = `non-existent id`, `op` = `listAvailablePackages` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.5.2`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `GET /api/v1/media-package-templates · GET /api/v1/agencies/{agencyId}/media-package-custom · GET /api/v1/workspaces/{workspaceId}/media-packages · GET /api/v1/workspaces/{workspaceId}/media-package · GET /api/v1/public/media-packages/{token}` (`MediaPackageController.listTemplates() / listAgencyCustomPackages() / listAvailablePackages() / getWorkspacePackage(), MediaPackageShareController.guest(), ProfileMatchingController.packageFit()` -> `MediaPackageService, MediaPackageShareService, PackageFit`) enforces `BR-25` and returns standardized `ApiResponse` envelopes (`401 UNAUTHORIZED` (workspace endpoints), `403 FORBIDDEN`, `404 PACKAGE_NOT_SELECTED` / `SHARE_LINK_NOT_FOUND`).
- **Concurrency & Tenant Isolation:** Verified version conflict guards (`409`) and strict Workspace/Agency membership boundaries (`403`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`mediaPackage.catalog.* / mediaPackage.guest.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/media-package/{index,agency,guest}.tsx`, `src/pages/media-package/components/{MediaPackageCatalog,MediaPackageCard,MediaPackageDetail,WorkspacePackageOverview}.tsx`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md).

