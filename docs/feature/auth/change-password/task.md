# Task — Đổi mật khẩu

## Backend
- [x] Endpoint `POST /auth/change-password` (cần JWT).
- [x] Lấy userId từ token.
- [x] Verify `currentPassword` BCrypt → sai → `WRONG_CURRENT_PASSWORD`.
- [x] Hash `newPassword`, set `passwordHash` + `lastPasswordChange`.
- [x] Trả success.
- [x] Xử lý 401 khi thiếu token.

## Frontend
- [x] `authService.changePassword`.
- [x] Form đổi mật khẩu (current, new, confirm) trong settings.
- [x] Xử lý 400 → báo current password sai.
