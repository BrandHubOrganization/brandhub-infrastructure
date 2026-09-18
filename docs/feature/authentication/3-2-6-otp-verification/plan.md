# Plan — OTP Verification

> [spec.md](./spec.md) — Component dùng chung cho OTP (register/reset/2FA).

## Quyết định API (khác spec API đề xuất)

Spec đề xuất API tổng quát `POST /otp/verify {otpSessionId, code, context}` + `POST /otp/resend`. **Code hiện tại dùng email-based**:
- `POST /api/v1/auth/verify-otp { email, otpCode }`
- `POST /api/v1/auth/resend-otp { email }`

Giữ nguyên pattern email-based (đồng bộ với FR 3.2.1 Sign Up). 2FA dùng TOTP riêng (FR 3.2.7), KHÔNG qua OTP email.

## Kỹ thuật

- `AuthServiceImpl.verifyOtp(email, otpCode)`: check OTP Redis (TTL) → đúng → `emailVerified=true` + (tùy context) auto login. Sai → `INVALID_OTP`/`OTP_EXPIRED`.
- `resendOtp(email)`: sinh OTP mới + gửi + cập nhật countdown.

## Data Model

- Redis `otp:{email}` (TTL, giới hạn số lần thử).

## Rủi ro

- Brute force OTP → giới hạn 5 lần thử (spec), hủy session khi vượt.
