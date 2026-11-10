# Task — List Workspace (FR 3.4.10)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.listMyWorkspaces(AuthenticatedUser)` — query `workspace_members` active theo `userId` → `findAllById` workspaces
- [x] Implement `WorkspaceServiceImpl.listManagedWorkspaces(AuthenticatedUser)` — lọc `role = MANAGER`, kèm `memberCount`
- [x] Map entity → `WorkspaceResponse` / `ManagedWorkspaceResponse`
- [x] `GET /api/v1/workspaces` và `GET /api/v1/workspaces/my-managed` đã có ở `WorkspaceController`

## Verify

- [x] `mvn test` pass (service + controller)
- [x] User chưa tham gia Workspace nào → trả mảng rỗng, không lỗi
- [x] `memberCount` ở `my-managed` đếm đúng theo `isActive = true`
