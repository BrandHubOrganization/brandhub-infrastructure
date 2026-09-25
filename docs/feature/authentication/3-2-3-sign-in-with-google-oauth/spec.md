# 3.2.3 Sign In With Google OAuth

| | |
|---|---|
| FR Code | 3.2.3 |
| Feature | Sign In with Google OAuth |
| Domain | Authentication (FR 3.2) |
| Role | Guest (unauthenticated) |
| Endpoints | `GET /api/v1/auth/oauth/google` (authorize redirect), `GET /api/v1/auth/oauth/google/callback` and alias `GET /login/oauth2/code/google` (Google callback) — both in `GoogleOAuthController` |
| Document status | Implemented — v1.1, 2026-09-25: `GoogleOAuthController.businessFailure()` now redirects `ACCOUNT_SUSPENDED` distinctly (`/oauth-callback?error=ACCOUNT_SUSPENDED`) instead of the generic `oauth_failed`; frontend shows a dedicated toast via `auth.login.oauthAccountSuspended`. |

## Function Trigger
Begins when a Guest activates the "Sign in with Google" button on the sign-in or registration screen, which sends the browser to `GET /api/v1/auth/oauth/google`.

## Function Description
- **Actors / Roles:** GUEST. The same handshake also serves a signed-in user linking Google to their existing account via `GET /api/v1/auth/oauth/google/link?token=...`, which is outside this feature (see Settings/Account Linking).
- **Purpose:** Let a user sign in with an existing Google account, create a local account on first use, and honour two-factor authentication when it is enabled.
- **Interface:** A "Sign in with Google" button on both the sign-in and the registration screen. The flow is a redirect handshake: the browser leaves the application for Google's consent screen and returns to the application's callback route, which then 302-redirects the browser back to the frontend carrying the result.
- **Data Processing:** `GoogleOAuthController.redirect()` calls `GoogleOAuthService.buildAuthorizationUrl()` (defined in the shared `OAuthService` base class) to issue and store a single-use state value, then 302s to Google. `GoogleOAuthController.callback()` receives Google's redirect, and `OAuthService.handleCallback()` validates the state, exchanges the authorization code for a Google access token, fetches the Google profile (`GoogleOAuthService.fetchProfile()`), links the Google identity to an existing account or creates a new verified one, checks the account status, and then issues tokens or a two-factor challenge. Any `BusinessException` thrown along the way is routed through `GoogleOAuthController.businessFailure()`, which now redirects `ACCOUNT_SUSPENDED` to `{frontendUrl}/oauth-callback?error=ACCOUNT_SUSPENDED` (distinct from the generic failure redirect), while `OAUTH_EMAIL_MISMATCH`/`OAUTH_ALREADY_LINKED` (link-mode only) still go to `/settings?error=<code>` and every other error still falls through to the generic `loginFailure()` (`?error=oauth_failed`).

## Screen Layout
Figure — Google sign-in entry and return:
- Entry: "Sign in with Google" button on `/login` and `/register`, linking to `GET /api/v1/auth/oauth/google`.
- Return: the browser lands on `/oauth-callback` (`OAuthCallbackPage.tsx`). `useOAuthCallback()` reads `token` from the URL fragment (or query, as a fallback), clears the URL, stores the token, calls `GET /api/v1/auth/me` (via `authService.getProfile()`) to load the profile, then navigates to the pending redirect target or `/dashboard`; toast MSG11 on success.
- If the callback carries `error=ACCOUNT_SUSPENDED` in the query string, `resolveCallback()` throws before the generic-error check and the page shows a dedicated toast via i18n key `auth.login.oauthAccountSuspended` ("This account has been suspended. Please contact support." / vi: "Tài khoản này đã bị tạm khóa. Vui lòng liên hệ hỗ trợ.") and navigates to `/login`.
- If the callback carries any other `error` in the query string, or no token is present, the page clears any partial auth state, shows toast MSG12 (`auth.login.oauthFailed`) or the equivalent `auth.login.oauthProfileFailed` (if the profile call itself fails after a token was received), and navigates to `/login`.
- When two-factor authentication is enabled the browser lands on the two-factor code screen (3.2.7) instead, carrying `twoFactorToken` as a query parameter.

