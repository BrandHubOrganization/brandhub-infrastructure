# UC — Update Agency Profile

| | |
|---|---|
| FR Code | 3.4.5 |
| Feature | Update Agency Profile |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cho phép Owner cập nhật thông tin Agency Profile.

## 2. User Story

Là một Owner,
tôi muốn cập nhật thông tin Agency Profile,
để giữ thông tin công ty luôn mới nhất.

## 3. Acceptance Criteria

- Form sửa: `name`, `description`, `logoUrl`.
- Chỉ Owner của chính Agency đó được sửa.

## 4. UI / UX

- Trang `/agencies/:id/profile/edit`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/agencies/{id}
{ "name"?, "description"?, "logoUrl"? }
→ 200 { "success": true, "data": { ...updated agency... } }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.
- `name` trống → 400 `VALIDATION_ERROR`.

## 7. Edge Cases

- Không có edge case đặc biệt ngoài quyền hạn.

## 8. Definition of Done

- Update thành công, chỉ Owner sửa được.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
