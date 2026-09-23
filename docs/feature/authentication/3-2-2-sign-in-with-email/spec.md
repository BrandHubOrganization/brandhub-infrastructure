# UC — Sign In With Email

| | |
|---|---|
| FR Code | 3.2.2 |
| Feature | Sign In With Email |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code (twoFactorToken + /2fa/verify) |

## 1. Objective

Cho phép user đã có tài khoản đăng nhập bằng email/password, không cần xác thực OTP lại (khác với Sign Up).

## 2. User Story

Là một User đã có tài khoản,
tôi muốn đăng nhập bằng email và password,
để truy cập vào hệ thống BrandHub.

## 3. Acceptance Criteria

- Form nhập `identifier` (email hoặc phone) + `password`.
- Đăng nhập đúng → trả JWT access token + refresh token, redirect vào Dashboard/Agency list.
- **Không yêu cầu OTP** ở bước này — khác biệt rõ với luồng Sign Up.
- Nếu tài khoản có bật 2FA (FR 3.2.7) → sau khi email/password đúng, chuyển tiếp sang màn nhập mã 2FA trước khi cấp token.

## 4. UI / UX

- Trang `/login`. Link 'Quên mật khẩu' trỏ tới Reset Password (FR 3.2.4).

## 5. API Contract (khớp code thật — `AuthController`, `LoginRequest`, `LoginResponse`)

```
POST /api/v1/auth/login
{ "identifier": "string", "password": "string" }   // identifier = email hoặc phone
→ 2FA TẮT (hoàn tất login):
  200 { "success": true, "data": { "accessToken", "tokenType": "Bearer", "expiresIn", "requireTwoFactor": false, "twoFactorToken": null } }
  + Set-Cookie refreshToken (HttpOnly, Secure, Path=/api/v1/auth, SameSite=Strict, MaxAge=refreshExpirationMs/1000)
→ 2FA BẬT (chặn trước khi cấp token):
  200 { "success": true, "data": { "accessToken": null, "tokenType": null, "expiresIn": 0, "requireTwoFactor": true, "twoFactorToken": "..." } }
  → KHÔNG set cookie refreshToken ở nhánh này.
  → FE gọi POST /api/v1/auth/2fa/verify { twoFactorToken, code } (FR 3.2.7) để lấy token đầy đủ.

POST /api/v1/auth/refresh
Đọc cookie "refreshToken" (không phải body). Thiếu cookie → 401 REFRESH_TOKEN_INVALID.
→ 200 LoginResponse (access token mới) + Set-Cookie refreshToken mới (rotate).
```

## 6. Error Handling

- Không tìm thấy user theo `identifier`, hoặc sai password, hoặc user chưa có password (OAuth-only) → 401 `INVALID_CREDENTIALS` (không tiết lộ email/phone có tồn tại hay không, tránh user enumeration).
- Account không active hoặc status khác ACTIVE/DEACTIVATED (vd. SUSPENDED) → 403 `ACCOUNT_SUSPENDED`.
- Account `status = DEACTIVATED` → 403 `ACCOUNT_DEACTIVATED`.
- `/refresh`: thiếu cookie hoặc token không hợp lệ → 401 `REFRESH_TOKEN_INVALID`; token đã bị blacklist (sau logout) → 401 `REFRESH_TOKEN_BLACKLISTED`; token được cấp trước lần đổi mật khẩu gần nhất (`issuedAt < lastPasswordChange`) → 401 `REFRESH_TOKEN_INVALID`; user không còn active → 401 `REFRESH_TOKEN_INVALID`.

## 7. Edge Cases

- Identifier nhập sai case (`USER@gmail.com`) nhưng account lưu `user@gmail.com` → vẫn login được nhờ chuẩn hóa lowercase khi tìm theo email.
- Identifier là số điện thoại → được chuẩn hóa (`PhoneUtil.normalize`) rồi tìm theo phone.

## 8. Definition of Done

- Login thành công trả đúng token, 2FA (nếu bật) chặn đúng trước khi cấp token.

## Out of Scope

- Rate limiting chi tiết (áp dụng tầng gateway, không thuộc spec này).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
