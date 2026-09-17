# UC — Reset Password

| | |
|---|---|
| FR Code | 3.2.4 |
| Feature | Reset Password |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép user quên mật khẩu lấy lại quyền truy cập qua email — gửi link đổi mật khẩu hoặc mã OTP để xác nhận trước khi đổi.

## 2. User Story

Là một User quên mật khẩu,
tôi muốn nhận link/OTP qua email để đặt lại mật khẩu,
để khôi phục quyền truy cập tài khoản.

## 3. Acceptance Criteria

- User nhập email tại `/forgot-password` → hệ thống gửi **link đổi mật khẩu HOẶC mã OTP** (1 trong 2 cơ chế, cần chốt khi thiết kế kỹ thuật — CSV liệt kê cả hai như phương án tương đương).
- Xác nhận qua link/OTP thành công → cho phép nhập mật khẩu mới, xác nhận lại (`confirmPassword`).
- Đổi thành công → tất cả refresh token cũ của user bị revoke (bắt buộc đăng nhập lại ở mọi thiết bị).

## 4. UI / UX

- Trang `/forgot-password` (nhập email) → `/reset-password?token=...` hoặc màn OTP Verification tùy cơ chế.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/forgot-password
{ "email": "string" }
→ 200 { "success": true, "data": null }

POST /api/v1/auth/reset-password
{ "token": "string", "newPassword": "string" }
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Email không tồn tại → vẫn trả 200 (không tiết lộ), không gửi email thật.
- Token/OTP hết hạn hoặc sai → 400 `INVALID_OR_EXPIRED_TOKEN`.

## 7. Edge Cases

- User request reset password nhiều lần liên tiếp → chỉ token/OTP mới nhất còn hiệu lực, các token cũ tự invalid.

## 8. Definition of Done

- Luồng gửi email + đổi mật khẩu + revoke session cũ hoạt động end-to-end.

## Out of Scope

- Reset password qua SMS (chỉ email ở phạm vi CSV hiện tại).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
