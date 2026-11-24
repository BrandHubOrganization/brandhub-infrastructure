> **Navigation:** [← Domain Index](../README.md) · [Spec](./spec.md) · [Plan](./plan.md) · [Task](./task.md) · **Test**

# Test Specification — FR 3.6.20: Apply Hashtag

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.20` |
| **Function Name** | Apply Hashtag |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `HashtagServiceImpl.add()` (30 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/HashtagServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Insert and normalize '#' hashtags from workspace collections into a task draft while deduplicating and checking platform limits |
| **Preconditions** | Can connect with server; Caller is Creator or Manager in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 18** (`Passed`: 18, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 4, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID18`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `1 existing id` | 200 OK - task hashtags list with 1 item | Hashtags applied | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `3 existing ids` | 200 OK - task hashtags list with 3 items | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Task of type Post exists; User is CLIENT | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `2 existing ids` | 200 OK - task hashtags list with 2 items | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `new tag not in Collection` | 200 OK - tag auto-created in Collection and attached | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `mix existing + new tag` | 200 OK - all attached, new one added to Collection | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists; Task already has hashtags | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `different ids` | 200 OK - hashtags replaced by new list | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists; Required hashtag exists in Collection | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `required hashtag id` | 200 OK - required hashtag attached | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `empty list` | 200 OK - all hashtags cleared | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `1 id` | 200 OK - single hashtag | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `max allowed ids` | 200 OK - max hashtags attached | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `max allowed + 1 ids` | 400 VALIDATION_ERROR (too many hashtags) | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `id from another workspace` | 400 INVALID_HASHTAG | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `soft-deleted hashtag id` | 400 INVALID_HASHTAG | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `null` | 400 VALIDATION_ERROR (hashtagIds required) | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task does not exist | `workspaceId` = `valid`, `taskId` = `non-existent`, `hashtagIds` = `1 existing id` | 404 TASK_NOT_FOUND | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task is not of type Post | `workspaceId` = `valid`, `taskId` = `survey task`, `hashtagIds` = `1 existing id` | 400 INVALID_TASK_TYPE | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Task of type Post exists; User is MANAGER without edit right | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `1 existing id` | 403 FORBIDDEN | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Task of type Post exists | `workspaceId` = `valid`, `taskId` = `valid`, `hashtagIds` = `duplicate ids` | 400 INVALID_HASHTAG (duplicate) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with `brandhub-final_report/report5/Report5_Unit Test.xls` sheet `FR3.6.20`, `brandhub-final_report/report5/Report5_Test Report.xlsx`, and `brandhub-final_report/report5/Report5_Test Documentation.docx`.
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

## 4. Integration & Cross-Cutting Verification Notes

- **Controller & Service Alignment:** Verified `GET /api/v1/workspaces/{workspaceId}/hashtags · POST /api/v1/workspaces/{workspaceId}/tasks/{taskId}/post · PATCH /api/v1/workspaces/{workspaceId}/posts/{postId}` (`HashtagController.list(), TaskPostController.save(), PostController.updateDraft(), AiCaptionController`) returns standardized `ApiResponse` envelopes and accurate `ErrorCode` mappings.
- **Workspace & Audience Isolation:** Verified cross-workspace and unauthorized role requests are rejected (`403 FORBIDDEN` / `WORKSPACE_ACCESS_DENIED`).
- **UI, i18n & Theme Parity:** Verified parallel `VI` / `EN` locale bundles and `Light` / `Dark` semantic theme contrast across Web and Mobile surfaces.
- **Traceability:** Aligned with [spec.md](./spec.md), [plan.md](./plan.md), [task.md](./task.md), and [BA Content & Workflow Spec](../../../../ba/05-content-task-workflow.md).
