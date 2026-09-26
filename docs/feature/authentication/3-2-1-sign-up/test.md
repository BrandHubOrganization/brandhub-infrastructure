# Test — Sign Up

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Đăng ký email mới hợp lệ | Form email+password+fullName | 201, `RegisterResponse{userId}` | Chưa test |
| TC-02 | Đăng ký email đã tồn tại (case khác) | "chuẩn hóa email" | 409 `EMAIL_ALREADY_EXISTS` (case-insensitive) | Chưa test |
| TC-03 | Đăng ký `USER@gmail.com` khi `user@gmail.com` tồn tại chưa verify | Edge "đăng ký lại case khác" | 409 `EMAIL_ALREADY_EXISTS` ngay, không tạo account mới, không tự resend OTP | Chưa test |
| TC-04 | Password yếu (<8 ký tự / thiếu số) | Validation | 400 `VALIDATION_ERROR` (validate `@Size`/`@Pattern`) | Chưa test |
| TC-05 | Email sai format | Error "VALIDATION_ERROR" | 400 `VALIDATION_ERROR` | Chưa test |
| TC-06 | Verify OTP đúng | AC "OTP đúng → verify" | `emailVerifiedAt` được set, KHÔNG tự login (user phải gọi `/login` riêng) | Chưa test |
| TC-07 | Password lưu dạng hash | AC "bcrypt" | DB `password_hash` không phải plaintext | Chưa test |
| TC-08 | Verify OTP email chưa đăng ký | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-09 | Verify OTP email đã verify (gọi lại) | Idempotent | 200 no-op, không lỗi | Chưa test |
| TC-10 | Resend OTP trong vòng 60s | Rate-limit | 429 `RATE_LIMIT_EXCEEDED` | Chưa test |
| TC-11 | Resend OTP email không tồn tại | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-12 | Resend OTP email đã verify | Idempotent | 200 no-op, không gửi lại | Chưa test |
