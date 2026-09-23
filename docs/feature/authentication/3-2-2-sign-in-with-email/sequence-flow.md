# Sequence Flow — Sign In With Email

> Bổ sung cho `spec.md` (FR 3.2.2). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật tại thời điểm này (`AuthController.login`, `AuthServiceImpl.login`).

## Actors

- **User** — đã có tài khoản.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`users`, `user_system_roles`, `workspace_members`), Redis (JWT blacklist — không dùng ở login).

---

## Flow A — Đăng nhập thành công, không 2FA

1. User → FE: mở `/login`, điền `email` (thực chất field request tên là `identifier` — hỗ trợ cả email lẫn phone), `password`.
2. FE → BE: `POST /api/v1/auth/login` `{identifier, password}`.
3. BE (`AuthServiceImpl.login`):
   a. `resolveByIdentifier`: nếu có `@` → tìm theo email (lowercase); ngược lại chuẩn hóa như số điện thoại (`PhoneUtil.normalize`) → tìm theo phone. Không tìm thấy → `401 INVALID_CREDENTIALS`.
   b. `checkStatus`: `!user.isActive()` → `403 ACCOUNT_SUSPENDED`; `status=DEACTIVATED` → `403 ACCOUNT_DEACTIVATED`; `status` khác `ACTIVE` (không rơi 2 case trên) → `403 ACCOUNT_SUSPENDED`.
   c. So khớp password bcrypt — sai hoặc `passwordHash=null` (tài khoản OAuth-only) → `401 INVALID_CREDENTIALS`.
   d. `user.isTwoFactorEnabled() == false` → `completeLogin`: set `lastLoginAt`, ghi `AuditLog(LOGIN)`, resolve `workspaceId` active đầu tiên của user, sinh `accessToken` (JWT, kèm role + workspaceId) + `refreshToken`.
4. BE → FE: `200 { accessToken, tokenType, expiresIn, requireTwoFactor=false }` + Set-Cookie `refreshToken` (HttpOnly, Secure, SameSite=Strict, path=`/api/v1/auth`).
5. FE: lưu `accessToken` vào store, gọi `GET /api/v1/users/me` (hoặc `/api/v1/auth/me`) lấy profile → `setAuth(...)` → điều hướng Dashboard/Agency list.

## Flow B — Đăng nhập, tài khoản có bật 2FA

Giống Flow A bước 1–3c, khác từ bước 3d:

3d. `user.isTwoFactorEnabled() == true` → sinh `twoFactorToken` (JWT loại `type=2fa`, payload subject=userId) → **KHÔNG cấp accessToken/refreshToken ở bước này**.
4. BE → FE: `200 { accessToken=null, tokenType=null, expiresIn=null, requireTwoFactor=true }` — `twoFactorToken` nằm trong `LoginResult` nội bộ, controller **không set Cookie refreshToken** ở nhánh này (`if (result.twoFactorToken() != null) return ...` — return sớm, bỏ qua đoạn set cookie).
   - Response thật `LoginResponse.twoFactorChallenge(twoFactorToken)` — record `LoginResponse(accessToken, tokenType, expiresIn, requireTwoFactor, twoFactorToken)`, field `twoFactorToken` nằm trực tiếp trong `data` trả về FE (xác nhận từ `LoginResponse.java`).
5. FE: nhận `requireTwoFactor=true` → lưu `twoFactorToken`, điều hướng `/2fa-verify` (component dùng chung — xem FR 3.2.7 Flow verify).
6. Tiếp tục **FR 3.2.7 — verify 2FA**: FE → BE `POST /api/v1/auth/2fa/verify {twoFactorToken, code}` → thành công → `200` kèm accessToken thật + Set-Cookie refreshToken → FE tiếp bước 5 của Flow A.

---

## Error paths tổng hợp (dùng cho sequence "alt"/"opt" fragments)

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Login | Không tìm thấy user theo identifier | 401 | `INVALID_CREDENTIALS` |
| Login | Sai password / user không có password (OAuth-only) | 401 | `INVALID_CREDENTIALS` |
| Login | `isActive()=false` hoặc `status` khác ACTIVE/DEACTIVATED | 403 | `ACCOUNT_SUSPENDED` |
| Login | `status=DEACTIVATED` | 403 | `ACCOUNT_DEACTIVATED` |
| Login (2FA nhánh phụ) | 2FA bật, chờ verify riêng | 200 | không lỗi — `requireTwoFactor=true` |
