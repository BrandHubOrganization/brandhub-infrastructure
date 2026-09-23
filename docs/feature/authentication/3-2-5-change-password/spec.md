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

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/auth/change-password
{ "currentPassword": "string", "newPassword": "string" }
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- `currentPassword` sai → 400 `WRONG_CURRENT_PASSWORD` (đã code, thay cho `INVALID_CURRENT_PASSWORD`).
- `newPassword` giống `currentPassword` → 400 `SAME_AS_CURRENT_PASSWORD`.

## 7. Edge Cases

- User đổi mật khẩu ngay sau khi vừa Reset Password (token-based) → vẫn hợp lệ, không giới hạn tần suất trong phạm vi FR này.

## 8. Definition of Done

- Đổi mật khẩu thành công, xác nhận đúng currentPassword trước khi cho đổi.

## Out of Scope

- Lịch sử mật khẩu cũ (chặn tái sử dụng password cũ) — không có trong CSV.

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
