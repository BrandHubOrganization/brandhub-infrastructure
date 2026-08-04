# Task — Quên / đặt lại mật khẩu

## Backend
- [ ] Endpoint `POST /auth/forgot-password` nhận `{email}`.
- [ ] Tìm user; không thấy → vẫn trả success (chống rò email).
- [ ] Tạo token, lưu Redis `pwd:reset:{token}` = userId, TTL.
- [ ] Gửi email link reset qua SMTP.
- [ ] Endpoint `POST /auth/reset-password` nhận `{token, newPassword}`.
- [ ] Validate token từ Redis → hết hạn/sai → `INVALID_OR_EXPIRED_TOKEN`.
- [ ] Hash password mới, set `passwordHash` + `lastPasswordChange`.
- [ ] Xóa token sau khi dùng.
- [ ] Trả success.

## Frontend
- [ ] `authService.forgotPassword` + `authService.resetPassword`.
- [ ] ForgotPasswordPage form email + state success.
- [ ] ResetPasswordPage đọc token từ URL, form password mới.
- [ ] Xử lý 400 token lỗi → thông báo + link yêu cầu lại.
