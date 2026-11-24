> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.5.6: View Media Campaign

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.6` |
| **Function Name** | View Media Campaign |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `MediaCampaignServiceImpl.getDraft()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaCampaignServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Retrieve media campaign details including package terms snapshot, deliverable plan, work items, version history, and approval state |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `valid workspace UUID`, `campaignId` = `getDraft(workspaceId, campaignId)` | 200 OK - getDraft returns MediaCampaignResponse with status, timeline, workItems, contentVersion | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `valid workspace UUID`, `campaignId` = `listByWorkspace(workspaceId)` | 200 OK - listByWorkspace returns List<MediaCampaignResponse> for workspace agreement | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `workspace with approved campaign`, `campaignId` = `getDraft(workspaceId, campaignId)` | 200 OK - MediaCampaignResponse includes packageTermsSnapshot, deliverablePlan, and allocations | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `workspace with approved campaign`, `campaignId` = `listByWorkspace(workspaceId)` | 200 OK - Dual approval metadata (approvedByAgencyAt/Version, approvedByClientAt/Version) included | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Campaign has packageTermsSnapshot, deliverablePlan, workItems, versions, and reviewEvents | `workspaceId` = `valid workspace UUID`, `campaignId` = `versions(workspaceId, campaignId)` | 200 OK - versions() returns List<CampaignVersion> ordered by contentVersion desc | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Campaign has packageTermsSnapshot, deliverablePlan, workItems, versions, and reviewEvents | `workspaceId` = `workspace with approved campaign`, `campaignId` = `versions(workspaceId, campaignId)` | 200 OK - reviewEvents() returns List<CampaignReviewEvent> ordered by createdAt desc | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `valid workspace UUID`, `campaignId` = `getDraft(workspaceId, campaignId)` | 200 OK - Completion metadata (completedAt, completedBy, completionReason, summary) included | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `valid workspace UUID`, `campaignId` = `listByWorkspace(workspaceId)` | 200 OK - Owner, Manager, Creator, and Client can view campaign in their workspace | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has no media package or 0 campaigns (empty list boundary) | `workspaceId` = `workspace with 0 campaigns`, `campaignId` = `reviewEvents(workspaceId, campaignId)` | 200 OK - listByWorkspace returns empty List.of() when workspace has no media package | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has no media package or 0 campaigns (empty list boundary) | `workspaceId` = `workspace with 0 campaigns`, `campaignId` = `reviewEvents(workspaceId, campaignId)` | 200 OK - Campaign with 1 work item and contentVersion=1 returned accurately | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `valid workspace UUID`, `campaignId` = `versions(workspaceId, campaignId)` | 200 OK - reviewEvents returns empty list when no approvals or feedback exist yet | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Campaign ID does not exist or belongs to a different workspace's media package | `workspaceId` = `non-existent workspace UUID`, `campaignId` = `getDraft(workspaceId, campaignId)` | CAMPAIGN_NOT_FOUND - 404 Media campaign ID does not exist | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Campaign ID does not exist or belongs to a different workspace's media package | `workspaceId` = `other workspace UUID`, `campaignId` = `getDraft(workspaceId, campaignId)` | CAMPAIGN_NOT_FOUND - 404 Campaign belongs to a different workspace's media package | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is not a member of the workspace | `workspaceId` = `valid workspace UUID`, `campaignId` = `getDraft(workspaceId, campaignId)` | WORKSPACE_ACCESS_DENIED - 403 Caller is not an active member of the workspace | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `non-existent workspace UUID`, `campaignId` = `non-existent campaign UUID` | WORKSPACE_NOT_FOUND - 404 Workspace does not exist | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has workspace access via CampaignWorkspaceAccess.require(workspaceId, user, false); Workspace has a WorkspaceMediaPackage and MediaCampaign | `workspaceId` = `other workspace UUID`, `campaignId` = `campaign from another workspace` | WORKSPACE_MEDIA_PACKAGE_NOT_FOUND - 404 Linked workspace media package not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.5.6`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `GET /api/v1/workspaces/{workspaceId}/campaigns · GET /api/v1/workspaces/{workspaceId}/campaigns/{campaignId} · GET /timeline · GET /versions · GET /feedback · GET /campaign-collaborators` (`WorkspaceCampaignController.list() / detail() / versions() / feedbackHistory() / tasks(), CampaignTimelineController.read(), CampaignCollaboratorController.list()` -> `MediaCampaignService, CampaignTimelineService, CampaignCollaboratorService`) enforces `BR-27` and returns standardized `ApiResponse` envelopes (`401 UNAUTHORIZED`, `403 WORKSPACE_ACCESS_DENIED` / `FORBIDDEN`, `404 CAMPAIGN_NOT_FOUND`).
- **Concurrency & Tenant Isolation:** Verified version conflict guards (`409`) and strict Workspace/Agency membership boundaries (`403`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale keys (`campaign.detail.* / campaign.timeline.* / campaign.partners.*`) and `Light` / `Dark` semantic theme rendering on `src/pages/campaign/{index,page}.tsx`, `src/pages/workspace/components/WorkspaceCampaignSummary.tsx`.
- **Traceability:** Linked to [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Media Package & Campaign Spec](../../../../ba/04-media-package-campaign.md).

