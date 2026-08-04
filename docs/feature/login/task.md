# Task — Đăng nhập

## Backend
- [ ] Endpoint `POST /api/v1/auth/login` nhận `{email, password}`.
- [ ] Trim + lowercase email trước khi tìm.
- [ ] Tìm user theo email; không thấy → `INVALID_CREDENTIALS`.
- [ ] Kiểm tra inactive/status → `ACCOUNT_DISABLED`.
- [ ] Verify password bằng BCrypt.
- [ ] Sai password → `INVALID_CREDENTIALS` (cùng message với email không tồn tại).
- [ ] Cập nhật `lastLoginAt`.
- [ ] Tạo access token RS256 + refresh token.
- [ ] Lưu refresh token.
- [ ] Trả `LoginResponse`.

## Frontend
- [ ] `authService.login` gọi đúng endpoint.
- [ ] LoginPage submit → gọi service → lưu token vào `authStore`.
- [ ] Redirect dashboard khi thành công.
- [ ] Hiển thị lỗi chung khi 401.
