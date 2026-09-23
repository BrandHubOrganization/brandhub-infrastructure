# UC — Change Password

| | |
|---|---|
| FR Code | 3.2.5 |
| Feature | Change Password |
| Domain | Authentication (FR 3.2) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Confirmed — đã code |

## 1. Objective

Cho phép user đã đăng nhập tự đổi mật khẩu, có bước xác nhận lại trước khi áp dụng.

## 2. User Story

Là một User đã đăng nhập,
tôi muốn đổi mật khẩu hiện tại,
để tăng bảo mật tài khoản của mình.

## 3. Acceptance Criteria

- Form nhập `currentPassword`, `newPassword`, `confirmNewPassword`.
- **Bắt buộc có bước confirm lại** trước khi submit thật (ví dụ: modal xác nhận, hoặc field confirm khác với password mới).
- Đổi thành công → toast confirm, không tự động logout (khác Reset Password — vì user đã chứng minh danh tính qua currentPassword).

## 4. UI / UX

- Trang `/settings/change-password`, theo pattern `PageWrapper` đã dùng ở code cũ.

## 5. API Contract (đã code)

```
POST /api/v1/auth/change-password
Header: Authorization: Bearer {accessToken}
{ "currentPassword": "string", "newPassword": "string" }
→ 200 { "success": true, "data": null }
```

- Thiếu/sai header `Authorization: Bearer <accessToken>` → 401 `INVALID_CREDENTIALS` (check tại controller, không vào service).

## 6. Business Rules

- **BR-1**: `currentPassword` phải khớp `passwordHash` hiện tại (bcrypt) — sai → 400 `WRONG_CURRENT_PASSWORD`. Check này chạy **trước**.
- **BR-2**: `newPassword` không được trùng `currentPassword` (so bằng `passwordEncoder.matches`) → 400 `SAME_AS_CURRENT_PASSWORD`. Check này chạy **sau** BR-1, chỉ khi currentPassword đã đúng.
- Thứ tự check: (1) verify currentPassword đúng → sai thì dừng ở `WRONG_CURRENT_PASSWORD`; (2) nếu đúng, so newPassword với currentPassword → trùng thì dừng ở `SAME_AS_CURRENT_PASSWORD`; (3) mới cho phép đổi.

## 7. Error Handling

- Thiếu/sai `Authorization: Bearer` → 401 `INVALID_CREDENTIALS`.
- User không tồn tại (token hợp lệ nhưng data lỗi) → 404 `USER_NOT_FOUND`.
- `currentPassword` sai → 400 `WRONG_CURRENT_PASSWORD` (đã code, thay cho `INVALID_CURRENT_PASSWORD`).
- `newPassword` giống `currentPassword` → 400 `SAME_AS_CURRENT_PASSWORD` (đã code).
- `newPassword` không đạt validation (@Valid) → 400 `VALIDATION_ERROR`.

## 8. Edge Cases

- User đổi mật khẩu ngay sau khi vừa Reset Password (token-based) → vẫn hợp lệ, không giới hạn tần suất trong phạm vi FR này.
- **Side-effect quan trọng**: đổi mật khẩu thành công cập nhật `lastPasswordChange = now`. Mọi refresh token cũ (issued trước thời điểm này) sẽ bị coi là invalid ở lần refresh tiếp theo (`AuthServiceImpl.refresh()` so `claims.issuedAt < user.lastPasswordChange` → `REFRESH_TOKEN_INVALID`). Access token hiện tại (chưa hết hạn) vẫn dùng được bình thường — không tự động logout session hiện tại, nhưng các refresh token cũ (ví dụ từ thiết bị khác đang đăng nhập) sẽ mất hiệu lực khi thử refresh.

## 9. Definition of Done

- Đổi mật khẩu thành công, xác nhận đúng currentPassword trước khi cho đổi.

## Out of Scope

- Lịch sử mật khẩu cũ (chặn tái sử dụng password cũ) — không có trong CSV.

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
