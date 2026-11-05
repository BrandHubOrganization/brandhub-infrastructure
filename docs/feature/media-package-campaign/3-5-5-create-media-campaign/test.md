# Test Specification — FR 3.5.5: Create Media Campaign

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.5` |
| **Function Name** | Create Media Campaign |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `MediaCampaignServiceImpl.createDraft()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaCampaignServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Create a DRAFT media campaign with deliverable allocations and planned work items for an APPROVED workspace media package |
| **Preconditions** | Can connect with server; Workspace media package is APPROVED |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 23** (`Passed`: 23, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 3, `Abnormal (A)`: 10 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID23`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Q4 Launch`, `workItems` = `1 item {id, name, type=POST, dueDate}` | 201 Created - MediaCampaignResponse(status=DRAFT) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Package is APPROVED; User is OWNER of agency | `workspaceId` = `valid`, `name` = `Q4 Launch`, `workItems` = `1 item {id, name, type=POST, dueDate}` | 201 Created - status=DRAFT | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Live`, `workItems` = `1 item type=VIDEO` | 201 Created - workItem type VIDEO kept | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Survey`, `workItems` = `1 item type=SURVEY` | 201 Created - workItem type SURVEY kept | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace; Workspace already has a campaign | `workspaceId` = `valid`, `name` = `Second`, `workItems` = `1 item {id, name, type=POST, dueDate}` | 201 Created - multiple campaigns allowed | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Stable`, `workItems` = `3 items without ids` | 201 Created - stable work item IDs generated | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Preserve`, `workItems` = `items with client-supplied ids` | 201 Created - provided stable IDs preserved | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Ordered`, `workItems` = `3 items` | Work items stored as JSONB in given order; no tasks created | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Get`, `workItems` = `1 item {id, name, type=POST, dueDate}`, `op` = `getCampaign` | 200 OK - campaign detail | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `op` = `listByWorkspace` | 200 OK - list of campaigns for workspace | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Min`, `workItems` = `exactly 1 item` | 201 Created - minimum work item count | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Big`, `workItems` = `max allowed items (100 items)` | 201 Created - maximum work item count | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `Due today`, `workItems` = `item dueDate = today` | 201 Created - boundary due date accepted | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MANAGER of workspace; Package is not APPROVED | `workspaceId` = `valid`, `name` = `X`, `workItems` = `1 item {id, name, type=POST, dueDate}` | PACKAGE_NOT_APPROVED (409) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER of workspace; Workspace has no selected package | `workspaceId` = `valid`, `name` = `X`, `workItems` = `1 item {id, name, type=POST, dueDate}` | WORKSPACE_MEDIA_PACKAGE_NOT_FOUND: No media package has been selected for this workspace | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `empty`, `workItems` = `empty list` | Validation error: workItems required | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `X`, `workItems` = `item missing name` | Validation error: work item name required | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `X`, `workItems` = `item type=INVALID` | Validation error: type must be POST\|VIDEO\|SURVEY | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `valid`, `name` = `X`, `workItems` = `item dueDate null` | Validation error: dueDate required | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Package is APPROVED; User is CLIENT of workspace | `workspaceId` = `valid`, `name` = `X`, `workItems` = `1 item {id, name, type=POST, dueDate}` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Package is APPROVED; User not a workspace member | `workspaceId` = `valid`, `name` = `X`, `workItems` = `1 item {id, name, type=POST, dueDate}` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Package is APPROVED; User is MANAGER of workspace | `workspaceId` = `non-existent`, `name` = `X`, `workItems` = `1 item {id, name, type=POST, dueDate}` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID23` | `A` | Can connect with server; Campaign exists in DRAFT | `op` = `getCampaign`, `campaignId` = `non-existent` | Campaign not found (404) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.5`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test - FR 3.5.5

| Case | Expected result |
|---|---|
| Approved package | Campaign is created as `DRAFT`. |
| Unapproved package | `409 PACKAGE_NOT_APPROVED`. |
| Work items | Stable IDs and required task fields are validated. |
| Duplicate campaign / concurrent creates | At most one Campaign exists for a Workspace, including DRAFT. |
| Create after Campaign COMPLETED | Cannot create another Campaign in that Workspace. |
| Agreement reassignment to bypass uniqueness | Rejected; Workspace still has one agreement/Campaign. |
| New Workspace using the same catalogue package | Independent selection, snapshot/counter/approvals; no reused approval. |
| Stale draft update | Conflict; current version and approvals are not overwritten. |
| Existing duplicate Campaigns before migration | Report specific conflicting IDs; do not delete or relink history automatically. |
| Locale/theme/mobile | vi/en, light/dark and narrow layouts remain usable. |

New lifecycle tests: **not run**; implementation has not started. Total-quantity,
legacy-snapshot and expanded Task type cases are in [phase-1 test matrix](../phase-1-design/test.md).

## Stage 2 execution — 2026-10-08 (supersedes status above for draft tests only)

- Maven clean targeted suite: 66 tests, zero failures/errors (Campaign service 13,
  validator 15, access 4, Package service 24, Package controller 10).
- Web build: pass; scoped ESLint: pass. Build includes TypeScript compilation.
- Playwright media-package suite: 17 pass / 1 fail. Four new Campaign cases pass:
  Manager create/edit (375px/dark), Client read-only (desktop/light), legacy monthly
  rejection and stale version preserving input. Screenshots in ignored test-results.
- Failed test: utility `/media-package` redirect lands on `/dashboard`; not fixed here.
- Live DB audit read-only: 116 Campaign; 35 agreements with two Campaigns. Migration
  not applied; no runtime schema/concurrent-request claim. Existing monthly/empty
  snapshots and prototype plans remain intact and require explicit review.
- Approval/deploy/completion/Task integration cases still belong to later stages.

## Review execution — 2026-10-10

- Full Business Service suite: 447 tests reported, 416 passed, 31 skipped,
  zero failures/errors. Includes 16 Campaign service and 15 plan-validator tests.
- Web lint: zero errors/81 warnings; type-check and production build passed.
- Mocked Package/Campaign Playwright suite: 16/18 passed initially. RETAINER
  timed out but passed on an isolated rerun; all four Campaign cases passed.
  Utility `/media-package` still redirects to `/dashboard` and fails its test.
- Live authenticated API, concurrent creation and end-to-end Atlas deployment
  were not tested in this review; no database changes were executed.
