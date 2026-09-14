# UC — User Management (Verify/Disable/Delete)

| | |
|---|---|
| FR Code | 3.10.5 |
| Feature | User Management (Verify/Disable/Delete) |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Chuyển đổi trạng thái người dùng trực tiếp — thiết kế để không cần tách quá nhiều FR riêng lẻ.

## 2. User Story

Là một Admin,
tôi muốn chuyển đổi trạng thái 1 User (verify/disable/delete),
để quản lý tài khoản người dùng linh hoạt.

## 3. Acceptance Criteria

- 1 action duy nhất `PATCH .../status` nhận `action` = `verify` | `disable` | `delete` (soft) — gộp thay vì 3 endpoint riêng, theo chủ đích thiết kế gọn (xem [09_Admin_Management.md](../../../BA/09_Admin_Management.md) mục 'User Management gộp FR').

## 4. UI / UX

- Dropdown action trong bảng User (`/admin/users`).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/admin/users/{userId}/status
{ "action": "verify|disable|delete" }
→ 200 { "success": true, "data": { ...updated user... } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Admin tự disable/delete chính mình → xem câu hỏi mở ở FR 3.10.9 (Admin xóa Admin) — CHƯA CÓ CÂU TRẢ LỜI, cần Trung xác nhận.

## 8. Definition of Done

- 3 action hoạt động đúng qua 1 endpoint gộp.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)
