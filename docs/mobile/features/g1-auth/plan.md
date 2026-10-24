# Plan — G1 Authentication (Mobile)

> [spec.md](./spec.md) — chi tiết API/flows/state đầy đủ. File này là bản tóm tắt thứ tự implement + quyết định kỹ thuật chốt.

## Thứ tự implement (theo dependency)

1. **Infra chung trước** — không màn hình nào chạy được nếu thiếu:
   - Axios instance + interceptor auto-refresh 401 (gọi `POST /auth/refresh`, retry request gốc).
   - `expo-secure-store` wrapper: `getTokens()`, `setTokens()`, `clearTokens()`.
   - `useAuthStore` (Zustand) theo state ở spec mục 5.
   - Bảng message lỗi tiếng Việt tập trung (map `ErrorCode` → string hiển thị).
2. **Login + Register + OTP** (block lõi, các màn khác phụ thuộc):
   - `useLoginMutation`, `useRegisterMutation`, `useVerifyOtpMutation`, `useResendOtpMutation`.
   - Screen: `Login`, `Register`, `VerifyOtp` (dùng chung).
3. **Forgot/Reset Password**:
   - `useForgotPasswordMutation`, `useResetPasswordMutation`.
   - Screen: `ForgotPassword`, `ResetPassword` — chỉ nhánh deep link (xem spec mục 8 câu 4, đã xác nhận backend không gửi OTP cho flow này).
   - Deep link scheme đăng ký trong `app.json`/`app.config.ts` (chốt `brandhub`, dùng chung với OAuth callback).
4. **Google OAuth**:
   - Thêm query `?client=mobile` khi gọi `startUrl` (backend đã hỗ trợ, xem spec mục 8 câu 1).
   - `WebBrowser.openAuthSessionAsync` + `expo-auth-session` `makeRedirectUri`.
   - Parse `result.url` → `token`/`error` → gọi tiếp `GET /api/v1/users/me` lấy profile đầy đủ.
5. **2FA Verify**:
   - `useVerifyTwoFactorMutation`.
   - Screen `TwoFactorVerify`, nhận `twoFactorToken` qua navigation param (không SecureStore).
6. **Logout**:
   - `useLogoutMutation` — **phải gửi `refreshToken` trong body** (`{ refreshToken }`), backend đã sửa để nhận field này (spec mục 8 câu 3b). Luôn `clearAuth()` ở `onSettled` dù API lỗi.
   - Lưu "last used platform" (FR 3.2.8) vào AsyncStorage, giữ nguyên qua `clearAuth()`.

## Quyết định kỹ thuật đã chốt

- **Deep link scheme**: `brandhub://oauth-callback` — đã xác nhận với backend (`app.mobile-redirect-uri` config), dùng chung cho cả OAuth callback.
- **Forgot/Reset Password**: chỉ 1 nhánh (deep link token), không code nhánh OTP — bỏ hẳn khỏi UI để tránh màn hình thừa.
- **Resend OTP cooldown**: 60 giây cố định, client tự đếm ngược, không đọc field nào từ response.
- **Profile đầy đủ**: gọi `GET /api/v1/users/me` (không phải `/api/v1/auth/me`) sau khi có token — domain Profile ngoài scope G1 nhưng G1 vẫn phải gọi 1 lần ngay sau login/OAuth để có `fullName`/`avatarUrl`/`role` cho Zustand store.

## Việc backend đã làm xong (không cần hỏi lại)

- `POST /auth/logout` nhận `refreshToken` qua body (fallback khi không có cookie).
- `GET /auth/oauth/google?client=mobile` → callback redirect về `app.mobile-redirect-uri` nếu set, không thì fallback web — mobile cần đảm bảo giá trị env `APP_MOBILE_REDIRECT_URI` đã set đúng ở môi trường test trước khi integration test OAuth thật.

## Rủi ro còn mở (xem chi tiết spec mục 8)

- Google OAuth nhánh lỗi (`businessFailure`, `loginFailure`) chưa phân biệt được mobile/web vì `state` đã bị xoá trước khi exception ném ra — mọi lỗi OAuth đều redirect về web URL, không về app. Mobile cần coi "không thấy redirect quay lại app trong X giây" là 1 dạng lỗi, không chỉ trông chờ `error=...` query param.
- Universal Links/App Links (https://) cho reset-password chưa quyết định — một số email client Android/iOS có thể chặn custom scheme `brandhub://`, cần test tay trên thiết bị thật trước khi release.
