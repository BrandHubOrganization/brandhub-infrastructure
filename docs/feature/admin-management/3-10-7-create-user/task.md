# Task — 3-10-7-create-user

- [x] Đối chiếu spec và quyết định ngày 2026-10-01.
- [x] Viết plan kỹ thuật và kịch bản test trước code.
- [x] Migration `2026-10-05-admin-user-provisioning.sql` (`users.require_password_reset`, `account_activation_tokens`, `subscription_plan_changes`); chạy 2 lần trên DB test, backup, 2 lần trên DB dev; đã gộp vào 2 init SQL.
- [x] `POST /api/v1/admin/users`: email unique (chuẩn hóa lowercase), họ tên 2–100, mật khẩu tạm tùy chọn theo policy, trạng thái `PENDING_VERIFICATION`, 0 thẻ phạt, gói yêu cầu chỉ ghi nhận (không cấp quyền trả phí).
- [x] Link kích hoạt bắt buộc qua outbox email: token 32 byte, lưu SHA-256, dùng 1 lần, hết hạn 72h; gửi lại thu hồi link cũ (`POST /users/{id}/activation`).
- [x] Mật khẩu tạm: nút Tạo ngẫu nhiên trong dialog; email gửi kèm mật khẩu tạm + link đổi mật khẩu; mật khẩu tạm chỉ dùng để kích hoạt, không đăng nhập trực tiếp (người dùng chọn 2026-10-04).
- [x] Trang công khai `/activate-account`: xác thực email + tự đặt mật khẩu; đăng nhập trước kích hoạt bị chặn `EMAIL_NOT_VERIFIED`.
- [x] Audit CREATE / ACCOUNT_ACTIVATION, không ghi mật khẩu/token.
- [x] UI: nút "Tạo người dùng" trong `/admin?view=users`, dialog tạo; locale VI/EN; light/dark.
- [x] Chạy test/build; ghi kết quả trong test.md.
- [ ] Review độc lập diff trước khi push.
