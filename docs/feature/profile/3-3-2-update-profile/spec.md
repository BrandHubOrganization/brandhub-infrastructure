# UC — Update Profile

| | |
|---|---|
| FR Code | 3.3.2 |
| Feature | Update Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép User cập nhật thông tin cá nhân. Gộp thành 1 FR duy nhất 'Update Profile' (theo ghi chú gốc CSV, không tách View riêng khỏi hành động Update ở tầng đặt tên FR).

## 2. User Story

Là một User,
tôi muốn cập nhật thông tin profile của mình,
để giữ thông tin cá nhân luôn chính xác.

## 3. Acceptance Criteria

- Form cho sửa: `fullName`, `avatarUrl` (upload ảnh), `phone`.
- **Không cho sửa `email`** ở FR này — đổi email cần luồng riêng có xác thực (không nằm trong CSV hiện tại, coi là out of scope).
- Lưu thành công → toast confirm, cập nhật lại UI ngay không cần reload.
- **[CHỐT 2026-09-20]** Avatar upload lưu thật lên S3 qua `POST /api/v1/users/me/avatar` (multipart `file`) — endpoint + `FileStorageService` (S3) đã có sẵn ở backend; FE `AvatarUploadModal` hiện chỉ set preview URL local, cần wire gọi endpoint và gắn `avatarUrl` trả về.

## 4. UI / UX

- Trang `/settings/profile`, form edit inline hoặc modal.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/users/me
{ "fullName"?: "string", "avatarUrl"?: "string", "phone"?: "string" }
→ 200 { "success": true, "data": { ...updated user... } }
```

## 6. Error Handling

- `fullName` trống → 400 `VALIDATION_ERROR`.
- Upload avatar quá dung lượng cho phép → 400 `FILE_TOO_LARGE`.

## 7. Edge Cases

- User xóa avatar (set null) → trả về avatar mặc định (initials), không lỗi.

## 8. Definition of Done

- Update thành công, không cho sửa email qua endpoint này (verify bằng test gửi field email → bị ignore hoặc 400).

## Out of Scope

- Đổi email (cần luồng xác thực riêng, không có trong CSV).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
