# Plan — Sign Out

> [spec.md](./spec.md) — Logout + gợi ý phương thức đăng nhập lần trước.

## Quyết định lastUsedLoginMethod (spec để mở)

Chốt: **FE local storage** (xác nhận với Trung). Không cần thay đổi backend — FE tự lưu method (`email` | `google_oauth`) khi login/logout thành công, tự đọc khi render `/login` để highlight nút.

## Kỹ thuật

- **[MỚI 2026-09-25]** FE (`authService.ts`) giờ đã có `logout()` gọi endpoint này — trước đây `Navbar.handleLogout` chỉ `clearAuth()` local, không gọi API. Giờ gọi fire-and-forget (`.catch(() => {})`), không chờ response, vẫn `clearAuth()` + redirect ngay.
- `POST /api/v1/auth/logout` (Bearer + refresh cookie) → blacklist access token (Redis `jwt:blacklist:{jti}`) + revoke refresh token → clear cookie → ghi audit log → 200.
- **Idempotent**: token đã hết hạn/không hợp lệ → vẫn 200 (không báo lỗi).
- Chỉ revoke refresh token của thiết bị hiện tại (không ảnh hưởng thiết bị khác).
- **Audit log (2026-09-23):** `AuditLog` thêm 2 field `ipAddress` (`ip_address` VARCHAR 45) + `userAgent` (`user_agent` VARCHAR 512). Controller lấy từ header `X-Forwarded-For` / `User-Agent`, truyền xuống `authService.logout(accessToken, refreshToken, ipAddress, userAgent)` và **lưu vào bản ghi audit** (trước đây nhận param nhưng không lưu).

## Luồng

1. Auth header (Bearer) → access token (thiếu/sai prefix → 401 `INVALID_CREDENTIALS`).
2. Parse token lấy `userId`; blacklist access + revoke refresh (jti).
3. `INSERT audit_logs (userId, LOGOUT, USER, ipAddress, userAgent)` — chỉ khi có `userId`.
4. Clear `refreshToken` cookie (maxAge=0).
5. 200 (kể cả token đã hết hạn).

## Data Model

- Redis `jwt:blacklist:{jti}`.
- `audit_logs` thêm cột `ip_address` (VARCHAR 45), `user_agent` (VARCHAR 512) — migration `brandhub-infrastructure/scripts/migrations/2026-09-23-audit-log-ip-user-agent.sql`.

## Rủi ro

- Logout nhiều thiết bị: mỗi thiết bị revoke riêng (đúng spec).
- `ipAddress` lấy từ header `X-Forwarded-For` — nếu không có reverse proxy set header này đúng, giá trị có thể null/spoof. Chấp nhận ở mức hiện tại (audit nội bộ).
