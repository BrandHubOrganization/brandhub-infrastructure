# Test Specification — FR 3.8.6: Schedule Platform Post

> Note: This specification maps to official **FR 3.8.6 — Schedule Platform Post** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-8-6-schedule-platform-post/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.8.6` |
| **Function Name** | Schedule Platform Post |
| **Functional Domain** | Publishing |
| **Canonical Actors / Roles** | `Owner, Manager, Creator` |
| **Target Class & Method** | `PostServiceImpl.reschedule()` (46 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/PostServiceImplTest.java` |
| **Code & Test Author** | Phước |
| **Test Requirement** | Schedule an APPROVED post for future publication (>= 5 minutes ahead in workspace timezone) across selected social accounts |
| **Preconditions** | Can connect with server; Post is APPROVED and social account connected |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 5 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is MEMBER of workspace; 3 scheduled posts in 2026-09 | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - 3 items {postId, platform, scheduledAt} | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is MEMBER of workspace; Workspace timezone Asia/Ho_Chi_Minh | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - scheduledAt in workspace timezone (+07:00) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is MEMBER of workspace; Workspace timezone UTC | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - scheduledAt in UTC | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is MEMBER of workspace; Posts on 4 platforms | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - each item carries its platform | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is MEMBER of workspace; Posts in other months | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - only September posts returned | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is MEMBER of workspace; Posts PENDING and DONE | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - items sorted by scheduledAt ascending | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is MEMBER of workspace; Month has no scheduled posts | `workspaceId` = `valid workspace`, `month` = `2026-10` | 200 - empty list | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is MEMBER of workspace; Other workspace has posts | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - only current workspace posts | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is MEMBER of workspace; Post at 2026-09-01 00:00 workspace tz | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - post included in September | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is MEMBER of workspace; Post at 2026-09-30 23:59 workspace tz | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - post included in September | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is MEMBER of workspace; Post 2026-09-30 20:00 UTC, tz +07:00 | `workspaceId` = `valid workspace`, `month` = `2026-09` | 200 - post shown on 2026-10-01 in October | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is MEMBER of workspace; Leap year | `workspaceId` = `valid workspace`, `month` = `2028-02` | 200 - includes 29 Feb posts | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `month` = `2026-13` | VALIDATION_ERROR: invalid month format | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `month` = `invalid` | VALIDATION_ERROR: invalid month format | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `valid workspace`, `month` = `null` | VALIDATION_ERROR: month is required | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is MEMBER of workspace | `workspaceId` = `non-existent id`, `month` = `2026-09` | WORKSPACE_NOT_FOUND: Workspace not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is not workspace member | `workspaceId` = `valid workspace`, `month` = `2026-09` | FORBIDDEN: access denied | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.8.6`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
