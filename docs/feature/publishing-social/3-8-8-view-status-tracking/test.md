# Test Specification — FR 3.8.7: Track Post Status

> Note: This specification maps to official **FR 3.8.7 — Track Post Status** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-7-track-post-status/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.7` |
| **Function Name** | Track Post Status |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `PostServiceImpl.getPostStatus()` (36 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Track publishing lifecycle status (PENDING, IN_PROGRESS, PUBLISHED, FAILED) with retry counter and manual retry for failed jobs |
| **Preconditions** | Can connect with server; Post job exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MEMBER of workspace; Post status PENDING | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - status=PENDING | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of workspace; Post status IN_PROGRESS | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - status=IN_PROGRESS | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of workspace; Post status DONE | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - status=DONE | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MEMBER of workspace; Post status FAIL | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - status=FAIL, failReason present | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MEMBER of workspace; FAIL reason TOKEN_EXPIRED | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - failReason=TOKEN_EXPIRED | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MEMBER of workspace; FAIL due to account disconnected | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - failReason=account disconnected | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MEMBER of workspace; Status just changed to DONE | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - latest status returned | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MEMBER of workspace; Post DONE | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - no failReason field | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of workspace; Post just created | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - initial status PENDING | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MEMBER of workspace; FAIL reason 1000 chars | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - long failReason returned intact | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MEMBER of workspace; FAIL with null reason | `workspaceId` = `valid workspace`, `postId` = `valid post` | 200 - status=FAIL, failReason omitted | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `postId` = `null` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `postId` = `non-existent id` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `postId` = `post of other workspace` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `non-existent id`, `postId` = `valid post` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is not workspace member | `workspaceId` = `valid workspace`, `postId` = `valid post` | FORBIDDEN: access denied | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Token missing | `workspaceId` = `valid workspace`, `postId` = `valid post` | UNAUTHORIZED: authentication required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.7`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
