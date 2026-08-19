# UC — Đăng nhập bằng tài khoản mạng xã hội (OAuth)

| | |
|---|---|
| Feature | OAuth social login |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép đăng nhập bằng tài khoản ngoài: **Google, GitHub, LinkedIn, Microsoft**. Dùng luồng OAuth 2.0 Authorization Code **do backend điều phối** (browser → backend → provider → callback → JWT). Email của provider được dùng làm định danh để link vào tài khoản có sẵn hoặc tạo tài khoản mới.

## 2. User Story

Là một người dùng,
tôi muốn đăng nhập bằng tài khoản Google/GitHub/LinkedIn/Microsoft của mình,
để truy cập nhanh mà không phải nhập email/mật khẩu.

## 3. Acceptance Criteria

- Mỗi provider có endpoint `GET /api/v1/auth/oauth/{provider}` redirect sang trang authorize provider.
- State token CSRF tạo + lưu Redis (TTL ~10 phút), verify khi callback.
- Callback exchange code → fetch profile → lấy email.
- Email provider khớp user có sẵn → link provider + login user đó.
- Email provider chưa có → tạo user mới (email anchor) + link provider.
- Phát JWT access + refresh như login thường.
- Provider redirect về FE `/oauth-callback?token=...`.
- Frontend `oauthUrl(provider)` trả URL để dùng làm `href`.

## 4. UI / UX

- Lưới nút OAuth (Google, GitHub, LinkedIn, Microsoft) trên trang Login/Register.
- Bấm nút → chuyển hướng browser sang provider, không phải axios call.
- Sau khi provider xác nhận → redirect về FE với token → tự đăng nhập.
- Trạng thái lỗi provider (user từ chối, hết hạn state) → thông báo, quay lại login.

### UI States
- Idle → redirect provider.
- Callback → tự đăng nhập hoặc báo lỗi.

## 5. API Contract

```
GET  /api/v1/auth/oauth/google                      # redirect sang Google
GET  /api/v1/auth/oauth/google/callback?code=&state=
GET  /api/v1/auth/oauth/github                      # redirect sang GitHub
GET  /api/v1/auth/oauth/github/callback?code=&state=
GET  /api/v1/auth/oauth/linkedin                    # redirect sang LinkedIn
GET  /api/v1/auth/oauth/linkedin/callback?code=&state=
GET  /api/v1/auth/oauth/microsoft                   # redirect sang Microsoft
GET  /api/v1/auth/oauth/microsoft/callback?code=&state=
```
- Mỗi provider có controller riêng với static path (không dynamic `/{provider}`).
- Redirect URI đăng ký trên provider console:
  `{OAUTH_REDIRECT_BASE_URL}/api/v1/auth/oauth/{provider}/callback`
- Callback thành công → 302 về `{FRONTEND_URL}/oauth-callback?token={accessToken}`.

## 6. Error Handling

- `state` không khớp / hết hạn → 400 `OAUTH_STATE_INVALID`.
- Provider trả lỗi / user từ chối → redirect FE với thông báo lỗi.
- Provider trả email null → không tạo user (email bắt buộc) → `EMAIL_REQUIRED`.
- Provider đã link cho user khác → link theo `provider_id` để tránh trùng (xử lý theo thiết kế).

## 7. Edge Cases

- Cùng provider login 2 lần → tra theo `provider_id`, không tạo user mới.
- Email đã có tài khoản thường → link provider vào tài khoản đó.
- Provider OIDC (LinkedIn/MS) trả `sub`/`id` làm provider_id.
- State hết hạn do chậm → báo lỗi, cho làm lại.
- Callback trùng → state đã xóa, từ chối.

## 8. UI States

- Nút OAuth idle/hover.
- Redirect đang chờ provider.
- Callback: loading → dashboard hoặc error.

## 9. Test Cases

- Mỗi provider: redirect URL đúng (client_id, redirect_uri, scope, state).
- Callback với state hợp lệ → JWT, user link/tạo đúng.
- Callback state sai/hết hạn → 400.
- OAuth email mới → tạo user + link.
- OAuth email trùng → link user cũ, không tạo mới.
- Provider email null → 400.
- Login cùng provider 2 lần → cùng user, không trùng provider_id.

## 10. Definition of Done

- Toàn bộ 4 provider hoạt động (credential đúng, redirect URI khớp console).
- State CSRF Redis, JWT RS256.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Facebook (đã bỏ).
- Token refresh riêng của provider (lưu trữ lâu dài).
- Link/ngắt liên kết provider từ profile (multi-method-login).
