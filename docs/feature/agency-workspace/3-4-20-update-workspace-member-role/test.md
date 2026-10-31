# Test Specification — FR 3.4.25: Update Workspace Member Role

> Note: This specification maps to official **FR 3.4.25 — Update Workspace Member Role** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-25-update-workspace-member-role/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.25` |
| **Function Name** | Update Workspace Member Role |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner, Manager` |
| **Target Class & Method** | `WorkspaceServiceImpl.updateMemberRole()` (30 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow Owner or Manager to change a workspace member's role while enforcing at least one active Manager in the workspace |
| **Preconditions** | Can connect with server; Caller is Owner or Manager |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 22** (`Passed`: 22, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 9, `Boundary (B)`: 4, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID22`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | WorkspaceMemberResponse(role=CLIENT) | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CLIENT | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | WorkspaceMemberResponse(role=CREATOR) | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR; Workspace has no MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `MANAGER` | WorkspaceMemberResponse(role=MANAGER) | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller is MANAGER of workspace; Member is MANAGER; Another MANAGER exists | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | WorkspaceMemberResponse(role=CREATOR) | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | WorkspaceMemberResponse(role=CREATOR) unchanged | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller is MANAGER of workspace; Member is MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `MANAGER` | WorkspaceMemberResponse(role=MANAGER) unchanged | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller is MANAGER of workspace; Member is CLIENT with clientProfileId | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | Response with fullName=null, email=null, clientProfileId kept | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; Caller is MANAGER of workspace; Another MANAGER exists; Caller demotes self | `workspaceId` = `valid workspace id`, `memberId` = `own member id of caller`, `newRole` = `CREATOR` | WorkspaceMemberResponse(role=CREATOR) | — | **Passed** |
| `UTCID09` | `N` | Can connect with server; Caller is MANAGER of workspace; Member role is CREATOR | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | Response keeps joinedAt, updatedAt refreshed | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller is MANAGER of workspace; Member is MANAGER; Another active MANAGER exists | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | WorkspaceMemberResponse(role=CLIENT) with exactly 2 MANAGER rows | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; Caller is MANAGER of workspace; Member is only active MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `MANAGER` | WorkspaceMemberResponse(role=MANAGER) no guard triggered | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; Caller is MANAGER of workspace; Member is only active MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; Caller is MANAGER of workspace; Workspace has exactly 1 member (the MANAGER) | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller is MANAGER of workspace; Caller demotes self; Member is only active MANAGER | `workspaceId` = `valid workspace id`, `memberId` = `own member id of caller`, `newRole` = `CREATOR` | LAST_MANAGER_CANNOT_BE_REMOVED | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller is MANAGER of workspace; Another active MANAGER exists | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `MANAGER` | MANAGER_ALREADY_ASSIGNED | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `memberId` = `non-existent id`, `newRole` = `CREATOR` | NOT_FOUND | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller is MANAGER of workspace; Member isActive=false | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CREATOR` | NOT_FOUND | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; Caller is MANAGER of workspace; Member belongs to other workspace | `workspaceId` = `valid workspace id`, `memberId` = `member of other workspace`, `newRole` = `CREATOR` | NOT_FOUND | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; Caller is CREATOR of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; Caller not member of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `CLIENT` | FORBIDDEN: Only Owner or Manager can perform this action | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `OWNER` | VALIDATION_ERROR: invalid role (MSG95) | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; Caller is MANAGER of workspace | `workspaceId` = `valid workspace id`, `memberId` = `valid active member id`, `newRole` = `null` | VALIDATION_ERROR: role required (MSG95) | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.25`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Update Workspace Member Role (FR 3.4.20)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | MANAGER đổi role member CREATOR → CLIENT (không liên quan MANAGER) | AC | 200; `role=CLIENT`, không guard nào kích hoạt | Happy path | Pass |
| TC-02 | MANAGER đổi role member CREATOR → MANAGER khi workspace chưa có MANAGER | AC (thăng quyền) | 200; `role=MANAGER` | Happy path | Pass |
| TC-03 | Non-MANAGER (CREATOR/CLIENT) gọi endpoint | AC | 403 `FORBIDDEN` (qua `@RequireRole`) | Error case | Pass |
| TC-04 | `memberId` không tồn tại | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-05 | `memberId` thuộc workspace khác (không khớp `workspaceId`) | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-06 | `memberId` đã inactive | Error (mục 6) | 404 `NOT_FOUND` | Error case | Pass |
| TC-07 | Đổi role MANAGER duy nhất xuống CREATOR/CLIENT | AC (giảm quyền) | 409 `LAST_MANAGER_CANNOT_BE_REMOVED` | Error case | Pass |
| TC-08 | Đổi role MANAGER xuống CREATOR khi còn MANAGER khác active | AC (giảm quyền) | 200; thành công, workspace vẫn còn ≥1 MANAGER | Edge case | Pass |
| TC-09 | Thăng role CREATOR → MANAGER khi workspace đã có MANAGER active | AC (thăng quyền) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-10 | Đổi role sang cùng giá trị hiện tại (CREATOR → CREATOR) | Edge (mục 7) | 200; no-op, role không đổi | Edge case | Pass |
| TC-11 | MANAGER đổi role chính mình xuống CREATOR khi là MANAGER duy nhất | Edge (mục 7) | 409 `LAST_MANAGER_CANNOT_BE_REMOVED` (không có ngoại lệ tự đổi) | Edge case | Pass |
| TC-12 | `role` thiếu/null trong request body | Error (mục 6) | 400 `VALIDATION_ERROR` (`@NotNull`) | Error case | Pass |
