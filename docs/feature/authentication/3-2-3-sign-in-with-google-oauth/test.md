# Test — Sign In with Google OAuth

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Consent → callback thành công | AC "redirect consent" | 302 redirect `{FRONTEND_URL}/oauth-callback#token=...` + Set-Cookie refreshToken | Chưa test |
| TC-02 | Email Google đã có User (password) | Edge "gắn thêm provider" | Login account cũ, gắn Google vào account đó, không tạo User trùng | Chưa test |
| TC-03 | Email Google chưa có User | AC "tạo User mới" | Tạo User `emailVerifiedAt=now`, không `passwordHash` | Chưa test |
| TC-04 | User cancel consent (callback không kèm code) | Error "user cancel" | 302 redirect `{FRONTEND_URL}/oauth-callback?error=oauth_failed` | Chưa test |
| TC-05 | Token exchange body form-urlencoded | AC "fix bug flow không chạy" | Google trả access_token, không lỗi content-type | Chưa test |
| TC-06 | State sai/đã dùng | Error (CSRF) | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_STATE_INVALID` | Chưa test |
| TC-07 | Google code exchange fail | Error "OAUTH_CODE_INVALID" | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_CODE_INVALID` | Chưa test |
| TC-08 | Callback user deactivated/suspended | Error "ACCOUNT_SUSPENDED" | 302 redirect `{FRONTEND_URL}/oauth-callback?error=ACCOUNT_SUSPENDED` (distinct redirect, dedicated toast `auth.login.oauthAccountSuspended`), ErrorCode nội bộ `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | State replay (dùng lại state đã consume) | Edge "CSRF replay" | 302 redirect `?error=oauth_failed`, ErrorCode nội bộ `OAUTH_STATE_INVALID` | Chưa test |
| TC-10 | User bật 2FA đăng nhập Google | AC "2FA bắt buộc qua OAuth" | 302 redirect `{FRONTEND_URL}/2fa-verify?twoFactorToken=...`, chưa cấp accessToken/refreshToken | Chưa test |
