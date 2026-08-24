# Plan — Verify / resend OTP

## Mục tiêu
Implement `POST /auth/verify-otp` xác thực OTP, và `POST /auth/resend-otp` gửi lại mã.

## Thành phần liên quan
- `AuthController` — 2 route.
- `AuthService` — tạo/validate OTP.
- `User` model — field `otpCode`, `otpExpiry`, `emailVerifiedAt`.
- `UserRepository` — tìm user theo email + lưu.
- `MailService` + SMTP — gửi OTP qua email.
- Frontend: `authService.verifyOtp`, `authService.resendOtp`, VerifyOtpPage.

## Luồng dữ liệu — verify
1. Nhận `{email, otpCode}` → trim/lowercase email.
2. Tìm user. Không thấy → `INVALID_OTP` (message chung).
3. So `otpCode` với OTP lưu, kiểm tra `otpExpiry` còn hiệu lực.
4. Sai / hết hạn → `INVALID_OTP`.
5. Đúng → set `emailVerifiedAt`, xóa `otpCode/otpExpiry`.
6. Trả success.

## Luồng dữ liệu — resend
1. Nhận email → tìm user.
2. Không thấy → vẫn trả success (chống rò email).
3. Tạo OTP mới, set `otpCode/otpExpiry`.
4. Gửi email. Trả success.

## Thứ tự build
1. verify-otp (validate + set verified).
2. resend-otp (tạo + gửi mới).
3. Xóa OTP sau khi dùng.
4. Frontend page + service.

## Rủi ro
- Rò email → message chung, luôn trả success khi email không tồn tại.
- OTP tái sử dụng → xóa sau verify.
