# Plan — Sign Out

> [spec.md](./spec.md) — Logout + gợi ý phương thức đăng nhập lần trước.

## Quyết định lastUsedLoginMethod (spec để mở)

Chốt: **FE local storage** (xác nhận với Trung). Không cần thay đổi backend — FE tự lưu method (`email` | `google_oauth`) khi login/logout thành công, tự đọc khi render `/login` để highlight nút.

## Kỹ thuật

- `POST /api/v1/auth/logout` (Bearer + refresh cookie) → blacklist access token (Redis `jwt:blacklist:{jti}`) + revoke refresh token → clear cookie → 200.
- **Idempotent**: token đã hết hạn/không hợp lệ → vẫn 200 (không báo lỗi).
- Chỉ revoke refresh token của thiết bị hiện tại (không ảnh hưởng thiết bị khác).

## Luồng

1. Auth header (Bearer) → access token.
2. Blacklist access + revoke refresh (jti).
3. Clear `refreshToken` cookie (maxAge=0).
4. 200 (kể cả token đã hết hạn).

## Data Model

- Redis `jwt:blacklist:{jti}`.

## Rủi ro

- Logout nhiều thiết bị: mỗi thiết bị revoke riêng (đúng spec).
