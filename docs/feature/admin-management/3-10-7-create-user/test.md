# Test — 3-10-7-create-user

Các kỳ vọng chi tiết: Acceptance Criteria/Edge Cases trong [spec](spec.md) và mục 2 của [plan kỹ thuật](../plan.md).

- [x] Unique email (so sánh lowercase, `EMAIL_ALREADY_EXISTS`)
- [x] password policy (≥8 ký tự, có số và ký tự đặc biệt; server `WEAK_PASSWORD`, UI khóa nút)
- [x] mandatory email (luôn xếp email kích hoạt vào outbox, không có tùy chọn bỏ qua)
- [x] PENDING_VERIFICATION, 0 thẻ phạt, gói yêu cầu không cấp quyền trả phí
- [x] activation replay/expiry (dùng 1 lần; gửi lại thu hồi link cũ; hết hạn 72h)
- [x] chưa kích hoạt không vào app (`AuthServiceImpl.checkStatus` → `EMAIL_NOT_VERIFIED`; kiểm bằng smoke)
- [x] VI/EN và light/dark

- [x] Chưa đăng nhập 401; USER gọi Admin 403; ADMIN hợp lệ mới được thao tác.
- [x] Lỗi server không báo thành công, không mất dữ liệu form; nút khóa khi đang gửi.
- [x] Không trả passwordHash/otpCode/totpSecret hoặc token trong danh sách/audit (token chỉ lưu SHA-256).

## Kết quả (2026-10-04)

- `AdminUserProvisioningDatabaseTest` 3/3 trên PostgreSQL 17 DB test `brandhub_admin_20261001_test`; `AdminSecurityTest` 15/15 (401/403, payload create/patch, trang kích hoạt công khai kể cả khi còn Bearer cũ).
- Full Business suite: 387 test, 0 failure, 11 error baseline (WorkspaceController/WorkspaceTemplate thiếu mock `RequireRoleAspect`, có từ upstream).
- Playwright `tests/e2e/admin/*` + `notifications/system-inbox.spec.ts` 39/39 pass (gồm `user-provisioning.spec.ts` 3/3).
- Smoke thật trên DB dev: tạo user → email kích hoạt trong outbox → mở link, đặt mật khẩu → đăng nhập thành công (ACTIVE, đã xác thực email); audit CREATE → ACCOUNT_ACTIVATION → LOGIN.
