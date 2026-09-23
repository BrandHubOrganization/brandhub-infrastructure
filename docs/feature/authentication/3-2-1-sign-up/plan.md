# Plan — Sign Up

> [spec.md](./spec.md) — Đăng ký email + xác thực OTP, chuẩn hóa email case-insensitive.

## Kỹ thuật

- `controller/AuthController.java` `POST /api/v1/auth/register` → 201.
- `service/AuthServiceImpl.register()`: chuẩn hóa email (lowercase local-part) → check tồn tại (case-insensitive) → hash bcrypt → tạo User `emailVerified=false` → gửi OTP (FR 3.2.6) → trả `RegisterResponse(otpSessionId, email)`.
- Khác spec API: spec đề xuất `{otpSessionId, email}` — code trả `RegisterResponse` tương đương.
- OTP verify xong (FR 3.2.6) → set `emailVerified=true`, tự login.

## Luồng

1. Validate email/password → 400 `VALIDATION_ERROR`/`WEAK_PASSWORD`.
2. Chuẩn hóa email → tồn tại? → 409 `EMAIL_ALREADY_EXISTS`.
3. Tạo User + gửi OTP → trả otpSessionId.
4. `verifyOtp` đúng → `emailVerified=true` + issue token (login).

## Data Model

- `users`: email (unique, lưu lowercase), passwordHash (bcrypt), emailVerified.

## Rủi ro

- User enum bằng email: giữ response chung, không tiết lộ (đã chốt). Dùng OTP session qua Redis.
