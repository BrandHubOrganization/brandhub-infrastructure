# Task — OTP Verification

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /verify-otp { email, otpCode }` — verify OTP Redis.
- [x] `POST /resend-otp { email }` — sinh OTP mới + gửi.
- [x] Error `INVALID_OTP` / `OTP_EXPIRED`.
- [x] Verify đúng → `emailVerified=true`.
- [x] `mvn compile` pass.
- [ ] Giới hạn số lần thử OTP (5 lần → hủy session) nếu chưa có.
- [ ] FE: component OTP dùng chung (context register|reset|2fa).

> Note: 2FA không dùng OTP email (TOTP — FR 3.2.7); OTP email chỉ cho register/reset.
