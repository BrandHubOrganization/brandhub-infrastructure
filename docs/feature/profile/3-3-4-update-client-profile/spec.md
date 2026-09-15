# UC — Update Client Profile

| | |
|---|---|
| FR Code | 3.3.4 |
| Feature | Update Client Profile |
| Domain | Profile (FR 3.3) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép cập nhật Client Profile, nhưng KHÔNG cho đổi email — email là khóa định danh cố định xuyên các Agency khác nhau.

## 2. User Story

Là một User đóng vai trò Client,
tôi muốn cập nhật thông tin Client Profile của mình,
nhưng email của tôi phải giữ cố định để các Agency luôn nhận diện đúng tôi.

## 3. Acceptance Criteria

- Form cho sửa: `displayName`, `company`, `phone`, `note`.
- **KHÔNG có field email trong form** — email cố định từ lúc tạo Client Profile, không thể đổi qua FR này.
- Lưu thành công → cập nhật đồng bộ hiển thị ở TẤT CẢ Workspace/Agency mà Client Profile này đang được dùng (vì chỉ có 1 bản Client Profile dùng chung).

## 4. UI / UX

- Form edit trong trang Client Profile (FR 3.3.3).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/client-profile/me
{ "displayName"?: "string", "company"?: "string", "phone"?: "string", "note"?: "string" }
→ 200 { "success": true, "data": { ...updated client profile... } }
```

## 6. Error Handling

- Gửi kèm field `email` trong request body → 400 `EMAIL_UPDATE_NOT_ALLOWED` (chặn rõ ràng, không âm thầm ignore).

## 7. Edge Cases

- Client cập nhật `displayName` khi đang có task đang chờ duyệt ở nhiều Workspace khác nhau → tên hiển thị mới áp dụng ngay cho tất cả, không cần đồng bộ thủ công từng nơi.

## 8. Definition of Done

- Update thành công mọi field trừ email; verify email bị chặn đổi bằng test case rõ ràng.

## Out of Scope

- Đổi email Client Profile (chặn hoàn toàn theo AC).

## Tham chiếu BA

[02-authentication-profile.md](../../../BA/02-authentication-profile.md)
