# UC — Quên / Đặt lại mật khẩu

| | |
|---|---|
| Feature | Quên / đặt lại mật khẩu |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng quên mật khẩu được đặt lại bằng cách: yêu cầu link reset gửi về email, rồi dùng token trong link để đặt mật khẩu mới. Token có thời hạn (TTL) và dùng một lần.

## 2. User Story

Là một người dùng quên mật khẩu,
tôi muốn yêu cầu đặt lại qua email và nhập mật khẩu mới bằng link an toàn,
để khôi phục quyền truy cập tài khoản của mình.

## 3. Acceptance Criteria

- `forgot-password` nhận email → tạo token reset, lưu có TTL, gửi email chứa link reset.
- Nếu email không tồn tại → vẫn trả thành công (không lộ email có tồn tại).
- `reset-password` nhận token + mật khẩu mới → xác thực token còn hiệu lực → đặt mật khẩu mới.
- Token hết hạn / không hợp lệ / đã dùng → lỗi 400.
- Mật khẩu mới hash BCrypt, cập nhật `last_password_change`.
- Token dùng 1 lần: sau reset thành công → vô hiệu hóa.

## 4. UI / UX

### Forgot password
- Form nhập email, nút "Gửi link đặt lại".
- Trạng thái thành công: thông báo "Nếu email tồn tại, chúng tôi đã gửi link đặt lại".
- Link "Quay lại đăng nhập".

### Reset password
- Trang đặt mật khẩu mới (token trong URL).
- Field mật khẩu mới + xác nhận, nút "Đặt lại mật khẩu".
- Trạng thái thành công: redirect login.
- Trạng thái lỗi (token hết hạn/sai): thông báo + link yêu cầu lại.

### UI States
- Loading, Success, Error cho cả 2 form.

## 5. API Contract

### Gửi yêu cầu
```
POST /api/v1/auth/forgot-password
{ "email": "string" }
```
Response 200: `{ "success": true }` (luôn trả success dù email tồn tại hay không).

### Đặt lại
```
POST /api/v1/auth/reset-password
{ "token": "string", "newPassword": "string" }
```
Response 200: `{ "success": true }`.
Response 400:
```json
{ "success": false, "error": { "code": "INVALID_OR_EXPIRED_TOKEN", "message": "Link đặt lại không hợp lệ hoặc đã hết hạn" } }
```

## 6. Error Handling

- Token sai/hết hạn → 400 `INVALID_OR_EXPIRED_TOKEN`.
- Password mới yếu → 400 `VALIDATION_ERROR`.
- Email không tồn tại → vẫn trả 200 (chống liệt kê email).

## 7. Edge Cases

- Gửi lại nhiều lần → tạo token mới, token cũ vô hiệu.
- Token dùng 2 lần → lần 2 bị lỗi (đã vô hiệu sau lần 1).
- Link mở sau khi TTL hết → lỗi, yêu cầu lại.
- Reset mật khẩu thành công → cập nhật `last_password_change`.

## 8. UI States

- Forgot: idle → submitting → success/error.
- Reset: idle → submitting → success (redirect) / error (token).

## 9. Test Cases

- forgot-password email tồn tại → 200, email chứa link token.
- forgot-password email không tồn tại → 200 (không lộ email).
- reset-password token hợp lệ + password mới → 200, login bằng password mới được.
- reset-password token hết hạn → 400.
- reset-password token đã dùng → 400.
- Reset xong → `last_password_change` cập nhật.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- Token lưu Redis TTL, dùng 1 lần.
- Email SMTP gửi link thành công (đã test live).
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Gửi OTP thay cho link (verify-otp).
- Đổi mật khẩu khi đang đăng nhập (change-password).
