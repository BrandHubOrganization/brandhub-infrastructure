# Test — OTP Verification

## Email OTP

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Verify OTP đúng | Verify đúng → `emailVerifiedAt` set | 200, `emailVerifiedAt != null` | Chưa test |
| TC-02 | OTP sai (chưa tới 5 lần) | Error OTP sai | 400 `OTP_INVALID` | Chưa test |
| TC-03 | OTP hết hạn | Error OTP hết hạn | 400 `OTP_INVALID` (gộp chung, không tách `OTP_EXPIRED`) | Chưa test |
| TC-04 | Resend OTP | Sinh OTP mới + gửi | 200, OTP mới trong `users.otp_code` | Chưa test |
| TC-05 | Sai 5 lần liên tiếp | Giới hạn thử | 400 `OTP_TOO_MANY_ATTEMPTS`, `otpCode`/`otpExpiry` bị xóa | Chưa test |
| TC-06 | Verify email chưa đăng ký | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-07 | Verify email đã verify (gọi lại) | Idempotent | 200, không check lại OTP | Chưa test |
| TC-08 | Resend trong vòng 60s | Rate-limit | 429 `RATE_LIMIT_EXCEEDED` | Chưa test |
| TC-09 | Resend email không tồn tại | — | 404 `USER_NOT_FOUND` | Chưa test |
| TC-10 | Resend khi đã verify | Idempotent | 200, không gửi lại | Chưa test |

## Phone OTP

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-11 | Link phone hợp lệ | Sinh OTP, gửi qua email | 200, Redis `phone:otp:{userId}` có giá trị | Chưa test |
| TC-12 | Link phone không hợp lệ | `PhoneUtil.normalize` trả null | 400 `INVALID_PHONE` | Chưa test |
| TC-13 | Link phone đã được user khác dùng | — | 409 `PHONE_ALREADY_IN_USE` | Chưa test |
| TC-13b | Gọi lại `/link/phone` trong vòng 60s | Rate-limit resend phone | 429 `RATE_LIMIT_EXCEEDED`, OTP cũ không bị ghi đè | Chưa test |
| TC-14 | Verify phone OTP đúng | Verify đúng → set `user.phone` | 200, `user.phone` được cập nhật | Chưa test |
| TC-15 | Verify phone OTP sai (chưa tới 5 lần) | — | 400 `OTP_INVALID` | Chưa test |
| TC-16 | Verify phone OTP khi chưa gọi link/phone hoặc đã hết hạn (10 phút) | Không có key Redis | 400 `OTP_INVALID` | Chưa test |
| TC-17 | Verify phone OTP đúng nhưng phone đã bị người khác lấy trong lúc chờ (race condition) | Edge case race | 409 `PHONE_ALREADY_IN_USE` | Chưa test |
| TC-18 | Verify phone OTP sai 5 lần liên tiếp | Giới hạn thử phone OTP | 400 `OTP_TOO_MANY_ATTEMPTS`; Redis `phone:otp:{userId}` + `phone:otp:attempt:{userId}` bị xóa | Chưa test |
| TC-19 | Sau khi bị `OTP_TOO_MANY_ATTEMPTS`, verify lại bằng mã cũ | Edge (OTP đã hủy) | 400 `OTP_INVALID` (không còn OTP session) | Chưa test |
| TC-20 | `/link/phone` sau khi cooldown 60s hết hạn | Rate-limit resend | 200, sinh OTP mới, counter attempt reset | Chưa test |
