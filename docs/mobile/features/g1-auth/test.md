# Test — G1 Authentication (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Login email/password đúng | Flow 4.1 | Lưu token SecureStore, vào Dashboard | Chưa test |
| TC-02 | Login sai password | `INVALID_CREDENTIALS` | Toast "Email hoặc mật khẩu không đúng" | Chưa test |
| TC-03 | Login account bị khóa tạm | `ACCOUNT_LOCKED` | Toast "Tài khoản tạm khóa do đăng nhập sai nhiều lần" | Chưa test |
| TC-04 | Login account suspended | `ACCOUNT_SUSPENDED` | Toast "Tài khoản đã bị khóa" | Chưa test |
| TC-05 | Login user đã bật 2FA | `requireTwoFactor === true` | Điều hướng `TwoFactorVerify`, không lưu access/refresh token | Chưa test |
| TC-06 | Register email/password/fullName hợp lệ | Flow 4.2 | 201, điều hướng `VerifyOtp(purpose=register)`, không tự login | Chưa test |
| TC-07 | Register email đã tồn tại (case khác) | `User@gmail.com` vs `user@gmail.com` | 409, không tạo account trùng | Chưa test |
| TC-08 | Verify OTP đúng (purpose=register) | Flow 4.3 | Điều hướng Login, toast "Xác thực thành công" | Chưa test |
| TC-09 | Verify OTP sai | `OTP_INVALID` | Toast "Mã không đúng hoặc đã hết hạn", không điều hướng | Chưa test |
| TC-10 | Resend OTP trong 60s | Cooldown | Nút disable, countdown hiển thị đúng | Chưa test |
| TC-11 | Forgot Password email tồn tại | Flow 4.4 | Toast thành công chung, email nhận link `reset-password?token=...` | Chưa test |
| TC-12 | Forgot Password email không tồn tại | Bảo mật — không lộ info | Toast thành công **giống hệt** TC-11 (không phân biệt) | Chưa test |
| TC-13 | Mở deep link reset password hợp lệ | Flow 4.5 bước 1 | Mở `ResetPassword` screen, `token` không cho sửa | Chưa test |
| TC-14 | Reset Password token hết hạn/invalid | `RESET_TOKEN_INVALID`/`RESET_TOKEN_USED` | Toast "Link đã hết hạn", nút quay về `ForgotPassword` | Chưa test |
| TC-15 | Reset Password thành công | Flow 4.5 bước 6 | Điều hướng Login kèm toast | Chưa test |
| TC-16 | Google OAuth login thành công (user mới) | Flow 4.6, backend `client=mobile` | Deep link `brandhub://oauth-callback#token=...` mở app, lưu token, gọi `/users/me`, vào Dashboard | Chưa test |
| TC-17 | Google OAuth account suspended | `error=ACCOUNT_SUSPENDED` | Toast riêng "Tài khoản đã bị khóa" | Chưa test |
| TC-18 | Google OAuth user đã bật 2FA | redirect `twoFactorToken` qua deep link | Điều hướng `TwoFactorVerify` | Chưa test |
| TC-19 | Google OAuth lỗi backend/network | `error=oauth_failed` hoặc không có token | Toast chung "Đăng nhập Google thất bại" | Chưa test |
| TC-20 | 2FA Verify đúng mã | Flow 4.7 | Nhận `LoginResponse` đầy đủ, lưu token, vào app | Chưa test |
| TC-21 | 2FA Verify sai mã | `OTP_INVALID` | Cho nhập lại, `twoFactorToken` còn hiệu lực, không quay về Login | Chưa test |
| TC-22 | Logout | Mục 8 câu 3b đã sửa backend | Gọi API kèm body `{refreshToken}`, token bị revoke trên server, local state clear | Chưa test |
| TC-23 | Logout khi API lỗi (network) | `onSettled` luôn clear | Local token vẫn bị xoá dù API fail, không stuck ở trạng thái logged-in | Chưa test |
| TC-24 | Last used platform persist qua logout | FR 3.2.8 | `lastUsedPlatform` còn nguyên sau `clearAuth()`, nút Google highlight đúng lần sau | Chưa test |
| TC-25 | Network timeout mọi màn hình | Error state chung | Toast "Không thể kết nối, vui lòng thử lại", không crash | Chưa test |
| TC-26 | Double-submit khi đang loading | Error state chung | Nút disable, không gọi API 2 lần | Chưa test |
