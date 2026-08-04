# Task — Quên / đặt lại mật khẩu

## Backend
- [x] Endpoint `POST /auth/forgot-password` nhận `{email}`.
- [x] Tìm user; không thấy → vẫn trả success (chống rò email).
- [x] Tạo token ngẫu nhiên 64 hex chars, lưu Redis `pwd:reset:{token}` = userId, TTL.
- [x] Gửi email link reset qua SMTP (`MailService.sendPasswordResetEmail`).
- [x] Endpoint `POST /auth/reset-password` nhận `{token, newPassword}`.
- [x] Validate token từ Redis → không có → `RESET_TOKEN_INVALID`.
- [x] Token đã dùng → `RESET_TOKEN_USED` (xóa atomically trước khi dùng).
- [x] Hash password mới (BCrypt), set `passwordHash` + `lastPasswordChange`.
- [x] Xóa token Redis sau khi dùng (single-use).
- [x] Ghi audit PASSWORD_RESET.
- [x] Trả success.

## Frontend
- [x] `authService.forgotPassword` + `authService.resetPassword`.
- [x] ForgotPasswordPage form email + state success.
- [x] ResetPasswordPage đọc token từ URL, form password mới.
- [x] Xử lý 400 token lỗi → thông báo + link yêu cầu lại.
