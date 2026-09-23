# Task — Change Password

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /change-password` (Bearer) — verify currentPassword + set newPassword.
- [x] `ChangePasswordRequest` DTO.
- [x] Error `INVALID_CURRENT_PASSWORD`.
- [x] Không tự logout sau khi đổi.
- [x] `mvn compile` pass.
- [ ] Guard `newPassword == currentPassword` → `SAME_AS_CURRENT_PASSWORD` (nếu chưa có).
- [ ] Test: đổi thành công, login bằng password mới.
