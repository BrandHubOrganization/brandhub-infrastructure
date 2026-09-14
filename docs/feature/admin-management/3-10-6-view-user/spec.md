# UC — View User

| | |
|---|---|
| FR Code | 3.10.6 |
| Feature | View User |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem danh sách User đang có trong hệ thống.

## 2. User Story

Là một Admin,
tôi muốn xem danh sách toàn bộ User,
để quản lý và tra cứu thông tin người dùng.

## 3. Acceptance Criteria

- List User: email, tên, plan, trạng thái, ngày tạo. Có search/filter.

## 4. UI / UX

- Trang Admin `/admin/users`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/users?search=...&status=...
→ 200 { "success": true, "data": [{ "id", "email", "fullName", "plan", "status", "createdAt" }] }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng, search/filter hoạt động.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)
