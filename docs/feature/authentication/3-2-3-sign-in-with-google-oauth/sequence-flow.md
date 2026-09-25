# Sequence Flow — Sign In With Google OAuth

> Companion to `spec.md` (3.2.3). Lists each actor → action → system step in enough detail to draw the sequence diagram directly. The flow is server-driven: the browser navigates straight to the application server, which performs the handshake with Google.

## Actors / Lifelines

- **User/Browser** — the Guest's browser; also runs the SPA (`OAuthCallbackPage` / `useOAuthCallback`) once control returns.
- **Google** — Google's OAuth authorization endpoint and userinfo endpoint.
- **GoogleOAuthController** — `«Boundary»`, exposes `GET /api/v1/auth/oauth/google` and `GET /api/v1/auth/oauth/google/callback` (alias `/login/oauth2/code/google`).
- **GoogleOAuthService** — `«Control»`, extends the shared `OAuthService` base class; implements `buildProviderUrl()` and `fetchProfile()` for Google, inherits `buildAuthorizationUrl()` and `handleCallback()`.
- **UserRepository** — `«Entity»`, looks up/creates the `User` row by email.
- **UserOAuthProviderRepository** — `«Entity»`, looks up/creates the `(provider, providerId)` link row.

---

## Flow A — Successful Google sign-in, first-time user

1. User/Browser → GoogleOAuthController: `GET /api/v1/auth/oauth/google` (activates "Sign in with Google" on `/login`).
2. GoogleOAuthController → GoogleOAuthService: `buildAuthorizationUrl()`.
3. GoogleOAuthService: generates a random 24-byte hex `state`, stores `oauth:state:{state} = "GOOGLE|"` in Redis with a 10-minute TTL, and builds the Google consent URL (`buildProviderUrl(state)`) with `client_id`, `redirect_uri`, `scope=openid email profile`, `state`.
4. GoogleOAuthController → User/Browser: `302 Found`, `Location: accounts.google.com/o/oauth2/v2/auth?...`.
5. User/Browser → Google: authenticates and grants consent.
6. Google → GoogleOAuthController: `302` to `/api/v1/auth/oauth/google/callback?code=...&state=...`.
7. GoogleOAuthController: `GoogleOAuthCallbackRequest.hasAuthorizationCode()` is true → calls `GoogleOAuthService.handleCallback(code, state)` (inherited from `OAuthService`).
8. GoogleOAuthService (in `OAuthService.handleCallback`):
   a. `redis.getAndDelete("oauth:state:" + state)` — missing/unknown, or provider mismatch → throws `BusinessException(OAUTH_STATE_INVALID)`.
   b. `fetchProfile(code)` — POSTs form-urlencoded to `oauth2.googleapis.com/token` (missing `access_token` → `OAUTH_CODE_INVALID`), then GETs `googleapis.com/oauth2/v2/userinfo`; missing `id`/`email` or `verified_email != true` → `OAUTH_CODE_INVALID`.
   c. → UserOAuthProviderRepository: `findByProviderAndProviderId(GOOGLE, providerId)` — not found (first-time user).
   d. → UserRepository: `findByEmail(email.toLowerCase().trim())` — not found → creates a new `User` (`emailVerifiedAt = now`, no `passwordHash`) and a default `UserSystemRole(USER)`.
   e. → UserOAuthProviderRepository: `save(UserOAuthProvider{userId, GOOGLE, providerId})`, linking the identity.
   f. Checks `user.isActive() && status == ACTIVE` — passes.
   g. `user.isTwoFactorEnabled()` is false → sets `lastLoginAt`, saves the user, writes an `AuditLog(LOGIN)`, resolves the active workspace, and issues an access token + refresh token via `JwtUtil`.
9. GoogleOAuthService → GoogleOAuthController: returns `CallbackResult(loginResult, isLinkMode=false, null, twoFactorToken=null)`. All writes in steps 8c-8g run inside the single `@Transactional handleCallback()` call.
10. GoogleOAuthController → User/Browser: adds `Set-Cookie: refreshToken=...; HttpOnly; Secure; Path=/api/v1/auth; SameSite=Strict`, then `302 Found` to `{frontendUrl}/oauth-callback#token={accessToken}`.
11. User/Browser (`useOAuthCallback`): reads `token` from the fragment, clears the URL, calls `GET /api/v1/auth/me`, stores the user/token, toast MSG11, navigates to the pending redirect or `/dashboard`.

## Flow B — Existing email/password account signing in with Google for the first time

Same as Flow A steps 1–8b, diverging at 8c-8d:

