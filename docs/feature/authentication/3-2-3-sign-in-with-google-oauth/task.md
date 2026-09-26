# Task — Sign In with Google OAuth

> [plan.md](./plan.md) | [test.md](./test.md)

- [x] Điều tra bug: token exchange gửi JSON thay vì form-urlencoded.
- [x] Fix `fetchProfile()`: `MultiValueMap` + `APPLICATION_FORM_URLENCODED`.
- [x] Build consent URL (Google), state CSRF Redis.
- [x] Callback: merge email theo chuẩn hóa (login account cũ, không tạo trùng).
- [x] Tạo User mới `emailVerifiedAt=now`, không `passwordHash`, nếu email chưa tồn tại.
- [x] 2FA: nếu `twoFactorEnabled=true` → sinh `twoFactorToken`, redirect `/2fa-verify`, không cấp accessToken thẳng.
- [x] `mvn compile` pass.
- [ ] Verify flow thật (đăng nhập Google end-to-end).
- [ ] Test: email đã dùng bởi account password → gắn thêm provider, không tạo account trùng.

> Note: 2FA áp dụng OAuth (đã chốt 2026-09-20, đảo ngược ghi chú cũ "known limitation").

## Completion tasks
- [x] Configure backend credentials from local JSON.
- [x] Test and implement callback success, cancellation and invalid state.
- [x] Configure callback alias through gateway and security.
- [ ] Update vi/en translations and preserve light/dark styling.
- [x] Verify profile loading and clearing stale authentication.
- [x] Verify Git tracking and remote history; publish ignore rule.
- [ ] Verify live redirect; human Google consent remains required.
