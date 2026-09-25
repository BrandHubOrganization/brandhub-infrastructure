# Task — Delete Workspace (FR 3.4.15)

> Trạng thái: **Implemented.**

- [x] `WorkspaceController.deleteWorkspace` / `restoreWorkspace` — đã code (DELETE/POST routes trên `/api/v1/workspaces/{workspaceId}`).
- [x] `WorkspaceServiceImpl.deleteWorkspace` / `restoreWorkspace` — gate Agency OWNER, soft-delete, 30-day restore window — đã code.
- [x] FE Danger Zone (xóa) trong `detail.tsx` — có confirm dialog nhập tên Workspace.
- [ ] FE Restore — chưa có UI; chỉ có backend endpoint. Cần bổ sung nếu BA muốn expose restore cho user.
- [ ] Vai trò "Owner cấp Workspace" — vẫn chưa formally confirmed bởi team (đã implement theo Agency OWNER, xem spec.md flag ⚠).
