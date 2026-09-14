# UC — Update User

| | |
|---|---|
| FR Code | 3.10.8 |
| Feature | Update User |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Chỉnh sửa thông tin User có trong hệ thống.

## 2. User Story

Là một Admin,
tôi muốn sửa thông tin 1 User,
để hỗ trợ khắc phục vấn đề tài khoản của họ.

## 3. Acceptance Criteria

- Sửa `fullName`, `email` (Admin có quyền đổi email User, khác với User tự đổi — không có FR tự đổi email trong CSV), `plan`.

## 4. UI / UX

- Trang chi tiết User trong `/admin/users/:id`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/admin/users/{userId}
{ "fullName"?, "email"?, "plan"? }
→ 200 { "success": true, "data": { ...updated user... } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.
- Đổi email trùng email User khác → 409 `EMAIL_ALREADY_EXISTS`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Update thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)
