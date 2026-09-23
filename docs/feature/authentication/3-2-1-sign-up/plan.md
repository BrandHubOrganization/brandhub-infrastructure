# Plan — Sign Up

> [spec.md](./spec.md) — Đăng ký email + xác thực OTP, chuẩn hóa email case-insensitive.

## Kỹ thuật

- `controller/AuthController.java` `POST /api/v1/auth/register` → 201.
- `service/AuthServiceImpl.register()`: chuẩn hóa email (lowercase+trim) → `INSERT users` (email unique constraint làm luôn việc check tồn tại — trùng thì `DataIntegrityViolationException`) → hash bcrypt → sinh OTP 6 số (10 phút) → gửi OTP (FR 3.2.6) → trả `RegisterResponse(userId)`.
- Response thật: `RegisterResponse(userId)` — không có `otpSessionId`/`email`.
- OTP verify xong (FR 3.2.6 `verifyOtp`) → chỉ set `emailVerifiedAt=now`, KHÔNG tự login. User tự gọi `/login` sau.

## Luồng

1. Validate email/password/fullName (Bean Validation) → 400 `VALIDATION_ERROR`.
2. Chuẩn hóa email → `INSERT` User, nếu trùng unique constraint → 409 `EMAIL_ALREADY_EXISTS`.
3. Tạo User (chưa verify) + gửi OTP đồng bộ → trả `{userId}`.
4. `verifyOtp` đúng → set `emailVerifiedAt=now`. Không issue token — user tự `/login`.

## Data Model

- `users`: email (unique, lưu lowercase+trim), passwordHash (bcrypt), emailVerifiedAt, otpCode, otpExpiry.

## Rủi ro

- OTP sai 5 lần liên tiếp → xoá OTP, ném `OTP_TOO_MANY_ATTEMPTS`, đếm qua Redis key `otp:attempt:`.
- Resend OTP rate-limit 60s qua Redis key `otp:resend:`.
