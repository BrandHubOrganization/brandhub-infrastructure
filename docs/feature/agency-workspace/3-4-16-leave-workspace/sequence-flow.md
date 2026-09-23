# Sequence Flow — Leave Workspace

> Bổ sung cho `spec.md` (FR 3.4.16). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.leaveWorkspace`, `WorkspaceServiceImpl.leaveWorkspace` + `assertNotLastManager`).

## Actors

- **Member** — active member của Workspace (MANAGER/CREATOR/CLIENT), rời chính workspace của mình.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_members`).

---

## Flow A — Rời Workspace

1. Member → FE: mở Workspace Settings/Members, bấm "Rời Workspace", xác nhận (confirm dialog).
2. FE → BE: `DELETE /api/v1/workspaces/{workspaceId}/leave` (không có body, `userId` lấy từ JWT principal). Không có `@RequireRole` chặn — endpoint mở cho bất kỳ user đã đăng nhập nào.
3. BE (`WorkspaceServiceImpl.leaveWorkspace`):
   a. `workspaceMemberRepository.findByWorkspaceIdAndUserIdAndIsActiveTrue(workspaceId, currentUser.id)` — không tìm thấy (không phải member, hoặc đã leave rồi) → `403 WORKSPACE_ACCESS_DENIED`.
   b. `assertNotLastManager(workspaceId, member)`: nếu `member.role != MANAGER` → pass. Nếu `member.role == MANAGER` → đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu `<= 1` → `409 LAST_OWNER_CANNOT_BE_REMOVED`.
   c. Set `member.isActive = false`, `updatedAt = now()`.
4. BE → DB: `UPDATE workspace_members SET is_active = false, updated_at = ? WHERE id = ?`.
5. BE → FE: `200 { data: null }`.
6. FE: điều hướng ra khỏi Workspace (về danh sách Workspace), user vẫn còn trong Agency và các Workspace khác. `AgencyMember` record không bị đụng tới.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Leave | `currentUser` không phải active member của workspace này | 403 | `WORKSPACE_ACCESS_DENIED` |
| Leave | `currentUser` là MANAGER active duy nhất của workspace | 409 | `LAST_OWNER_CANNOT_BE_REMOVED` |

## Ghi chú khác biệt so với spec.md gốc

- Không có — FR này đã chuyển từ Draft sang Implemented; spec.md và sequence-flow viết lại hoàn toàn khớp `WorkspaceController.leaveWorkspace` / `WorkspaceServiceImpl.leaveWorkspace`, dùng chung guard `assertNotLastManager` với FR 3.4.20 và 3.4.21.
