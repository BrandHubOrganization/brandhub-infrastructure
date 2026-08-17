# UC — Đăng nhập đa phương thức, Email là định danh duy nhất

| | |
|---|---|
| Feature | Đăng nhập đa phương thức (email / SĐT / OAuth) quy về một account |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép một tài khoản người dùng có **nhiều phương thức đăng nhập** (email + mật khẩu, số điện thoại + mật khẩu, và các provider OAuth: Google, GitHub, LinkedIn, Microsoft) nhưng **mọi phương thức đều quy về đúng một tài khoản duy nhất**. Email là định danh độc nhất (identity anchor) của tài khoản — không hai tài khoản nào chung email. Người dùng đăng nhập bằng cách nào cũng nhận được đúng tài khoản, dữ liệu và vai trò (role) của mình.

## 2. User Story

Là một người dùng BrandHub,
tôi muốn đăng nhập bằng email, số điện thoại hoặc tài khoản mạng xã hội (Google, GitHub, LinkedIn, Microsoft),
để truy cập cùng một tài khoản và dữ liệu của tôi dù tôi dùng cách đăng nhập nào,
và liên kết/ngắt liên kết các phương thức này một cách linh hoạt.

## 3. Acceptance Criteria

- Email là định danh duy nhất của account: bắt buộc có, unique, không trùng giữa 2 account.
- Đăng nhập bằng email + mật khẩu hoạt động (đã có, giữ nguyên).
- Đăng nhập bằng SĐT + mật khẩu hoạt động; mật khẩu **chung** với mật khẩu email (cùng 1 `password_hash`).
- Một endpoint đăng nhập duy nhất nhận `identifier` (email **hoặc** SĐT) + `password`.
- SĐT lưu chuẩn E.164 (vd. `+84912158715`), unique, optional.
- Thêm/link SĐT vào account (qua profile) phải verify bằng OTP; sau khi link, đăng nhập SĐT + mật khẩu không cần OTP.
- Người dùng có thể link nhiều provider OAuth (Google, GitHub, LinkedIn, Microsoft) vào account.
- Mỗi provider chỉ link được **một lần** với một account (không link cùng provider 2 lần).
- Đăng nhập bằng OAuth: nếu email provider khớp account có sẵn → link + login account đó; nếu chưa có → tạo account mới (email làm anchor) rồi link.
- User tạo từ OAuth (chưa có mật khẩu) có flow **đặt mật khẩu** để sau này login bằng email + mật khẩu.
- Ngắt liên kết được một phương thức (SĐT hoặc OAuth provider); account luôn giữ ít nhất 1 phương thức login còn lại.
- Mọi phương thức đăng nhập trả về cùng JWT của đúng account đó.

## 4. UI / UX

### Trang Login
- Form email/password hiện tại giữ nguyên.
- Bổ sung trường nhập hỗ trợ **cả email lẫn SĐT** (placeholder: "Email hoặc số điện thoại").
- Lưới nút OAuth (Google, GitHub, LinkedIn, Microsoft) hiện tại giữ nguyên.

### Trang Register
- Form đăng ký email + password + fullName hiện tại giữ nguyên.
- **Không** hiện SĐT ở register (SĐT thêm sau ở profile).

### Trang Profile / Cài đặt tài khoản (mới)
- Mục **Phương thức đăng nhập** liệt kê các phương thức đã link:
  - Email + mật khẩu (luôn có, anchor).
  - SĐT: hiển thị SĐT đã link + nút "Thêm SĐT" / "Đổi SĐT" / "Ngắt liên kết".
  - Mỗi provider OAuth: hiển thị trạng thái đã link/chưa link + nút "Liên kết" / "Ngắt liên kết".
- Nút "Đặt mật khẩu" hiển thị khi account chưa có mật khẩu (tạo từ OAuth).
- Modal verify OTP khi thêm SĐT (input 6 số, gửi lại mã).

### UI States
- Loading: spinner khi gửi login / link / OTP.
- Success: redirect vào dashboard sau login; toast "Đã liên kết SĐT" / "Đã liên kết Google".
- Error: thông báo lỗi cụ thể (SĐT đã dùng, OTP sai, provider đã link).
- Phone đã thuộc account khác → lỗi conflict, không cho link.

## 5. API Contract

> Base: `{OAUTH_REDIRECT_BASE_URL}` = gateway port 8080. Prefix `/api/v1`.

### 5.1 Đăng nhập (email hoặc SĐT)
```
POST /auth/login
Content-Type: application/json
{
  "identifier": "brandhub404@gmail.com | +84912158715",
  "password": "string"
}
```
Response 200:
```json
{
  "success": true,
  "data": { "accessToken": "string", "tokenType": "Bearer", "expiresIn": 900000 }
}
```
- `identifier` chứa `@` → tra cứu theo email; không chứa `@` → chuẩn hóa E.164 rồi tra cứu theo SĐT.

### 5.2 Đăng ký
```
POST /auth/register
{ "email": "string", "password": "string", "fullName": "string" }
```
Response 200: `{ "success": true, "data": { "userId": "string" } }`

### 5.3 Link SĐT — gửi OTP
```
POST /auth/link/phone        (cần xác thực)
{ "phone": "+84912158715" }
```
Response 200: `{ "success": true }` (gửi OTP, TTL mặc định).
- Chuẩn hóa SĐT sang E.164 trước khi lưu/kiểm tra trùng.

### 5.4 Xác nhận OTP link SĐT
```
POST /auth/verify-phone-otp  (cần xác thực)
{ "otpCode": "123456" }
```
Response 200: `{ "success": true }` → gán SĐT vào account (ghi vào `users.phone`).

