# Plan — Reset Password

> [spec.md](./spec.md) — Quên mật khẩu, gửi token/OTP email, đổi mật khẩu + revoke session cũ.

## Quyết định cơ chế (spec để mở: link HOẶC OTP)

Chốt dùng **token qua email** (đồng bộ với code hiện có `forgotPassword` + `resetPassword`), KHÔNG dùng OTP riêng cho reset.

## Kỹ thuật

- `POST /api/v1/auth/forgot-password { email }` → luôn 200 (không tiết lộ email tồn tại); nếu tồn tại → sinh token reset (Redis TTL) + gửi email.
- `POST /api/v1/auth/reset-password { token, newPassword }` → verify token → hash bcrypt → **revoke toàn bộ refresh token cũ** của user → 200.
- Token/OTP sai/hết hạn → 400 `INVALID_OR_EXPIRED_TOKEN`.

## Luồng

1. forgot: normalize email → tồn tại? → sinh+store token → gửi email. Luôn 200.
2. reset: verify token → set password mới → blacklist tất cả refresh token cũ → 200.

## Data Model

- Redis: `reset:token:{...}` (TTL ngắn).
- `users.passwordHash` cập nhật.

## Rủi ro

- Spam: email không tồn tại vẫn 200 → không gửi thật (tránh enumeration + spam).
