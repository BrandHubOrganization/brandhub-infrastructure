# UC — Đăng ký tài khoản

| | |
|---|---|
| Feature | Đăng ký |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng mới tạo tài khoản bằng **email + mật khẩu + họ tên**. Email là định danh duy nhất — không cho trùng.

## 2. User Story

Là một người dùng chưa có tài khoản,
tôi muốn đăng ký bằng email, mật khẩu và họ tên,
để tạo tài khoản và bắt đầu sử dụng hệ thống.

## 3. Acceptance Criteria

- Đăng ký với email chưa tồn tại + password + fullName → tạo user, trả `userId`.
- Email trùng với tài khoản đã có → lỗi 409, không tạo mới.
- Mật khẩu hash bằng BCrypt trước khi lưu.
- User mới gán hệ thống role mặc định `USER`.
- Các field bắt buộc: `email`, `password`, `fullName`.

## 4. UI / UX

- Form Register: field email, password, xác nhận password, fullName, nút "Đăng ký".
- Validate: email hợp lệ, password tối thiểu độ dài, 2 password khớp.
- Link "Đã có tài khoản? Đăng nhập" → sang login.
- Sau đăng ký, OTP 6 số tự động gửi về email → chuyển sang verify OTP (xác thực email).

### UI States
- Loading: disable nút.
- Success: thông báo + redirect verify/login.
- Error: báo email đã tồn tại / validation sai.

## 5. API Contract

```
POST /api/v1/auth/register
Content-Type: application/json
{
  "email": "string",
  "password": "string",
  "fullName": "string"
}
```
Response 201 (Created):
```json
{ "success": true, "data": { "userId": "string" } }
```
Response 409:
```json
{ "success": false, "error": { "code": "EMAIL_ALREADY_EXISTS", "message": "Email đã được sử dụng" } }
```

## 6. Error Handling

- Email đã tồn tại → 409 `EMAIL_ALREADY_EXISTS`.
- Field thiếu / không hợp lệ → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Email có khoảng trắng/khác hoa thường → chuẩn hóa lowercase + trim trước khi kiểm tra trùng.
- Password yếu → áp policy độ dài (vd. ≥ 8 ký tự).
- Double-submit form → chống trùng request.

## 8. UI States

- Loading, Success, Error như mục 4.
- Empty: field trống → validation.

## 9. Test Cases

- Đăng ký email mới → 200, trả userId, user tồn tại trong DB.
- Đăng ký email trùng → 409.
- Bỏ fullName → 400.
- Password quá ngắn → 400.
- Email có khoảng trắng → vẫn tạo user, email chuẩn hóa.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- Password hash BCrypt, role mặc định USER.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Xác thực email bằng OTP (thuộc verify-otp).
- Đăng ký bằng SĐT (multi-method-login).
- Đăng ký bằng OAuth (oauth-social-login).
