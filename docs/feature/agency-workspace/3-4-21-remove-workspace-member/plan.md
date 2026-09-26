# Plan — Remove Workspace Member (FR 3.4.21)

> Liên kết: [spec.md](spec.md) — cho MANAGER soft-delete 1 member khỏi Workspace (không đụng AgencyMember), kèm guard last-MANAGER.

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.removeMember(workspaceId, memberId)` |
| File đã có | `WorkspaceController` (`DELETE /{workspaceId}/members/{memberId}`), helper `assertNotLastManager` (dùng chung 3.4.16/3.4.20) |

## 2. API Contract (final)

```
DELETE /api/v1/workspaces/{workspaceId}/members/{memberId}
→ 200 ApiResponse<null>
```

Bảo vệ bởi `@RequireRole({MemberRole.MANAGER})`. Không lệch spec.md.

## 3. Data Model

- **SOFT-DELETE** `workspace_members`: `isActive = false`, `updatedAt = now`. Không xóa cứng, không đụng `agency_members`.
- Guard last-MANAGER dùng chung `assertNotLastManager` với 3.4.16 (Leave) và 3.4.20 (Update Role) — dựa trên `countByWorkspaceIdAndRoleAndIsActiveTrue`.

## 4. Luồng xử lý

1. `@RequireRole(MANAGER)` chặn.
2. Tìm member theo `memberId`, filter `workspaceId` khớp + `isActive=true` → không có → 404 `NOT_FOUND`.
3. `assertNotLastManager` — nếu member role MANAGER và count active MANAGER <=1 → 409 `LAST_MANAGER_CANNOT_BE_REMOVED`.
4. `member.setActive(false)`, `updatedAt = now`, save.

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `WorkspaceMember`, `countByWorkspaceIdAndRoleAndIsActiveTrue` (đã có) |
| Bị chặn | `View Workspace Members` (3.4.18) — member biến mất khỏi danh sách sau khi remove |

## 6. Rủi ro kỹ thuật

- **Dùng chung `assertNotLastManager` với 3.4.16/3.4.20** — sửa guard 1 chỗ ảnh hưởng 3 FR.
- **Soft-delete không xóa Task/Social Account gán cho member** — member bị xóa vẫn có thể còn dữ liệu tham chiếu (Task đang làm). Chưa có cơ chế unassign tự động, cần task riêng nếu muốn dọn dẹp.
- **Member là MANAGER duy nhất bị chặn, không có đường "transfer quyền rồi mới xóa" tự động** — MANAGER phải tự thăng người khác lên MANAGER trước (3.4.20) rồi mới remove được chính mình/người cuối.
