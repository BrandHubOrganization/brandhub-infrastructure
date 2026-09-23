# Sequence Flow — Two-Factor Authentication (2FA, TOTP)

> Bổ sung cho `spec.md` (FR 3.2.7). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController` các route `/2fa/*`, `AuthServiceImpl`, `TotpUtil`).

## Actors

- **User** — đã đăng nhập (setup/confirm/disable) hoặc đang login (verify).
- **FE** — brandhub-web-dashboard (`/settings/security`, `/2fa-verify`).
- **BE** — brandhub-business-service.
- **DB** — PostgreSQL (`users.totp_secret`, `users.two_factor_enabled`), Redis (`2fa:setup:{userId}` secret tạm, TTL 10 phút).
- **Authenticator App** — Google Authenticator/Authy (offline, ngoài hệ thống).

---

## Flow A — Setup 2FA lần đầu

1. User → FE: `/settings/security`, bấm "Bật 2FA".
2. FE → BE: `POST /api/v1/auth/2fa/setup` (Bearer token).
3. BE (`setupTwoFactor`): tìm `User` — không có → `404 USER_NOT_FOUND`; `twoFactorEnabled=true` sẵn → `400 TWO_FA_ALREADY_ENABLED`.
4. BE: `TotpUtil.generateSecret()` sinh secret ngẫu nhiên → `SET 2fa:setup:{userId}=secret` Redis, TTL 10 phút — **secret CHƯA lưu vào DB** ở bước này (chỉ tạm trong Redis cho tới khi confirm).
5. BE → FE: `200 { otpAuthUrl }` — `TotpUtil.buildOtpAuthUrl(email, secret)` dạng `otpauth://totp/...` — **không trả `secret` plain text** (đúng theo spec, không có nút copy).
6. FE: render QR code từ `otpAuthUrl` (client-side, dùng lib QR).
7. User → Authenticator App: scan QR → app tự sinh mã TOTP 6 số theo chu kỳ 30s.
8. User → FE: nhập mã từ app để confirm.
9. FE → BE: `POST /api/v1/auth/2fa/confirm {code}`.
10. BE (`confirmTwoFactor`):
    a. `twoFactorEnabled=true` sẵn (race condition/double submit) → `400 TWO_FA_ALREADY_ENABLED`.
    b. `GET 2fa:setup:{userId}` từ Redis — không có (hết hạn 10 phút hoặc chưa từng gọi `/setup`) → `400 TWO_FA_NOT_ENABLED`.
    c. `TotpUtil.verify(secret, code)` sai → `400 TWO_FA_CODE_INVALID`, **không** xóa Redis key (user được thử lại trong 10 phút).
    d. Đúng → `UPDATE users SET totpSecret=secret, twoFactorEnabled=true`, xóa `2fa:setup:{userId}` khỏi Redis.
11. BE → FE: `200 { success: true, data: null }`.
12. FE: toast xác nhận 2FA đã bật.

## Flow B — Disable 2FA

1. User → FE: `/settings/security`, bấm "Tắt 2FA", nhập mã TOTP hiện tại để xác nhận.
2. FE → BE: `POST /api/v1/auth/2fa/disable {code}` (Bearer token).
3. BE (`disableTwoFactor`): `!twoFactorEnabled || totpSecret=null` → `400 TWO_FA_NOT_ENABLED`; `TotpUtil.verify` sai → `400 TWO_FA_CODE_INVALID`.
4. BE: `UPDATE users SET twoFactorEnabled=false, totpSecret=null`.
5. BE → FE: `200 { success: true, data: null }`.

## Flow C — Verify 2FA lúc login (tiếp nối FR 3.2.2 Flow B / FR 3.2.3 Flow C)

1. User đã qua bước email/password (FR 3.2.2) hoặc Google OAuth (FR 3.2.3) với `twoFactorEnabled=true` → nhận `twoFactorToken` (JWT `type=2fa`, không phải access token).
2. User → FE (`/2fa-verify`): nhập mã TOTP từ app.
3. FE → BE: `POST /api/v1/auth/2fa/verify {twoFactorToken, code}` — **route KHÔNG cần Bearer header**, vì user chưa có access token thật, `twoFactorToken` chính là bằng chứng đã qua bước 1.
4. BE (`verifyTwoFactor`):
   a. Parse `twoFactorToken` — lỗi JWT hoặc `claims.type != "2fa"` → `401 TWO_FA_TOKEN_INVALID`.
   b. Tìm `User` theo `subject` trong token — không có → `401 TWO_FA_TOKEN_INVALID`.
   c. `checkStatus(user)` — suspended/deactivated → `403 ACCOUNT_SUSPENDED`/`403 ACCOUNT_DEACTIVATED`.
   d. `!twoFactorEnabled || totpSecret=null` (user vừa tắt 2FA ở tab khác giữa lúc đang login) → `400 TWO_FA_NOT_ENABLED`.
   e. `TotpUtil.verify` sai → `400 TWO_FA_CODE_INVALID`.
   f. Đúng → `completeLogin`: set `lastLoginAt`, ghi `AuditLog(LOGIN)`, sinh `accessToken` + `refreshToken` như login thường.
5. BE → FE: `200 { accessToken, tokenType, expiresIn, requireTwoFactor=false }` + Set-Cookie `refreshToken`.
6. FE: lưu token, `GET /api/v1/users/me`, `setAuth(...)`, điều hướng Dashboard.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Setup | User không tồn tại | 404 | `USER_NOT_FOUND` |
| Setup | 2FA đã bật sẵn | 400 | `TWO_FA_ALREADY_ENABLED` |
| Confirm | 2FA đã bật sẵn | 400 | `TWO_FA_ALREADY_ENABLED` |
| Confirm | Không có secret tạm trong Redis (hết hạn/chưa setup) | 400 | `TWO_FA_NOT_ENABLED` |
| Confirm | Mã TOTP sai | 400 | `TWO_FA_CODE_INVALID` |
| Disable | 2FA chưa bật | 400 | `TWO_FA_NOT_ENABLED` |
| Disable | Mã TOTP sai | 400 | `TWO_FA_CODE_INVALID` |
| Verify (login) | Token JWT lỗi hoặc sai `type` | 401 | `TWO_FA_TOKEN_INVALID` |
| Verify (login) | User không tồn tại theo token | 401 | `TWO_FA_TOKEN_INVALID` |
| Verify (login) | User suspended | 403 | `ACCOUNT_SUSPENDED` |
| Verify (login) | User deactivated | 403 | `ACCOUNT_DEACTIVATED` |
| Verify (login) | 2FA đã bị tắt giữa chừng | 400 | `TWO_FA_NOT_ENABLED` |
| Verify (login) | Mã TOTP sai | 400 | `TWO_FA_CODE_INVALID` |
