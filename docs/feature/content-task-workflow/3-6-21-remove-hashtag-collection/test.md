# Test Specification — FR 3.6.24: Remove Hashtag Collection

> Note: This specification maps to official **FR 3.6.24 — Remove Hashtag Collection** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-24-remove-hashtag-collection/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.24` |
| **Function Name** | Remove Hashtag Collection |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `HashtagServiceImpl.remove()` (22 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/HashtagServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | Soft-delete a hashtag collection from the workspace library while keeping hashtags already applied to existing posts |
| **Preconditions** | Can connect with server; Hashtag collection exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 16** (`Passed`: 16, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID16`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - success=true, data=null | Hashtag soft-deleted | **Passed** |
| `UTCID02` | `N` | Can connect with server; Hashtag exists in workspace; User is CLIENT | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - success=true, data=null | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace; Hashtag applied to old Tasks | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - old Tasks still show the hashtag | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - status=removed | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - hashtag no longer in selection list | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Hashtag exists in workspace; User is CREATOR or MANAGER; Hashtag is required, set by Client | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - required hashtag removed | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace; Hashtag not used by any Task | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - soft-deleted | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Collection has exactly 1 hashtag | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - collection becomes empty | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace; Hashtag applied to many Tasks | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - all Task references kept | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag exists in workspace | `workspaceId` = `valid`, `hashtagId` = `valid` | 200 OK - removedAt set once | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Hashtag exists in workspace; User has no permission | `workspaceId` = `valid`, `hashtagId` = `valid` | 403 FORBIDDEN | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag does not exist | `workspaceId` = `valid`, `hashtagId` = `non-existent` | 404 HASHTAG_NOT_FOUND | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag already removed | `workspaceId` = `valid`, `hashtagId` = `removed` | 404 HASHTAG_NOT_FOUND | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace does not exist | `workspaceId` = `non-existent`, `hashtagId` = `valid` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtag belongs to another workspace | `workspaceId` = `valid`, `hashtagId` = `other workspace hashtag` | 404 HASHTAG_NOT_FOUND | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Hashtag exists in workspace; User not authenticated | `workspaceId` = `valid`, `hashtagId` = `valid` | 401 UNAUTHORIZED | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.24`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
