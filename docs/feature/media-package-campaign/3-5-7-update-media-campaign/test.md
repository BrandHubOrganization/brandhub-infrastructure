# Test Specification — FR 3.5.7: Update Media Campaign

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.7` |
| **Function Name** | Update Media Campaign |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `MediaCampaignServiceImpl.updateDraft()` (47 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaCampaignServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Update DRAFT campaign plan (name, strategy, brandGuideline, timeline, workItems) with optimistic version lock and approval reset |
| **Preconditions** | Can connect with server; Campaign is in DRAFT status |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `updated name + strategy + timeline + workItems` | 200 OK - MediaCampaignResponse updated with trimmed name, strategyDetail, brandGuideline, timeline | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `updated workItems matching deliverablePlan` | 200 OK - Validated workItems updated against deliverablePlan quantities | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign with prior approvals`, `command` = `updated name + strategy + timeline + workItems` | 200 OK - contentVersion incremented (v1 -> v2) and new CampaignVersion snapshot saved | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign with prior approvals`, `command` = `updated workItems matching deliverablePlan` | 200 OK - Prior Agency and Client approval timestamps, actor IDs, and versions reset to null | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); request.expectedVersion() matches campaign.getContentVersion() | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `Client addFeedback(comment, contentVersion)` | 200 OK - Opposite side notified via UserNotificationService.campaignReview | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); request.expectedVersion() matches campaign.getContentVersion() | `campaignId` = `DRAFT campaign with prior approvals`, `command` = `Client addFeedback(comment, contentVersion)` | 200 OK - Client addFeedback saves FEEDBACK CampaignReviewEvent and notifies Agency side | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `updated name + strategy + timeline + workItems` | 200 OK - Unchanged plan returns existing campaign without incrementing contentVersion | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `updated workItems matching deliverablePlan` | 200 OK - Unchanged plan does not clear existing approval timestamps or send notification | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Submitted CampaignPlanRequest is identical to current campaign plan (no-op boundary) | `campaignId` = `DRAFT campaign (unchanged payload)`, `command` = `identical plan fields (no change)` | 200 OK - Single work item matching single deliverable quantity accepted at boundary | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Submitted CampaignPlanRequest is identical to current campaign plan (no-op boundary) | `campaignId` = `DRAFT campaign (unchanged payload)`, `command` = `identical plan fields (no change)` | 200 OK - Timeline with startDate == endDate validated and stored as JSON | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `Client addFeedback(comment, contentVersion)` | 200 OK - Trimmed campaign name comparison avoids false version bump on whitespace | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Campaign status is not DRAFT (e.g. APPROVED, IN_PROGRESS, COMPLETED) or version mismatches | `campaignId` = `APPROVED/IN_PROGRESS campaign UUID`, `command` = `updated name + strategy + timeline + workItems` | CAMPAIGN_IMMUTABLE - 409 Campaign cannot be edited when status is not DRAFT | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Campaign status is not DRAFT (e.g. APPROVED, IN_PROGRESS, COMPLETED) or version mismatches | `campaignId` = `non-existent campaign UUID`, `command` = `updated name + strategy + timeline + workItems` | CAMPAIGN_NOT_FOUND - 404 Campaign not found or does not belong to workspace | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is Client calling addFeedback on DRAFT campaign or unauthorized Creator | `campaignId` = `DRAFT campaign UUID (v1)`, `command` = `updated name + strategy + timeline + workItems` | FORBIDDEN - 403 Caller role cannot edit campaign plan (or non-CLIENT calling addFeedback) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `APPROVED/IN_PROGRESS campaign UUID`, `command` = `stale expectedVersion` | CAMPAIGN_VERSION_CONFLICT - 409 expectedVersion does not match campaign contentVersion | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has edit permission via CampaignWorkspaceAccess.require(workspaceId, user, true); Workspace has a WorkspaceMediaPackage and a MediaCampaign in DRAFT status | `campaignId` = `non-existent campaign UUID`, `command` = `allocationPeriod != null or empty deliverablePlan` | CAMPAIGN_LEGACY_TERMS - 409 Campaign has legacy allocationPeriod or empty deliverablePlan | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
