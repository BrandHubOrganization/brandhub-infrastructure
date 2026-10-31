# Test Specification — FR 3.5.9: Complete Media Campaign

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.9` |
| **Function Name** | Complete Media Campaign |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `CampaignDeploymentServiceImpl.complete()` (28 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/CampaignDeploymentServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Complete an IN_PROGRESS media campaign once all tasks are terminal, record task summary, and enqueue pending request cancellation |
| **Preconditions** | Can connect with server; Campaign is IN_PROGRESS and caller is Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | 200 OK - MediaCampaignResponse(status=COMPLETED, completedAt=now, completedBy=userId) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, null)` | 200 OK - completionTaskSummary JSON populated with total, finished, and cancelled task counts | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS campaign with reason`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | 200 OK - completionReason trimmed and persisted on MediaCampaign | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS campaign with reason`, `request` = `CampaignCompletionRequest(expectedVersion, null)` | 200 OK - ContentRequestCompletion.enqueue(workspaceId, campaignId, userId) triggered | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign deployment is SUCCEEDED and all linked tasks are in terminal status (FINISHED/CANCELLED) | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `repeat call on COMPLETED campaign` | 200 OK - Null completionReason stored as null without NullPointerException | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign deployment is SUCCEEDED and all linked tasks are in terminal status (FINISHED/CANCELLED) | `campaignId` = `IN_PROGRESS campaign with reason`, `request` = `repeat call on COMPLETED campaign` | 200 OK - Campaign with mix of FINISHED and CANCELLED terminal tasks completes cleanly | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | 200 OK - CampaignClosureService.inspect confirms canComplete=true before state transition | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, null)` | 200 OK - Updated campaign persisted via MediaCampaignRepository.save | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign is already in COMPLETED status (idempotent repeat call) | `campaignId` = `already COMPLETED campaign UUID`, `request` = `100% FINISHED tasks boundary` | 200 OK - Idempotent call on already COMPLETED campaign returns current MediaCampaignResponse | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign is already in COMPLETED status (idempotent repeat call) | `campaignId` = `already COMPLETED campaign UUID`, `request` = `100% FINISHED tasks boundary` | 200 OK - Campaign with 1 planned work item in FINISHED status completes at min boundary | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `repeat call on COMPLETED campaign` | 200 OK - Whitespace-only completionReason trimmed to empty string | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign is in DRAFT/APPROVED status, version mismatches, or unfinished tasks block closure | `campaignId` = `DRAFT or APPROVED campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | CAMPAIGN_NOT_IN_PROGRESS - 409 Campaign status must be IN_PROGRESS to complete | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Campaign is in DRAFT/APPROVED status, version mismatches, or unfinished tasks block closure | `campaignId` = `non-existent campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | CAMPAIGN_NOT_FOUND - 404 Media campaign not found in workspace | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not Manager (e.g. Client or Creator) | `campaignId` = `IN_PROGRESS completable campaign UUID`, `request` = `CampaignCompletionRequest(expectedVersion, 'All deliverables done')` | FORBIDDEN - 403 Only Manager can complete a media campaign | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `DRAFT or APPROVED campaign UUID`, `request` = `stale expectedVersion` | CAMPAIGN_VERSION_CONFLICT - 409 expectedVersion does not match campaign contentVersion | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is Manager of the workspace (closure.requireManager(workspaceId, user)); Media campaign is in IN_PROGRESS status with matching expectedVersion | `campaignId` = `non-existent campaign UUID`, `request` = `unfinished tasks / reviewing requests` | CAMPAIGN_CLOSURE_BLOCKED - 409 Unfinished tasks, reviewing requests, or incomplete deployment | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.9`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
