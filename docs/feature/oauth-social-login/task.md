# Task — OAuth social login

## Backend — framework
- [x] `OAuthService` abstract: sinh state, lưu Redis `oauth:state:*` TTL 10m.
- [x] `handleCallback`: verify state → exchange code → fetch profile → link/create user → check status → JWT.
- [x] `linkOrCreateUser`: link theo email hoặc tạo user mới + role USER.
- [x] Audit LOGIN + lastLoginAt.
- [x] Block suspended/inactive accounts (ACCOUNT_SUSPENDED).

## Backend — Google
- [x] `GoogleOAuthService` + `GoogleOAuthController` (static path `/oauth/google`) — build URL + userinfo.
- [x] Credential `OAUTH_GOOGLE_*` trong .env.

## Backend — GitHub
- [x] `GitHubOAuthService` + controller (static path `/oauth/github`) — scope `read:user user:email` + `/user/emails`.

## Backend — LinkedIn
- [x] `LinkedInOAuthService` + controller (static path `/oauth/linkedin`) — OIDC, scope `openid profile email`.

## Backend — Microsoft
- [x] `MicrosoftOAuthService` + controller (static path `/oauth/microsoft`) — Graph `/me`, derive email từ mail/userPrincipalName.

## Config
- [x] `.env` đủ 4 provider credential.
- [x] Redirect URI khớp console mỗi provider.

## Frontend
- [x] `oauthUrl(provider)` trả href.
- [x] Nút OAuth trên Login/Register (Google, GitHub, LinkedIn, Microsoft).
- [x] `OAuthCallbackPage` đọc token query, lưu store, redirect.
