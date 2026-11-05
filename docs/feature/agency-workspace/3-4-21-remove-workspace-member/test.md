# Test Specification — FR 3.4.26: Remove Workspace Member

> Note: This specification maps to official **FR 3.4.26 — Remove Workspace Member** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-26-remove-workspace-member/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.26` |
| **Function Name** | Remove Workspace Member |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `WorkspaceServiceImpl.removeMember()` (28 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow Owner or Manager to remove a member from the workspace while retaining their historical contributions and agency membership |
| **Preconditions** | Can connect with server; Caller is Owner or Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 20** (`Passed`: 20, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 8 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID20`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; member isActive=false | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CLIENT | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; member isActive=false | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is MANAGER of workspace; Member is MANAGER; Another MANAGER exists | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; member isActive=false | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; updatedAt set, row kept (soft delete) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; member absent from FR 3.4.18 list afterwards | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; agency membership unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR; Workspace has other members | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; other members unaffected | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is MANAGER of workspace; Another MANAGER exists; Caller removes self | `workspaceId` = `valid workspace id`, `memberId` = `own member id of caller` | void; caller membership isActive=false | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is MANAGER of workspace; Member is MANAGER; Another active MANAGER exists | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; member isActive=false (exactly 2 MANAGER rows) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is MANAGER of workspace; Member is only active MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is MANAGER of workspace; Workspace has 2 members (CREATOR + caller MANAGER) | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; CREATOR removed, MANAGER remains | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR; Only MANAGER is another user | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | void; guard skipped for non-MANAGER | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `memberId` = `non-existent id` | NOT_FOUND | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `memberId` = `null` | NOT_FOUND | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is MANAGER of workspace; Member already isActive=false | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | NOT_FOUND | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is MANAGER of workspace; Member belongs to other workspace | `workspaceId` = `valid workspace id`, `memberId` = `member of other workspace` | NOT_FOUND | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is MANAGER of workspace; Sole MANAGER removes self | `workspaceId` = `valid workspace id`, `memberId` = `own member id of caller` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller is CREATOR of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller is CLIENT of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller not member of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.26`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
