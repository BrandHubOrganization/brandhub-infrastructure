# Task — Reset Password

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /forgot-password` — sinh token + gửi email, luôn 200.
- [x] `POST /reset-password` — verify token, đổi password, set `lastPasswordChange` (invalid hoá refresh token cũ gián tiếp).
- [x] `ForgotPasswordRequest`, `ResetPasswordRequest` DTO.
- [x] Error `RESET_TOKEN_INVALID` / `RESET_TOKEN_USED` khi token sai/hết hạn/đã dùng.
- [x] Reverse-index Redis `pwd:reset:user:{userId}` → xoá token cũ khi có request forgot-password mới.
- [x] Xoá reverse-index sau khi reset-password dùng token thành công.
- [x] `mvn compile` pass.
- [ ] Test: đổi password xong → refresh token cũ (issued trước `lastPasswordChange`) bị từ chối ở `/refresh`.
- [ ] Test: request forgot-password nhiều lần → token cũ trả `RESET_TOKEN_INVALID` ngay (không cần đợi TTL hay dùng thử).
