# Plan — List Workspace (FR 3.4.10)

> Liên kết: [spec.md](spec.md) — cho user xem danh sách Workspace họ đang là `WorkspaceMember`.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.listMyWorkspaces()`, `WorkspaceServiceImpl.listManagedWorkspaces()` |
| File đã có | `WorkspaceController` (`GET /api/v1/workspaces`, `GET /api/v1/workspaces/my-managed`), `WorkspaceRepository`, `WorkspaceMemberRepository`, `WorkspaceResponse`, `ManagedWorkspaceResponse` |

## 2. API Contract (final)

```
GET /api/v1/workspaces
Authorization: Bearer <access-token>
→ 200 ApiResponse<List<WorkspaceResponse>>

GET /api/v1/workspaces/my-managed
Authorization: Bearer <access-token>
→ 200 ApiResponse<List<ManagedWorkspaceResponse>>
   data = [{ id, name, role, memberCount }]
```

Không lệch so với spec.md — cả 2 endpoint đã khớp code thật.

## 3. Data Model

- Flow A: `workspace_members` theo `userId = currentUser.id AND isActive = true` → lấy `workspaceId` → `workspaces.findAllById`.
- Flow B: như trên nhưng lọc thêm `role = MANAGER`; với mỗi Workspace còn lại đếm `memberCount` qua `countByWorkspaceIdAndIsActiveTrue`.
- Không migration.

## 4. Luồng xử lý

1. Query `workspace_members` active của current user.
2. Lấy `workspaceId` → `findAllById` trên `workspaces`.
3. Map → `WorkspaceResponse` (Flow A) hoặc `ManagedWorkspaceResponse` kèm `memberCount` (Flow B).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `Workspace`/`WorkspaceMember` entity + repository (đã có) |
| Bị chặn | `View Workspace Profile` (3.4.13), `Add/Remove Member` (3.4.19/3.4.21) — cùng repo |

## 6. Rủi ro kỹ thuật

- **Không có khái niệm "Owner Agency thấy toàn bộ Workspace"** ở endpoint này — chỉ trả Workspace mà user có membership trực tiếp. Nếu BA muốn Owner Agency thấy toàn bộ Workspace con của Agency mình (kể cả chưa là member), cần endpoint riêng — hiện chưa có, ghi nhận là gap tiềm năng.
- **2 query riêng biệt (Flow A/B) thay vì 1 query có filter role** — chấp nhận vì đơn giản, số lượng Workspace/user nhỏ, không cần tối ưu N+1 ở quy mô hiện tại.
