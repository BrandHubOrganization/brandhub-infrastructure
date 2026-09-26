# Plan — View Workspace Members (FR 3.4.18)

> Liên kết: [spec.md](spec.md) — hiển thị danh sách thành viên của 1 Workspace.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.listMembers()` |
| File đã có | `WorkspaceController` (`GET /{workspaceId}/members`), `WorkspaceMemberRepository`, `UserRepository`, `ClientProfileRepository`, `WorkspaceMemberResponse` |

## 2. API Contract (final)

```
GET /api/v1/workspaces/{workspaceId}/members
Authorization: Bearer <access-token>
→ 200 ApiResponse<List<WorkspaceMemberResponse>>
   data = [{ id, workspaceId, userId, fullName, email, clientProfileId, role, joinedAt, isActive }]
```

Không lệch spec.md.

## 3. Data Model

- `findWorkspaceOrThrow(workspaceId)` — đọc `workspaces`.
- `assertMember` — đọc `workspace_members`.
- Query `workspace_members` theo `workspaceId + isActive=true`.
- Batch `findAllById` trên `users` (theo `userId` không null) và `client_profiles` (theo `clientProfileId` không null) — tránh N+1.
- Map: nếu có `userId` → lấy `fullName`/`email` từ User; nếu không (member kiểu CLIENT gán qua `addClient`) → lấy `displayName` từ ClientProfile làm `fullName`, `email = null`.
- Không migration.

## 4. Luồng xử lý

1. `findWorkspaceOrThrow` → 404 `WORKSPACE_NOT_FOUND`.
2. `assertMember(workspaceId, currentUser.id)` — check thủ công (không `@RequireRole`, cùng lý do với `getWorkspace`) → 403 `WORKSPACE_ACCESS_DENIED`.
3. Query members active → batch load Users + ClientProfiles → map response.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `WorkspaceMember`, `User`, `ClientProfile` entity (đã có) |
| Bị chặn | `Update Member Role` (3.4.20), `Remove Member` (3.4.21) — cùng hiển thị list này ở FE |

## 6. Rủi ro kỹ thuật

- **2 nguồn dữ liệu cho `fullName`** (User vs ClientProfile tùy loại member) — logic map dễ nhầm nếu thêm loại member mới sau này; cần document rõ invariant "CLIENT member luôn có `clientProfileId`, không có `userId`" (hoặc ngược lại) nếu có thay đổi domain sau này.
- **Batch `findAllById` 2 lần (Users, ClientProfiles)** — đã tối ưu N+1 so với query từng member riêng lẻ, chấp nhận được ở quy mô hiện tại.
