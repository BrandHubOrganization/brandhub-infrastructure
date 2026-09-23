# Task — Sign In With Email

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /api/v1/auth/login` — verify email/pw, chuẩn hóa email.
- [x] Phân nhánh 2FA: bật → trả `twoFactorToken` (không access token); tắt → token đầy đủ.
- [x] `LoginResponse` thêm `requireTwoFactor` + `twoFactorToken` (factory `twoFactorChallenge`).
- [x] `checkStatus()` — DEACTIVATED → 403 `ACCOUNT_DEACTIVATED`, SUSPENDED → 401.
- [x] `JwtUtil.generateTwoFactorToken` (TTL 5p, claim `type=2fa`).
- [x] `mvn compile` pass.
- [ ] Test login-2FA end-to-end (login → challenge → /2fa/verify → token).
