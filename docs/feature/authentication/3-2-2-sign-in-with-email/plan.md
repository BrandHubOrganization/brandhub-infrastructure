# Plan — Sign In With Email

> [spec.md](./spec.md) — Login email/password, phân nhánh 2FA khi bật.

## Quyết định đã chốt (khác spec API cũ)

Spec đề xuất login trả `{accessToken, refreshToken, require2FA}` **cùng lúc**. Nhưng AC yêu cầu "2FA chặn trước khi cấp token" → KHÔNG cấp access token nếu chưa qua 2FA.

**Chốt: twoFactorToken + /2fa/verify** (xác nhận với Trung):
- Login email/pw đúng + 2FA **bật** → trả `LoginResponse(requireTwoFactor=true, twoFactorToken=...)` — **KHÔNG** có accessToken/refreshToken.
- FE chuyển màn nhập mã → gọi `POST /2fa/verify { twoFactorToken, code }` (FR 3.2.7) để lấy token đầy đủ.
- 2FA tắt → trả token như bình thường.

## Kỹ thuật

- `AuthServiceImpl.login()`: `resolveByIdentifier(identifier)` → `checkStatus(user)` (DEACTIVATED → 403 `ACCOUNT_DEACTIVATED`, không active/status khác → 403 `ACCOUNT_SUSPENDED`) → verify password → 2FA bật? → trả `LoginResponse.twoFactorChallenge(twoFactorToken)` : `completeLogin(user, role)`.
- `JwtUtil.generateTwoFactorToken(userId)` — JWT ngắn hạn 5 phút, claim `type=2fa`.
- `completeLogin()` — phát access + refresh, blacklist cũ, audit log.

## Luồng

1. Validate `identifier` (email/phone) + chuẩn hóa → check tồn tại → không thấy → 401 `INVALID_CREDENTIALS`.
2. `checkStatus` → DEACTIVATED → 403 `ACCOUNT_DEACTIVATED`; không active/status khác → 403 `ACCOUNT_SUSPENDED`.
3. Verify password (bcrypt), hoặc `passwordHash=null` (OAuth-only) → sai → 401 `INVALID_CREDENTIALS` (không tiết lộ).
4. `twoFactorEnabled` → challenge : completeLogin.

## Rủi ro

- User enum: mọi nhánh sai thông tin trả 401 chung.
