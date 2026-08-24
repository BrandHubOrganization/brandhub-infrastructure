# Plan — Quên / đặt lại mật khẩu

## Mục tiêu
Implement `POST /auth/forgot-password` gửi link reset, và `POST /auth/reset-password` đặt mật khẩu mới bằng token.

## Thành phần liên quan
- `AuthController` — 2 route.
- `AuthService` — logic tạo/validate token, đặt mật khẩu.
- `StringRedisTemplate` (Redis) — lưu token `pwd:reset:{token}` → userId, TTL `PASSWORD_RESET_TTL_SECONDS` (3600).
- `PasswordResetToken` model — (nếu dùng DB) hoặc Redis-only.
- `MailService` + SMTP (`brandhub404@gmail.com`) — gửi email.
- `FRONTEND_URL` — build link reset `{FRONTEND_URL}/reset-password?token=...`.
- `BCryptPasswordEncoder` — hash password mới.
- Frontend: `authService.forgotPassword`, `authService.resetPassword`, 2 page.

## Luồng dữ liệu — forgot
1. Nhận email → trim/lowercase.
2. Tìm user. Không thấy → vẫn trả success (chống rò email).
3. Tạo token ngẫu nhiên → lưu Redis `pwd:reset:{token}` = userId, TTL.
4. Gửi email chứa link `{FRONTEND_URL}/reset-password?token={token}`.
5. Trả success.

## Luồng dữ liệu — reset
1. Nhận `{token, newPassword}`.
2. Đọc Redis `pwd:reset:{token}`. Không có → `INVALID_OR_EXPIRED_TOKEN`.
3. Lấy user → hash password mới → set `passwordHash`, `lastPasswordChange`.
4. Xóa token Redis (dùng 1 lần).
5. Trả success.

## Thứ tự build
1. forgot-password (token + email).
2. reset-password (validate + đặt mật khẩu).
3. Xóa token sau khi dùng.
4. Frontend 2 page + service.

## Rủi ro
- Rò email → luôn trả success dù email không tồn tại.
- Token tái sử dụng → xóa sau khi dùng.
- Email không gửi được (SMTP lỗi) → log + vẫn trả success (tránh lộ).
