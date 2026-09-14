# UC — Two-Factor Authentication (2FA, TOTP)

| | |
|---|---|
| FR Code | 3.2.7 |
| Feature | Two-Factor Authentication (2FA, TOTP) |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

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

## 4. UI / UX

- Trang `/settings/security` phần 2FA — chỉ hiển thị QR, không có nút copy/download backup codes.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/2fa/setup
→ 200 { "success": true, "data": { "qrCodeUrl": "string" } }
-- KHÔNG trả secretKey plain text trong response cho FE hiển thị/copy

POST /api/v1/auth/2fa/confirm
{ "code": "string" }
→ 200 { "success": true, "data": null }

POST /api/v1/auth/2fa/disable
{ "code": "string" }
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Mã confirm sai lúc setup → 400 `INVALID_2FA_CODE`, không bật 2FA.
- User mất access app Authenticator, không còn backup codes để khôi phục → PHẢI liên hệ support/Admin để disable 2FA thủ công (chấp nhận trade-off vì đã bỏ backup codes).

## 7. Edge Cases

- User bật 2FA rồi đổi điện thoại mất app Authenticator → không có backup code tự phục hồi, đây là hệ quả đã biết của quyết định bỏ backup codes, cần Admin can thiệp (xem FR 3.10.5).

## 8. Definition of Done

- Setup/confirm/disable 2FA hoạt động, KHÔNG có UI copy secret hay backup codes ở bất kỳ đâu.

## Out of Scope

- Backup codes, SMS-based 2FA (đã loại khỏi scope theo yêu cầu đơn giản hóa).

## Tham chiếu BA

[02_Authentication_Profile.md](../../../BA/02_Authentication_Profile.md)
