# Plan — Đăng nhập

## Mục tiêu
Implement endpoint `POST /api/v1/auth/login` xác thực email + password, issue JWT access + refresh token.

## Thành phần liên quan
- `AuthController` — route `/api/v1/auth/login`.
- `AuthService` — logic xác thực + phát token.
- `UserRepository` — tìm user theo email (lowercase).
- `JwtUtil` + `JwtProperties` — tạo access (RS256) + refresh token.
- `UserRefreshTokenRepository` — lưu refresh token.
- Frontend: `authService.login`, `authStore` (Zustand persist).

## Luồng dữ liệu
1. Nhận `{email, password}` → trim + lowercase email.
2. Tìm user theo email. Không thấy → ném `INVALID_CREDENTIALS` (message chung).
3. Kiểm tra `isActive` / `status` → inactive → `ACCOUNT_DISABLED`.
4. Verify password bằng `BCryptPasswordEncoder` chống lại `passwordHash`.
5. Sai → `INVALID_CREDENTIALS`.
6. Đúng → cập nhật `lastLoginAt`, tạo access token + refresh token, lưu refresh token.
7. Trả `LoginResponse{accessToken, tokenType, expiresIn}`.

## Thứ tự build
1. Đảm bảo `AuthService.login` xử lý đúng các nhánh lỗi.
2. Ràng buộc message lỗi chung (tránh rò email).
3. Tích hợp refresh token lưu trữ.
4. Frontend: gọi login, lưu token vào store, redirect.

## Rủi ro
- Rò email qua message khác nhau → dùng 1 message chung cho cả 2 lỗi.
- Refresh token lưu sai → test kỹ luồng refresh.
