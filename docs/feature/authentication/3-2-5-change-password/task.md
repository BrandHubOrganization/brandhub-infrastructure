# Task — Change Password

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] `POST /change-password` (Bearer) — verify currentPassword + set newPassword.
- [x] `ChangePasswordRequest` DTO.
- [x] Error `WRONG_CURRENT_PASSWORD` (400, check trước).
- [x] Guard `newPassword == currentPassword` → `SAME_AS_CURRENT_PASSWORD` (400, check sau `WRONG_CURRENT_PASSWORD`).
- [x] Cập nhật `lastPasswordChange` khi đổi thành công (invalid hoá refresh token cũ ở lần refresh tiếp theo).
- [x] Không tự logout sau khi đổi (access token hiện tại vẫn dùng được).
- [x] `mvn compile` pass.
- [ ] Test: đổi thành công, login bằng password mới.
