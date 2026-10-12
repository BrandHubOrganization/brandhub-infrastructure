# UC — Update Mail Template

| | |
|---|---|
| FR Code | 3.6.30 |
| Feature | Update Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [../3-6-28-32-mail-template/plan.md](../3-6-28-32-mail-template/plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Method**: **PATCH** (không phải PUT), trường `bodyHtml`; thêm `attachmentIds?`.
- Template hệ thống từ Workspace → 403 `SYSTEM_TEMPLATE_READ_ONLY`. Sửa template của người khác chỉ OWNER/MANAGER. Template không tồn tại → 404 `TEMPLATE_NOT_FOUND`.
- Sửa template **không** ảnh hưởng lô đã gửi hoặc đã hẹn (snapshot).

## 1. Objective

Chỉnh sửa lại mẫu email vừa tạo hoặc mẫu có sẵn.

## 2. User Story

Là một Member,
tôi muốn sửa lại mẫu email đã tạo,
để cập nhật nội dung phù hợp hơn.

## 3. Acceptance Criteria

- Sửa `name`, `subject`, `body`.

## 4. UI / UX

- Nút Edit trong list Mail Template.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
PATCH /api/v1/workspaces/{id}/mail-templates/{templateId}
{ "name"?, "subject"?, "body"? }
→ 200 { "success": true, "data": { ...updated template... } }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Update thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
