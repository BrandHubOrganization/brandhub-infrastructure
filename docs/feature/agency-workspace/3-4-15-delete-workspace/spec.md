# UC — Delete Workspace

| | |
|---|---|
| FR Code | 3.4.15 |
| Feature | Delete Workspace |
| Domain | Agency & Workspace (FR 3.4) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Chỉ Owner được xóa (mềm) Workspace, khôi phục được trong 30 ngày, khi xóa toàn bộ member mất quyền truy cập và dữ liệu chuyển inactive.

## 2. User Story

Là một Owner,
tôi muốn xóa 1 Workspace không còn dùng nữa,
nhưng có thể khôi phục nếu cần trong 30 ngày.

## 3. Acceptance Criteria

- Bấm Delete (confirm dialog, yêu cầu nhập tên Workspace để xác nhận — hành động nguy hiểm).
- Set `Workspace.status = SOFT_DELETED`, `deletedAt = now()`.
- Toàn bộ Member/Client mất quyền truy cập ngay lập tức.
- Mọi dữ liệu trong Workspace (Task, Campaign, Material...) chuyển trạng thái `inactive` — không xóa cứng.
- **Chỉ OWNER** mới bấm được nút này (khác Update Workspace Profile cho phép cả Manager).

## 4. UI / UX

- Nút Delete trong Workspace Settings, chỉ hiển thị cho Owner.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
DELETE /api/v1/workspaces/{id}
→ 200 { "success": true, "data": null }

POST /api/v1/workspaces/{id}/restore
→ 200 { "success": true, "data": { ...restored workspace... } }
```

## 6. Error Handling

- Không phải Owner (kể cả Manager của Workspace đó) → 403 `FORBIDDEN`.
- Khôi phục sau 30 ngày → 410 `RESTORE_WINDOW_EXPIRED`.

## 7. Edge Cases

- Workspace đang có Task ở trạng thái `IN_PROGRESS`/`CLIENT_REVIEW` khi bị xóa → toàn bộ chuyển `inactive`, khi restore lại phải khôi phục ĐÚNG trạng thái trước đó (không reset về backlog).

## 8. Definition of Done

- Soft delete + restore hoạt động đúng, chỉ Owner thao tác được.

## Out of Scope

- Xóa cứng ngay (chỉ soft delete theo CSV).

## Tham chiếu BA

[01_Organization_Structure.md](../../../BA/01_Organization_Structure.md), [03_Agency_Workspace_Management.md](../../../BA/03_Agency_Workspace_Management.md)
