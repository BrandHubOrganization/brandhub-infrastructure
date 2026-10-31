# Test Specification — FR 3.6.21: View Hashtag Collection

> Note: This specification maps to official **FR 3.6.21 — View Hashtag Collection** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-6-21-view-hashtag-collection/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.6.21` |
| **Function Name** | View Hashtag Collection |
| **Functional Domain** | Content & Task |
| **Canonical Actors / Roles** | `Owner, Manager, Creator, Client` |
| **Target Class & Method** | `HashtagServiceImpl.list()` (24 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/HashtagServiceImplTest.java` |
| **Code & Test Author** | Tuấn |
| **Test Requirement** | List and search hashtag collections in a workspace filtered by purpose (Brand Core, Campaign, Seasonal, Mandatory Client) |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has hashtags | `workspaceId` = `valid` | 200 OK - list of {id, tag, purpose, addedBy, isRequired} | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is CLIENT; Client added a required hashtag | `workspaceId` = `valid` | 200 OK - item with isRequired=true | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is CREATOR; Creator added an optional hashtag | `workspaceId` = `valid` | 200 OK - item with isRequired=false | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Hashtags of mixed purposes | `workspaceId` = `valid` | 200 OK - items include purpose brand/campaign/trending/event-specific | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has hashtags | `workspaceId` = `valid` | 200 OK - addedBy identifies the author | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has hashtags | `workspaceId` = `valid`, `purpose` = `campaign` | 200 OK - only campaign hashtags | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has removed hashtags | `workspaceId` = `valid` | 200 OK - excludes status=removed hashtags | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is CREATOR or CLIENT of workspace; Two workspaces have hashtags | `workspaceId` = `valid` | 200 OK - only this workspace hashtags | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has no hashtags | `workspaceId` = `valid` | 200 OK - empty list | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has exactly 1 hashtag | `workspaceId` = `valid` | 200 OK - list with 1 item | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has 1000 hashtags | `workspaceId` = `valid` | 200 OK - full list returned | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is CREATOR or CLIENT of workspace; Only removed hashtags exist | `workspaceId` = `valid` | 200 OK - empty list | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is not a member of workspace | `workspaceId` = `valid` | 403 FORBIDDEN | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User not authenticated | `workspaceId` = `valid` | 401 UNAUTHORIZED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace | `workspaceId` = `non-existent` | 404 WORKSPACE_NOT_FOUND | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is CREATOR or CLIENT of workspace; Workspace has hashtags | `workspaceId` = `valid`, `purpose` = `unknown purpose` | 400 VALIDATION_ERROR (invalid purpose) | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MANAGER not in workspace | `workspaceId` = `valid` | 403 FORBIDDEN | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.6.21`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
