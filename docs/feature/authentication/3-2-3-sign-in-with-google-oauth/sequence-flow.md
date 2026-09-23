# Sequence Flow — Sign In with Google OAuth

> Bổ sung cho `spec.md` (FR 3.2.3). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`GoogleOAuthController`, `OAuthService`, `GoogleOAuthService`). Backend-driven flow — FE điều hướng thẳng sang backend, không tự gọi Google SDK.

## Actors

- **User** — Guest/User đăng nhập qua Google.
- **FE** — brandhub-web-dashboard (React, `LoginPage`, `OAuthCallbackPage`).
- **BE** — brandhub-business-service (`GoogleOAuthController`, `OAuthService`/`GoogleOAuthService`).
- **Google** — Google OAuth 2.0 consent + token/userinfo endpoint.
- **DB** — PostgreSQL (`users`, `user_oauth_providers`, `user_system_roles`), Redis (`oauth:state:*` CSRF state, TTL 10 phút).

---

## Flow A — Đăng nhập Google thành công, user mới (chưa từng có account)

1. User → FE (`/login`): bấm nút "Đăng nhập với Google" — `<a href="/api/v1/auth/oauth/google">`, browser điều hướng thẳng, rời SPA.
2. FE → BE: `GET /api/v1/auth/oauth/google`.
3. BE (`GoogleOAuthController.redirect` → `OAuthService.buildAuthorizationUrl()`): sinh `state` CSRF random 24 byte, lưu Redis `oauth:state:{state} = "GOOGLE|"` (không có `linkingUserId` — login-mode), TTL 10 phút.
4. BE → User: `302 Redirect` sang `https://accounts.google.com/o/oauth2/v2/auth?client_id=...&redirect_uri=...&scope=openid email profile&state=...`.
5. User → Google: đăng nhập + đồng ý consent.
6. Google → BE: `302` tới `GET /api/v1/auth/oauth/google/callback?code=...&state=...`.
7. BE (`callback`):
   a. `handleCallback(code, state)`: lấy + xóa `oauth:state:{state}` khỏi Redis (`getAndDelete`) — không có → `400 OAUTH_STATE_INVALID`; provider trong state không khớp `GOOGLE` → cùng lỗi.
   b. `fetchProfile(code)`: BE → Google `POST /token` (form-urlencoded: code, client_id, client_secret, redirect_uri, grant_type=authorization_code) đổi lấy `access_token`; token null → `400 OAUTH_CODE_INVALID`.
   c. BE → Google: `GET /userinfo` (Bearer access_token) lấy `{id, email, verified_email, name, picture}`; thiếu email hoặc `verified_email != true` → `400 OAUTH_CODE_INVALID`.
   d. Tìm `user_oauth_providers` theo `(GOOGLE, providerId)` — không có → `linkOrCreateUser`: tìm `User` theo email — không có → `INSERT users` mới (`emailVerifiedAt=now`, không có `passwordHash`) + `INSERT user_system_roles(USER)`; sau đó luôn `INSERT user_oauth_providers` (userId, GOOGLE, providerId).
   e. Check `user.isActive()` / `status=ACTIVE` — sai → `403 ACCOUNT_SUSPENDED`.
   f. `user.isTwoFactorEnabled()=false` → set `lastLoginAt`, ghi `AuditLog(LOGIN)`, resolve `workspaceId`, sinh `accessToken` + `refreshToken`.
8. BE → DB: các INSERT/UPDATE ở bước 7d/7f (cùng transaction `@Transactional` trên `handleCallback`).
9. BE → User: Set-Cookie `refreshToken` (HttpOnly/Secure/SameSite=Strict) + `302 Redirect` tới `{FRONTEND_URL}/oauth-callback#token={accessToken}` — **token nằm trong URL fragment**, không phải query string.
10. FE (`OAuthCallbackPage` → `useOAuthCallback` → `resolveCallback()`): đọc `window.location.hash`, lấy token, gọi `GET /api/v1/users/me`, `setAuth(...)`, điều hướng tiếp (Dashboard, hoặc `consumeAuthRedirect()` nếu có lưu redirect trước đó — xem FR agency-workspace 3-4-7 Flow E cho pattern chung).

## Flow B — User đã có account email/password cùng email, đăng nhập Google lần đầu

Giống Flow A bước 1–7c, khác 7d:

7d'. Tìm `user_oauth_providers` theo `(GOOGLE, providerId)` — chưa có (lần đầu dùng Google) → `linkOrCreateUser` tìm `User` theo email → **đã tồn tại** (tạo qua Sign Up thường) → dùng row đó, **không tạo account mới** → `INSERT user_oauth_providers` gắn thêm provider Google vào account cũ.
7e–10: tiếp tục như Flow A — login vào account cũ, không merge dữ liệu vì chỉ có 1 account từ đầu.

## Flow C — User đã có account, đăng nhập Google, tài khoản bật 2FA

Giống Flow A/B tới bước 7d, khác 7e trở đi:

7e. Check active/status OK.
7f'. `user.isTwoFactorEnabled()=true` → sinh `twoFactorToken` (JWT `type=2fa`), **không** set lastLoginAt/audit log/access token.
9'. BE → User: `302 Redirect` tới `{FRONTEND_URL}/2fa-verify?twoFactorToken=...` — token nằm trên **query param**, không phải cookie/fragment (khác Flow A). Không set Cookie refreshToken ở bước này.
10'. FE (`TwoFactorVerifyPage`): đọc `twoFactorToken` từ URL. → tiếp tục **FR 3.2.7 verify-2FA**: `POST /api/v1/auth/2fa/verify {twoFactorToken, code}` → thành công → nhận accessToken thật + Set-Cookie refreshToken → FE tiếp bước 10 Flow A.

## Nhánh phụ — Lỗi / user hủy consent

- Google trả lỗi hoặc user bấm Cancel ở consent screen → Google callback về BE **không kèm `code`** → `callback.hasAuthorizationCode()=false` → BE `302 Redirect` `{FRONTEND_URL}/oauth-callback?error=oauth_failed`, không gọi Google API nào thêm.
- `BusinessException` khác trong lúc xử lý (không phải `OAUTH_EMAIL_MISMATCH`/`OAUTH_ALREADY_LINKED`) → cùng redirect `?error=oauth_failed`.
- Lỗi mạng gọi Google (`RestClientException`) → log cảnh báo (không log message/body vì có thể chứa credential), redirect `?error=oauth_failed`.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | Hành vi | ErrorCode nội bộ |
|---|---|---|---|
| Callback | `state` không có trong Redis / provider không khớp | Redirect `?error=oauth_failed` | `OAUTH_STATE_INVALID` |
| Callback | Google trả token null | Redirect `?error=oauth_failed` | `OAUTH_CODE_INVALID` |
| Callback | Thiếu email hoặc `verified_email != true` | Redirect `?error=oauth_failed` | `OAUTH_CODE_INVALID` |
| Callback | User bị suspend | Redirect `?error=oauth_failed` | `ACCOUNT_SUSPENDED` |
| Callback | Google không trả `code` (user cancel) | Redirect `?error=oauth_failed` | — |
| Callback | Lỗi mạng gọi Google | Redirect `?error=oauth_failed` | — |
