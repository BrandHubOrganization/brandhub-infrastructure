# Task — Đổi mật khẩu

## Backend
- [ ] Endpoint `POST /auth/change-password` (cần JWT).
- [ ] Lấy userId từ token.
- [ ] Verify `currentPassword` BCrypt → sai → `INVALID_CURRENT_PASSWORD`.
- [ ] Hash `newPassword`, set `passwordHash` + `lastPasswordChange`.
- [ ] Trả success.
- [ ] Xử lý 401 khi thiếu token.

## Frontend
- [ ] `authService.changePassword`.
- [ ] Form đổi mật khẩu (current, new, confirm) trong settings.
- [ ] Xử lý 400 → báo current password sai.
