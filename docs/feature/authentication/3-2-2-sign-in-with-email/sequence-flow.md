# Sequence Flow — Sign In With Email

> Companion to `spec.md` (3.2.2). Lists each actor -> action -> system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors / Lifelines

- **User/Browser** — holds an existing account; `LoginPage.tsx`.
- **AuthController** — `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh`.
- **AuthServiceImpl** — `login()`, `refresh()`, `resolveByIdentifier()`, `checkStatus()`, `completeLogin()`.
- **UserRepository** — `findByEmail`, `findByPhone`, `findById`.
- **JwtUtil** — `generateAccessToken`, `generateRefreshToken`, `generateTwoFactorToken`, `parseToken`, `isBlacklisted`, `blacklistToken`.
- **Redis** — backs the refresh-token / access-token blacklist (`jwtUtil.isBlacklisted` / `blacklistToken`).

---

## Flow A — Successful sign-in without two-factor authentication

1. User/Browser -> AuthController: `POST /api/v1/auth/login {identifier, password}`.
2. AuthController -> AuthServiceImpl: `login(request)`.
3. AuthServiceImpl -> UserRepository: `resolveByIdentifier(identifier)` — email (contains "@", lower-cased) via `findByEmail`, otherwise E.164-normalized via `findByPhone`. No match -> throws `INVALID_CREDENTIALS` (401).
4. AuthServiceImpl: `checkStatus(user)` — `!isActive` -> `ACCOUNT_SUSPENDED` (403); `status == DEACTIVATED` -> `ACCOUNT_DEACTIVATED` (403); `status != ACTIVE` -> `ACCOUNT_SUSPENDED` (403).
5. AuthServiceImpl: compares `request.password()` against `user.getPasswordHash()` (bcrypt); null hash (OAuth-only account) or mismatch -> `INVALID_CREDENTIALS` (401).
6. AuthServiceImpl: resolves the user's system role via `userSystemRoleRepository`.
7. AuthServiceImpl: `user.isTwoFactorEnabled()` is false -> calls `completeLogin(user, role)`.
8. AuthServiceImpl -> UserRepository: saves `lastLoginAt`; saves an `AuditLog(LOGIN)` row; resolves the active `workspaceId`.
9. AuthServiceImpl -> JwtUtil: `generateAccessToken(userId, role, workspaceId)` (RS256, 15-minute TTL) and `generateRefreshToken(userId)` (30-day TTL, jti-based).
10. AuthServiceImpl --> AuthController: `LoginResult(LoginResponse.of(accessToken, accessExpirationMs), refreshToken, refreshExpirationMs, null)`.
11. AuthController -> User/Browser: sets `refreshToken` cookie (HttpOnly, Secure, Path=`/api/v1/auth`, SameSite=Strict, MaxAge=refreshExpirationMs/1000); returns `200 ApiResponse<LoginResponse>` with the access token.
12. User/Browser: stores the access token, calls `GET /api/v1/users/me`, navigates to the redirect target / Dashboard; toast MSG11.

## Flow B — Sign-in on an account with two-factor authentication enabled

Same as Flow A steps 1–6, diverging at step 7:

1. AuthServiceImpl: `user.isTwoFactorEnabled()` is true -> AuthServiceImpl -> JwtUtil: `generateTwoFactorToken(userId)` (RS256, 5-minute TTL, claim `type=2fa`).
2. AuthServiceImpl --> AuthController: `LoginResult(LoginResponse.twoFactorChallenge(twoFactorToken), null, 0, twoFactorToken)` — no refresh token, no access token.
3. AuthController -> User/Browser: `200 ApiResponse<LoginResponse>` with `requireTwoFactor=true` and `twoFactorToken`; **no** `refreshToken` cookie is set.
4. User/Browser: stores `twoFactorToken` in `sessionStorage`, navigates to `/2fa-verify`.
5. Continues in Two-Factor Verify (FR 3.2.7 — `POST /api/v1/auth/2fa/verify`): on a correct code, that flow issues the real access token and sets the refresh cookie, after which the client resumes Flow A step 12.

## Flow C — Refresh access token

1. User/Browser -> AuthController: `POST /api/v1/auth/refresh` with the `refreshToken` cookie (no body).
2. AuthController: cookie missing/blank -> throws `REFRESH_TOKEN_INVALID` (401) directly, before calling the service.
3. AuthController -> AuthServiceImpl: `refresh(refreshToken)`.
4. AuthServiceImpl -> JwtUtil: `parseToken(refreshToken)` — unparseable/expired -> `REFRESH_TOKEN_INVALID` (401).
5. AuthServiceImpl -> JwtUtil/Redis: `isBlacklisted(jti)` — true -> `REFRESH_TOKEN_BLACKLISTED` (401).
6. AuthServiceImpl -> UserRepository: `findById(sub claim)` — not found -> `REFRESH_TOKEN_INVALID` (401).
7. AuthServiceImpl: token `issuedAt` before `user.getLastPasswordChange()` -> `REFRESH_TOKEN_INVALID` (401) (a password change invalidates old refresh tokens).
8. AuthServiceImpl: `!isActive` or `status != ACTIVE` -> `REFRESH_TOKEN_INVALID` (401).
9. AuthServiceImpl -> JwtUtil/Redis: `blacklistToken(oldRefreshToken)`.
10. AuthServiceImpl -> JwtUtil: issues a new access token + new refresh token pair (same TTLs as Flow A).
11. AuthServiceImpl -> UserRepository: saves an `AuditLog(TOKEN_REFRESH)` row.
12. AuthServiceImpl --> AuthController: new `LoginResult`.
13. AuthController -> User/Browser: sets the new `refreshToken` cookie (same attributes as login), returns `200 ApiResponse<LoginResponse>` with the new access token.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| Login | No account matches the identifier | 401 | `INVALID_CREDENTIALS` |
| Login | Wrong password, or account has no password hash | 401 | `INVALID_CREDENTIALS` |
| Login | `!user.isActive()` | 403 | `ACCOUNT_SUSPENDED` |
| Login | `status == DEACTIVATED` | 403 | `ACCOUNT_DEACTIVATED` |
| Login | `status != ACTIVE` (and not DEACTIVATED) | 403 | `ACCOUNT_SUSPENDED` |
| Login | Two-factor enabled — challenge issued, no error | 200 | — (`requireTwoFactor=true`) |
| Refresh | Cookie missing/blank | 401 | `REFRESH_TOKEN_INVALID` |
| Refresh | Token unparseable/expired | 401 | `REFRESH_TOKEN_INVALID` |
| Refresh | `jti` blacklisted | 401 | `REFRESH_TOKEN_BLACKLISTED` |
| Refresh | User not found by `sub` | 401 | `REFRESH_TOKEN_INVALID` |
| Refresh | `issuedAt` before `lastPasswordChange` | 401 | `REFRESH_TOKEN_INVALID` |
| Refresh | User inactive / not `ACTIVE` | 401 | `REFRESH_TOKEN_INVALID` |

## Notes

- The identifier field accepts both an email address and a phone number in the same input; resolution is by format ("@" -> email), which is why the wrong-credential answer is identical for both.
- The refresh token travels only as an HTTP-only cookie (`Path=/api/v1/auth`), is rotated on every successful refresh, and is never present in any JSON response body.
- Verifying the 2FA code itself (`POST /2fa/verify`) and clearing the refresh cookie on sign-out (`POST /logout`) belong to FR 3.2.7 and FR 3.2.8 respectively — not duplicated here beyond the handoff points shown in Flow B step 5.
