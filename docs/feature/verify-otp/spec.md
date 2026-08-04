# UC — Xác thực email bằng OTP

| | |
|---|---|
| Feature | Verify / resend OTP |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng xác thực email sau đăng ký bằng mã OTP 6 số gửi về email, nhằm xác nhận email thuộc quyền sở hữu. Hỗ trợ gửi lại mã khi hết hạn / không nhận được.

## 2. User Story

Là một người dùng vừa đăng ký,
tôi muốn nhập mã OTP được gửi về email của tôi,
để xác thực email và kích hoạt đầy đủ tài khoản.

## 3. Acceptance Criteria

- Sau đăng ký, OTP 6 số gửi về email, lưu kèm thời hạn (expiry).
- `verify-otp` nhận `{email, otpCode}` → đúng mã + còn hiệu lực → đánh dấu email đã xác thực (`email_verified_at`).
- OTP sai / hết hạn → lỗi 400.
- `resend-otp` nhận `{email}` → tạo OTP mới, gửi lại email.
- OTP dùng 1 lần: sau verify thành công → vô hiệu hóa.

## 4. UI / UX

### Verify OTP
- Form nhập 6 số OTP + field email (hiển thị email đang xác thực).
- Nút "Xác nhận".
- Link/nút "Gửi lại mã" + đếm ngược thời gian chờ gửi lại.

### UI States
- Loading, Success, Error.
- Countdown trước khi cho gửi lại mã.

## 5. API Contract

### Xác nhận OTP
```
POST /api/v1/auth/verify-otp
{ "email": "string", "otpCode": "123456" }
```
Response 200: `{ "success": true }`.
Response 400:
```json
{ "success": false, "error": { "code": "INVALID_OTP", "message": "Mã xác nhận không đúng hoặc đã hết hạn" } }
```

### Gửi lại mã
```
POST /api/v1/auth/resend-otp
{ "email": "string" }
```
Response 200: `{ "success": true }`.

## 6. Error Handling

- OTP sai / hết hạn → 400 `INVALID_OTP`.
- Email không tồn tại → vẫn trả success (chống rò email).
- Gửi lại quá nhanh → có thể chặn (cooldown).

## 7. Edge Cases

- OTP hết hạn giữa chừng → báo, cho gửi lại.
- Nhập sai nhiều lần → vẫn cho thử, hoặc giới hạn theo thiết kế.
- Email không tồn tại khi verify → lỗi `INVALID_OTP` chung.
- OTP dùng 2 lần → lần 2 lỗi.

## 8. UI States

- Idle → submitting → success/error.
- Countdown gửi lại mã.

## 9. Test Cases

- verify OTP đúng → 200, `email_verified_at` set.
- verify OTP sai → 400.
- verify OTP hết hạn → 400.
- verify OTP dùng 2 lần → lần 2 lỗi.
- resend-otp → OTP mới gửi, verify bằng OTP mới được.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- OTP lưu trên User có expiry, dùng 1 lần.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- OTP qua SMS (multi-method-login).
- Link reset qua email (forgot-reset-password).
