> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.4.15: View Workspace Profile

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.15` |
| **Function Name** | View Workspace Profile |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceServiceImpl.getWorkspace()` (24 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Return workspace profile details including name, description, linked Client info, status, and IANA timezone configuration |
| **Preconditions** | Can connect with server; User is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is active member of workspace; User role is MANAGER | `workspaceId` = `valid workspace id`, `currentUser` = `MANAGER` | WorkspaceResponse(id,name,industry,settings) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active member of workspace; User role is CREATOR | `workspaceId` = `valid workspace id`, `currentUser` = `CREATOR` | WorkspaceResponse(id,name,industry,settings) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Workspace has CLIENT member | `workspaceId` = `valid workspace id`, `currentUser` = `CLIENT via owned clientProfile` | WorkspaceResponse via client-profile fallback | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is active member of workspace; Workspace settings JSON valid | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse(timezone, defaultPlatforms from settings) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is active member of workspace; Workspace settings JSON malformed | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse with empty settings (timezone=null, platforms empty) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is active member of workspace; Workspace settings null | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse with empty settings | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is active member of workspace; Workspace has extended profile fields | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse(brandColor,tagline,foundedYear,social links) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is active member of workspace; Workspace has no optional fields | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse with null optional fields | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is active member of workspace | `workspaceId` = `first workspace of agency`, `currentUser` = `active member` | WorkspaceResponse | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is active member of workspace; Member has just joined | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Workspace has exactly 1 active member | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is active member of workspace; Name at max length | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WorkspaceResponse with full name | — | **Passed** |
| `UTCID13` | `A` | Can connect with server | `workspaceId` = `non-existent id`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server | `workspaceId` = `null`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace is soft-deleted | `workspaceId` = `valid workspace id`, `currentUser` = `active member` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is not member of workspace | `workspaceId` = `valid workspace id`, `currentUser` = `non-member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User membership isActive=false (left) | `workspaceId` = `valid workspace id`, `currentUser` = `former member` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Member of another workspace only | `workspaceId` = `valid workspace id`, `currentUser` = `member of other workspace` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; CLIENT profile not linked to workspace | `workspaceId` = `valid workspace id`, `currentUser` = `client of other workspace` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.4.15`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `GET /api/v1/workspaces/{workspaceId} · GET /api/v1/workspaces/{workspaceId}/completeness` (`WorkspaceController.getWorkspace(), ProfileMatchingController.workspaceCompleteness()` -> `WorkspaceServiceImpl.getWorkspace(), WorkspaceSettingsHelper, CompletenessService`) returns standardized `ApiResponse` payloads and `ErrorCode` statuses (`403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 WORKSPACE_NOT_FOUND`).
- **Multi-Tenant Isolation:** Verified unauthorized callers and cross-Agency/cross-Workspace requests are rejected (`403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`workspace.detail.* / workspace.settings.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/workspace/detail.tsx`, `src/pages/workspace/components/settings/WorkspaceInfoView.tsx`, `src/components/shared/CompletenessCard.tsx`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Agency & Workspace Spec](../../../../ba/03-agency-workspace.md).