### 5.5 Link OAuth provider
```
GET  /auth/oauth/{google|github|linkedin|microsoft}      → redirect sang provider
GET  /auth/oauth/{provider}/callback                     → nhận code, issue JWT
```
- Cơ chế hiện có giữ nguyên (`OAuthService.handleCallback`).
- Nếu provider đã link cho account khác → lỗi conflict.

### 5.6 Đặt mật khẩu (user OAuth-only)
```
POST /auth/set-password       (cần xác thực)
{ "password": "string" }
```
Response 200: `{ "success": true }`. Chỉ cho phép khi account chưa có `password_hash`.

### 5.7 Liệt kê phương thức login
```
GET /auth/me                  (cần xác thực)
```
Response 200:
```json
{
  "success": true,
  "data": {
    "userId": "string",
    "email": "string",
    "phone": "+84912158715 | null",
    "hasPassword": true,
    "linkedProviders": ["GOOGLE", "GITHUB"]
  }
}
```

### 5.8 Ngắt liên kết
```
POST /auth/unlink/phone       (cần xác thực)  — xóa users.phone
POST /auth/unlink/oauth       (cần xác thực)
{ "provider": "GOOGLE" }
```
- Chặn: không cho ngắt khi account chỉ còn 1 phương thức login (trừ email anchor luôn tồn tại).

### 5.9 Có sẵn (giữ nguyên)
- `POST /auth/forgot-password`, `POST /auth/reset-password`
- `POST /auth/change-password`, `POST /auth/logout`, `POST /auth/refresh`
- `POST /auth/verify-otp`, `POST /auth/resend-otp`

## 6. Error Handling

- `identifier` không khớp email lẫn SĐT → lỗi 401 `INVALID_CREDENTIALS`.
- SĐT sai định dạng/không chuẩn hóa được → 400 `INVALID_PHONE`.
- SĐT đã thuộc account khác khi link → 409 `PHONE_ALREADY_IN_USE`.
- Provider OAuth đã link cho account khác → 409 `PROVIDER_ALREADY_LINKED`.
- OTP sai/hết hạn → 400 `INVALID_OTP`.
- Đặt mật khẩu khi đã có password → 400 `PASSWORD_ALREADY_SET`.
- Ngắt liên kết khiến account không còn phương thức login → 400 `LAST_LOGIN_METHOD`.
- Đăng nhập OAuth: provider trả email null → tạo account không được (email là anchor bắt buộc) → 400 `EMAIL_REQUIRED`.

## 7. Edge Cases

- Account tạo từ OAuth (email có, password null) đăng nhập bằng SĐT trước khi đặt mật khẩu → không được (chưa có password). Đăng nhập bằng OAuth hoặc đặt mật khẩu trước.
- Cùng một provider OAuth, đăng nhập lần 2 → tra cứu theo `provider_id`, không tạo account mới (đã có logic hiện tại).
- Đăng nhập email trùng account đã có nhưng chưa link provider → account đó được link thêm provider (đã có logic hiện tại).
- Email đổi sang một account khác qua forgot-password → không đổi email, chỉ đặt lại mật khẩu.
- SĐT nhập linh hoạt (`0912158715`, `+84 912 158 715`) → chuẩn hóa E.164 trước khi so khớp/lưu.
- Link SĐT bỏ dở (gửi OTP nhưng không xác nhận) → SĐT chưa ghi, có thể gửi lại.

## 8. UI States

- Loading: skeleton/disabled nút khi đang login, link, gửi OTP.
- Empty: account chưa link SĐT → mục SĐT hiện nút "Thêm SĐT".
- Success: toast xác nhận sau link/unlink/set-password.
- Error: hiển thị thông báo lỗi theo mã (conflict phone/provider, OTP sai...).
- OAuth-only: profile hiện banner "Bạn chưa đặt mật khẩu" + nút đặt mật khẩu.

## 9. Test Cases

- Đăng nhập email + password đúng → JWT.
- Đăng nhập SĐT + password đúng → JWT (cùng account với email).
- Đăng nhập `identifier` email nhưng password sai → 401.
- Đăng nhập `identifier` SĐT không tồn tại → 401.
- Link SĐT mới → OTP gửi → verify → `users.phone` ghi, login bằng SĐT hoạt động.
- Link SĐT đã thuộc account khác → 409.
- Link cùng provider OAuth 2 lần → lỗi conflict.
- Đăng nhập OAuth với email mới → tạo account + link.
- Đăng nhập OAuth với email đã tồn tại → link vào account cũ, không tạo mới.
- User OAuth-only đặt mật khẩu → login email+password sau đó hoạt động.
- Đặt mật khẩu khi đã có password → 400.
- Ngắt liên kết SĐT/provider → account vẫn login được bằng phương thức còn lại.
- Ngắt liên kết khiến hết phương thức login → bị chặn.
- `/auth/me` trả đúng danh sách phương thức đã link.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- DB: thêm cột `phone` (E.164, unique, nullable) vào `users` — migration an toàn cho DB đang chạy.
- Login 1 endpoint nhận email/SĐT hoạt động đúng.
- Các flow link SĐT (OTP), link OAuth, set-password, unlink hoạt động.
- Profile UI liệt kê/quản lý phương thức login.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Gửi OTP qua SMS thật (dùng OTP in-memory/DB hiện có, không tích hợp nhà cung cấp SMS).
- Đổi email chính của account.
- Đăng ký bằng SĐT (register chỉ email + password).
- Login bằng username / mật khẩu dạng khác ngoài email/SĐT.
- Quản lý nhiều SĐT trên 1 account (mỗi account tối đa 1 SĐT).
- Email/SĐT hợp nhất tài khoản trùng (account linking nâng cao).
