# Task — OTP Verification

> [plan.md](./plan.md) | [test.md](./test.md)

## Email OTP (Sign Up)

- [x] `POST /verify-otp { email, otpCode }` — verify OTP lưu trên `users.otp_code`/`otp_expiry`.
- [x] `POST /resend-otp { email }` — sinh OTP mới + gửi, cooldown 60s.
- [x] Error `OTP_INVALID` / `OTP_TOO_MANY_ATTEMPTS` / `RATE_LIMIT_EXCEEDED` / `USER_NOT_FOUND`.
- [x] Verify đúng → `emailVerifiedAt = now`.
- [x] Giới hạn 5 lần thử sai (Redis `otp:attempt:{email}`) → hủy OTP hiện tại khi vượt ngưỡng.

## Phone OTP (liên kết số điện thoại)

- [x] `POST /link/phone { phone }` (Bearer token) — normalize phone, check trùng, sinh OTP, lưu Redis `phone:otp:{userId}`, gửi qua email.
- [x] `POST /verify-phone-otp { otpCode }` (Bearer token) — verify, check lại trùng phone (race condition), set `user.phone`.
- [x] Error `INVALID_PHONE` / `PHONE_ALREADY_IN_USE` / `OTP_INVALID`.
- [x] **[MỚI 2026-09-23]** Rate-limit resend `linkPhone`: Redis `phone:otp:resend:{userId}` TTL 60s → `429 RATE_LIMIT_EXCEEDED`.
- [x] **[MỚI 2026-09-23]** Giới hạn 5 lần thử sai `verifyPhoneOtp`: Redis `phone:otp:attempt:{userId}` (TTL 10 phút) → `400 OTP_TOO_MANY_ATTEMPTS`, xóa `phone:otp:{userId}` + counter.

## Chung

- [x] `mvn compile` pass.
- [ ] FE: màn hình nhập OTP cho luồng Sign Up và luồng liên kết phone (có thể dùng chung component UI, gọi API khác nhau).

> Note: 2FA không dùng OTP email (TOTP — FR 3.2.7); Reset Password không dùng OTP (token qua link — FR 3.2.4); Deactivate OTP (OAuth-only user) thuộc FR 3.2.9, không nằm trong task này.
