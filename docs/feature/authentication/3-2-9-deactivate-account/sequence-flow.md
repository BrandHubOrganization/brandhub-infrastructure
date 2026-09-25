# Sequence Flow — Deactivate Account

> Companion to `spec.md` (3.2.9). Lists each actor -> action -> system step in enough detail to draw the sequence diagram directly (see `sequence-flow.drawio`). Actors match the real classes: `AuthController`, `AuthServiceImpl`, `UserRepository`, `AgencyRepository`, `JwtUtil`, Redis, `MailService`.

## Actors

- **User** — the signed-in account holder, acting through the `/profile` Danger Zone UI.
- **AuthController** — `POST /api/v1/auth/deactivate` and `POST /api/v1/auth/deactivate/send-otp`; resolves the caller via `requireUserId(authHeader)`, reads the raw access token from the `Authorization` header and the refresh token from the `refreshToken` cookie.
- **AuthServiceImpl** — `deactivate(userId, password, otpCode, accessToken, refreshToken)` and `sendDeactivateOtp(userId)`.
- **UserRepository** — loads the `User` row (`passwordHash`, `status`).
- **AgencyRepository** — `findByOwnerId(userId)`, used for the ownership guard (BR-23, pre-existing/unchanged).
- **JwtUtil** — `blacklistToken(token)`, used to revoke the access token and refresh token (BR-22, new this session).
- **Redis** — `StringRedisTemplate`, key `otp:deactivate:{userId}`, TTL 10 minutes.
- **MailService** — `sendOtpEmail(email, otp)`.

---

## Flow A — Account with a password

1. User -> AuthController: `POST /deactivate { password }` with `Authorization: Bearer <accessToken>` and (if present) `refreshToken` cookie.
2. AuthController: `requireUserId(authHeader)` — missing/malformed header -> 401 `INVALID_CREDENTIALS`.
3. AuthController: extracts `accessToken` from the `Authorization` header (strip `Bearer `) and `refreshToken` from the cookie.
4. AuthController -> AuthServiceImpl: `deactivate(userId, password, null, accessToken, refreshToken)`.
5. AuthServiceImpl -> UserRepository: `findById(userId)` — not found -> 404 `USER_NOT_FOUND`.
6. AuthServiceImpl: `user.getPasswordHash() != null`, so the password branch applies — `passwordEncoder.matches(password, passwordHash)`; mismatch -> 400 `WRONG_CURRENT_PASSWORD`.
7. AuthServiceImpl -> AgencyRepository: `findByOwnerId(userId)`, filters `status == ACTIVE` (BR-23 guard — pre-existing, unchanged, runs before the status update). None found.
8. AuthServiceImpl -> UserRepository: `user.setStatus(DEACTIVATED)`, `save(user)`.
9. AuthServiceImpl -> JwtUtil: `blacklistToken(accessToken)` (skipped if blank; `JwtException` caught and ignored — BR-22, new this session).
10. AuthServiceImpl -> JwtUtil: `blacklistToken(refreshToken)` (skipped if blank; `JwtException` caught and ignored — BR-22, new this session).
11. AuthServiceImpl --> AuthController --> User: 200, `ApiResponse<Void>` (no payload).
12. Client clears the local session, redirects to `/login`, toast MSG91.
13. (Later) If the user tries to sign in or refresh with the now-blacklisted tokens, they are rejected immediately by the blacklist check, not only by `checkStatus()`'s `status == DEACTIVATED` -> 403 `ACCOUNT_DEACTIVATED` path. Session cut-off is now immediate (BR-22 closed).

### Flow A' — Blocked: caller owns an active Agency

Same as steps 1–6, diverging at step 7. This guard is unchanged from before this session and still runs strictly before the status update / token blacklist, so a blocked caller's tokens are left untouched.

7'. AuthServiceImpl -> AgencyRepository: `findByOwnerId(userId)` returns an Agency with `status == ACTIVE` -> throw `AGENCY_OWNERSHIP_ACTIVE` (409). `user.status` is left unchanged; no blacklist calls happen.
8'. AuthServiceImpl --> AuthController --> User: 409, error code `AGENCY_OWNERSHIP_ACTIVE`.

---

## Flow B — Account with no password (OAuth-only)

### B.1 — Requesting the OTP

1. User -> AuthController: `POST /deactivate/send-otp` with `Authorization: Bearer <token>`, no body.
2. AuthController: `requireUserId(authHeader)` — missing/malformed -> 401 `INVALID_CREDENTIALS`.
3. AuthController -> AuthServiceImpl: `sendDeactivateOtp(userId)`.
4. AuthServiceImpl -> UserRepository: `findById(userId)` — not found -> 404 `USER_NOT_FOUND`.
5. AuthServiceImpl: generates a 6-digit OTP (`SecureRandom`).
6. AuthServiceImpl -> Redis: `SET otp:deactivate:{userId} <otp> EX 600` (10 min TTL). No cooldown/rate-limit check is applied here — unlike `resendOtp` (60s cooldown, `otp:resend:{email}`) or `linkPhone` (60s cooldown, `phone:otp:resend:{userId}`) — unchanged BA conflict.
7. AuthServiceImpl -> MailService: `sendOtpEmail(user.getEmail(), otp)`.
8. AuthServiceImpl --> AuthController --> User: 200, no payload.
9. User reads the code from email.