## Function Details
### Data Specifications
- **Input required:** nothing entered by the user; Google supplies `code` and `state` (or `error`) on the callback via `GoogleOAuthCallbackRequest(code, state, error)`.
- **Input optional:** none.
- **System data:** `providerId` (Google `id`), `email`, `emailVerifiedAt`, `passwordHash` (absent for OAuth-only users), `twoFactorEnabled`, `status`/`isActive`, `lastLoginAt`, active `workspaceId`, `accessToken`, `refreshToken`, `twoFactorToken`.
- **Output:** on success, a `302` redirect to `{frontendUrl}/oauth-callback#token={accessToken}` (fragment, never a query parameter) plus a `Set-Cookie: refreshToken=...; HttpOnly; Secure; Path=/api/v1/auth; SameSite=Strict`. When two-factor authentication is enabled, a `302` redirect to `{frontendUrl}/2fa-verify?twoFactorToken=...` is returned instead and no cookie is set. On a suspended/inactive account, a `302` redirect to `{frontendUrl}/oauth-callback?error=ACCOUNT_SUSPENDED`. On any other failure, a `302` redirect to `{frontendUrl}/oauth-callback?error=oauth_failed`, except the two account-linking conflicts below which redirect to `{frontendUrl}/settings?error=OAUTH_EMAIL_MISMATCH` / `?error=OAUTH_ALREADY_LINKED` (link-mode only — see Out of Scope).

### Business Rules
- **BR-09:** The state value is single-use, stored in Redis under `oauth:state:{state}` for 10 minutes and deleted on first read via `getAndDelete` (CSRF protection). A missing/expired/unknown state, or a state recorded for a different provider → 400 `OAUTH_STATE_INVALID`, and the browser is returned to the sign-in screen with a generic error (Toast MSG12).
- **BR-10:** Email is the linking anchor for OAuth — `linkOrCreateUser()` looks up an existing account by lower-cased/trimmed email; a match reuses that account and links the Google identity to it (no duplicate account); no match creates a new account. A failed token exchange, or a Google profile without an `id`/`email`, or with `verified_email != true` → 400 `OAUTH_CODE_INVALID`, browser returned with a generic error (Toast MSG12).
- **BR-11:** `UserOAuthProviderRepository.findByProviderAndProviderId(provider, providerId)` enforces one `(provider, providerId)` pair → exactly one user. On first use of a Google identity the local account is created with `emailVerifiedAt = now`, no `passwordHash` (set later via `/set-password`), and default `SystemRole.USER`.
- **BR-06:** `!user.isActive() || user.getStatus() != ACTIVE` → 403 `ACCOUNT_SUSPENDED`. `GoogleOAuthController.businessFailure()` redirects this case distinctly to `{frontendUrl}/oauth-callback?error=ACCOUNT_SUSPENDED` (not the generic `oauth_failed`); the frontend shows a dedicated toast (i18n key `auth.login.oauthAccountSuspended`), separate from the generic OAuth-failure MSG12 toast.
- **BR-08:** When `user.isTwoFactorEnabled()`, no access token and no refresh token are issued; a `twoFactorToken` is generated (`jwtUtil.generateTwoFactorToken`) and returned instead so the user completes Two-Factor Authentication (3.2.7). Applies uniformly across sign-in methods, including Google.

### Validation
- The user cancels consent or Google returns an error → `GoogleOAuthCallbackRequest.hasAuthorizationCode()` is false (missing/blank `code` or `state`, or `error` present) → the browser is sent back to `{frontendUrl}/oauth-callback?error=oauth_failed` with a generic error (Toast MSG12), without any further call to Google.
- The Google profile has no `id`/`email`, or `verified_email` is not `true` → rejected with 400 `OAUTH_CODE_INVALID` (Toast MSG12).
- A `RestClientException` while calling Google (token exchange or userinfo) is caught, logged with only the exception type (never the request/response body, which can carry OAuth credentials), and treated as a generic login failure (Toast MSG12).

