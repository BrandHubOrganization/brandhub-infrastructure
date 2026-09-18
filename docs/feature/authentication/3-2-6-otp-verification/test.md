# Test — OTP Verification

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Verify OTP đúng | AC "verify đúng → tiếp tục luồng" | 200, `emailVerified=true` | Chưa test |
| TC-02 | OTP sai | Error "INVALID_OTP" | 400 `OTP_INVALID` | Chưa test |
| TC-03 | OTP hết hạn | Error "OTP_EXPIRED" | 400 `OTP_INVALID` (code gộp expired vào invalid) | Chưa test |
| TC-04 | Resend OTP | AC "resend + đếm ngược" | 200, gửi OTP mới | Chưa test |
| TC-05 | Sai 5 lần → hủy session | Error "giới hạn thử" | 400 `OTP_TOO_MANY_ATTEMPTS`, `otpCode`/`otpExpiry` bị xóa | Chưa test |
| TC-06 | otpSessionId còn hiệu lực sau khi đóng tab | Edge "đóng tab mở lại" | Vẫn verify được nếu chưa hết hạn | Chưa test |
| TC-07 | Verify email chưa đăng ký | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-08 | Verify email đã verify (gọi lại) | Idempotent | 200 no-op | Chưa test |
| TC-09 | Resend trong vòng 60s | Rate-limit | 429 `RATE_LIMIT_EXCEEDED` | Chưa test |
| TC-10 | Resend email không tồn tại | — | 404 `USER_NOT_FOUND` | Chưa test |
