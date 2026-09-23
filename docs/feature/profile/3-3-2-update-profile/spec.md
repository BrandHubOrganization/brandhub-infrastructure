# UC — Update Profile

| | |
|---|---|
| FR Code | 3.3.2 |
| Feature | Update Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.1 (sync với code thật, 2026-09-23) |
| Trạng thái tài liệu | Đã code — spec khớp `UserController`/`UserServiceImpl` |

## 1. Objective

Cho phép User cập nhật thông tin cá nhân. Gộp thành 1 FR duy nhất 'Update Profile' (theo ghi chú gốc CSV, không tách View riêng khỏi hành động Update ở tầng đặt tên FR).

## 2. User Story

Là một User,
tôi muốn cập nhật thông tin profile của mình,
để giữ thông tin cá nhân luôn chính xác.

## 3. Acceptance Criteria

- Form cho sửa: `fullName` (bắt buộc), `phone`, `timezone`, `notificationPreferences` (tất cả trừ `fullName` là optional — chỉ field được gửi mới bị ghi đè, field không gửi giữ nguyên giá trị cũ).
- **Không cho sửa `email`** ở FR này — `UpdateProfileRequest` không có field `email` nên về mặt cấu trúc không thể gửi qua endpoint này (không phải BE âm thầm ignore).
- `avatarUrl` **không nằm trong body update này** — đổi avatar qua endpoint multipart riêng `POST /api/v1/users/me/avatar`.
- Lưu thành công → toast confirm, cập nhật lại UI ngay không cần reload.
- Avatar upload lưu thật lên S3 qua `POST /api/v1/users/me/avatar` (multipart `file`) — endpoint + `FileStorageService` (S3).

## 4. UI / UX

- Trang `/settings/profile`, form edit inline hoặc modal.
- Avatar: `AvatarUploadModal` gọi riêng `POST /api/v1/users/me/avatar`, không gộp chung với form fullName/phone/timezone.

## 5. API Contract

```
PUT /api/v1/users/me
Authorization: Bearer <access-token>
{ "fullName": "string", "phone"?: "string", "timezone"?: "string", "notificationPreferences"?: {} }
→ 200 { "success": true, "data": {
    "userId", "email", "fullName", "avatarUrl", "phone",
    "role", "workspaceId", "timezone", "notificationPreferences", "createdAt"
  } }  // cùng shape với GET /api/v1/users/me

POST /api/v1/users/me/avatar
Content-Type: multipart/form-data; field "file"
→ 200 { "success": true, "data": { "avatarUrl": "string" } }
```

## 6. Error Handling

- `fullName` trống → 400 `VALIDATION_ERROR`.
- Upload avatar: không có file → 400 `NO_FILE_PROVIDED`; sai content-type (không phải `image/*`) → 400 `INVALID_FILE_TYPE`; quá dung lượng cho phép (> 5MB) → 400 `FILE_TOO_LARGE`; lỗi đọc file (IO) → 400 `UPLOAD_FAILED`.
- Lỗi serialize `preferences` JSON (hiếm) → 400 `INVALID_REQUEST`.

## 7. Edge Cases

- User xóa avatar (set null) → trả về avatar mặc định (initials), không lỗi.
- Upload avatar mới khi đã có avatar cũ → BE xoá file cũ trên S3 sau khi upload file mới thành công.

## 8. Definition of Done

- Update text field (fullName/phone/timezone/notificationPreferences) qua `PUT /me` thành công, không cho sửa email (verify bằng test: DTO không có field email nên không thể gửi).
- Upload avatar qua `POST /me/avatar` thành công, độc lập với `PUT /me`.

## Out of Scope

- Đổi email (cần luồng xác thực riêng, không có trong CSV).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
