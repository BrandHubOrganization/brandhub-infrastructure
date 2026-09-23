# Test — Two-Factor Authentication (2FA, TOTP)

| ID | Mô tả | AC | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Setup khi chưa bật 2FA | AC "hiển thị QR" | 200, `otpAuthUrl` dạng `otpauth://totp/...`, KHÔNG có `secretKey`/`qrCodeUrl` | Happy | Chưa test |
| TC-02 | Setup khi đã bật | AC "confirm → bật" | 400 `TWO_FA_ALREADY_ENABLED` | Error | Chưa test |
| TC-03 | Confirm code đúng (sinh từ secret pending) | AC "nhập OTP confirm" | 200, `twoFactorEnabled=true` trong DB | Happy | Chưa test |
| TC-04 | Confirm code sai | Error "mã confirm sai" | 400 `TWO_FA_CODE_INVALID`, 2FA vẫn tắt | Error | Chưa test |
| TC-05 | Confirm khi chưa gọi setup (không có pending) | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
| TC-06 | Disable code đúng | AC "disable" | 200, `twoFactorEnabled=false`, `totpSecret=null` | Happy | Chưa test |
| TC-07 | Disable khi chưa bật | — | 400 `TWO_FA_NOT_ENABLED` | Error | Chưa test |
| TC-08 | Verify (login-2FA) code đúng + token hợp lệ | AC "sau email/pw yêu cầu OTP" | 200, access+refresh token | Happy | Chưa test |
| TC-09 | Verify token sai type (dùng access token thường) | — | 401 `TWO_FA_TOKEN_INVALID` | Error | Chưa test |
| TC-10 | Verify token hết hạn (>5 phút) | — | 401 `TWO_FA_TOKEN_INVALID` | Edge | Chưa test |
| TC-11 | Verify code sai | Error "mã confirm sai" | 400 `TWO_FA_CODE_INVALID`, không cấp token | Error | Chưa test |
| TC-12 | Không có bất kỳ UI/field copy secret hay backup codes | AC "KHÔNG copy secret/backup" | Response không chứa secret; không endpoint trả secret | Edge | Chưa test |
| TC-13 | Code lệch ±1 time-step (clock drift) | Edge "đổi giờ" | verify vẫn pass (WINDOW=1) | Edge | Chưa test |
| TC-14 | Disable code sai (đã bật) | Error "mã sai" | 400 `TWO_FA_CODE_INVALID` | Error | Chưa test |
| TC-15 | Verify khi user tắt 2FA giữa chừng | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
| TC-16 | Verify user suspended/deactivated | — | 403 `ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` | Error | Chưa test |
| TC-17 | Confirm khi pending secret hết hạn (>10 phút) | — | 400 `TWO_FA_NOT_ENABLED` | Edge | Chưa test |
