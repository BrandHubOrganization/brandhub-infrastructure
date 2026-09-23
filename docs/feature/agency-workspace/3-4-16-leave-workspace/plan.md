# Plan — Leave Workspace (FR 3.4.16)

> Liên kết: [spec.md](spec.md) — cho member tự rời 1 Workspace, vẫn còn trong Agency. API mới vừa code xong.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.leaveWorkspace()`, `WorkspaceServiceImpl.assertNotLastManager()` (helper dùng chung) |
| File đã có | `WorkspaceController` (`DELETE /{workspaceId}/leave`), `WorkspaceMemberRepository` |

## 2. API Contract (final)

```
DELETE /api/v1/workspaces/{workspaceId}/leave
Authorization: Bearer <access-token>
→ 200 ApiResponse<null>
```

Không có request body — `userId` lấy từ `AuthenticatedUser` principal (JWT). Không có `@RequireRole` — endpoint mở cho bất kỳ user đã đăng nhập nào, vì action chỉ tác động lên chính `WorkspaceMember` record của `currentUser`.

## 3. Data Model

- Đọc `workspace_members` theo `workspaceId + userId(currentUser) + isActive=true`.
- Ghi: `UPDATE workspace_members SET is_active = false, updated_at = ? WHERE id = ?` — soft-delete, **không đụng `agency_members`**.
- Không migration.

## 4. Luồng xử lý

1. `findByWorkspaceIdAndUserIdAndIsActiveTrue` — không tìm thấy → 403 `WORKSPACE_ACCESS_DENIED`.
2. `assertNotLastManager(workspaceId, member)`: nếu `role != MANAGER` → pass; nếu `role == MANAGER` → đếm MANAGER active — `<= 1` → 409 `LAST_OWNER_CANNOT_BE_REMOVED`.
3. Set `isActive = false`, `updatedAt = now()`, save.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `WorkspaceMember` entity + repository (đã có) |
| Bị chặn | Không — nhưng dùng chung `assertNotLastManager` với FR 3.4.20 (Update Role) và 3.4.21 (Remove Member) |

## 6. Rủi ro kỹ thuật

- **Guard `assertNotLastManager` dùng chung 3 FR (3.4.16/3.4.20/3.4.21)** — sửa logic 1 chỗ ảnh hưởng cả 3, cần test cả 3 khi thay đổi threshold hay điều kiện đếm MANAGER.
- **Không có `@RequireRole`** — rủi ro bảo mật thấp vì action luôn tự áp dụng lên `currentUser`, không nhận `memberId` tham số, nên không thể leave giùm người khác; nhưng cần review kỹ nếu sau này thêm tham số.
- **FE đã build UI "Leave workspace"** (xác nhận 2026-09-23: nút trong `InternalMembersSection.tsx` + `workspaceService.leaveWorkspace` + i18n `leaveButton`/`leaveSuccess`) — không còn là mục chờ xác nhận, xem task.md. Theo Out of Scope, chỉ "tự động chọn MANAGER thay thế" là ngoài phạm vi.
