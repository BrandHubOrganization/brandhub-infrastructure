# Sequence Flow — Reset Password (3.2.4)

> Companion to `spec.md`. Actors are the real classes/methods in
> `brandhub-business-service`: `AuthController`, `AuthServiceImpl`,
> `UserRepository`, Redis (`StringRedisTemplate`), `MailService`,
> `AuditLogRepository`. Covers both endpoints and their error branches,
> including an expired/superseded token and an already-used token.

## Actors

- **User / Browser** — `ForgotPasswordPage.tsx` / `ResetPasswordPage.tsx`.
- **AuthController** — `forgotPassword()`, `resetPassword()` REST handlers.
- **AuthServiceImpl** — `forgotPassword(email)`, `resetPassword(token, newPassword)`.
- **UserRepository** — `findByEmail`, `findById`, `save`.
- **Redis** — `pwd:reset:{token}` → userId; `pwd:reset:user:{userId}` → current token (reverse-index).
- **MailService** — `sendPasswordResetEmail(email, token)`.
- **AuditLogRepository** — `save(AuditLog)` on successful reset.

---

## Flow A — Forgot password (email exists)

1. User/Browser → AuthController: `POST /api/v1/auth/forgot-password { email }`.
2. AuthController → AuthServiceImpl: `forgotPassword(email)`.
3. AuthServiceImpl → UserRepository: `findByEmail(normalizedEmail)` → found.
4. AuthServiceImpl → Redis: `GET pwd:reset:user:{userId}` → returns `oldToken` if one exists.
5. AuthServiceImpl → Redis: `DEL pwd:reset:{oldToken}` (only if `oldToken != null`).
6. AuthServiceImpl: generates a new 32-byte `SecureRandom` hex token.
7. AuthServiceImpl → Redis: `SET pwd:reset:{token} = userId` and `SET pwd:reset:user:{userId} = token`, both TTL = `appProperties.passwordResetTtlSeconds` (≤ 1h).
8. AuthServiceImpl → MailService: `sendPasswordResetEmail(email, token)`.
9. AuthServiceImpl → AuthController → User/Browser: 200, `ApiResponse<Void>` (no body). Toast MSG15.

## Flow B — Forgot password (email does not exist) — anti-enumeration

1. User/Browser → AuthController → AuthServiceImpl: `forgotPassword(email)`.
2. AuthServiceImpl → UserRepository: `findByEmail` → empty.
3. AuthServiceImpl returns immediately — no token generated, no email sent.
4. AuthController → User/Browser: 200, identical response to Flow A. Toast MSG15 (same wording; the UI cannot tell the two cases apart).

## Flow C — Reset password, valid token

1. User/Browser → AuthController: `POST /api/v1/auth/reset-password { token, newPassword }`.
2. AuthController → AuthServiceImpl: `resetPassword(token, newPassword)`.
3. AuthServiceImpl → Redis: `GET pwd:reset:{token}` → returns `userId`.
4. AuthServiceImpl → Redis: `DEL pwd:reset:{token}` (atomic delete-and-check) → deletion succeeded (token was present).
5. AuthServiceImpl → UserRepository: `findById(userId)` → found.
6. AuthServiceImpl → Redis: `DEL pwd:reset:user:{userId}` (clear reverse-index).
7. AuthServiceImpl: hashes `newPassword` (BCrypt), sets `lastPasswordChange = now`.
8. AuthServiceImpl → UserRepository: `save(user)`.
9. AuthServiceImpl → AuditLogRepository: `save(AuditLog{action=PASSWORD_RESET, userId, resourceType=USER})`.
10. AuthServiceImpl → AuthController → User/Browser: 200, no body. Toast MSG18; redirect to `/login`.
11. Side effect (next `/refresh` call with a pre-reset refresh token): `AuthServiceImpl.refresh()` compares the token's `issuedAt` against `user.lastPasswordChange`; issuedAt is earlier → 401 `REFRESH_TOKEN_INVALID`. Not part of this call, but a direct consequence of step 7.

## Flow D — Reset password, token invalid/expired/superseded

1. User/Browser → AuthController → AuthServiceImpl: `resetPassword(token, newPassword)`.
2. AuthServiceImpl → Redis: `GET pwd:reset:{token}` → `null` (never existed, TTL expired, or superseded by a newer forgot-password request per Flow A step 5).
3. AuthServiceImpl throws `BusinessException(RESET_TOKEN_INVALID)`.
4. AuthController → User/Browser: 400 `RESET_TOKEN_INVALID`. Toast MSG16.

## Flow E — Reset password, token already used (race)

1. Two requests present the same valid `token` concurrently (or one retried after success).
2. Request 1: AuthServiceImpl → Redis: `GET pwd:reset:{token}` → returns `userId`; `DEL pwd:reset:{token}` → succeeds; proceeds through Flow C.
3. Request 2: AuthServiceImpl → Redis: `GET pwd:reset:{token}` → still returns the cached `userId` momentarily, but `DEL pwd:reset:{token}` → reports `false` (key already gone).
4. AuthServiceImpl throws `BusinessException(RESET_TOKEN_USED)`.
5. AuthController → User/Browser: 400 `RESET_TOKEN_USED`. Toast MSG17.

## Flow F — Reset password, user record no longer exists

1. AuthServiceImpl → Redis: `GET pwd:reset:{token}` → returns `userId`; `DEL` succeeds.
2. AuthServiceImpl → UserRepository: `findById(userId)` → empty (account deleted after the token was issued).
3. AuthServiceImpl throws `BusinessException(RESET_TOKEN_INVALID)`.
4. AuthController → User/Browser: 400 `RESET_TOKEN_INVALID`. Toast MSG16.

---

## Error paths summary

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| forgot-password | Email does not match any account | 200 | — (silent, BR-13) |
| reset-password | Token missing, expired, or superseded | 400 | `RESET_TOKEN_INVALID` |
| reset-password | Token already consumed (race) | 400 | `RESET_TOKEN_USED` |
| reset-password | Token valid but user record gone | 400 | `RESET_TOKEN_INVALID` |
| reset-password | `newPassword` fails bean validation | 400 | `VALIDATION_ERROR` |

## Notes

- Only the most recently issued token per account is valid — Flow A step 5 invalidates any earlier link the instant a new one is requested.
- The forgot-password response is deliberately identical for existing and non-existing emails (Flow A vs Flow B), preventing account enumeration (BR-13).
- BR-12 (forced re-login on every device) is enforced in `refresh()`, not in `resetPassword` — see Flow C step 11.
