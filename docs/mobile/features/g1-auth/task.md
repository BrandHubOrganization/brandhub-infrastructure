# Task — G1 Authentication (Mobile)

> [spec.md](./spec.md) | [plan.md](./plan.md) | [test.md](./test.md)

## Infra chung

- [ ] Axios instance + response interceptor auto-refresh 401 (`POST /auth/refresh`, retry request gốc).
- [ ] `expo-secure-store` wrapper: `getTokens()`, `setTokens()`, `clearTokens()`.
- [ ] `useAuthStore` (Zustand) — `accessToken`, `refreshToken`, `user`, `lastUsedPlatform`, `isAuthenticated`, `setAuth()`, `setTokens()`, `clearAuth()`.
- [ ] Bảng message lỗi tiếng Việt tập trung (map `ErrorCode` → string).
- [ ] Deep link scheme `brandhub` đăng ký trong `app.json`/`app.config.ts`.

## Login / Register / OTP

- [ ] `useLoginMutation` — `POST /auth/login`, set Zustand store khi không cần 2FA, điều hướng `TwoFactorVerify` khi `requireTwoFactor === true`.
- [ ] `useRegisterMutation` — `POST /auth/register`, điều hướng `VerifyOtp(email, purpose=register)` sau khi có `userId`.
- [ ] `useVerifyOtpMutation`, `useResendOtpMutation` (cooldown 60s client-side).
- [ ] Screen `Login`: form identifier+password, link "Quên mật khẩu?", nút Google OAuth, link Register, highlight nút Google nếu `lastUsedPlatform === "google"`.
- [ ] Screen `Register`: form email+password+fullName, hiển thị rule password (>=8 ký tự + có số).
- [ ] Screen `VerifyOtp`: 6 ô nhập OTP, nút "Gửi lại mã" với cooldown.

## Forgot / Reset Password

- [ ] `useForgotPasswordMutation` — `POST /auth/forgot-password`, luôn hiển thị message thành công chung.
- [ ] `useResetPasswordMutation` — `POST /auth/reset-password` với `{ token, newPassword }`.
- [ ] Screen `ForgotPassword`: 1 input email.
- [ ] Screen `ResetPassword`: đọc `token` từ deep link query param, input `newPassword` + `confirmPassword` (client-side validate).
- [ ] Deep link handler: `brandhub://reset-password?token=...` → mở thẳng `ResetPassword` screen.

## Google OAuth

- [ ] `startUrl` = `{API_BASE_URL}/api/v1/auth/oauth/google?client=mobile` (param `client=mobile` bắt buộc).
- [ ] `returnUrl` = `makeRedirectUri({ scheme: "brandhub", path: "oauth-callback" })`.
- [ ] `WebBrowser.openAuthSessionAsync(startUrl, returnUrl)` → parse `result.url` lấy `token`/`error`.
- [ ] Sau khi có token: lưu SecureStore → gọi `GET /api/v1/users/me` lấy profile đầy đủ → set Zustand store.
- [ ] Xử lý `error=ACCOUNT_SUSPENDED` riêng (toast khác), còn lại → toast chung "Đăng nhập Google thất bại".
- [ ] Set `lastUsedPlatform = "google"` khi thành công.

## 2FA Verify

- [ ] `useVerifyTwoFactorMutation` — `POST /auth/2fa/verify` với `{ twoFactorToken, code }`.
- [ ] Screen `TwoFactorVerify`: nhận `twoFactorToken` qua navigation param, input 6 số, giữ token hiệu lực khi nhập sai (không tự quay về Login).

## Logout

- [ ] `useLogoutMutation` — `POST /auth/logout` với body `{ refreshToken }` (**bắt buộc gửi**, backend đã hỗ trợ đọc từ body).
- [ ] Luôn `clearAuth()` ở `onSettled` dù API lỗi.
- [ ] `lastUsedPlatform` KHÔNG bị xoá trong `clearAuth()` — chỉ xoá token/user.

## Error/Loading states chung

- [ ] Mọi submit button: disable + spinner khi đang gọi API.
- [ ] Lỗi network (timeout, no response): toast riêng "Không thể kết nối, vui lòng thử lại".
- [ ] `tsc --noEmit` pass, không lỗi type.

## Chưa làm / out of scope G1 (xem spec mục 7)

- [ ] Không làm: Setup 2FA (QR), Disable 2FA, Change Password, Deactivate Account, Link/Unlink Phone/OAuth, Profile đầy đủ (View/Update).
