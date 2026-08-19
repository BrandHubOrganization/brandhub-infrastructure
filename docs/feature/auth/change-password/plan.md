# Plan — Đổi mật khẩu

## Mục tiêu
Implement `POST /auth/change-password` (authenticated) xác nhận currentPassword rồi đặt password mới.

## Thành phần liên quan
- `AuthController` — route `/auth/change-password`.
- `AuthService` — logic đổi mật khẩu.
- JWT filter — lấy userId từ token.
- `UserRepository` — load user + lưu.
- `BCryptPasswordEncoder` — verify + hash.
- Frontend: `authService.changePassword`, form trong profile/settings.

## Luồng dữ liệu
1. Lấy userId từ JWT.
2. Load user.
3. Verify `currentPassword` bằng BCrypt → sai → `WRONG_CURRENT_PASSWORD`.
4. Hash `newPassword` → set `passwordHash`, `lastPasswordChange`.
5. Trả success.

## Thứ tự build
1. Xác định userId từ token.
2. Verify currentPassword.
3. Hash + cập nhật password mới.
4. Frontend form + service.

## Rủi ro
- Nhầm currentPassword → luôn verify BCrypt trước khi đổi.
- Sau đổi, quyết định giữ/đăng xuất phiên — ghi rõ hành vi.
