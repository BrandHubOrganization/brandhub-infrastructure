# Task — Đăng nhập đa phương thức

## DB
- [x] Migration thêm `users.phone` varchar(20), unique, nullable.
- [x] `User` model thêm field `phone`.

## Backend — login
- [x] `AuthService.login` nhận `identifier` (email/SĐT) + password.
- [x] `UserRepository.findByPhone` (chuẩn hóa E.164).
- [x] Phân loại identifier: `@` → email; else → phone.
- [x] OAuth-only (passwordHash null) → `INVALID_CREDENTIALS`.
- [x] Account status check: `isActive` + `status == ACTIVE` → `ACCOUNT_SUSPENDED`.

## Backend — link phone
- [x] `POST /auth/link/phone` (auth): chuẩn hóa E.164 (PhoneUtil), check trùng → `PHONE_ALREADY_IN_USE`, gửi OTP qua email.
- [x] `POST /auth/verify-phone-otp` (auth): validate OTP từ Redis `phone:otp:{userId}` → ghi `user.phone`.

## Backend — set-password
- [x] `POST /auth/set-password` (auth): `passwordHash` có → `PASSWORD_ALREADY_SET`; chưa → hash + set.

## Backend — unlink
- [x] `POST /auth/unlink/phone` (auth): xóa phone, chặn `LAST_LOGIN_METHOD`.
- [x] `POST /auth/unlink/oauth` (auth): xóa provider; chống link trùng.
- [x] Chặn `LAST_LOGIN_METHOD` khi hết phương thức (không password, không phone, chỉ 1 provider).

## Backend — me
- [x] `GET /auth/me` trả email, phone, hasPassword, linkedProviders.

## Frontend
- [x] `authService`: login identifier, linkPhone, verifyPhoneOtp, setPassword, unlinkPhone, unlinkOAuth, me.
- [x] Profile page quản lý phương thức login (SĐT + OAuth + set-password).
