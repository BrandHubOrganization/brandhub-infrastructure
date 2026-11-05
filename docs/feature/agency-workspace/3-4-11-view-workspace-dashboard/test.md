# Test Specification — FR 3.4.13: View Workspace Dashboard

> Note: This specification maps to official **FR 3.4.13 — View Workspace Dashboard** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-13-view-workspace-dashboard/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.13` |
| **Function Name** | View Workspace Dashboard |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `WorkspaceServiceImpl.getDashboard()` (33 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Aggregate workspace member counts by role, campaign counts by status, package negotiation status, and AI credit usage |
| **Preconditions** | Can connect with server; User is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 19** (`Passed`: 19, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID19`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is active member of workspace; Workspace has media package and campaigns | `workspaceId` = `existing id` | 200 - WorkspaceDashboardResponse with member, campaign counts and negotiationStatus | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is active member of workspace; Workspace has 3 members of mixed roles | `workspaceId` = `existing id` | 200 - membersByRole grouped by role, totalMembers=3 | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is active member of workspace; Workspace has campaigns of mixed status | `workspaceId` = `existing id` | 200 - campaignsByStatus counts per status | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is active member of workspace; Agency has AI credit ledger this month | `workspaceId` = `existing id` | 200 - creditsUsed = ledger usedAmount for current month | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CLIENT of workspace | `workspaceId` = `existing id` | 200 - WorkspaceDashboardResponse | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is active member of workspace | `workspaceId` = `existing id` | 200 - response includes agencyId and currentMonth yyyy-MM | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is active member of workspace; Package negotiation status set | `workspaceId` = `existing id` | 200 - negotiation status = enum name | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MANAGER member of workspace | `workspaceId` = `existing id` | 200 - WorkspaceDashboardResponse | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is active member of workspace; Workspace has no media package | `workspaceId` = `existing id` | 200 - totalCampaigns=0, negotiationStatus=null | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is active member of workspace; Media package has no campaigns | `workspaceId` = `existing id` | 200 - totalCampaigns=0, empty campaignsByStatus | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is active member of workspace; No AI credit ledger for current month | `workspaceId` = `existing id` | 200 - creditsUsed=0 | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is active member of workspace; Workspace has exactly 1 active member | `workspaceId` = `existing id` | 200 - totalMembers=1 | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is active member of workspace; Inactive members exist | `workspaceId` = `existing id` | 200 - inactive members not counted | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Workspace does not exist | `workspaceId` = `non-existing id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Workspace is SOFT_DELETED | `workspaceId` = `deleted id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is not member of workspace | `workspaceId` = `existing id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User membership isActive=false | `workspaceId` = `existing id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CLIENT of a different workspace | `workspaceId` = `existing id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Owner without workspace membership | `workspaceId` = `existing id` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.13`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — View Workspace Dashboard (FR 3.4.11)

> Test cases derived from [spec.md](spec.md) Business Rules / Validation / Abnormal Cases.

| Test case ID | Description | Related rule | Expected result | Type | Status |
|---|---|---|---|---|---|
| TC-01 | Active member (MANAGER/CREATOR/CLIENT) opens dashboard of a Workspace with members, a package, and campaigns | BR-29, Normal Flow | 200; full `WorkspaceDashboardResponse` — correct `totalActiveMembers`, `membersByRole`, `totalCampaigns`, `campaignsByStatus`, `packageNegotiationStatus`, Agency AI credit fields | Happy path | Pass |
| TC-02 | Member opens dashboard of a newly created Workspace with no package and no campaigns | BR-04, 4.a1 | 200; `totalCampaigns: 0`, `campaignsByStatus: {}`, `packageNegotiationStatus: null`, member counts shown normally | Edge case | Pass |
| TC-03 | Workspace has a package but zero campaigns under it | BR-04 | 200; `packageNegotiationStatus` set, `totalCampaigns: 0`, `campaignsByStatus: {}` | Edge case | Pass |
| TC-04 | Caller has an active membership row but a role outside {MANAGER, CREATOR, CLIENT} | @RequireRole | 403 `FORBIDDEN` | Error case | Pass |
| TC-05 | Caller has no membership row at all for the Workspace | BR-29, 3.b1 | 403 `WORKSPACE_ACCESS_DENIED` (or `FORBIDDEN` per dual-layer check, see FR 3.4.13) | Error case | Pass |
| TC-06 | `workspaceId` does not exist | 3.a1 | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-07 | Agency has no `AiCreditLedger` row for the current month | Data Specifications | 200; `agencyAiCreditsUsedThisMonth: 0`, `aiCreditMonth` set to current month | Edge case | Pass |
| TC-08 | Dashboard call does not mutate any data (read-only check) | BR-03 | No row inserted/updated as a side effect of the call | Regression | Pass |

## Notes

- TC-04 vs TC-05 reflects the two-layer access check documented in `plan.md` and `sequence-flow.md`: `@RequireRole` on the controller rejects callers with no qualifying role, `assertMember` in the service rejects callers with no active membership row at all — same pattern as FR 3.4.13 `getWorkspace`.
- No Task/Material test cases — no such entity exists in this codebase (see spec.md "Known scope note" and "Out of Scope").
