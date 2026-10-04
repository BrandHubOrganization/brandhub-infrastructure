# Task — Sign In With Email

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /api/v1/auth/login` — verify email/pw, chuẩn hóa email.
- [x] Phân nhánh 2FA: bật → trả `twoFactorToken` (không access token); tắt → token đầy đủ.
- [x] `LoginResponse` thêm `requireTwoFactor` + `twoFactorToken` (factory `twoFactorChallenge`).
- [x] `checkStatus()` — DEACTIVATED → 403 `ACCOUNT_DEACTIVATED`, SUSPENDED → 401.
- [x] `JwtUtil.generateTwoFactorToken` (TTL 5p, claim `type=2fa`).
- [x] `mvn compile` pass.
- [ ] Test login-2FA end-to-end (login → challenge → /2fa/verify → token).

## Dev Quick Login repair — 2026-10-04

- [x] Tái hiện INVALID_CREDENTIALS và xác nhận ba tài khoản thiếu, 0 Workspace/ClientProfile.
- [x] Spec → plan → task → test trước code.
- [x] Viết test RED cho workspace UUID động/role.
- [x] Seed fixture nhỏ, idempotent và không sửa tài khoản đã có.
- [x] Sửa helper điều hướng từ quyền thật; locale VI/EN.
- [x] E2E/build/lint và đăng nhập cả bốn role qua API thật; ghi kết quả.

