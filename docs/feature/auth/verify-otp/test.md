# Test — Verify / resend OTP

| # | Test case | Input | Mong đợi | Pass |
|---|---|---|---|---|
| 1 | OTP đúng | otpCode khớp | 200, emailVerifiedAt set | ☐ |
| 2 | OTP sai | sai số | 400 INVALID_OTP | ☐ |
| 3 | OTP hết hạn | sau expiry | 400 | ☐ |
| 4 | OTP dùng 2 lần | dùng lại | lần 2 lỗi | ☐ |
| 5 | resend | email tồn tại | OTP mới gửi, verify được | ☐ |
| 6 | resend email lạ | email không tồn tại | 200 (không lộ email) | ☐ |
