# Task — Sign Up

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /api/v1/auth/register` — validate + chuẩn hóa email + hash bcrypt + gửi OTP.
- [x] Chuẩn hóa email case-insensitive (lowercase local-part).
- [x] Check email tồn tại → 409 `EMAIL_ALREADY_EXISTS`.
- [x] `RegisterRequest` (email, password) validation.
- [x] `RegisterResponse(otpSessionId, email)`.
- [x] Verify OTP → `emailVerified=true` + auto login (FR 3.2.6).
- [x] `mvn compile` pass.
- [ ] Unit test chuẩn hóa email (đăng ký 2 lần case khác → 1 account).

> Note: password `confirmPassword` do FE check; BE chỉ nhận email+password.
