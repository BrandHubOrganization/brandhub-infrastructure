# UC — OTP Verification

| | |
|---|---|
| FR Code | 3.2.6 |
| Feature | OTP Verification |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 3.1 (2026-09-23) — phone OTP có rate-limit resend + giới hạn 5 lần thử sai |
| Trạng thái tài liệu | Confirmed — đã code |

## 1. Objective

Xác thực bằng mã OTP 6 số gửi qua email, dùng cho 2 mục đích độc lập ở BE:
1. **Email OTP** — xác thực email sau khi Sign Up (FR 3.2.1).
2. **Phone OTP** — xác thực số điện thoại khi user liên kết phone vào tài khoản (`/link/phone` + `/verify-phone-otp`).

Cả hai đều dùng chung cơ chế: sinh mã 6 số, lưu có TTL, verify giới hạn số lần sai, gửi qua email (`mailService.sendOtpEmail`) — **kể cả với "phone OTP", mã vẫn được gửi tới email của user, không phải SMS**.

## 2. User Story

Là một User đang Sign Up hoặc đang muốn liên kết số điện thoại vào tài khoản,
tôi muốn nhập mã OTP nhận được qua email,
để hoàn tất xác thực email hoặc xác thực phone.

## 3. Acceptance Criteria

- Email OTP: nhập 6 số nhận qua email ngay sau Sign Up → verify đúng thì `emailVerifiedAt` được set, verify sai được báo lỗi, quá 5 lần sai thì OTP hiện tại bị hủy.
- Nút "Gửi lại mã" (resend) có cooldown 60 giây trước khi bấm lại được (enforce ở BE qua Redis TTL).
- Phone OTP: sau khi nhập số điện thoại (`/link/phone`), nhận OTP qua email, nhập lại đúng OTP thì phone được gắn vào tài khoản.
- Phone OTP: gọi lại `/link/phone` trong vòng 60 giây → `429 RATE_LIMIT_EXCEEDED` (Redis `phone:otp:resend:{userId}`).
- Phone OTP: nhập sai 5 lần → OTP hiện tại bị hủy, trả `400 OTP_TOO_MANY_ATTEMPTS` (Redis `phone:otp:attempt:{userId}`).

## 4. UI / UX

- 2 luồng OTP độc lập ở tầng BE, có thể dùng chung 1 component nhập OTP ở FE (không bắt buộc theo spec này) nhưng gọi API khác nhau tùy ngữ cảnh (email verify vs phone verify).

## 5. API Contract (khớp code)

### 5.1 Email OTP — xác thực email (Sign Up)

```
POST /api/v1/auth/verify-otp
{ "email": "string", "otpCode": "string" }
→ 200 { "success": true, "data": null }
```

```
POST /api/v1/auth/resend-otp
{ "email": "string" }
→ 200 { "success": true, "data": null }
```

### 5.2 Phone OTP — liên kết số điện thoại (yêu cầu Bearer token)

```
POST /api/v1/auth/link/phone
Authorization: Bearer <token>
{ "phone": "string" }
→ 200 { "success": true, "data": null }
```

```
POST /api/v1/auth/verify-phone-otp
Authorization: Bearer <token>
{ "otpCode": "string" }
→ 200 { "success": true, "data": null }
```

> Không có khái niệm `otpSessionId` hay `context` (register|reset-password|2fa) như bản spec cũ đề xuất. Reset Password (FR 3.2.4) dùng token qua link, không dùng OTP. 2FA (FR 3.2.7) dùng TOTP, không dùng OTP email. Deactivate (FR 3.2.9) có OTP riêng cho flow OAuth-only user (`/deactivate/send-otp`) — **không thuộc phạm vi FR này**.

## 6. Business Rules

### 6.1 Email OTP — verify (`verifyOtp`)

- Chuẩn hóa email (lowercase, trim), không tìm thấy user → `404 USER_NOT_FOUND`.
- User đã verify (`emailVerifiedAt != null`) → return sớm, idempotent, không kiểm tra lại OTP.
- `otpExpiry == null` hoặc `otpCode == null` hoặc đã hết hạn → `400 OTP_INVALID`.
- OTP sai → tăng counter Redis `otp:attempt:{email}` (TTL 10 phút ở lần tăng đầu tiên); nếu `attempts >= 5` → xóa `otpCode`/`otpExpiry` của user, xóa counter, trả `400 OTP_TOO_MANY_ATTEMPTS`; nếu chưa tới 5 → `400 OTP_INVALID`.
- OTP đúng → xóa counter Redis, xóa `otpCode`/`otpExpiry`, set `emailVerifiedAt = now`.

### 6.2 Email OTP — resend (`resendOtp`)

- Check cooldown Redis `otp:resend:{email}` — còn hiệu lực → `429 RATE_LIMIT_EXCEEDED`.
- Không tìm thấy user → `404 USER_NOT_FOUND`.
- Đã verify → return sớm, không gửi lại.
- Sinh OTP mới (6 số), hiệu lực 10 phút, lưu vào `users.otp_code`/`users.otp_expiry`.
- Set cooldown Redis `otp:resend:{email}` TTL 60 giây, xóa counter `otp:attempt:{email}` cũ.
- Gửi email OTP mới.

