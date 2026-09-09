# Task — Đăng ký

## Backend
- [x] Endpoint `POST /api/v1/auth/register` nhận `{email, password, fullName}` (trả 201 Created).
- [x] Trim + lowercase email.
- [x] Kiểm tra email trùng → `EMAIL_ALREADY_EXISTS`.
- [x] Hash password BCrypt.
- [x] Tạo `User` (status ACTIVE).
- [x] Tạo `UserSystemRole` mặc định USER.
- [x] Tự động tạo OTP 6 số + gửi email xác thực ngay sau đăng ký.
- [x] Trả `{userId}`.
- [x] Bắt lỗi unique constraint khi trùng đồng thời.

## Frontend
- [x] `authService.register` gọi đúng endpoint.
- [x] RegisterPage form + validate (email, độ dài password, khớp password).
- [x] Xử lý 409 → báo email đã tồn tại.
- [x] Redirect verify/login sau thành công.