## Functionalities
### Normal Flow
1. The Guest activates "Sign in with Google" on `/login` or `/register`, hitting `GET /api/v1/auth/oauth/google`.
2. `GoogleOAuthController.redirect()` calls `buildAuthorizationUrl()`: a random 24-byte hex state is generated, stored in Redis (`oauth:state:{state}` → `"GOOGLE|"`) for 10 minutes, and the browser is 302'd to Google's consent screen (`accounts.google.com/o/oauth2/v2/auth`) with `client_id`, `redirect_uri`, `scope=openid email profile`, and `state`.
3. The user authenticates with Google and grants consent.
4. Google 302s the browser to `/api/v1/auth/oauth/google/callback` (or the Spring Security alias `/login/oauth2/code/google`) with `code` and `state`.
5. `GoogleOAuthController.callback()` validates `hasAuthorizationCode()`, then `OAuthService.handleCallback(code, state)` consumes the state (BR-09), exchanges `code` for a Google access token (form-urlencoded POST to `oauth2.googleapis.com/token`), and fetches the profile from `googleapis.com/oauth2/v2/userinfo`.
6. `linkOrCreateUser()` links the Google identity to an existing account with the same email (BR-10), or creates a new verified account with no password (BR-11).
7. The system checks the account status (BR-06) and, with two-factor authentication disabled (BR-08), sets `lastLoginAt`, writes an `AuditLog` (`LOGIN`), resolves the active workspace, and issues an access token and a refresh token.
8. All of the above (account/role/link/audit writes) run inside a single `@Transactional` method (`OAuthService.handleCallback`).
9. `GoogleOAuthController` sets the refresh token as an `HttpOnly`/`Secure`/`SameSite=Strict` cookie scoped to `/api/v1/auth`, and 302-redirects to `{frontendUrl}/oauth-callback#token={accessToken}`.
10. `OAuthCallbackPage` / `useOAuthCallback()` reads the token from the fragment, calls `GET /api/v1/auth/me`, stores the user/token, shows toast MSG11, and navigates to the pending redirect target or `/dashboard`.

### Abnormal Cases
- 4.a1: The user cancels consent or Google returns an error → the callback carries no authorization code; the browser is sent back to `oauth-callback?error=oauth_failed`, toast MSG12, and no further call to Google is made. 4.a2: The Guest retries "Sign in with Google" from `/login`.
- 5.a1: The state value is missing, already used/expired, or belongs to another provider (BR-09) → 400 `OAUTH_STATE_INVALID`, browser sent back with toast MSG12. 5.a2: The Guest retries "Sign in with Google" from `/login`.
- 5.b1: The token exchange fails (`access_token` missing), or the Google profile has no email or an unverified email (BR-10) → 400 `OAUTH_CODE_INVALID`, browser sent back with toast MSG12. 5.b2: The Guest retries "Sign in with Google" from `/login`, or signs in with email/password instead.
- 5.c1: A `RestClientException` occurs while calling Google → generic failure redirect, toast MSG12 (no ErrorCode surfaced to the frontend, logged server-side only). 5.c2: The Guest retries.
- 7.a1: The account is suspended or deactivated (BR-06) → 403 `ACCOUNT_SUSPENDED`; `businessFailure()` redirects to `{frontendUrl}/oauth-callback?error=ACCOUNT_SUSPENDED`, and the frontend shows a dedicated toast (`auth.login.oauthAccountSuspended`), distinct from the generic MSG12 OAuth-failure toast. 7.a2: The Guest contacts support to resolve the account status.
- 7.b1: Two-factor authentication is enabled on the account (BR-08) → no access token and no refresh token are issued; a two-factor challenge token is returned instead. 7.b2: The browser is sent to `{frontendUrl}/2fa-verify?twoFactorToken=...` for the Guest to complete sign-in (3.2.7).

⚠ BA conflict (needs team decision): `Section5_Requirement_Appendix.md` has no numbered MSG code dedicated to the OAuth `ACCOUNT_SUSPENDED` toast (BR-06 only defines the generic password-login suspended toast; the appendix's MSG list stops at MSG14, all OAuth-linking related). The frontend copy for this case lives only as the i18n key `auth.login.oauthAccountSuspended` ("This account has been suspended. Please contact support."), not as an appendix MSG-NN entry. Confirm whether this key should be formally registered as a new MSG code in the appendix, or whether ad-hoc i18n keys outside the MSG table are acceptable going forward.

## Post-Conditions
- The Google identity is linked to a local account (`UserOAuthProvider` row for `(GOOGLE, providerId)`), created on first use with the email already verified and no password.
- The sign-in is recorded (`lastLoginAt` updated, `AuditLog` LOGIN entry written), unless the user still has to complete two-factor verification.
- An access token and a refresh-token cookie are issued, or a two-factor challenge token when two-factor authentication is enabled.

## Out of Scope
- Link-mode (`GET /api/v1/auth/oauth/google/link?token=...`, a signed-in user attaching Google to their current account) and its `OAUTH_EMAIL_MISMATCH` / `OAUTH_ALREADY_LINKED` conflict redirects to `/settings`.
- `POST /api/v1/auth/unlink/oauth` (body: `UnlinkOAuthRequest{provider}`) — removing a linked OAuth provider from an account, guarded elsewhere by `OAUTH_ONLY_ACCOUNT` / `LAST_LOGIN_METHOD` in `AuthController`/`AuthServiceImpl`.
