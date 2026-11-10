# Plan — Reset Password

> [spec.md](./spec.md) — Quên mật khẩu, gửi token/OTP email, đổi mật khẩu + revoke session cũ.

## Quyết định cơ chế (spec để mở: link HOẶC OTP)

Chốt dùng **token qua email** (đồng bộ với code hiện có `forgotPassword` + `resetPassword`), KHÔNG dùng OTP riêng cho reset.

## Kỹ thuật

- `POST /api/v1/auth/forgot-password { email }` → luôn 200 (không tiết lộ email tồn tại); nếu tồn tại → xoá token reset cũ (nếu có, qua reverse-index) → sinh token reset mới (Redis TTL) + gửi email.
- `POST /api/v1/auth/reset-password { token, newPassword }` → verify token → hash bcrypt → set `lastPasswordChange=now` (refresh token cũ tự invalid khi so `issuedAt` với `lastPasswordChange`, không phải revoke chủ động) → 200.
- Token sai/hết hạn/đã invalidate → 400 `RESET_TOKEN_INVALID`. Token đã dùng (race) → 400 `RESET_TOKEN_USED`.

## Luồng

1. forgot: normalize email → tồn tại? → đọc `pwd:reset:user:{userId}` lấy `oldToken` (nếu có) → xoá `pwd:reset:{oldToken}` → sinh token mới → lưu `pwd:reset:{token}=userId` và `pwd:reset:user:{userId}=token` (cùng TTL) → gửi email. Luôn 200.
2. reset: verify token → xoá `pwd:reset:{token}` (atomic) → xoá `pwd:reset:user:{userId}` (dọn reverse-index) → set password mới + `lastPasswordChange=now` → audit log `PASSWORD_RESET` → 200.

## Data Model

- Redis: `pwd:reset:{token}` → userId (TTL = `appProperties.passwordResetTtlSeconds`); `pwd:reset:user:{userId}` → token hiện hành (reverse-index, cùng TTL, dùng để invalidate token cũ khi có request mới).
- `users.passwordHash`, `users.lastPasswordChange` cập nhật.

## Rủi ro

- Spam: email không tồn tại vẫn 200 → không gửi thật (tránh enumeration + spam).
