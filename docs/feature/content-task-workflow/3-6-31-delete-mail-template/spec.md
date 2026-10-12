# UC — Delete Mail Template

| | |
|---|---|
| FR Code | 3.6.31 |
| Feature | Delete Mail Template |
| Domain | Content & Workflow (FR 3.6) |
| Role | OWNER, MANAGER, CREATOR (đã chốt 2026-10-12) |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Đã chốt nghiệp vụ 2026-10-12 — xem plan.md, chưa code |

## Quyết định đã chốt (2026-10-12)

> Nguồn chuẩn: [../3-6-28-32-mail-template/plan.md](../3-6-28-32-mail-template/plan.md). Mục này **ghi đè** các phần "đề xuất" và `TBD` bên dưới khi có mâu thuẫn.

- **Phạm vi**: template theo **Workspace**. **Role**: OWNER, MANAGER, CREATOR (CLIENT không). Sửa/xóa template của Workspace: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin sửa/xóa.
- **Soft delete** bằng `deletedAt` (không `repository.delete()`); không có khôi phục.
- Xóa template **không** hủy lô đã hẹn (đã snapshot) và không xóa lịch sử gửi.
- Quyền: người tạo hoặc OWNER/MANAGER; template hệ thống chỉ Admin (`DELETE /api/v1/admin/mail-templates/{tid}`).

## 1. Objective

Xóa mẫu email vừa tạo hoặc mẫu đang dùng.

## 2. User Story

Là một Member,
tôi muốn xóa mẫu email không còn dùng,
để giữ danh sách gọn gàng.

## 3. Acceptance Criteria

- Xóa Mail Template (đề xuất soft delete để nhất quán với pattern xóa khác trong hệ thống).

## 4. UI / UX

- Nút Delete trong list Mail Template, confirm dialog.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}/mail-templates/{templateId}
→ 200 { "success": true, "data": null }
```

## 6. Error Handling

- Không có quyền → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Xóa thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[05-content-task-workflow.md](../../../BA/05-content-task-workflow.md)
