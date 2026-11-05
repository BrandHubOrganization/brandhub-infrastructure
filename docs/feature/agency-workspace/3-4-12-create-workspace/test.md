# Test Specification — FR 3.4.14: Create Workspace

> Note: This specification maps to official **FR 3.4.14 — Create Workspace** in the 141 Atomic CRUD FR baseline (canonical folder: `../3-4-14-create-workspace/`).

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.4.14` |
| **Function Name** | Create Workspace |
| **Functional Domain** | Agency & Workspace |
| **Canonical Actors / Roles** | `Owner` |
| **Target Class & Method** | `WorkspaceServiceImpl.createWorkspace()` (68 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/WorkspaceServiceTest.java` |
| **Code & Test Author** | Trung |
| **Test Requirement** | Allow the Owner to create a workspace with required Manager assignment, IANA timezone configuration, and initial members |
| **Preconditions** | Can connect with server; User is Owner of agency |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 22** (`Passed`: 22, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 8, `Boundary (B)`: 5, `Abnormal (A)`: 9 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID22`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | WorkspaceResponse(name=Acme Studio); creator saved as MANAGER | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `industry` = `MARKETING`, `companySize` = `18568.0`, `website` = `https://acme.vn`, `phone` = `901234567.0`, `location` = `HCMC` | WorkspaceResponse with extended profile fields | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `brandColor` = `#FF5500`, `logoIcon` = `star`, `tagline` = `We grow brands`, `foundedYear` = `2015.0` | WorkspaceResponse with brand fields | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `facebookUrl` = `valid url`, `linkedinUrl` = `valid url`, `instagramUrl` = `valid url` | WorkspaceResponse with social links | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=B role=CREATOR` | WorkspaceResponse; member B added as CREATOR; creator stays MANAGER | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=B role=MANAGER` | WorkspaceResponse; creator demoted to CREATOR, B is MANAGER | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `2 entries, 1 other user role=MANAGER` | WorkspaceResponse; exactly 1 MANAGER in workspace | — | **Passed** |
| `UTCID08` | `N` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `industryFields` = `[tech, retail]` | WorkspaceResponse; industryFields saved in settings | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `1 char` | WorkspaceResponse(name length 1) | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `max length name` | WorkspaceResponse(name at max length) | — | **Passed** |
| `UTCID11` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `empty list` | WorkspaceResponse; only creator as MANAGER | — | **Passed** |
| `UTCID12` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `null` | WorkspaceResponse; only creator as MANAGER | — | **Passed** |
| `UTCID13` | `B` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `foundedYear` = `boundary year 1900` | WorkspaceResponse(foundedYear=1900) | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; User is not member of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; User is MANAGER (not OWNER) of agency | `agencyId` = `valid agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `non-existent agency id`, `name` = `Acme Studio` | NOT_AGENCY_OWNER: Only the Owner can perform this action | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; User is OWNER of agency; Assignee is not agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=outsider role=CREATOR` | NOT_AGENCY_MEMBER: User is not a member of this agency | — | **Passed** |
| `UTCID18` | `A` | Can connect with server; User is OWNER of agency; Assignee is agency member; Assignee user row missing | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `1 entry userId=ghost` | USER_NOT_FOUND | — | **Passed** |
| `UTCID19` | `A` | Can connect with server; User is OWNER of agency; Assignee is agency member | `agencyId` = `valid agency id`, `name` = `Acme Studio`, `assignMembers` = `2 entries both role=MANAGER, different users` | MANAGER_ALREADY_ASSIGNED: second MANAGER rejected | — | **Passed** |
| `UTCID20` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `null` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID21` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `valid agency id`, `name` = `empty` | VALIDATION_ERROR: name must not be blank (MSG02) | — | **Passed** |
| `UTCID22` | `A` | Can connect with server; User is OWNER of agency | `agencyId` = `null`, `name` = `Acme Studio` | VALIDATION_ERROR: agencyId required | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.4.14`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — Create Workspace (FR 3.4.12)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Agency member tạo Workspace, không kèm `assignMembers` | AC1, AC2 | 200; Workspace tạo thành công, người tạo là MANAGER duy nhất | Happy path | Pass |
| TC-02 | Tạo kèm `assignMembers` có 1 người khác role MANAGER | AC3 | 200; người tạo xuống CREATOR, người được chỉ định là MANAGER | Happy path | Pass |
| TC-03 | Tạo kèm `assignMembers` chọn chính mình làm MANAGER | Edge (mục 7) | 200; người tạo vẫn giữ MANAGER bình thường (không coi là "người khác") | Edge case | Pass |
| TC-04 | `name` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-05 | `agencyId` thiếu | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-06 | `assignMembers` có 2 người cùng role MANAGER | Error (mục 6) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-07 | User không phải AgencyMember của `agencyId` gọi tạo | Sequence-flow error | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-08 | `assignMembers` có entry `userId` không phải AgencyMember của agency | Sequence-flow error | 403 `NOT_AGENCY_MEMBER` | Error case | Pass |
| TC-09 | `assignMembers` có entry `userId` không tồn tại trong `users` | Sequence-flow error | Lỗi `USER_NOT_FOUND` | Error case | Pass |

## Ghi chú

- TC-08, TC-09 lấy từ sequence-flow.md (2 nhánh lỗi chưa được liệt kê đầy đủ ở spec.md mục 6 — xem plan.md mục 6).
