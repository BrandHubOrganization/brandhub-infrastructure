# Task — Verify / resend OTP

## Backend
- [ ] Endpoint `POST /auth/verify-otp` nhận `{email, otpCode}`.
- [ ] Tìm user; không thấy → `INVALID_OTP` (message chung).
- [ ] So otpCode + kiểm tra expiry.
- [ ] Sai/hết hạn → `INVALID_OTP`.
- [ ] Đúng → set `emailVerifiedAt`, xóa otp.
- [ ] Endpoint `POST /auth/resend-otp` nhận `{email}`.
- [ ] Tạo OTP mới, set `otpCode/otpExpiry`, gửi email.
- [ ] Không thấy user → vẫn trả success.

## Frontend
- [ ] `authService.verifyOtp` + `authService.resendOtp`.
- [ ] VerifyOtpPage form 6 số + countdown gửi lại.
- [ ] Xử lý 400 → báo OTP sai.
