# Task — Đăng nhập

## Backend
- [x] Endpoint `POST /api/v1/auth/login` nhận `{identifier, password}`.
- [x] Trim identifier, phân loại: `@` → email (lowercase); else → chuẩn hóa E.164 → phone.
- [x] `UserRepository.findByEmail` + `UserRepository.findByPhone`.
- [x] Không thấy user → `INVALID_CREDENTIALS` (message chung).
- [x] Kiểm tra `isActive` + `status == ACTIVE` → không đạt → `ACCOUNT_SUSPENDED`.
- [x] `passwordHash` null (OAuth-only) → `INVALID_CREDENTIALS`.
- [x] Verify password bằng BCrypt.
- [x] Sai password → `INVALID_CREDENTIALS` (cùng message với identifier không tồn tại).
- [x] Cập nhật `lastLoginAt` + ghi audit LOGIN.
- [x] Tạo access token RS256 + refresh token.
- [x] Set refresh token cookie (HttpOnly, Secure, SameSite=Strict).
- [x] Trả `LoginResponse`.

## Frontend
- [x] `authService.login` gọi đúng endpoint với `identifier` field.
- [x] LoginPage submit → gọi service → lưu token vào `authStore`.
- [x] Redirect dashboard khi thành công.
- [x] Hiển thị lỗi chung khi 401.
