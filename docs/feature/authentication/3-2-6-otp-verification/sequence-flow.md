# Sequence Flow — OTP Verification

> Bổ sung cho `spec.md` (FR 3.2.6). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`AuthController`/`AuthServiceImpl`). FR 3.2.6 gồm 2 luồng OTP độc lập: **email OTP** (xác thực email lúc Sign Up, FR 3.2.1) và **phone OTP** (liên kết số điện thoại). Cả hai gửi mã qua email (`mailService.sendOtpEmail`), phone OTP không dùng SMS dù tên route là "phone". 2FA có route riêng (`/2fa/verify`, xem FR 3.2.7), Reset Password không dùng OTP (xem FR 3.2.4), Deactivate OTP cho OAuth-only user thuộc FR 3.2.9.

## Actors

- **User** — đang Sign Up (email OTP) hoặc đã đăng nhập và muốn liên kết phone (phone OTP).
- **FE** — brandhub-web-dashboard.
- **BE** — brandhub-business-service.
- **DB** — PostgreSQL (`users.otp_code`, `users.otp_expiry`, `users.phone`), Redis (`otp:attempt:{email}`, `otp:resend:{email}`, `phone:otp:{userId}`, `phone:otp:resend:{userId}`, `phone:otp:attempt:{userId}`).

---

## Flow A — Verify Email OTP đúng

1. User → FE: sau Sign Up (FR 3.2.1), ở màn OTP nhập 6 số nhận qua email.
2. FE → BE: `POST /api/v1/auth/verify-otp {email, otpCode}`.
3. BE (`AuthServiceImpl.verifyOtp`):
   a. Chuẩn hóa `email`, tìm `User` — không có → `404 USER_NOT_FOUND`.
   b. `emailVerifiedAt != null` (đã verify trước đó) → return sớm, coi như thành công (idempotent), không check lại OTP.
   c. `otpExpiry=null` hoặc `otpCode=null` hoặc đã hết hạn → `400 OTP_INVALID`.
   d. So khớp `otpCode` — sai → tăng counter Redis `otp:attempt:{email}` (đặt TTL 10 phút ở lần đầu); nếu `attempts >= 5` → xóa `otpCode`/`otpExpiry` của User, xóa counter, trả `400 OTP_TOO_MANY_ATTEMPTS`; nếu chưa tới 5 → `400 OTP_INVALID`.
   e. Đúng → xóa counter Redis, xóa `otpCode`/`otpExpiry`, set `emailVerifiedAt=now`.
4. BE → FE: `200 { success: true, data: null }`.
5. FE: tiếp tục luồng Sign Up — điều hướng `/login` để user tự đăng nhập.

## Flow B — Resend Email OTP

1. User → FE: bấm "Gửi lại mã" (nút bị disable bởi countdown FE cho tới khi hết cooldown).
2. FE → BE: `POST /api/v1/auth/resend-otp {email}`.
3. BE (`AuthServiceImpl.resendOtp`):
   a. Check Redis `otp:resend:{email}` — đã có (chưa hết cooldown 60s) → `429 RATE_LIMIT_EXCEEDED`.
   b. Tìm `User` — không có → `404 USER_NOT_FOUND`.
   c. `emailVerifiedAt != null` → return sớm, không gửi lại.
   d. Sinh OTP mới, hạn 10 phút, `UPDATE users`.
   e. `SET otp:resend:{email}="1"` TTL 60s (cooldown), xóa counter `otp:attempt:{email}`.
   f. Gửi mail OTP mới.
4. BE → FE: `200 { success: true, data: null }` (không có `nextResendAt`, FE tự quản lý countdown 60s ở client).

## Flow C — Sai Email OTP quá 5 lần

1–2. Giống Flow A bước 1–2, lặp lại 5 lần với mã sai.
3. Lần thứ 5: BE xóa `otpCode`/`otpExpiry` của User, trả `400 OTP_TOO_MANY_ATTEMPTS`.
4. FE: hiện lỗi, bắt buộc user bấm "Gửi lại mã" (Flow B) để có OTP mới.

## Flow D — Link Phone (gửi OTP)

