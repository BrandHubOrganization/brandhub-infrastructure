# Task — Đăng ký

## Backend
- [ ] Endpoint `POST /api/v1/auth/register` nhận `{email, password, fullName}`.
- [ ] Trim + lowercase email.
- [ ] Kiểm tra email trùng → `EMAIL_ALREADY_EXISTS`.
- [ ] Hash password BCrypt.
- [ ] Tạo `User` (status ACTIVE).
- [ ] Tạo `UserSystemRole` mặc định USER.
- [ ] Trả `{userId}`.
- [ ] Bắt lỗi unique constraint khi trùng đồng thời.

## Frontend
- [ ] `authService.register` gọi đúng endpoint.
- [ ] RegisterPage form + validate (email, độ dài password, khớp password).
- [ ] Xử lý 409 → báo email đã tồn tại.
- [ ] Redirect verify/login sau thành công.
