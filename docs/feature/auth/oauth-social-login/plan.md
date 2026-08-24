# Plan — OAuth social login

## Mục tiêu
Triển khai OAuth 2.0 Authorization Code backend-driven cho Google/GitHub/LinkedIn/Microsoft, link/tạo user theo email, issue JWT.

## Thành phần liên quan
- `OAuthService` (abstract) — framework chung: state CSRF (Redis), link/create user, JWT.
- `GoogleOAuthService`, `GitHubOAuthService`, `LinkedInOAuthService`, `MicrosoftOAuthService` — build URL + fetch profile.
- Controller per provider với static path: `/oauth/google`, `/oauth/github`, `/oauth/linkedin`, `/oauth/microsoft` (không dùng dynamic `/{provider}`).
- `OAuthProperties` + `.env` — client-id/secret per provider.
- `UserOAuthProvider` model — map user ↔ (provider, providerId).
- `StringRedisTemplate` — `oauth:state:{state}` TTL 10 phút.
- Frontend: `authService.oauthUrl(provider)`, `OAuthCallbackPage`.

## Luồng — authorize
1. GET `/oauth/{provider}` → sinh state, lưu Redis, build provider URL (client_id, redirect_uri, scope, state) → 302.

## Luồng — callback
1. Nhận `code`, `state` → verify state trong Redis (đúng provider + còn hiệu lực) → xóa state.
2. Exchange code → access token → fetch profile (email, name, avatar, providerId).
3. Tra `UserOAuthProvider` theo (provider, providerId):
   - Có → load user.
   - Không → link theo email có sẵn hoặc tạo user mới + gán SystemRole.USER + link.
4. Set lastLoginAt, ghi audit LOGIN.
5. Issue JWT access + refresh.
6. 302 về `{FRONTEND_URL}/oauth-callback?token={accessToken}`.

## Cấu hình credentials
- `.env`: `OAUTH_{GOOGLE|GITHUB|LINKEDIN|MICROSOFT}_CLIENT_ID/SECRET`.
- Redirect URI khớp console provider.

## Thứ tự build
1. Framework `OAuthService` (state, link/create, JWT).
2. Provider Google + controller.
3. Provider GitHub (thêm `/user/emails` cho email riêng tư).
4. Provider LinkedIn (OIDC userinfo).
5. Provider Microsoft (Graph /me).
6. Frontend nút OAuth + callback page.

## Rủi ro
- Credential/redirect sai → OAuth fail; kiểm tra khớp console.
- Email null → chặn tạo user (email anchor).
- State bị tái sử dụng → xóa sau khi verify.
