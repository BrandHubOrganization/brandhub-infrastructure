# UC — Two-Factor Authentication (2FA, TOTP)

| | |
|---|---|
| FR Code | 3.2.7 |
| Feature | Two-Factor Authentication (2FA, TOTP) |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.1 (2026-09-23) — field response `/2fa/setup` đổi `qrCodeUrl` → `otpAuthUrl` |
| Trạng thái tài liệu | Confirmed — đã code (setup/confirm/disable/verify) |

## 1. Objective

Cho phép user bật 2FA bằng TOTP (scan QR vào app Authenticator) hoặc nhập OTP — đơn giản hóa so với hiện trạng bằng cách BỎ tính năng copy secret key và bỏ backup codes.

## 2. User Story

Là một User quan tâm bảo mật,
tôi muốn bật 2FA cho tài khoản,
để tăng an toàn khi đăng nhập.

## 3. Acceptance Criteria

- Setup 2FA: hiển thị QR code để scan vào app Authenticator (Google Authenticator, Authy...).
- **KHÔNG hiển thị nút copy secret key** (thay đổi so với hiện trạng — giảm bề mặt tấn công, tránh user paste secret key ra nơi không an toàn).
- **KHÔNG cung cấp backup codes** (thay đổi so với hiện trạng — đơn giản hóa UI, giảm surface quản lý).
- Sau khi scan, user nhập mã OTP từ app để confirm 2FA đã setup đúng → bật `twoFactorEnabled=true`.
- Khi login (FR 3.2.2), nếu `twoFactorEnabled=true` → sau email/password đúng, yêu cầu nhập mã OTP từ app trước khi cấp token.
- **[CHỐT 2026-09-20]** Áp dụng cho **mọi phương thức đăng nhập**, kể cả Google OAuth (FR 3.2.3): sau khi Google xác thực email, nếu `twoFactorEnabled=true` → yêu cầu nhập TOTP trước khi cấp token.

## 4. UI / UX

- Trang `/settings/security` phần 2FA — chỉ hiển thị QR (FE render từ `data.otpAuthUrl`), không có nút copy/download backup codes.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/2fa/setup   (Authorization: Bearer — bắt buộc)
→ 200 { "success": true, "data": { "otpAuthUrl": "string" } }   -- otpauth://totp/... URI để FE render QR
-- KHÔNG trả secretKey plain text trong response cho FE hiển thị/copy
-- Secret sinh mới CHƯA lưu DB, chỉ lưu tạm Redis (TTL 10 phút) chờ /confirm

POST /api/v1/auth/2fa/confirm   (Authorization: Bearer — bắt buộc)
{ "code": "string" }   -- 6 số
→ 200 { "success": true, "data": null }

POST /api/v1/auth/2fa/disable   (Authorization: Bearer — bắt buộc)
{ "code": "string" }   -- 6 số
→ 200 { "success": true, "data": null }

POST /api/v1/auth/2fa/verify   (PUBLIC — không cần Bearer, dùng trong luồng login khi user đã bật 2FA)
{ "twoFactorToken": "string", "code": "string" }
→ 200 { "success": true, "data": { "accessToken", "tokenType", "expiresIn", "requireTwoFactor": false } }
  + Set-Cookie refreshToken (giống login thường)
```

## 6. Error Handling

| ErrorCode | HTTP | Route | Ý nghĩa |
|---|---|---|---|
| `TWO_FA_ALREADY_ENABLED` | 400 | setup, confirm | 2FA đã bật sẵn cho user |
| `TWO_FA_NOT_ENABLED` | 400 | confirm, disable, verify | confirm/verify: không có secret pending trong Redis (hết hạn 10 phút hoặc chưa gọi `/setup`) — **tên mã hơi phản trực giác, không có nghĩa đen "2FA chưa bật"** ở case confirm; disable/verify: user thực sự chưa bật 2FA hoặc `totpSecret=null` |
| `TWO_FA_CODE_INVALID` | 400 | confirm, disable, verify | Mã TOTP nhập sai |
| `TWO_FA_TOKEN_INVALID` | 401 | verify | `twoFactorToken` không parse được, sai claim `type`, hoặc user trong token không tồn tại |
| `ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` | 403 | verify | Tài khoản bị khóa/vô hiệu hóa (check giống login thường) |

- User mất access app Authenticator, không còn backup codes để khôi phục → PHẢI liên hệ support/Admin để disable 2FA thủ công (chấp nhận trade-off vì đã bỏ backup codes).

## 7. Edge Cases

- User bật 2FA rồi đổi điện thoại mất app Authenticator → không có backup code tự phục hồi, đây là hệ quả đã biết của quyết định bỏ backup codes, cần Admin can thiệp (xem FR 3.10.5).

## 8. Definition of Done

- Setup/confirm/disable 2FA hoạt động, KHÔNG có UI copy secret hay backup codes ở bất kỳ đâu.

## Out of Scope

- Backup codes, SMS-based 2FA (đã loại khỏi scope theo yêu cầu đơn giản hóa).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
