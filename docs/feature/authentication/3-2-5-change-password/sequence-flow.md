# Sequence Flow — Change Password

> Companion to `spec.md` (3.2.5). Lists each actor → action → system step in enough detail to draw the sequence diagram directly; the business description lives in `spec.md`.

## Actors

- **User/Browser** — already signed in; the change-password page in `brandhub-web-dashboard`.
- **AuthController** — `POST /api/v1/auth/change-password`.
- **AuthServiceImpl** — `changePassword(accessToken, request)`.
- **UserRepository** — persistence for the `User` entity (`passwordHash`, `lastPasswordChange`).

---

## Flow A — Successful password change

1. User/Browser: enters the current password, the new password and the confirmation on the Settings > Security form; the client checks the confirmation matches before submitting.
2. User/Browser → AuthController: `POST /change-password` with `Authorization: Bearer <accessToken>` and body `{currentPassword, newPassword}`.
3. AuthController: checks the header is present and starts with `Bearer `; missing/malformed → 401 `INVALID_CREDENTIALS`, returned immediately without calling the service.
4. AuthController → AuthServiceImpl: `changePassword(accessToken, request)`.
5. AuthServiceImpl: parses the access token's JWT subject to get `userId`.
6. AuthServiceImpl → UserRepository: `findById(userId)`; not found → 404 `USER_NOT_FOUND`.
7. AuthServiceImpl: `passwordEncoder.matches(currentPassword, user.passwordHash)`; false → 400 `WRONG_CURRENT_PASSWORD`.
8. AuthServiceImpl: `passwordEncoder.matches(newPassword, user.passwordHash)`; true (same as current) → 400 `SAME_AS_CURRENT_PASSWORD`. Reached only after step 7 passes.
9. AuthServiceImpl: sets `user.passwordHash = encode(newPassword)` and `user.lastPasswordChange = now()`.
10. AuthServiceImpl → UserRepository: `save(user)`.
11. AuthServiceImpl: writes an `AuditLog` row with `action = AuditAction.PASSWORD_RESET` (the same audit action reused from Reset Password, 3.2.4 — there is no separate "password changed" action in code).
12. AuthServiceImpl → AuthController → User/Browser: 200 `ApiResponse<Void>`, no data.
13. User/Browser: shows a success toast and stays signed in; the current access token keeps working. Every refresh token issued before step 9 is rejected on its next use (401 `REFRESH_TOKEN_INVALID`), per BR-12.

---

## Related endpoint (context only): Set Password

`POST /api/v1/auth/set-password` follows the same Bearer-auth shape via `AuthController.requireUserId` (invalid/missing token → 401 `INVALID_CREDENTIALS`) and calls `AuthServiceImpl.setPassword(userId, password)`. It has no "current password" to check — it exists for OAuth-only accounts that have never set one — and instead checks `user.passwordHash != null` → 400 `PASSWORD_ALREADY_SET` before hashing and saving the new password with `lastPasswordChange = now()`. It is a distinct, adjacent FR and is not detailed further here.

---

## Error paths summary (for "alt"/"opt" fragments)

| Step | Failure condition | HTTP | Error code |
|---|---|---|---|
| AuthController | Missing or malformed `Authorization: Bearer` header | 401 | `INVALID_CREDENTIALS` |
| AuthServiceImpl | The account no longer exists, even with a valid token | 404 | `USER_NOT_FOUND` |
| AuthServiceImpl | `currentPassword` does not match the stored hash | 400 | `WRONG_CURRENT_PASSWORD` |
| AuthServiceImpl | `newPassword` equals `currentPassword`, checked only after the above passes | 400 | `SAME_AS_CURRENT_PASSWORD` |
| Request validation | `newPassword` fails the password policy (BR-02) | 400 | `VALIDATION_ERROR` |

## Notes

- Check order matters: `WRONG_CURRENT_PASSWORD` is always evaluated before `SAME_AS_CURRENT_PASSWORD` — a wrong current password never falls through to the "same password" case.
- The session that made the change keeps its access token; every refresh token — on this device or any other — is invalidated by the `lastPasswordChange` bump (BR-12).
- `set-password` is mentioned only as a related/adjacent endpoint; it is out of scope for this FR's detailed flow.
