# Task — Sign Up

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /api/v1/auth/register` — validate + chuẩn hóa email + hash bcrypt + gửi OTP.
- [x] Chuẩn hóa email case-insensitive (lowercase + trim toàn bộ email).
- [x] Email trùng → unique constraint → bắt `DataIntegrityViolationException` → 409 `EMAIL_ALREADY_EXISTS`.
- [x] `RegisterRequest` (email, password, fullName) validation.
- [x] `RegisterResponse(userId)`.
- [x] Verify OTP (FR 3.2.6) → set `emailVerifiedAt=now`, KHÔNG auto login.
- [x] `mvn compile` pass.
- [ ] Unit test chuẩn hóa email (đăng ký 2 lần case khác → lần 2 trả 409, không tạo thêm account).

> Note: `confirmPassword` do FE check; BE nhận email+password+fullName.
