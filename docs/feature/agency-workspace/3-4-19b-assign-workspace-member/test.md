# Test Specification — FR 3.4.24: Add Workspace Member

> Note: This specification maps to official **FR 3.4.24 — Add Workspace Member** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-24-add-workspace-member/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.24` |
| **Function Name** | Add Workspace Member |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `WorkspaceServiceImpl.inviteMember()` (43 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow Owner or Manager to add or invite a member or Client to the workspace with a canonical role (MANAGER, CREATOR, CLIENT) |
| **Preconditions** | Can connect with server; Caller is Owner or Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 23** (`Passed`: 23, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 4, `Abnormal (A)`: 11 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID23`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `new@brandhub.vn`, `role` = `CREATOR` | void; invitation PENDING saved with token | Workspace invitation email sent | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `client@brandhub.vn`, `role` = `CLIENT` | void; invitation PENDING with role CLIENT | Workspace invitation email sent | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is MANAGER of workspace; Workspace has no MANAGER | `workspaceId` = `valid workspace id`, `email` = `m@brandhub.vn`, `role` = `MANAGER` | void; invitation PENDING with role MANAGER | Workspace invitation email sent | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `Mixed@BrandHub.VN`, `role` = `CREATOR` | void; email trimmed and lowercased in invitation | Workspace invitation email sent | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `new@brandhub.vn`, `role` = `CREATOR`, `note` = `Welcome aboard` | void; invitation email includes note | Workspace invitation email sent | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is MANAGER of workspace; Previous invitation for email expired | `workspaceId` = `valid workspace id`, `email` = `again@brandhub.vn`, `role` = `CREATOR` | void; new invitation PENDING saved | Workspace invitation email sent | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is MANAGER of workspace; Users are agency members | `workspaceId` = `valid workspace id`, `assignMembers` = `2 entries role=CREATOR` | AssignMembersResponse(added=2, skippedUserIds=[]) | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is MANAGER of workspace; 1 of 2 users already active member | `workspaceId` = `valid workspace id`, `assignMembers` = `2 entries role=CREATOR` | AssignMembersResponse(added=1, skippedUserIds=[existing]) | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `new@brandhub.vn`, `role` = `CREATOR`, `note` = `null` | void; invitation saved without note | Workspace invitation email sent | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `edge@brandhub.vn`, `role` = `CREATOR` | void; expiresAt = now + INVITATION_EXPIRY_DAYS | Workspace invitation email sent | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `assignMembers` = `1 entry (minimum)` | AssignMembersResponse(added=1) | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `assignMembers` = `all entries already active` | AssignMembersResponse(added=0, skippedUserIds=all) | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller is MANAGER of workspace; Email already active member | `workspaceId` = `valid workspace id`, `email` = `member@brandhub.vn`, `role` = `CREATOR` | ALREADY_IN_WORKSPACE: User is already a member of this workspace | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is MANAGER of workspace; Pending unexpired invitation exists | `workspaceId` = `valid workspace id`, `email` = `pending@brandhub.vn`, `role` = `CREATOR` | INVITATION_ALREADY_PENDING | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is MANAGER of workspace; Workspace already has active MANAGER | `workspaceId` = `valid workspace id`, `email` = `m2@brandhub.vn`, `role` = `MANAGER` | MANAGER_ALREADY_ASSIGNED | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is MANAGER of workspace; Workspace already has active MANAGER | `workspaceId` = `valid workspace id`, `assignMembers` = `1 entry role=MANAGER` | MANAGER_ALREADY_ASSIGNED | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is MANAGER of workspace; User is not agency member | `workspaceId` = `valid workspace id`, `assignMembers` = `1 entry outsider userId` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller is MANAGER of workspace; Agency member user row missing | `workspaceId` = `valid workspace id`, `assignMembers` = `1 entry ghost userId` | USER_NOT_FOUND | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller is CREATOR of workspace | `workspaceId` = `valid workspace id`, `email` = `new@brandhub.vn`, `role` = `CREATOR` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `not-an-email`, `role` = `CREATOR` | VALIDATION_ERROR: invalid email (MSG04) | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `null`, `role` = `CREATOR` | VALIDATION_ERROR: email required (MSG02) | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `email` = `new@brandhub.vn`, `role` = `OWNER` | VALIDATION_ERROR: invalid role (MSG95) | — | **Passed** |
| `UTCID23` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `assignMembers` = `empty list` | VALIDATION_ERROR: at least one entry required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.24`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).
