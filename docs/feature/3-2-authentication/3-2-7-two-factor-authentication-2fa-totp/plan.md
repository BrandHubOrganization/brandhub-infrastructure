# Plan — Two-Factor Authentication (2FA, TOTP)

> Link: [spec.md](./spec.md) — Cho user bật 2FA bằng TOTP (scan QR), KHÔNG copy secret, KHÔNG backup codes.

## Phạm vi kỹ thuật

- **brandhub-business-service** (backend). FE render QR từ `otpAuthUrl` — ngoài phạm vi plan này.
- File sửa/tạo:
  - `util/TotpUtil.java` (MỚI) — RFC 6238 HMAC-SHA1 + Base32, stdlib.
  - `model/User.java` — thêm `twoFactorEnabled` (boolean), `totpSecret` (String).
  - `exception/ErrorCode.java` — thêm `TWO_FA_*`.
  - `service/AuthService.java` + `service/impl/AuthServiceImpl.java` — 3 method setup/confirm/disable + verify.
  - `controller/AuthController.java` — endpoint `/2fa/*`.
  - `util/JwtUtil.java` — `generateTwoFactorToken` (JWT ngắn hạn 5 phút, claim `type=2fa`).

## API Contract (final)

```
POST /api/v1/auth/2fa/setup     (Authorization: Bearer)
  → 200 { success:true, data:{ otpAuthUrl:"otpauth://totp/BrandHub:...@..." } }
  Không trả secretKey plaintext.

POST /api/v1/auth/2fa/confirm   { code:"123456" } (Authorization)
  → 200 { success:true, data:null }   (bật twoFactorEnabled=true)

POST /api/v1/auth/2fa/disable   { code:"123456" } (Authorization)
  → 200 { success:true, data:null }   (tắt, xóa totpSecret)

POST /api/v1/auth/2fa/verify    { twoFactorToken:"...", code:"123456" }  (KHÔNG cần auth)
  → 200 { data:{ accessToken, tokenType, expiresIn, requireTwoFactor:false } }
  (điểm hoàn tất login khi 2FA bật; set refresh cookie như login thường)
```

`/2fa/verify` bắt buộc để hoàn tất luồng login-2FA (đã có trong spec.md mục 5). Confirm/disable require Authorization (cần đăng nhập), verify thì không.

## Data Model

- `users` thêm 2 cột: `two_factor_enabled` (bool, default false), `totp_secret` (varchar 64, nullable).
- Secret PENDING lưu Redis `2fa:setup:{userId}` (TTL 10 phút) — chỉ ghi vào `users` khi confirm thành công, tránh trạng thái nửa-vời.
- Migration: cần ALTER TABLE thêm 2 cột (Flyway/Liquibase nếu có; hiện chưa thấy migration framework — dev chạy tay).

## Luồng xử lý

1. **setup**: check chưa bật → sinh secret 160-bit → lưu Redis `2fa:setup:{userId}` → trả `otpauth://` URI (không trả secret).
2. **confirm**: lấy secret pending từ Redis → `TotpUtil.verify` (±1 step) → đúng thì ghi `totpSecret` + `twoFactorEnabled=true`, xóa Redis. Sai → `TWO_FA_CODE_INVALID`.
3. **disable**: check đang bật → verify code với `totpSecret` → đúng thì tắt + null secret.
4. **verify** (login-2FA): parse `twoFactorToken`, check claim `type=2fa`, load user, verify code, issue token (tái dùng `completeLogin`).

## Dependencies

- Không phụ thuộc feature khác. FR 3.2.2 (login) đọc `twoFactorEnabled` để phân nhánh — phải xong trước/song song.

## Rủi ro kỹ thuật

- **Clock drift** giữa server/app Authenticator → cho phép ±1 step (WINDOW=1).
- **Mất app Authenticator** không có backup code (đã bỏ) → phải nhờ Admin (FR 3.10.5), chấp nhận trade-off đã chốt.
- **Bỏ copy secret** → FE không cần secret, giảm surface. QR render từ `otpAuthUrl` (có thể dùng lib QR phía FE).
- **Đổi tên field 2026-09-23:** `TwoFactorSetupResponse` đổi `qrCodeUrl` → `otpAuthUrl` để phản ánh đúng nội dung (đây là `otpauth://` URI, không phải URL ảnh QR). FE đọc `data.otpAuthUrl`.
- **BR-86 lockout (2026-09-25):** thêm `checkTwoFactorAttempt` trong `AuthServiceImpl` — Redis key `2fa:attempt:{userId}` TTL 10 phút, max 5 lần sai (`OTP_MAX_ATTEMPTS`, tái dùng constant có sẵn) → 429 `TWO_FA_TOO_MANY_ATTEMPTS`. Áp dụng chung cho confirm/disable/verify.
