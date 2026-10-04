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

## Dev Quick Login repair — 2026-10-04

1. `src/main/resources/seed/dev-quick-login.sql`: PostgreSQL transaction/guard tạo fixture cho ba email legacy khi thiếu; agency/workspace/package/profile có UUID riêng cố định để rerun idempotent. Password bcrypt qua pgcrypto, chỉ áp dụng tài khoản mới. Reuse existing seed tool conventions, không thêm API công khai hay migration production.
2. `brandhub-web/src/components/auth/DevQuickLogin.tsx`: giữ Admin/Owner/Client landing; Manager/Creator gọi workspaceService.list sau setAuth, chọn myRole thay landingPath UUID. Có fallback và error giữ phiên thật; challenge 2FA đi /2fa-verify.
3. `src/i18n/locales/{vi,en}/auth.json`: `login.devWorkspaceMissing`.
4. Playwright fixture chứng minh Manager/Creator được đưa vào UUID API trả, không chọn Workspace sai role; Client/Owner/Admin landing giữ nguyên, 2FA không đọc profile. Live browser cả bốn role, verify DB rerun không thêm record hoặc sửa dữ liệu ngoài fixture; không chạy bulk reseed.

