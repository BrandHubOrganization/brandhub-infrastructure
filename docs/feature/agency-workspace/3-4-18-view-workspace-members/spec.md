# UC — View Workspace Members

| | |
|---|---|
| FR Code | 3.4.18 |
| Feature | View Workspace Members |
| Domain | Agency & Workspace (FR 3.4) |
| Role | MANAGER/CREATOR/CLIENT |
| Version | 2.2 — Cập nhật 2026-09-23 — đồng bộ theo code thật (bổ sung workspace-not-found + membership check) |
| Trạng thái tài liệu | Đã code |

## 1. Objective

Hiển thị danh sách thành viên của 1 Workspace.

## 2. User Story

Là một thành viên của Workspace,
tôi muốn xem danh sách thành viên,
để biết ai đang tham gia và vai trò của họ.

## 3. Acceptance Criteria

- List toàn bộ `WorkspaceMember` của Workspace: `id`, `workspaceId`, `userId`, `fullName`, `email`, `clientProfileId`, `role` (`MANAGER`|`CREATOR`|`CLIENT` — KHÔNG có `OWNER` ở cấp Workspace, Owner chỉ tồn tại ở cấp Agency), `joinedAt`, `isActive`.
- Workspace không tồn tại → 404 (kiểm tra qua `findWorkspaceOrThrow` trước khi list).
- Caller phải là active `WorkspaceMember` của chính workspace đang xem — kiểm tra thủ công trong `WorkspaceServiceImpl.listMembers` (không dùng `@RequireRole`, tương tự cách `getWorkspace` xử lý).

## 4. UI / UX

- Trang `/workspaces/:id/members`.

## 5. API Contract

```
GET /api/v1/workspaces/{workspaceId}/members
→ 200 { "success": true, "data": [WorkspaceMemberResponse, ...] }
```

`WorkspaceMemberResponse`: `id`, `workspaceId`, `userId`, `fullName`, `email`, `clientProfileId`, `role`, `joinedAt`, `isActive`.

## 6. Error Handling

- Workspace không tồn tại → 404 `WORKSPACE_NOT_FOUND`.
- Caller không phải active member của workspace này → 403 `WORKSPACE_ACCESS_DENIED`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- List hiển thị đúng, mọi Member xem được.

## Out of Scope

- Không có.

## Tham chiếu BA

[01-organization-structure.md](../../../BA/01-organization-structure.md), [03-agency-workspace-management.md](../../../BA/03-agency-workspace-management.md)
