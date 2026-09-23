# Plan — OTP Verification

> [spec.md](./spec.md) — 2 luồng OTP độc lập: email OTP (xác thực email Sign Up) + phone OTP (liên kết số điện thoại), cả hai gửi mã qua email.

## Quyết định API

Không có API tổng quát `otpSessionId` + `context` như bản spec cũ. Code hiện tại dùng 2 cặp API tách biệt theo mục đích:
- `POST /api/v1/auth/verify-otp { email, otpCode }` + `POST /api/v1/auth/resend-otp { email }` — email OTP, không cần token.
- `POST /api/v1/auth/link/phone { phone }` + `POST /api/v1/auth/verify-phone-otp { otpCode }` — phone OTP, cần Bearer token (user đã đăng nhập).

2FA dùng TOTP riêng (FR 3.2.7), KHÔNG qua OTP email. Reset Password dùng token qua link (FR 3.2.4), KHÔNG dùng OTP.

## Kỹ thuật

- `AuthServiceImpl.verifyOtp(email, otpCode)` / `resendOtp(email)`: OTP lưu trực tiếp trên `users.otp_code`/`users.otp_expiry` (không phải Redis), Redis chỉ giữ counter sai (`otp:attempt:{email}`) và cooldown resend (`otp:resend:{email}`).
- `AuthServiceImpl.linkPhone(userId, phone)` / `verifyPhoneOtp(userId, otpCode)`: OTP + phone lưu chung 1 giá trị Redis `phone:otp:{userId}` = `"<otp>:<phone>"`, TTL 10 phút. Không có bảng nào lưu OTP phone ngoài Redis. Kèm 2 key phụ: `phone:otp:resend:{userId}` (cooldown 60s) và `phone:otp:attempt:{userId}` (đếm số lần sai, TTL 10 phút).
- Cả 2 luồng đều gửi mã qua `mailService.sendOtpEmail` — phone OTP cũng đi qua email, không phải SMS dù tên field/route là "phone".

## Data Model

- Email OTP: cột `users.otp_code`, `users.otp_expiry`; Redis `otp:attempt:{email}` (TTL 10 phút), `otp:resend:{email}` (TTL 60s).
- Phone OTP: Redis `phone:otp:{userId}` (TTL 10 phút), `phone:otp:resend:{userId}` (TTL 60s), `phone:otp:attempt:{userId}` (TTL 10 phút) — không có cột DB riêng, chỉ `users.phone` được set sau khi verify thành công.

## Rủi ro

- Email OTP: brute force → giới hạn 5 lần thử (đã code), hủy OTP hiện tại khi vượt ngưỡng.
- Phone OTP brute force: đã bổ sung giới hạn 5 lần thử sai (`phone:otp:attempt:{userId}`) — hủy OTP hiện tại khi vượt ngưỡng, và rate-limit resend 60s (`phone:otp:resend:{userId}`).
- Phone OTP có race condition giữa link và verify (phone bị chiếm bởi user khác) — đã code check lại ở bước verify.