### B.2 — Confirming deactivation with the OTP

10. User -> AuthController: `POST /deactivate { otpCode }` with `Authorization: Bearer <accessToken>` and (if present) `refreshToken` cookie.
11. AuthController: `requireUserId(authHeader)` — missing/malformed -> 401 `INVALID_CREDENTIALS`.
12. AuthController: extracts `accessToken` and `refreshToken` as in Flow A.
13. AuthController -> AuthServiceImpl: `deactivate(userId, null, otpCode, accessToken, refreshToken)`.
14. AuthServiceImpl -> UserRepository: `findById(userId)` — not found -> 404 `USER_NOT_FOUND`.
15. AuthServiceImpl: `user.getPasswordHash() == null`, so the OTP branch applies.
16. AuthServiceImpl -> Redis: `GET otp:deactivate:{userId}`.
17. AuthServiceImpl: key is null, or `otpCode` is null, or the values don't match -> 400 `OTP_INVALID`.
18. AuthServiceImpl -> Redis: match -> `DEL otp:deactivate:{userId}` (single-use).
19. AuthServiceImpl -> AgencyRepository: `findByOwnerId(userId)`, filters `status == ACTIVE` (BR-23 guard, pre-existing). None found.
20. AuthServiceImpl -> UserRepository: `user.setStatus(DEACTIVATED)`, `save(user)`.
21. AuthServiceImpl -> JwtUtil: `blacklistToken(accessToken)`, then `blacklistToken(refreshToken)` — same BR-22 best-effort cleanup as Flow A steps 9–10.
22. AuthServiceImpl --> AuthController --> User: 200, no payload.
23. Client clears the local session, redirects to `/login`, toast MSG91.
24. (Later) sign-in/refresh with the blacklisted tokens is rejected immediately — same as Flow A step 13.

### Flow B' — Blocked: caller owns an active Agency (OTP already consumed)

Same as steps 10–18, diverging at step 19.

19'. AuthServiceImpl -> AgencyRepository: an ACTIVE agency is found -> throw `AGENCY_OWNERSHIP_ACTIVE` (409). `user.status` is left unchanged; no blacklist calls happen. Note the OTP key was already deleted at step 18, so the user must call `send-otp` again before retrying after transferring ownership.
20'. AuthServiceImpl --> AuthController --> User: 409, error code `AGENCY_OWNERSHIP_ACTIVE`.

### Flow B'' — OTP invalid, missing, or expired

17'. Redis key absent (never requested or TTL elapsed), `otpCode` null, or mismatch -> 400 `OTP_INVALID`.
18''. AuthServiceImpl --> AuthController --> User: 400, error code `OTP_INVALID`.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| send-otp, deactivate | Missing/malformed Bearer token | 401 | `INVALID_CREDENTIALS` |
| send-otp, deactivate | `UserRepository.findById` returns empty | 404 | `USER_NOT_FOUND` |
| deactivate, password branch | `passwordEncoder.matches` fails | 400 | `WRONG_CURRENT_PASSWORD` |
| deactivate, OTP branch | Redis key missing/expired, `otpCode` null, or mismatch | 400 | `OTP_INVALID` |
| deactivate, either branch | `agencyRepository.findByOwnerId` finds an ACTIVE agency (BR-23, pre-existing) | 409 | `AGENCY_OWNERSHIP_ACTIVE` |

## Notes

- The Agency-ownership guard (`AGENCY_OWNERSHIP_ACTIVE`) is unchanged this session and still runs strictly before the status update and before the token blacklist calls — a blocked caller keeps their existing session.
- BR-22 is now fully implemented: after `user.setStatus(DEACTIVATED)`/`save`, `deactivate()` calls `jwtUtil.blacklistToken()` on both the caller's access token (from the `Authorization` header, threaded through by `AuthController`) and refresh token (from the `refreshToken` cookie, also threaded through by `AuthController`), each guarded by a best-effort try/catch on `JwtException` for a malformed/absent token. Session cut-off is therefore immediate, not just on next refresh attempt.
- The branch (password vs. OTP) is selected purely by `user.getPasswordHash() == null`, never by which field the client populates in `DeactivateRequest`; the unused field is ignored.
- `sendDeactivateOtp` still has no resend cooldown, unlike `resendOtp` and `linkPhone` (flagged in spec.md, unchanged this session).
