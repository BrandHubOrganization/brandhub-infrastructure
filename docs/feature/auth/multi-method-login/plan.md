# Plan — Đăng nhập đa phương thức (email anchor)

## Mục tiêu
Biến email thành định danh duy nhất; cho đăng nhập bằng email **hoặc** SĐT (chung password_hash); link/ngắt link SĐT + OAuth provider; user OAuth-only có set-password. Dựa trên các feature cũ (login, oauth-social-login) đã có.

## Thành phần liên quan
- `User` model — **thêm** cột `phone` (E.164, unique, nullable).
- Migration DB — `ALTER TABLE users ADD COLUMN phone varchar(20) UNIQUE;`.
- `AuthService` — login phân loại `identifier` (email/SĐT), link phone OTP, set-password, unlink.
- `UserRepository` — `findByEmail` (có) + `findByPhone`.
- `UserOAuthProviderRepository` — link provider (có), thêm chống trùng provider.
- `OAuthService` — đã link theo email (có); giữ.
- Redis — OTP phone tạm `phone:otp:{userId}` hoặc reuse `User.otpCode`.
- `StringRedisTemplate`, `BCryptPasswordEncoder`.
- Frontend: `authService` + Profile/Settings page quản lý phương thức login.

## Luồng — login (identifier)
1. Nhận `{identifier, password}`.
2. Chứa `@` → tìm theo email; không → chuẩn hóa E.164 → tìm theo phone.
3. Không thấy → `INVALID_CREDENTIALS`.
4. Verify password BCrypt → sai → `INVALID_CREDENTIALS`.
5. Có `passwordHash` = null (OAuth-only) → `INVALID_CREDENTIALS` (chưa có password).
6. Issue JWT như login thường.

## Luồng — link phone (OTP)
1. `POST /auth/link/phone {phone}` (auth) → chuẩn hóa E.164.
2. Kiểm tra phone chưa thuộc user khác → trùng → `PHONE_ALREADY_IN_USE`.
3. Gửi OTP, lưu tạm.
4. `POST /auth/verify-phone-otp {otpCode}` (auth) → đúng → ghi `user.phone`.

## Luồng — set-password (OAuth-only)
1. `POST /auth/set-password {password}` (auth).
2. `passwordHash` đã có → `PASSWORD_ALREADY_SET`.
3. Chưa có → hash, set `passwordHash`.

## Luồng — unlink
- `POST /auth/unlink/phone` → xóa `user.phone`.
- `POST /auth/unlink/oauth {provider}` → xóa bản ghi `UserOAuthProvider`.
- Chặn: account còn lại < 1 phương thức login → `LAST_LOGIN_METHOD` (email anchor luôn còn, trừ khi check).

## Thứ tự build
1. Migration thêm `users.phone`.
2. Login identifier (email/SĐT) + `findByPhone`.
3. Link phone + OTP.
4. Set-password.
5. Unlink phone/oauth.
6. `/auth/me` trả phone + linkedProviders.
7. Frontend profile page.

## Rủi ro
- SĐT chuẩn hóa E.164 sai → normalize kỹ trước so khớp/lưu.
- Trùng phone đồng thời → unique constraint DB.
- OAuth-only login bằng password → chặn vì `passwordHash` null.
