# Test Specification — FR 3.4.16: Update Workspace Profile

> Note: This specification maps to official **FR 3.4.16 — Update Workspace Profile** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-16-update-workspace-profile/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.16` |
| **Function Name** | Update Workspace Profile |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `WorkspaceServiceImpl.updateSettings()` (39 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner or Manager to update workspace profile metadata and IANA timezone/default platform settings |
| **Preconditions** | Can connect with server; Caller is Owner or Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 21** (`Passed`: 21, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 5, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID21`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `name` = `New Name` | WorkspaceResponse(name=New Name) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `timezone` = `Asia/Ho_Chi_Minh` | WorkspaceResponse(timezone updated) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `defaultPlatforms` = `[FACEBOOK, TIKTOK]` | WorkspaceResponse(defaultPlatforms updated) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `industry` = `MARKETING`, `companySize` = `18568.0` | WorkspaceResponse(industry, companySize updated) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `website` = `https://new.vn`, `phone` = `909999999.0`, `location` = `Hanoi` | WorkspaceResponse(website, phone, location updated) | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `name` = `New Name`, `timezone` = `UTC`, `industry` = `RETAIL` | WorkspaceResponse with all given fields updated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id` | WorkspaceResponse unchanged except updatedAt | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is MANAGER of workspace; Existing industryFields in settings | `workspaceId` = `valid workspace id`, `timezone` = `UTC` | WorkspaceResponse; industryFields preserved | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Caller is MANAGER of workspace; Existing timezone in settings | `workspaceId` = `valid workspace id`, `defaultPlatforms` = `[INSTAGRAM]` | WorkspaceResponse; timezone preserved | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `name` = `blank spaces only` | WorkspaceResponse; name unchanged (blank ignored) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `name` = `empty` | WorkspaceResponse; name unchanged (empty ignored) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `name` = `1 char` | WorkspaceResponse(name length 1) | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `defaultPlatforms` = `empty list` | WorkspaceResponse(defaultPlatforms empty) | — | **Passed** |
| `UTCID14` | `B` | Can connect with server; Caller is MANAGER of workspace; Workspace settings JSON malformed | `workspaceId` = `valid workspace id`, `timezone` = `UTC` | WorkspaceResponse; settings rebuilt from empty + timezone | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `non-existent id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Workspace is soft-deleted | `workspaceId` = `valid workspace id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is CREATOR of workspace | `workspaceId` = `valid workspace id`, `name` = `X` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller is CLIENT of workspace | `workspaceId` = `valid workspace id`, `name` = `X` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller not member of workspace | `workspaceId` = `valid workspace id`, `name` = `X` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `industry` = `INVALID_VALUE` | VALIDATION_ERROR: invalid WorkspaceIndustry (MSG02) | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `companySize` = `INVALID_VALUE` | VALIDATION_ERROR: invalid CompanySize (MSG02) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.16`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