### 6.3 Phone OTP — link (`linkPhone`)

- Chuẩn hóa phone qua `PhoneUtil.normalize`; không hợp lệ → `400 INVALID_PHONE`.
- Không tìm thấy user → `404 USER_NOT_FOUND`.
- Phone đã được user khác dùng (`existsByPhone`) → `409 PHONE_ALREADY_IN_USE`.
- **Rate-limit resend:** Redis key `phone:otp:resend:{userId}` còn hiệu lực → `429 RATE_LIMIT_EXCEEDED` (cooldown 60 giây).
- Sinh OTP 6 số, lưu Redis key `phone:otp:{userId}` = `"<otp>:<phone>"`, TTL 10 phút.
- Set `phone:otp:resend:{userId}` TTL 60 giây, xóa counter `phone:otp:attempt:{userId}` cũ.
- Gửi OTP qua **email** (`mailService.sendOtpEmail`), không phải SMS.

### 6.4 Phone OTP — verify (`verifyPhoneOtp`)

- Đọc Redis key `phone:otp:{userId}` — không có (hết hạn/chưa từng gọi link) → `400 OTP_INVALID`.
- Parse `"<otp>:<phone>"`; sai OTP hoặc format hỏng → tăng counter Redis `phone:otp:attempt:{userId}` (TTL 10 phút ở lần tăng đầu tiên); nếu `attempts >= 5` → xóa `phone:otp:{userId}` và counter, trả `400 OTP_TOO_MANY_ATTEMPTS`; nếu chưa tới 5 → `400 OTP_INVALID`.
- Đúng → xóa key `phone:otp:{userId}` và counter `phone:otp:attempt:{userId}`, kiểm tra lại phone đã bị người khác lấy mất chưa (race condition giữa lúc link và lúc verify) → `409 PHONE_ALREADY_IN_USE` nếu có.
- Set `user.phone`, save.

## 7. Error Handling

| Flow | Điều kiện | HTTP | ErrorCode |
|---|---|---|---|
| Email OTP verify | User không tồn tại | 404 | `USER_NOT_FOUND` |
| Email OTP verify | OTP hết hạn/null | 400 | `OTP_INVALID` |
| Email OTP verify | OTP sai (chưa tới 5 lần) | 400 | `OTP_INVALID` |
| Email OTP verify | Sai OTP lần thứ 5 | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Email OTP resend | Chưa hết cooldown 60s | 429 | `RATE_LIMIT_EXCEEDED` |
| Email OTP resend | User không tồn tại | 404 | `USER_NOT_FOUND` |
| Phone OTP link | Phone không hợp lệ | 400 | `INVALID_PHONE` |
| Phone OTP link | Phone đã được dùng | 409 | `PHONE_ALREADY_IN_USE` |
| Phone OTP link | Gọi lại trong vòng 60 giây | 429 | `RATE_LIMIT_EXCEEDED` |
| Phone OTP verify | Không có OTP session (hết hạn) | 400 | `OTP_INVALID` |
| Phone OTP verify | OTP sai (chưa tới 5 lần) | 400 | `OTP_INVALID` |
| Phone OTP verify | Sai OTP lần thứ 5 | 400 | `OTP_TOO_MANY_ATTEMPTS` |
| Phone OTP verify | Phone bị người khác lấy trước (race) | 409 | `PHONE_ALREADY_IN_USE` |

## 8. Edge Cases

- Email OTP: sai 5 lần liên tiếp → OTP hiện tại bị hủy hoàn toàn (`otpCode`/`otpExpiry` = null), bắt buộc phải resend để có mã mới.
- Phone OTP: có race condition giữa lúc gửi OTP (`linkPhone`) và lúc verify — phone có thể bị user khác chiếm trong lúc chờ, được check lại ở bước verify.
- Phone OTP: sai 5 lần liên tiếp → OTP hiện tại bị hủy (`phone:otp:{userId}` bị xóa), bắt buộc gọi lại `/link/phone` để có mã mới (giống Email OTP).
- Phone OTP: cooldown resend 60 giây (`phone:otp:resend:{userId}`) — gọi lại `/link/phone` sớm hơn sẽ bị `429`, không ghi đè OTP cũ.

## 9. Definition of Done

- Verify/resend email OTP hoạt động đúng theo Business Rules 6.1–6.2.
- Link/verify phone OTP hoạt động đúng theo Business Rules 6.3–6.4, gồm rate-limit resend 60s và giới hạn 5 lần thử sai.

## Out of Scope

- OTP qua SMS thực sự (cả email OTP và phone OTP hiện tại đều gửi qua email).
- 2FA TOTP (FR 3.2.7), Reset Password qua token (FR 3.2.4), Deactivate OTP cho OAuth-only user (FR 3.2.9).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