8c'. UserOAuthProviderRepository finds no link for `(GOOGLE, providerId)` yet.
8d'. UserRepository.`findByEmail()` finds an existing account created earlier via Sign Up (password-based) — that `User` row is reused; `linkOrCreateUser()` does not create a new row.
8e-11. Continue as Flow A: `UserOAuthProviderRepository.save()` links Google to the existing account, and the rest of the flow (status check, token issuance, redirect, frontend resolution) proceeds unchanged. No duplicate account is created — the same email now has two ways to sign in.

## Flow C — Account with two-factor authentication enabled

Same as Flow A/B up to step 8e (identity resolved and linked), diverging at 8f-8g:

8f. Account status check passes.
8g'. `user.isTwoFactorEnabled()` is true → `jwtUtil.generateTwoFactorToken(userId)` is generated; `lastLoginAt`, the `AuditLog` entry and the access/refresh tokens are **not** touched.
9'. GoogleOAuthService → GoogleOAuthController: returns `CallbackResult(loginResult=null, isLinkMode=false, null, twoFactorToken)`.
10'. GoogleOAuthController → User/Browser: `302 Found` to `{frontendUrl}/2fa-verify?twoFactorToken=...`; no `Set-Cookie`.
11'. User/Browser: reads `twoFactorToken` from the query string and continues in Two-Factor Authentication (3.2.7). A correct code there issues the real access token and refresh cookie, after which the client resumes Flow A step 11.

## Sub-flow — Error or consent cancelled

- Google reports `error` on the callback, or the callback is missing `code`/`state` → `hasAuthorizationCode()` is false → `GoogleOAuthController.callback()` returns `loginFailure()` directly, without calling `GoogleOAuthService` at all.
- Any `BusinessException` from `handleCallback()` is caught in `GoogleOAuthController.callback()` and routed to `businessFailure(exception)`, which branches on the error code:
  - `OAUTH_EMAIL_MISMATCH` / `OAUTH_ALREADY_LINKED` (link-mode only, see Out of Scope in `spec.md`) → `302` to `{frontendUrl}/settings?error=<code>`.
  - `ACCOUNT_SUSPENDED` → `302` to `{frontendUrl}/oauth-callback?error=ACCOUNT_SUSPENDED` (distinct from the generic failure redirect). `useOAuthCallback().resolveCallback()` checks for this exact value before its generic `query.has("error")` check and throws `Error(ACCOUNT_SUSPENDED)`, which `reportCallbackError()` maps to i18n key `auth.login.oauthAccountSuspended` (a dedicated toast, not MSG12).
  - Everything else (`OAUTH_STATE_INVALID`, `OAUTH_CODE_INVALID`, etc.) → falls through to the same generic `loginFailure()` redirect (`?error=oauth_failed`), which the frontend renders as toast MSG12 (`auth.login.oauthFailed`).
- A `RestClientException` while calling Google (token exchange or userinfo) is caught, logged with only `exception.getClass().getSimpleName()` (never the request/response body, which can carry OAuth credentials), and produces the same generic `loginFailure()` redirect — provider errors are not distinguished at the redirect level, by design (security).

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | Behaviour | ErrorCode / HTTP |
|---|---|---|---|
| Callback | `state` unknown, expired, or recorded for another provider | Generic redirect, toast MSG12 | `OAUTH_STATE_INVALID` (400) |
| Callback | Google token exchange returns no `access_token` | Generic redirect, toast MSG12 | `OAUTH_CODE_INVALID` (400) |
| Callback | Google profile missing `id`/`email`, or `verified_email != true` | Generic redirect, toast MSG12 | `OAUTH_CODE_INVALID` (400) |
| Callback | Account `isActive=false` or `status != ACTIVE` | Distinct redirect `?error=ACCOUNT_SUSPENDED`, dedicated toast (`auth.login.oauthAccountSuspended`) — not MSG12 | `ACCOUNT_SUSPENDED` (403) |
| Callback | Callback carries no `code`/`state`, or `error` param present (user cancelled) | Generic redirect, toast MSG12 | — (no ErrorCode; short-circuited before `handleCallback`) |
| Callback | `RestClientException` calling Google | Generic redirect, toast MSG12 | — (logged server-side only) |
| Callback (link-mode, out of scope) | Linking email mismatches the signed-in user | Redirect to `/settings?error=OAUTH_EMAIL_MISMATCH` | `OAUTH_EMAIL_MISMATCH` (409) |
| Callback (link-mode, out of scope) | `(provider, providerId)` already linked to a different user | Redirect to `/settings?error=OAUTH_ALREADY_LINKED` | `OAUTH_ALREADY_LINKED` (409) |

## Notes

- The access token is carried in the address fragment (`#token=`), never as a query parameter, so it is not sent to the server and does not appear in server access logs.
- Link-mode (`GET /api/v1/auth/oauth/google/link?token=...`, a signed-in user attaching Google to their current account) shares `GoogleOAuthController`/`GoogleOAuthService` but is a separate settings flow and is not part of this feature — see `spec.md` Out of Scope.
