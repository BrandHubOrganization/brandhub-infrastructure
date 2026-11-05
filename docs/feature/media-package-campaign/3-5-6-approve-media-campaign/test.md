# Test Specification — FR 3.5.8: Approve Media Campaign

> Note: This specification maps to official **FR 3.5.8 — Approve Media Campaign** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-5-8-approve-media-campaign/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.5.8` |
| **Function Name** | Approve Media Campaign |
| **Functional Domain** | Media Package |
| **Canonical Actors / Roles** | `Owner, Manager, Client` |
| **Target Class & Method** | `MediaCampaignServiceImpl.approveCampaign()` (35 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/MediaCampaignServiceImplTest.java` |
| **Code & Test Author** | Lộc |
| **Test Requirement** | Record dual Agency and Client approval on the media campaign and deploy planned work items into workspace backlog tasks |
| **Preconditions** | Can connect with server; Campaign exists and plan is complete |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 10, `Boundary (B)`: 3, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Campaign exists in DRAFT; User is MANAGER of workspace | `campaignId` = `valid` | Agency timestamp set; campaign not yet deployable | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Campaign exists in DRAFT; User is OWNER of agency | `campaignId` = `valid` | Agency timestamp set; not deployable | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Campaign exists in DRAFT; User is CLIENT of workspace | `campaignId` = `valid` | Client timestamp set; not deployable | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Campaign exists in DRAFT; User is CLIENT of workspace; Agency already approved | `campaignId` = `valid` | Both approvals; campaign deployable | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Campaign exists in DRAFT; User is MANAGER of workspace; Client already approved | `campaignId` = `valid` | Both approvals; campaign deployable | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Campaign fully approved, 3 work items | `campaignId` = `valid`, `op` = `deploy` | 3 backlog tasks created with campaignId, no assignee; status IN_PROGRESS | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Campaign fully approved, 1 work item | `campaignId` = `valid`, `op` = `deploy` | 1 task with workspaceId, type, name, dueDate, status=backlog | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Campaign already deployed | `campaignId` = `valid`, `op` = `deploy` | Retry: same task count and identities, no duplicates | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Deploy partially failed in Mongo | `campaignId` = `valid`, `op` = `deploy` | Retry upserts remaining items on {campaignId, workItemId}; no duplicates | — | **Passed** |
| `UTCID10` | `N` | Can connect with server; Caller already approved this campaign | `campaignId` = `valid` | Idempotent response; no change | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Campaign fully approved, 1 work item | `campaignId` = `valid`, `op` = `deploy`, `workItems` = `1 item` | Boundary: single task created | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Campaign fully approved, no work items | `campaignId` = `valid`, `op` = `deploy`, `workItems` = `0 items` | No tasks created; status transitions to APPROVED | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Campaign exists in DRAFT; Agency already approved; Campaign content edited after agency approval | `campaignId` = `valid` | Prior approvals invalidated for new version | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Only one party approved | `campaignId` = `valid`, `op` = `deploy` | Campaign not fully approved (409) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Campaign exists in DRAFT | `campaignId` = `non-existent` | Campaign not found (404) | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Campaign exists in DRAFT; User not a workspace member | `campaignId` = `valid` | WORKSPACE_ACCESS_DENIED: You do not have access to this workspace | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Campaign exists in DRAFT; User has other role (e.g. VIEWER) | `campaignId` = `valid` | FORBIDDEN: Your role does not have permission to perform this action | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Campaign is not DRAFT (e.g. IN_PROGRESS) | `campaignId` = `valid` | Campaign not approvable in current state (409) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.5.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test - FR 3.5.6

| Case | Expected result |
|---|---|
| One approval | Campaign remains unapproved. |
| Both approvals | Campaign becomes deployable. |
| Deploy | One backlog task per work item with `campaignId`. |
| Retry/double deploy | Same task count and identities; no duplicates. |
| Partial Mongo failure | Retry completes remaining work safely. |
| Edit after one party approved | Version increments and both prior approvals become invalid. |
| Approve with stale version | Conflict; no approval granted to unseen content. |
| Same actor attempts to approve both sides | Cannot satisfy two-party consent. |
| Edit fully approved content | Rejected; operational progress remains separately updateable. |
| Service restart during deployment | Durable progress permits retry; no missing/duplicate tasks. |
| Retry after Creator edited a generated Task | Existing Task content/status/assignee remain intact. |
| Cross-Workspace ID substitution | Access denied; no approval, deployment or notification leakage. |
| Generated Post task opened in Content Writing | Resolves the same agreed Task identity and existing editor works. |
| Locale/theme/mobile | Approval, error and retry states render in vi/en and both themes. |
| Client feedback then Manager edit | Feedback does not directly change terms; Manager edit resets both approvals. |
| Complete without Manager action | No automatic completion solely from aggregate Task status. |
| Manager complete action | Authorization and actor/time recorded; child tasks are not implicitly completed. |
| Complete with unfinished Tasks | Blank reason rejected; valid reason completes Campaign without changing Task states. |
| Task continues after Campaign completed | Existing permissions/workflow still apply; Campaign completion does not implicitly lock Task. |
| Editor WebSocket SEND/SUBSCRIBE to foreign Task | Rejected despite valid login token. |
| Mongo unavailable while completing | Campaign stays IN_PROGRESS; no zero-task assumption. |
| Existing PostgreSQL Task before cutover | Migration aborts until ID/content has been reconciled. |

Stage 3 targeted service tests cover stale version, two-sided approval, feedback
without version change, edit reset, no-op edit and immutable approved content.
Stage 4 unit tests cover deterministic Task ID, insert-only retry, storage failure,
completion reason and missing Task detection. PostgreSQL migration passed locally
with preflight counts 0/0/0; Atlas `brandhub` preflight found no `tasks` collection.
The initial Mongo migration attempt was rejected by automatic approval review.
Migration and verification instructions were subsequently supplied to the user;
the resulting Atlas schema has not yet been independently verified. Authenticated
end-to-end deploy/editor tests remain pending.
See [phase-1 test matrix](../phase-1-design/test.md).

2026-10-10 review: full Business Service suite passed (416 passed, 31 skipped,
zero failures/errors); Web lint/type-check/production build passed. This review
did not run migrations or change live data. Approval UI and duplicate/deployment
flows still require authenticated browser/API verification beyond mocked draft tests.
