# UC — Sign In With Email

| | |
|---|---|
| FR Code | 3.2.2 |
| Feature | Sign In With Email |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép user đã có tài khoản đăng nhập bằng email/password, không cần xác thực OTP lại (khác với Sign Up).

## 2. User Story

Là một User đã có tài khoản,
tôi muốn đăng nhập bằng email và password,
để truy cập vào hệ thống BrandHub.

## 3. Acceptance Criteria

- Form nhập `email` + `password`.
- Đăng nhập đúng → trả JWT access token + refresh token, redirect vào Dashboard/Agency list.
- **Không yêu cầu OTP** ở bước này — khác biệt rõ với luồng Sign Up.
- Nếu tài khoản có bật 2FA (FR 3.2.7) → sau khi email/password đúng, chuyển tiếp sang màn nhập mã 2FA trước khi cấp token.

## 4. UI / UX

- Trang `/login`. Link 'Quên mật khẩu' trỏ tới Reset Password (FR 3.2.4).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/auth/login
{ "email": "string", "password": "string" }
→ 200 { "success": true, "data": { "accessToken", "refreshToken", "require2FA": boolean } }
```

## 6. Error Handling

- Sai email/password → 401 `INVALID_CREDENTIALS` (không tiết lộ email có tồn tại hay không, tránh user enumeration).
- Account bị deactivate → 403 `ACCOUNT_DEACTIVATED`.

## 7. Edge Cases

- Email nhập sai case (`USER@gmail.com`) nhưng account lưu `user@gmail.com` → vẫn login được nhờ chuẩn hóa email giống FR 3.2.1.

## 8. Definition of Done

- Login thành công trả đúng token, 2FA (nếu bật) chặn đúng trước khi cấp token.

## Out of Scope

- Rate limiting chi tiết (áp dụng tầng gateway, không thuộc spec này).

## Tham chiếu BA

[02_Authentication_Profile.md](../../../BA/02_Authentication_Profile.md)
