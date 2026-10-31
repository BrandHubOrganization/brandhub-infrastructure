# Test Specification — FR 3.8.3: View Dashboard Post

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.3` |
| **Function Name** | View Dashboard Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `PostServiceImpl.getDashboard()` (38 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Return publishing dashboard metrics, platform distribution (Facebook, Instagram, TikTok, Threads), and recent published posts |
| **Preconditions** | Can connect with server; Caller is a member of the workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MEMBER of workspace; Workspace has 10 posts: 8 DONE, 2 FAIL | `workspaceId` = `valid workspace` | 200 - totalPosts=10, successRate=80 | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of workspace; Posts on FACEBOOK and TIKTOK | `workspaceId` = `valid workspace` | 200 - byPlatform={FACEBOOK:n, TIKTOK:m} | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of workspace; All posts DONE | `workspaceId` = `valid workspace` | 200 - successRate=100 | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MEMBER of workspace; All posts FAIL | `workspaceId` = `valid workspace` | 200 - successRate=0 | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MEMBER of workspace; Posts on 4 platforms | `workspaceId` = `valid workspace` | 200 - byPlatform has 4 entries | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MEMBER of workspace; Mixed statuses incl. PENDING | `workspaceId` = `valid workspace` | 200 - PENDING not counted as failure | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MEMBER of workspace; Other workspace has posts | `workspaceId` = `valid workspace` | 200 - only current workspace counted | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace` | 200 - data has totalPosts, byPlatform, successRate | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of workspace; Workspace has no posts | `workspaceId` = `valid workspace` | 200 - totalPosts=0, byPlatform empty/0, successRate=0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MEMBER of workspace; Workspace has 1 DONE post | `workspaceId` = `valid workspace` | 200 - totalPosts=1, successRate=100 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MEMBER of workspace; Workspace has 3 posts: 1 DONE, 2 FAIL | `workspaceId` = `valid workspace` | 200 - successRate rounded 33.33 | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MEMBER of workspace; Workspace has 100000 posts | `workspaceId` = `valid workspace` | 200 - totals computed without overflow | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `null` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `non-existent id` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is not workspace member | `workspaceId` = `valid workspace` | FORBIDDEN: access denied | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Token missing | `workspaceId` = `valid workspace` | UNAUTHORIZED: authentication required | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is MEMBER of workspace; Workspace is soft-deleted | `workspaceId` = `deleted workspace` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.3`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
