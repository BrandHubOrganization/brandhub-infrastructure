# Test Specification — FR 3.10.8: Update User

## 1. Traceability & Execution Summary

| Field | Value |
| :--- | :--- |
| **FR ID** | `FR 3.10.8` |
| **Function Name** | Update User |
| **Functional Domain** | Admin |
| **Canonical Actors / Roles** | `Admin` |
| **Target Class & Method** | `AdminUserProvisioningService.update()` (36 LOC) |
| **Unit Test File** | `brandhub-business-service/src/test/java/com/brandhub/business/service/admin/AdminUserProvisioningServiceTest.java` |
| **Code & Test Author** | Ân |
| **Test Requirement** | Allow Admin to update a user's fullName, phone, or system role while protecting the last active Admin account |
| **Preconditions** | Can connect with server; Caller has ADMIN system role |
| **Overall Status** | **Passed (100%)** |
| **Test Case Breakdown** | **Total: 17** (`Passed`: 17, `Failed`: 0, `Untested`: 0) — `Normal (N)`: 7, `Boundary (B)`: 3, `Abnormal (A)`: 7 |

---

## 2. Unit Test Case Matrix (`UTCID01`–`UTCID17`)

| Test Case ID | Type | Preconditions | Test Inputs | Expected Return / Exception | Log Message | Status |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| `UTCID01` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `fullName` = `New Name` | 200 OK - updated user with new fullName | — | **Passed** |
| `UTCID02` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists; New email not used | `userId` = `valid user id`, `email` = `new unused email` | 200 OK - updated user with new email | — | **Passed** |
| `UTCID03` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `plan` = `PRO` | 200 OK - updated user with plan=PRO | — | **Passed** |
| `UTCID04` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists; New email not used | `userId` = `valid user id`, `fullName` = `New Name`, `email` = `new unused email`, `plan` = `PRO` | 200 OK - updated user with all fields changed | — | **Passed** |
| `UTCID05` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `email` = `same email as current` | 200 OK - updated user, email unchanged, no conflict | — | **Passed** |
| `UTCID06` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id` | 200 OK - updated user, nothing changed | — | **Passed** |
| `UTCID07` | `N` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `fullName` = `Padded Name` | 200 OK - updated user, fullName trimmed | — | **Passed** |
| `UTCID08` | `B` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `fullName` = `1 char name` | 200 OK - updated user | — | **Passed** |
| `UTCID09` | `B` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `fullName` = `max length name` | 200 OK - updated user | — | **Passed** |
| `UTCID10` | `B` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `email` = `email at 255 chars` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID11` | `A` | Can connect with server; Target user exists; Caller does not have ADMIN system role | `userId` = `valid user id`, `fullName` = `New Name` | BusinessException(FORBIDDEN) - Your role does not have permission to perform this action | — | **Passed** |
| `UTCID12` | `A` | Can connect with server; Caller has ADMIN system role | `userId` = `non-existent id`, `fullName` = `New Name` | BusinessException(USER_NOT_FOUND) - User not found | — | **Passed** |
| `UTCID13` | `A` | Can connect with server; Caller has ADMIN system role; Target user exists; Email used by another user | `userId` = `valid user id`, `email` = `existing other email` | BusinessException(EMAIL_ALREADY_EXISTS) - This email is already associated with another account | — | **Passed** |
| `UTCID14` | `A` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `email` = `invalid email format` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID15` | `A` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `fullName` = `empty` | BusinessException(INVALID_REQUEST) - Invalid request format or parameters | — | **Passed** |
| `UTCID16` | `A` | Can connect with server; Caller has ADMIN system role; Target user exists | `userId` = `valid user id`, `plan` = `UNKNOWN_PLAN` | BusinessException(PLAN_NOT_FOUND) - Plan not found | — | **Passed** |
| `UTCID17` | `A` | Can connect with server; Caller has ADMIN system role; Target user is soft-deleted | `userId` = `deleted user id`, `fullName` = `New Name` | BusinessException(USER_NOT_FOUND) - User not found | — | **Passed** |

---

## 3. Synchronization & Verification Notes

- Synchronized 1-to-1 with [`Report5_Unit Test.xls`](../../../../brandhub-final_report/report5/Report5_Unit%20Test.xls) sheet `FR3.10.8`, [`Report5_Test Report.xlsx`](../../../../brandhub-final_report/report5/Report5_Test%20Report.xlsx), and [`Report5_Test Documentation.docx`](../../../../brandhub-final_report/report5/Report5_Test%20Documentation.docx).
- Role names strictly follow the 6 canonical roles (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`).

---

## 4. Feature Acceptance & Integration Verification

# Test — 3-10-8-update-user

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 2 của [plan kỹ thuật](../plan.md).

- [x] Email immutable (`EMAIL_IMMUTABLE`; UI chỉ đọc, không gửi trường email)
- [x] peer ADMIN và chính mình: không đổi vai trò (`USER_ROLE_PROTECTED`; UI khóa kèm lý do)
- [x] chủ Agency không chuyển thành ADMIN tại đây; hồ sơ vẫn sửa được
- [x] next-cycle chưa thanh toán không đổi quota/MRR (`subscription_plan_changes` PENDING, `payment_required`)
- [x] `rowVersion` cũ → 409 `ADMIN_STATE_CONFLICT`, lý do < 5 ký tự → 400
- [x] VI/EN và light/dark

- [x] Chưa đăng nhập 401; USER gọi Admin 403; ADMIN hợp lệ mới được thao tác.
- [x] Lỗi server không báo thành công, không mất dữ liệu form; nút khóa khi đang gửi.
- [x] Không trả passwordHash/otpCode/totpSecret hoặc token trong danh sách/audit.

## Kết quả (2026-10-04)

- `AdminUserProvisioningDatabaseTest` 3/3 trên PostgreSQL 17 DB test `brandhub_admin_20261001_test`; `AdminSecurityTest` 15/15 (401/403, payload create/patch, trang kích hoạt công khai kể cả khi còn Bearer cũ).
- Full Business suite: 387 test, 0 failure, 11 error baseline (WorkspaceController/WorkspaceTemplate thiếu mock `RequireRoleAspect`, có từ upstream).
- Playwright `tests/e2e/admin/*` + `notifications/system-inbox.spec.ts` 39/39 pass (gồm `user-provisioning.spec.ts` 3/3).
- Smoke thật trên DB dev: tạo user → email kích hoạt trong outbox → mở link, đặt mật khẩu → đăng nhập thành công (ACTIVE, đã xác thực email); audit CREATE → ACCOUNT_ACTIVATION → LOGIN.
