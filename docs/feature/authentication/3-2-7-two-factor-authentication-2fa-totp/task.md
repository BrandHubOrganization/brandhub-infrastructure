# Task — Two-Factor Authentication (2FA, TOTP)

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `util/TotpUtil.java` — RFC 6238 (HMAC-SHA1, 6 chữ số, 30s) + Base32 encode/decode, stdlib.
- [x] `model/User.java` — thêm `twoFactorEnabled` + `totpSecret`.
- [x] `exception/ErrorCode.java` — thêm `TWO_FA_NOT_ENABLED`, `TWO_FA_ALREADY_ENABLED`, `TWO_FA_CODE_INVALID`, `TWO_FA_TOKEN_INVALID`, `TWO_FA_TOO_MANY_ATTEMPTS` (429).
- [x] **[2026-09-25] BR-86 lockout:** `AuthServiceImpl.checkTwoFactorAttempt(userId, codeValid)` — Redis `2fa:attempt:{userId}`, TTL 10 phút, max 5 lần sai (`OTP_MAX_ATTEMPTS`) → `TWO_FA_TOO_MANY_ATTEMPTS`; gọi từ confirm/disable/verify.
- [x] `util/JwtUtil.java` — `generateTwoFactorToken` (TTL 5 phút, claim `type=2fa`).
- [x] `service/AuthService.java` — khai báo `setupTwoFactor/confirmTwoFactor/disableTwoFactor/verifyTwoFactor`.
- [x] `service/impl/AuthServiceImpl.java` — implement 4 method (Redis `2fa:setup:{userId}` cho pending secret).
- [x] `controller/AuthController.java` — endpoint `/2fa/setup|confirm|disable|verify`.
- [x] DTO: `TwoFactorSetupResponse`, `TwoFactorConfirmRequest`, `TwoFactorVerifyRequest`.
- [x] `mvn compile` pass.
- [ ] Viết unit test cho `TotpUtil` (generate/verify đúng, reject sai code) — và test service cho 4 method setup/confirm/disable/verify. **Xác nhận (2026-09-21): chưa có test nào cho 2FA** trong `brandhub-business-service/src/test` — đang bổ sung.
- [x] **[XÁC NHẬN 2026-09-21 — SỬA LẠI, dòng cũ ghi sai]** FE đã có đầy đủ: `pages/security/index.tsx` (enable/QR/confirm/disable UI đầy đủ), `pages/auth/TwoFactorVerifyPage.tsx` (bước nhập code khi login), route `/security` đã khai ở `AppRoutes.tsx`. Không phải "ngoài plan BE" hay còn thiếu — dòng cũ do Grep sai pattern (`settings/security` thay vì đúng path `pages/security`).

> Ghi chú: bỏ copy secret + backup codes theo quyết định đã chốt.
