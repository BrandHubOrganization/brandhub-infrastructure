# UC — Sign In with Google OAuth

| | |
|---|---|
| FR Code | 3.2.3 |
| Feature | Sign In with Google OAuth |
| Domain | Authentication (FR 3.2) |
| Role | GUEST |
| Version | 2.1 (khớp code thật, đồng bộ 2026-09-23) |
| Trạng thái tài liệu | Confirmed — đã code, chạy được (bug form-urlencoded đã fix) |

## 1. Objective

Cho phép user đăng nhập nhanh qua Google OAuth. Flow là **backend-driven redirect**: FE điều hướng thẳng sang BE (`GoogleOAuthController`), BE tự redirect sang Google, nhận callback, exchange code, rồi redirect ngược về FE kèm token — không phải flow FE tự gọi Google SDK rồi POST JSON lên BE.

## 2. User Story

Là một Guest,
tôi muốn đăng nhập bằng tài khoản Google,
để không cần nhớ thêm password riêng cho BrandHub.

## 3. Acceptance Criteria

- Nút "Đăng nhập với Google" → redirect Google OAuth consent screen.
- Callback thành công → nếu email đã có `User` (kể cả tạo qua Sign Up thường) → login vào account đó; nếu chưa có → tạo `User` mới với `emailVerifiedAt=now` (Google đã verify email), không có `passwordHash`.
- Bug form-urlencoded (Google reject request JSON body khi exchange token) đã fix: `GoogleOAuthService` dùng `MultiValueMap` + `APPLICATION_FORM_URLENCODED`. Flow chạy được thực tế.
- **[CHỐT 2026-09-20]** Nếu user đã bật 2FA (`twoFactorEnabled=true`) → sau khi Google xác thực email, **bắt buộc qua màn hình nhập TOTP** trước khi cấp accessToken (không bypass 2FA qua OAuth). BE redirect `{FRONTEND_URL}/2fa-verify?twoFactorToken=...`, FE tiếp tục FR 3.2.7 verify-2FA để lấy accessToken thật.

## 4. UI / UX

- Nút Google OAuth đặt cùng trang `/login` và `/register`.

## 5. API Contract (đã code — redirect-based, không phải JSON response)

```
GET /api/v1/auth/oauth/google → 302 redirect sang Google consent
GET /api/v1/auth/oauth/google/callback?code=...&state=...
(Google cũng có thể callback tới alias /login/oauth2/code/google)
→ Thành công, không 2FA: 302 redirect {FRONTEND_URL}/oauth-callback#token={accessToken}
  (Set-Cookie refreshToken: HttpOnly/Secure/SameSite=Strict, path=/api/v1/auth)
→ Thành công, có 2FA: 302 redirect {FRONTEND_URL}/2fa-verify?twoFactorToken=...
  (chưa cấp accessToken/refreshToken, chưa Set-Cookie)
→ Lỗi: 302 redirect {FRONTEND_URL}/oauth-callback?error=oauth_failed
  (hoặc ?error=OAUTH_EMAIL_MISMATCH / OAUTH_ALREADY_LINKED redirect về /settings nếu đang ở link-mode)
```

Không có endpoint nào trong flow này trả JSON `{accessToken, refreshToken, isNewUser}` trực tiếp — accessToken nằm trên URL fragment (`#token=`), FE tự đọc `window.location.hash` rồi gọi `GET /api/v1/users/me`.

Ngoài scope Sign In (không thuộc guest flow, không vẽ trong sequence-flow của FR này): `GET /api/v1/auth/oauth/google/link?token=...` — link-mode cho user đã đăng nhập muốn gắn thêm Google vào account hiện tại (thuộc Settings/Account Linking).

## 6. Error Handling

- Google trả lỗi/user cancel consent (callback không kèm `code`) → `302` redirect `{FRONTEND_URL}/oauth-callback?error=oauth_failed`, không gọi Google API nào thêm.
- Email Google đã được dùng bởi account khác qua Sign Up thường → gắn thêm Google provider vào account đó (không tạo account trùng), theo logic chuẩn hóa email (lowercase + trim).
- State CSRF sai/hết hạn/đã dùng → `OAUTH_STATE_INVALID` (400) → redirect `?error=oauth_failed`.
- Token exchange với Google thất bại (token null) hoặc profile thiếu email/`verified_email != true` → `OAUTH_CODE_INVALID` (400) → redirect `?error=oauth_failed`.
- User bị suspend/inactive → `ACCOUNT_SUSPENDED` (403) → redirect `?error=oauth_failed`.

## 7. Edge Cases

- User bấm Google OAuth nhưng đã có account email/password cùng email → login thẳng vào account cũ, không tạo account riêng cho "Google user".

## 8. Definition of Done

- Flow chạy được thực tế (bug form-urlencoded đã fix). Verify bằng test đăng nhập thật vẫn còn `[ ]` mở trong task.md.

## Out of Scope

- OAuth provider khác ngoài Google (Facebook, GitHub... không thuộc CSV V2 hiện tại).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
