# Task — Sign In with Google OAuth

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] Điều tra bug: token exchange gửi JSON thay vì form-urlencoded.
- [x] Fix `fetchProfile()`: `MultiValueMap` + `APPLICATION_FORM_URLENCODED`.
- [x] Build consent URL (Google), state CSRF Redis.
- [x] Callback: merge email theo chuẩn hóa (login account cũ, không tạo trùng).
- [x] Tạo User mới `emailVerified=true` nếu email chưa tồn tại.
- [x] `mvn compile` pass.
- [ ] Verify flow thật (đăng nhập Google end-to-end).
- [ ] Test: email đã dùng bởi account password → merge, không account trùng.

> Note: 2FA không áp dụng OAuth (known limitation).
