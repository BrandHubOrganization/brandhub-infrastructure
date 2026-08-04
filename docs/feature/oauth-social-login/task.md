# Task — OAuth social login

## Backend — framework
- [ ] `OAuthService` abstract: sinh state, lưu Redis `oauth:state:*` TTL 10m.
- [ ] `handleCallback`: verify state → exchange code → fetch profile → link/create user → JWT.
- [ ] `linkOrCreateUser`: link theo email hoặc tạo user mới + role USER.
- [ ] Audit LOGIN + lastLoginAt.

## Backend — Google
- [ ] `GoogleOAuthService` + `GoogleOAuthController` (build URL + userinfo).
- [ ] Credential `OAUTH_GOOGLE_*` trong .env.

## Backend — GitHub
- [ ] `GitHubOAuthService` + controller (scope `read:user user:email` + `/user/emails`).

## Backend — LinkedIn
- [ ] `LinkedInOAuthService` + controller (OIDC, scope `openid profile email`).

## Backend — Microsoft
- [ ] `MicrosoftOAuthService` + controller (Graph `/me`, derive email từ mail/userPrincipalName).

## Config
- [ ] `.env` đủ 4 provider credential.
- [ ] Redirect URI khớp console mỗi provider.

## Frontend
- [ ] `oauthUrl(provider)` trả href.
- [ ] Nút OAuth trên Login/Register.
- [ ] `OAuthCallbackPage` đọc token query, lưu store, redirect.
