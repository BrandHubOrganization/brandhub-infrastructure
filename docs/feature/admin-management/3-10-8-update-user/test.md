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
