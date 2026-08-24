# Task — User Settings Expansion

## Backend
- [ ] `ErrorCode.OAUTH_EMAIL_MISMATCH` mới.
- [ ] `OAuthService.buildAuthorizationUrl(UUID linkingUserId)` overload, đổi state format sang pipe-delimited.
- [ ] `handleCallback()` — phân nhánh link-mode (so email, throw `OAUTH_EMAIL_MISMATCH` nếu khác) vs login-mode (giữ nguyên).
- [ ] Route `GET /{provider}/link` — cả 4 controller (Google/GitHub/LinkedIn/Microsoft), nhận `token` query param, verify JWT, gọi `buildAuthorizationUrl(userId)`.
- [ ] Callback redirect: link-mode thành công → `/settings?linked={provider}`, login-mode giữ `/oauth-callback?token=`.
- [ ] `mvn compile` + `mvn test` — thêm test case link-mode thành công + email-mismatch.

## Frontend — Nav
- [ ] `Sidebar.tsx` — thêm nav item "Thiết lập" vào section Hệ thống, hiện mọi role.

## Frontend — SettingsPage mở rộng
- [ ] Thêm tab "Chung" (General) — theme toggle (`useTheme()`), language toggle (tái dùng logic landing Navbar).
- [ ] Thêm phone link UI vào cuối tab Profile — hiện phone hiện tại, form gửi OTP nếu chưa có, form xác nhận OTP, nút gỡ nếu đã có.
- [ ] Thêm tab "Kết nối tài khoản" — list Google/GitHub, trạng thái từ `linkedProviders`, nút Kết nối/Ngắt kết nối.
- [ ] `authService.ts` — thêm `oauthLinkUrl(provider)`.
- [ ] Xử lý query param `?linked=`/`?error=` khi mount `SettingsPage` — toast tương ứng.

## i18n
- [ ] `nav.settings` — thêm cả 2 file.
- [ ] `settings.tabs.general`, `settings.tabs.connections` — thêm cả 2 file.
- [ ] `settings.general.*` (themeLabel, languageLabel) — thêm cả 2 file.
- [ ] `settings.phone.*` (label, sendOtp, verifyOtp, unlink, otpSentSuccess) — thêm cả 2 file.
- [ ] `settings.connections.*` (title, connect, disconnect, connectedLabel, notConnectedLabel, emailMismatchWarning) — thêm cả 2 file.

## Verify
- [ ] `tsc --noEmit` clean.
- [ ] `eslint` clean cho file đã sửa.
- [ ] `mvn compile` + `mvn test` clean.
- [ ] Test tay: click "Thiết lập" từ Sidebar → đúng `/settings`.
- [ ] Test tay: đổi theme → áp dụng ngay, giữ qua reload.
- [ ] Test tay: đổi ngôn ngữ → áp dụng ngay, giữ qua reload.
- [ ] Test tay: link Google với đúng email hiện tại → thành công, `linkedProviders` cập nhật.
- [ ] Test tay (nếu có 2 tài khoản Google test): link Google với email khác → lỗi `OAUTH_EMAIL_MISMATCH` hiển thị đúng, không tạo/link nhầm user.
- [ ] Test tay: unlink provider cuối cùng khi không có mật khẩu/phone khác → lỗi `LAST_LOGIN_METHOD` hiển thị đúng.
