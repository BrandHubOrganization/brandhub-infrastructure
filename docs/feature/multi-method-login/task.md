# Task — Đăng nhập đa phương thức

## DB
- [ ] Migration thêm `users.phone` varchar(20), unique, nullable.
- [ ] `User` model thêm field `phone`.

## Backend — login
- [ ] `AuthService.login` nhận `identifier` (email/SĐT) + password.
- [ ] `UserRepository.findByPhone` (chuẩn hóa E.164).
- [ ] Phân loại identifier: `@` → email; else → phone.
- [ ] OAuth-only (passwordHash null) → `INVALID_CREDENTIALS`.

## Backend — link phone
- [ ] `POST /auth/link/phone` (auth): chuẩn hóa E.164, check trùng → `PHONE_ALREADY_IN_USE`, gửi OTP.
- [ ] `POST /auth/verify-phone-otp` (auth): validate OTP → ghi `user.phone`.

## Backend — set-password
- [ ] `POST /auth/set-password` (auth): `passwordHash` có → `PASSWORD_ALREADY_SET`; chưa → hash + set.

## Backend — unlink
- [ ] `POST /auth/unlink/phone` (auth): xóa phone.
- [ ] `POST /auth/unlink/oauth` (auth): xóa provider; chống link trùng.
- [ ] Chặn `LAST_LOGIN_METHOD` khi hết phương thức.

## Backend — me
- [ ] `GET /auth/me` trả email, phone, hasPassword, linkedProviders.

## Frontend
- [ ] `authService`: login identifier, linkPhone, verifyPhoneOtp, setPassword, unlink, me.
- [ ] Profile page quản lý phương thức login (SĐT + OAuth + set-password).
