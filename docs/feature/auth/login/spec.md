# UC — Đăng nhập (email/SĐT + mật khẩu)

| | |
|---|---|
| Feature | Đăng nhập |
| Version | 1.1 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng đã đăng ký truy cập vào hệ thống bằng **email hoặc SĐT + mật khẩu** (trường `identifier` duy nhất), nhận JWT access token + refresh token qua HttpOnly cookie.

## 2. User Story

Là một người dùng đã có tài khoản,
tôi muốn đăng nhập bằng email hoặc số điện thoại và mật khẩu của mình,
để truy cập vào hệ thống và các dữ liệu của tôi.

## 3. Acceptance Criteria

- Đăng nhập với identifier (email hoặc SĐT) + mật khẩu đúng → trả `accessToken`, `tokenType=Bearer`, `expiresIn`.
- Identifier chứa `@` → tra cứu theo email; không chứa `@` → chuẩn hóa E.164 rồi tra cứu theo SĐT.
- Email/SĐT không tồn tại hoặc mật khẩu sai → lỗi 401 `INVALID_CREDENTIALS`, message chung không tiết lộ định danh có tồn tại.
- Tài khoản bị khóa/inactive (status != ACTIVE hoặc isActive=false) → chặn đăng nhập, 403 `ACCOUNT_SUSPENDED`.
- Tài khoản OAuth-only (passwordHash = null) → từ chối, 401 `INVALID_CREDENTIALS` (không tiết lộ lý do).
- Đăng nhập thành công → cập nhật `last_login_at` + ghi audit LOGIN.
- Trả kèm refresh token qua cookie HttpOnly, Secure, SameSite=Strict.

## 4. UI / UX

- Form Login: field identifier (placeholder "Email hoặc số điện thoại"), field password, nút "Đăng nhập".
- Link "Quên mật khẩu?" → sang flow forgot-password.
- Link "Chưa có tài khoản? Đăng ký" → sang register.
- Hiển thị lỗi chung khi sai identifier/mật khẩu (không tách riêng để tránh rò email/SĐT).
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
  "identifier": "brandhub404@gmail.com | +84912158715",
  "password": "string"
}
```
Response 200 (kèm Set-Cookie: refreshToken):
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
{ "success": false, "error": { "code": "INVALID_CREDENTIALS", "message": "Invalid email or password" } }
```
Response 403:
```json
{ "success": false, "error": { "code": "ACCOUNT_SUSPENDED", "message": "This account has been suspended" } }
```

## 6. Error Handling

- Identifier sai / password sai / OAuth-only → 401 `INVALID_CREDENTIALS`, message chung.
- Tài khoản inactive/suspended → 403 `ACCOUNT_SUSPENDED`.
- Thiếu field → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Identifier có khoảng trắng đầu/cuối → trim trước khi so khớp.
- Email khác hoa/thường → chuẩn hóa lowercase khi lưu + so khớp.
- SĐT nhập linh hoạt (`0912158715`, `+84 912 158 715`) → chuẩn hóa E.164 trước khi so khớp (PhoneUtil).
- Tài khoản tạo từ OAuth chưa có password → từ chối đăng nhập bằng password, phải set-password trước.
- Nhiều lần login sai liên tiếp → có thể áp giới hạn/backoff (ngoài scope v1).
- Token hết hạn giữa phiên → dùng refresh token từ cookie (POST /api/v1/auth/refresh).

## 8. UI States

- Loading, Success, Error như mục 4.
- Empty: field trống → validation báo.

## 9. Test Cases

- Login đúng email + password → 200, có accessToken + Set-Cookie refreshToken.
- Login đúng SĐT + password → 200, cùng account với email.
- Login sai password → 401 INVALID_CREDENTIALS.
- Login identifier không tồn tại → 401 (cùng message như sai password).
- Login identifier có khoảng trắng → vẫn đăng nhập được (trim).
- Login tài khoản inactive/suspended → 403 ACCOUNT_SUSPENDED.
- Login OAuth-only account (không có password) → 401 INVALID_CREDENTIALS.
- Login thành công → `last_login_at` được cập nhật, audit LOGIN ghi nhận.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- JWT RS256 issue đúng, refresh token cookie HttpOnly Secure SameSite=Strict hoạt động.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Đăng nhập bằng OAuth (thuộc oauth-social-login).
- Giới hạn số lần thử sai / captcha.
- MFA.
