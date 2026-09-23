# Sequence Flow — List Workspace

> Bổ sung cho `spec.md` (FR 3.4.10). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController`, `WorkspaceServiceImpl`).

## Actors

- **User** — thành viên Workspace bất kỳ (MANAGER/CREATOR/CLIENT), đã đăng nhập.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_members`, `workspaces`).

---

## Flow A — Danh sách Workspace user đang tham gia

1. User → FE: mở trang danh sách Workspace.
2. FE → BE: `GET /api/v1/workspaces`.
3. BE (`WorkspaceServiceImpl.listMyWorkspaces`):
   a. Query `workspace_members` theo `userId = currentUser.id AND isActive = true`.
   b. Lấy danh sách `workspaceId` từ kết quả trên.
   c. Query `workspaces` theo `findAllById(workspaceIds)`.
   d. Map từng `Workspace` → `WorkspaceResponse`.
4. BE → DB: 2 query (bước a, c).
5. BE → FE: `200 { data: [WorkspaceResponse, ...] }`.
6. FE: hiển thị danh sách Workspace (rỗng nếu user chưa tham gia Workspace nào).

## Flow B — Danh sách Workspace user đang MANAGER (endpoint phụ)

1. User → FE: mở trang "Workspace tôi quản lý" (nếu có UI riêng).
2. FE → BE: `GET /api/v1/workspaces/my-managed`.
3. BE (`WorkspaceServiceImpl.listManagedWorkspaces`):
   a. Query `workspace_members` theo `userId = currentUser.id AND isActive = true`, lọc tiếp `role = MANAGER`.
   b. Query `workspaces` theo các `workspaceId` còn lại.
   c. Với mỗi Workspace: đếm `memberCount` bằng `countByWorkspaceIdAndIsActiveTrue`.
   d. Map → `ManagedWorkspaceResponse { id, name, role, memberCount }`.
4. BE → FE: `200 { data: [ManagedWorkspaceResponse, ...] }`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| List (A/B) | Chưa đăng nhập | 401 | (cơ chế xác thực chung, không có ErrorCode riêng ở tầng WorkspaceService) |

Không có ErrorCode nghiệp vụ nào khác — endpoint chỉ đọc theo `currentUser`, không có nhánh lỗi 4xx/409 nào trong `WorkspaceServiceImpl` cho 2 flow này.
