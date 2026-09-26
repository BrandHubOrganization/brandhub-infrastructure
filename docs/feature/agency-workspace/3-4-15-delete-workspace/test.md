# Test — Delete Workspace (FR 3.4.15)

> Trạng thái: **Implemented — API Contract đã chốt theo code thật** (xem [plan.md](plan.md)). Vai trò "Owner cấp Workspace" (Agency OWNER) đã được code dùng, nhưng chưa formally confirmed bởi team — xem flag ⚠ trong spec.md.

| Test case ID | Mô tả | Kết quả mong đợi |
|---|---|---|
| TC-01 | Agency OWNER xóa Workspace, nhập đúng tên xác nhận | 200; `status = SOFT_DELETED`, `deletedAt` set |
| TC-02 | Workspace MANAGER (không phải Agency OWNER) xóa Workspace | 403 `FORBIDDEN` |
| TC-03 | Xóa Workspace không tồn tại | 404 `WORKSPACE_NOT_FOUND` |
| TC-04 | Agency OWNER restore Workspace trong 30 ngày | 200; `status = ACTIVE`, `deletedAt = null` |
| TC-05 | Restore sau 30 ngày | 410 `RESTORE_WINDOW_EXPIRED` |
| TC-06 | Restore Workspace chưa bị xóa (status khác `SOFT_DELETED`) | 400 `WORKSPACE_NOT_DELETED` |

> Chưa có test case cho FE Restore vì chưa có UI (chỉ backend endpoint tồn tại).
