# Test Specification — FR 3.8.4: View Posted Detail

> Note: This specification maps to official **FR 3.8.4 — View Posted Detail** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-4-view-posted-detail/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.4` |
| **Function Name** | View Posted Detail |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `PostServiceImpl.getPostTrackDetail()` (30 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Return published post details including permalink, published timestamp, and engagement metrics (reactions, comments, shares, views) |
| **Preconditions** | Can connect with server; Published post exists in workspace |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 3, `Abnormal (A)`: 6 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MEMBER of workspace; Post DONE on FACEBOOK | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - platformPostUrl, reactionCount, commentCount, shareCount | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of workspace; Post DONE on INSTAGRAM | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - counts and link of Instagram post | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of workspace; Post DONE on TIKTOK | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - counts and link of TikTok video | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MEMBER of workspace; Post DONE on THREADS | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - counts and link of Threads post | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MEMBER of workspace; Platform metrics API OK | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - fresh metrics with lastUpdatedAt = now | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MEMBER of workspace; Platform rate-limited, cache exists | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - cached metrics with older lastUpdatedAt timestamp | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MEMBER of workspace; Post has 5 reactions | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - reactionCount=5 | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MEMBER of workspace; Post has platformPostUrl | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - link opens original platform post | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of workspace; Post has zero engagement | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - reaction/comment/share all 0 | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MEMBER of workspace; Post has 2147483647 reactions | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - reactionCount=2147483647 | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MEMBER of workspace; Platform rate-limited, no cache | `workspaceId` = `valid workspace`, `postId` = `published post` | 200 - counts 0/null with no timestamp | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `postId` = `null` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `postId` = `non-existent id` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of workspace; Post PENDING (not published) | `workspaceId` = `valid workspace`, `postId` = `unpublished post` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MEMBER of workspace; Post FAIL | `workspaceId` = `valid workspace`, `postId` = `failed post` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of workspace; Post belongs to other workspace | `workspaceId` = `valid workspace`, `postId` = `post of other workspace` | POST_NOT_FOUND: Post not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not workspace member | `workspaceId` = `valid workspace`, `postId` = `published post` | FORBIDDEN: access denied | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.4`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
