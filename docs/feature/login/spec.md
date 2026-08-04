# UC — Đăng nhập (email + mật khẩu)

| | |
|---|---|
| Feature | Đăng nhập |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng đã đăng ký truy cập vào hệ thống bằng **email + mật khẩu**, nhận JWT access token để gọi các API có xác thực.

## 2. User Story

Là một người dùng đã có tài khoản,
tôi muốn đăng nhập bằng email và mật khẩu của mình,
để truy cập vào hệ thống và các dữ liệu của tôi.

## 3. Acceptance Criteria

- Đăng nhập với email + mật khẩu đúng → trả `accessToken`, `tokenType=Bearer`, `expiresIn`.
- Email không tồn tại hoặc mật khẩu sai → lỗi 401, không tiết lộ email có tồn tại hay không.
- Tài khoản bị khóa/inactive → chặn đăng nhập.
- Đăng nhập thành công → cập nhật `last_login_at`.
- Trả kèm refresh token (qua cookie httpOnly hoặc body theo thiết kế hiện tại) để refresh sau này.

## 4. UI / UX

- Form Login: field email, field password, nút "Đăng nhập".
- Link "Quên mật khẩu?" → sang flow forgot-password.
- Link "Chưa có tài khoản? Đăng ký" → sang register.
- Hiển thị lỗi chung khi sai email/mật khẩu (không tách riêng để tránh rò email).
- Sau đăng nhập thành công → redirect vào dashboard.
- Lưới nút OAuth (Google/GitHub/LinkedIn/Microsoft) hiển thị dưới form.

### UI States
- Loading: disable nút, spinner.
- Success: redirect dashboard.
- Error: toast/inline thông báo lỗi đăng nhập.

## 5. API Contract

```
POST /api/v1/auth/login
Content-Type: application/json
{
  "email": "string",
  "password": "string"
}
```
Response 200:
```json
{
  "success": true,
  "data": {
    "accessToken": "string",
    "tokenType": "Bearer",
    "expiresIn": 900000
  }
}
```
Response 401:
```json
{ "success": false, "error": { "code": "INVALID_CREDENTIALS", "message": "Sai email hoặc mật khẩu" } }
```

## 6. Error Handling

- Email/mật khẩu sai → 401 `INVALID_CREDENTIALS`, message chung.
- Tài khoản inactive/bị khóa → 403 `ACCOUNT_DISABLED`.
- Thiếu field → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Email có khoảng trắng đầu/cuối → trim trước khi so khớp.
- Email khác hoa/thường → chuẩn hóa lowercase khi lưu + so khớp.
- Nhiều lần login sai liên tiếp → có thể áp giới hạn/backoff (ngoài scope v1).
- Token hết hạn giữa phiên → dùng refresh token (flow refresh riêng).

## 8. UI States

- Loading, Success, Error như mục 4.
- Empty: field trống → validation báo.

## 9. Test Cases

- Login đúng email + password → 200, có accessToken.
- Login sai password → 401.
- Login email không tồn tại → 401 (cùng message như sai password).
- Login email có khoảng trắng → vẫn đăng nhập được (trim).
- Login tài khoản inactive → 403.
- Login thành công → `last_login_at` được cập nhật.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- JWT RS256 issue đúng, refresh token hoạt động.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Đăng nhập bằng SĐT (thuộc multi-method-login).
- Đăng nhập bằng OAuth (thuộc oauth-social-login).
- Giới hạn số lần thử sai / captcha.
- MFA.
