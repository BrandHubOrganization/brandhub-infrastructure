# Task — Verify / resend OTP

## Backend
- [x] Endpoint `POST /auth/verify-otp` nhận `{email, otpCode}`.
- [x] Tìm user; không thấy → `INVALID_OTP` (message chung).
- [x] So otpCode + kiểm tra expiry.
- [x] Đã verify → idempotent, trả success.
- [x] Sai/hết hạn → `INVALID_OTP`.
- [x] Đúng → set `emailVerifiedAt`, xóa otp.
- [x] Endpoint `POST /auth/resend-otp` nhận `{email}`.
- [x] Tạo OTP mới, set `otpCode/otpExpiry`, gửi email.
- [x] Không thấy user → vẫn trả success.
- [x] Rate limiting: Redis `otp:resend:{email}` TTL 60s, chặn gửi lại quá nhanh.
- [x] Đã verify → trả success, không gửi lại.

## Frontend
- [x] `authService.verifyOtp` + `authService.resendOtp`.
- [x] VerifyOtpPage form 6 số + countdown gửi lại.
- [x] Xử lý 400 → báo OTP sai.
