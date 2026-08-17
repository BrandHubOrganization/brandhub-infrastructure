# Plan — Đăng nhập

## Mục tiêu
Implement endpoint `POST /api/v1/auth/login` xác thực identifier (email hoặc SĐT) + password, issue JWT access + refresh token qua HttpOnly cookie.

## Thành phần liên quan
- `AuthController` — route `/api/v1/auth/login`.
- `AuthService` — logic xác thực (resolveByIdentifier, password check, status check) + phát token.
- `UserRepository` — `findByEmail` (lowercase) + `findByPhone` (E.164).
- `PhoneUtil` — chuẩn hóa SĐT sang E.164 trước khi tra cứu.
- `JwtUtil` + `JwtProperties` — tạo access (RS256) + refresh token.
- `StringRedisTemplate` — dùng cho refresh token blacklist.
- Frontend: `authService.login`, `authStore` (Zustand persist).

## Luồng dữ liệu
1. Nhận `{identifier, password}` → trim.
2. Phân loại identifier: chứa `@` → tìm theo email (lowercase); không chứa `@` → chuẩn hóa E.164 bằng `PhoneUtil.normalize()` → tìm theo phone.
3. Không thấy user → `INVALID_CREDENTIALS` (message chung, không tiết lộ định danh tồn tại).
4. Kiểm tra `isActive` và `status == ACTIVE` → không đạt → `ACCOUNT_SUSPENDED` (403).
5. `passwordHash` == null (OAuth-only) → `INVALID_CREDENTIALS` (401, message chung).
6. Verify password bằng `BCryptPasswordEncoder` chống lại `passwordHash`.
7. Sai → `INVALID_CREDENTIALS`.
8. Đúng → cập nhật `lastLoginAt`, tạo access token + refresh token, ghi audit LOGIN.
9. Set refresh token cookie (HttpOnly, Secure, SameSite=Strict).
10. Trả `LoginResponse{accessToken, tokenType, expiresIn}`.

## Thứ tự build
1. Đảm bảo `AuthService.login` xử lý đúng các nhánh lỗi (identifier resolve, password check, status check).
2. Ràng buộc message lỗi chung (tránh rò email/SĐT).
3. Tích hợp refresh token cookie.
4. Frontend: gọi login, lưu token vào store, redirect.

## Rủi ro
- Rò email/SĐT qua message khác nhau → dùng 1 message chung cho tất cả lỗi 401.
- SĐT chuẩn hóa E.164 sai → test kỹ với các format khác nhau (0XXXXXX, +84, local).
- Refresh token lưu sai → test kỹ luồng refresh.
