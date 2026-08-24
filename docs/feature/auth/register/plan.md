# Plan — Đăng ký

## Mục tiêu
Implement `POST /api/v1/auth/register` tạo user mới từ email/password/fullName, gán role mặc định.

## Thành phần liên quan
- `AuthController` — route `/api/v1/auth/register`.
- `AuthService` — logic tạo user.
- `UserRepository` — kiểm tra trùng email + lưu.
- `UserSystemRoleRepository` — gán role mặc định.
- `BCryptPasswordEncoder` — hash password.
- Frontend: `authService.register`, RegisterPage.

## Luồng dữ liệu
1. Nhận `{email, password, fullName}` → trim + lowercase email.
2. Kiểm tra email đã tồn tại → có → `EMAIL_ALREADY_EXISTS`.
3. Hash password bằng BCrypt.
4. Tạo `User` (status ACTIVE, isActive true).
5. Tạo `UserSystemRole` với `SystemRole.USER`.
6. Trả `{userId}`.

## Thứ tự build
1. Validation field + chuẩn hóa email.
2. Kiểm tra trùng email.
3. Hash + lưu user + role.
4. Frontend form + gọi service + redirect verify/login.

## Rủi ro
- Đua trạng thái trùng email (2 request cùng lúc) → dựa vào unique constraint DB, bắt exception.
- Password lưu plaintext → luôn BCrypt.
