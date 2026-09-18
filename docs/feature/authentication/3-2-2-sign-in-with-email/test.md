# Test — Sign In With Email

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Login đúng email/pw (2FA tắt) | AC "trả JWT" | 200, access+refresh token | Chưa test |
| TC-02 | Login sai pw | Error "INVALID_CREDENTIALS" | 401, không tiết lộ email tồn tại | Chưa test |
| TC-03 | Login email case khác (`USER@gmail.com`) | Edge "chuẩn hóa email" | login thành công | Chưa test |
| TC-04 | Login account deactivated | Error "ACCOUNT_DEACTIVATED" | 403 `ACCOUNT_DEACTIVATED` | Chưa test |
| TC-05 | Login account 2FA bật | AC "chặn trước khi cấp token" | 200 `requireTwoFactor=true` + `twoFactorToken`, KHÔNG accessToken | Chưa test |
| TC-06 | Login 2FA bật, gọi /2fa/verify đúng | AC "hoàn tất login-2FA" | 200 access+refresh token | Chưa test |
| TC-07 | Không yêu cầu OTP ở login (2FA tắt) | AC "không OTP" | login thẳng, không bước OTP | Chưa test |
| TC-08 | Login account suspended | Error "ACCOUNT_SUSPENDED" | 403 `ACCOUNT_SUSPENDED` | Chưa test |
| TC-09 | Login OAuth-only account (không password) | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-10 | Login bằng phone identifier không tồn tại | — | 401 `INVALID_CREDENTIALS` | Chưa test |
| TC-11 | Refresh token sai/hết hạn | Error "REFRESH_TOKEN_INVALID" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-12 | Refresh token đã blacklist (sau logout) | Error "REFRESH_TOKEN_BLACKLISTED" | 401 `REFRESH_TOKEN_BLACKLISTED` | Chưa test |
| TC-13 | Refresh sau reset password (`iat < lastPasswordChange`) | Edge "revoke mọi thiết bị" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
| TC-14 | Refresh khi user deactivated | Edge "không login được" | 401 `REFRESH_TOKEN_INVALID` | Chưa test |
