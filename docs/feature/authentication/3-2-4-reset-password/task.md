# Task — Reset Password

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /forgot-password` — sinh token + gửi email, luôn 200.
- [x] `POST /reset-password` — verify token, đổi password, revoke toàn bộ refresh token cũ.
- [x] `ForgotPasswordRequest`, `ResetPasswordRequest` DTO.
- [x] Error `INVALID_OR_EXPIRED_TOKEN` khi token sai/hết hạn.
- [x] `mvn compile` pass.
- [ ] Test: đổi password xong → mọi refresh token cũ bị revoke.
- [ ] Test: token cũ sau khi request lại nhiều lần → chỉ token mới hiệu lực.