1. User → FE: đã đăng nhập, vào màn liên kết số điện thoại, nhập số phone.
2. FE → BE: `POST /api/v1/auth/link/phone {phone}`, header `Authorization: Bearer <token>`.
3. BE (`AuthServiceImpl.linkPhone`):
   a. Chuẩn hóa `phone` qua `PhoneUtil.normalize` — không hợp lệ → `400 INVALID_PHONE`.
   b. Tìm `User` theo `userId` từ token — không có → `404 USER_NOT_FOUND`.
   c. Phone đã được user khác dùng (`existsByPhone`) → `409 PHONE_ALREADY_IN_USE`.
   d. Check Redis `phone:otp:resend:{userId}` — còn hiệu lực (chưa hết cooldown 60s) → `429 RATE_LIMIT_EXCEEDED`.
   e. Sinh OTP 6 số, `SET phone:otp:{userId}="<otp>:<phone>"` TTL 10 phút.
   f. `SET phone:otp:resend:{userId}="1"` TTL 60s (cooldown), `DEL phone:otp:attempt:{userId}` (reset counter sai).
   g. Gửi OTP qua email (`mailService.sendOtpEmail`) tới email của user — **không phải SMS**.
4. BE → FE: `200 { success: true, data: null }`.
5. FE: chuyển sang màn nhập OTP cho phone.

## Flow E — Verify Phone OTP

1. User → FE: nhập 6 số OTP nhận qua email.
2. FE → BE: `POST /api/v1/auth/verify-phone-otp {otpCode}`, header `Authorization: Bearer <token>`.
3. BE (`AuthServiceImpl.verifyPhoneOtp`):
   a. Đọc Redis `phone:otp:{userId}` — không có (hết hạn hoặc chưa từng gọi link/phone) → `400 OTP_INVALID`.
   b. Parse `"<otp>:<phone>"` — sai OTP hoặc format hỏng → tăng counter Redis `phone:otp:attempt:{userId}` (đặt TTL 10 phút ở lần tăng đầu tiên); nếu `attempts >= 5` → xóa `phone:otp:{userId}` + counter, trả `400 OTP_TOO_MANY_ATTEMPTS`; nếu chưa tới 5 → `400 OTP_INVALID`.
   c. Đúng → xóa `phone:otp:{userId}` và `phone:otp:attempt:{userId}`.
   d. Check lại `existsByPhone(phone)` (race condition: phone có thể bị user khác chiếm trong lúc chờ verify) → `409 PHONE_ALREADY_IN_USE` nếu có.
   e. Tìm `User` theo `userId` — không có → `404 USER_NOT_FOUND`.
   f. Set `user.phone = phone`, save.
4. BE → FE: `200 { success: true, data: null }`.
5. FE: hiện phone đã liên kết thành công.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Verify Email OTP | User không tồn tại | 404 | `USER_NOT_FOUND` |
| Verify Email OTP | OTP hết hạn / đã bị xóa (null) | 400 | `OTP_INVALID` |
| Verify Email OTP | OTP sai (chưa tới 5 lần) | 400 | `OTP_INVALID` |
| Verify Email OTP | Sai OTP lần thứ 5 | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Resend Email OTP | Chưa hết cooldown 60s | 429 | `RATE_LIMIT_EXCEEDED` |
| Resend Email OTP | User không tồn tại | 404 | `USER_NOT_FOUND` |
| Link Phone | Phone không hợp lệ | 400 | `INVALID_PHONE` |
| Link Phone | Phone đã được dùng | 409 | `PHONE_ALREADY_IN_USE` |
| Link Phone | Gọi lại trong vòng 60 giây (cooldown resend) | 429 | `RATE_LIMIT_EXCEEDED` |
| Verify Phone OTP | Không có OTP session (hết hạn/đã hủy) | 400 | `OTP_INVALID` |
| Verify Phone OTP | OTP sai (chưa tới 5 lần) | 400 | `OTP_INVALID` |
| Verify Phone OTP | Sai OTP lần thứ 5 | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Verify Phone OTP | Phone bị người khác lấy trước (race) | 409 | `PHONE_ALREADY_IN_USE` |

## Ghi chú drift đã fix

- Bản trước ghi "Phone OTP: không có giới hạn số lần thử sai (khác Email OTP) và không có rate-limit resend riêng ở code hiện tại". **Không còn đúng**: code hiện tại có rate-limit resend 60s cho `linkPhone` (Redis `phone:otp:resend:{userId}` → `429 RATE_LIMIT_EXCEEDED`) và giới hạn 5 lần thử sai cho `verifyPhoneOtp` (Redis `phone:otp:attempt:{userId}` → `400 OTP_TOO_MANY_ATTEMPTS`, xóa OTP). Đã cập nhật Flow D/E + bảng error paths.
