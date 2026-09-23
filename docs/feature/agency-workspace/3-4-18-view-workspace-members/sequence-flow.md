# Sequence Flow — View Workspace Members

> Bổ sung cho `spec.md` (FR 3.4.18). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.listMembers`, `WorkspaceServiceImpl.listMembers`).

## Actors

- **User** — active member của Workspace (MANAGER/CREATOR/CLIENT).
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspaces`, `workspace_members`, `users`, `client_profiles`).

---

## Flow A — Xem danh sách thành viên Workspace

1. User → FE: mở `/workspaces/:id/members`.
2. FE → BE: `GET /api/v1/workspaces/{workspaceId}/members`.
3. BE (`WorkspaceServiceImpl.listMembers`):
   a. `findWorkspaceOrThrow(workspaceId)` — không tồn tại → `404 WORKSPACE_NOT_FOUND`.
   b. `assertMember(workspaceId, currentUser.id)` — caller không phải active member của workspace này → `403 WORKSPACE_ACCESS_DENIED`.
   c. Query `workspace_members` theo `workspaceId` và `isActive = true`.
   d. Lấy danh sách `userId` (loại bỏ null) → query `users` theo `findAllById`.
   e. Lấy danh sách `clientProfileId` (loại bỏ null) → query `client_profiles` theo `findAllById`.
   f. Map từng `WorkspaceMember`:
      - Nếu có `userId`: lấy `fullName`/`email` từ `User`.
      - Nếu không có `userId` (member kiểu CLIENT gán qua `addClient`): lấy `displayName` từ `ClientProfile` làm `fullName`, `email = null`.
4. BE → DB: 5 SELECT (bước a, b, c, d, e).
5. BE → FE: `200 { data: [WorkspaceMemberResponse, ...] }` (`id`, `workspaceId`, `userId`, `fullName`, `email`, `clientProfileId`, `role`, `joinedAt`, `isActive`).
6. FE: render bảng thành viên kèm role.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| List members | Workspace không tồn tại | 404 | `WORKSPACE_NOT_FOUND` |
| List members | Caller không phải active member của workspace này | 403 | `WORKSPACE_ACCESS_DENIED` |
