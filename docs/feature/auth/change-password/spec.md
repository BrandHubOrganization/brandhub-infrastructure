# UC — Đổi mật khẩu (khi đang đăng nhập)

| | |
|---|---|
| Feature | Đổi mật khẩu |
| Version | 1.0 |
| Ngày công (HĐ) | TBD |
| Nhóm | A. Chức năng người dùng |

## 1. Objective

Cho phép người dùng **đang đăng nhập** đổi mật khẩu, phải xác nhận mật khẩu hiện tại trước khi đặt mật khẩu mới.

## 2. User Story

Là một người dùng đã đăng nhập,
tôi muốn đổi mật khẩu của mình (cần nhập mật khẩu hiện tại để xác nhận),
để bảo mật tài khoản.

## 3. Acceptance Criteria

- `change-password` cần xác thực (JWT hợp lệ).
- Nhận `{currentPassword, newPassword}`.
- `currentPassword` sai → lỗi 400 `WRONG_CURRENT_PASSWORD`, không đổi.
- Đúng → hash `newPassword` bằng BCrypt, cập nhật `passwordHash` + `last_password_change`.
- Không dùng lại password hiện tại làm password mới (tùy policy).

## 4. UI / UX

- Form trong phần cài đặt tài khoản: field password hiện tại, password mới, xác nhận password mới.
- Nút "Đổi mật khẩu".
- Thành công → thông báo + đăng xuất / giữ phiên tùy thiết kế.

### UI States
- Loading, Success, Error.

## 5. API Contract

```
POST /api/v1/auth/change-password
Authorization: Bearer <token>
{ "currentPassword": "string", "newPassword": "string" }
```
Response 200: `{ "success": true }`.
Response 400:
```json
{ "success": false, "error": { "code": "WRONG_CURRENT_PASSWORD", "message": "Current password is incorrect" } }
```

## 6. Error Handling

- Không có JWT → 401.
- `currentPassword` sai → 400 `WRONG_CURRENT_PASSWORD`.
- Password mới yếu → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Đổi mật khẩu xong → phiên cũ (JWT) vẫn hoạt động hay phải login lại? Quyết định theo thiết kế (thường giữ phiên hiện tại).
- Password mới trùng password cũ → chặn nếu policy yêu cầu.

## 8. UI States

- Idle → submitting → success/error.

## 9. Test Cases

- Đổi mật khẩu đúng current → 200, password mới login được.
- currentPassword sai → 400.
- Không có token → 401.
- Password mới yếu → 400.
- Đổi xong → `last_password_change` cập nhật.

## 10. Definition of Done

- Toàn bộ Acceptance Criteria đạt.
- Password hash BCrypt.
- Test case mục 9 pass.
- Không lỗi console/network nghiêm trọng.

## Out of Scope

- Quên mật khẩu (forgot-reset-password).
- Đặt mật khẩu cho user OAuth-only (multi-method-login).
