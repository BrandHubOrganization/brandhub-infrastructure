# Task — Two-Factor Authentication (2FA, TOTP)

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `util/TotpUtil.java` — RFC 6238 (HMAC-SHA1, 6 chữ số, 30s) + Base32 encode/decode, stdlib.
- [x] `model/User.java` — thêm `twoFactorEnabled` + `totpSecret`.
- [x] `exception/ErrorCode.java` — thêm `TWO_FA_NOT_ENABLED`, `TWO_FA_ALREADY_ENABLED`, `TWO_FA_CODE_INVALID`, `TWO_FA_TOKEN_INVALID`.
- [x] `util/JwtUtil.java` — `generateTwoFactorToken` (TTL 5 phút, claim `type=2fa`).
- [x] `service/AuthService.java` — khai báo `setupTwoFactor/confirmTwoFactor/disableTwoFactor/verifyTwoFactor`.
- [x] `service/impl/AuthServiceImpl.java` — implement 4 method (Redis `2fa:setup:{userId}` cho pending secret).
- [x] `controller/AuthController.java` — endpoint `/2fa/setup|confirm|disable|verify`.
- [x] DTO: `TwoFactorSetupResponse`, `TwoFactorConfirmRequest`, `TwoFactorVerifyRequest`.
- [x] `mvn compile` pass.
- [ ] Viết unit test cho `TotpUtil` (generate/verify đúng, reject sai code).
- [ ] FE: render QR từ `qrCodeUrl`, UI `/settings/security` (ngoài plan BE).

> Ghi chú: bỏ copy secret + backup codes theo quyết định đã chốt.
