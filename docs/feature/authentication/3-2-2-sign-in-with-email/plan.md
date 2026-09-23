# Plan — Sign In With Email

> [spec.md](./spec.md) — Login email/password, phân nhánh 2FA khi bật.

## Quyết định đã chốt (khác spec API cũ)

Spec đề xuất login trả `{accessToken, refreshToken, require2FA}` **cùng lúc**. Nhưng AC yêu cầu "2FA chặn trước khi cấp token" → KHÔNG cấp access token nếu chưa qua 2FA.

**Chốt: twoFactorToken + /2fa/verify** (xác nhận với Trung):
- Login email/pw đúng + 2FA **bật** → trả `LoginResponse(requireTwoFactor=true, twoFactorToken=...)` — **KHÔNG** có accessToken/refreshToken.
- FE chuyển màn nhập mã → gọi `POST /2fa/verify { twoFactorToken, code }` (FR 3.2.7) để lấy token đầy đủ.
- 2FA tắt → trả token như bình thường.

## Kỹ thuật

- `AuthServiceImpl.login()`: chuẩn hóa email → `checkStatus(user)` (DEACTIVATED → 403 `ACCOUNT_DEACTIVATED`, SUSPENDED → `INVALID_CREDENTIALS`) → verify password → 2FA bật? → trả `LoginResponse.twoFactorChallenge(twoFactorToken)` : `completeLogin(user, role)`.
- `JwtUtil.generateTwoFactorToken(userId)` — JWT ngắn hạn 5 phút, claim `type=2fa`.
- `completeLogin()` — phát access + refresh, blacklist cũ, audit log.

## Luồng

1. Validate + chuẩn hóa email → check tồn tại.
2. Verify password (bcrypt) → sai → 401 `INVALID_CREDENTIALS` (không tiết lộ).
3. `checkStatus` → DEACTIVATED → 403; SUSPENDED/other → 401.
4. `twoFactorEnabled` → challenge : completeLogin.

## Rủi ro

- User enum: mọi nhánh sai thông tin trả 401 chung.
