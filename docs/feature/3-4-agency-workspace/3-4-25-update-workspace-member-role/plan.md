# Plan — Update Workspace Member Role (FR 3.4.20)

> Liên kết: [spec.md](spec.md) — cho MANAGER đổi role của 1 member trong Workspace, kèm 2 guard (mất MANAGER cuối + trùng MANAGER).

## 1. Phạm vi kỹ thuật

| Mục | Nội dung |
|---|---|
| Repo | `brandhub-business-service` |
| File implement | `WorkspaceServiceImpl.updateMemberRole(workspaceId, memberId, newRole)` |
| File đã có | `WorkspaceController` (`PATCH /{workspaceId}/members/{memberId}/role`), `UpdateMemberRoleRequest { role }`, `WorkspaceMemberRepository.countByWorkspaceIdAndRoleAndIsActiveTrue`, helper `assertNotLastManager` (dùng chung 3.4.16/3.4.21) |

## 2. API Contract (final)

```
PATCH /api/v1/workspaces/{workspaceId}/members/{memberId}/role
{ "role": "MANAGER|CREATOR|CLIENT" }
→ 200 ApiResponse<WorkspaceMemberResponse>
```

Bảo vệ bởi `@RequireRole({MemberRole.MANAGER})`. Không lệch spec.md.

## 3. Data Model

- **UPDATE** `workspace_members.role` của member target (đã active, thuộc đúng `workspaceId`). Không thêm cột, không migration.
- 2 guard dùng chung pattern với 3.4.16 (Leave) và 3.4.21 (Remove) — cùng method `assertNotLastManager`.

## 4. Luồng xử lý

1. `@RequireRole(MANAGER)` chặn (aspect, check membership theo `user.getWorkspaceId()`).
2. Tìm member theo `memberId`, filter `workspaceId` khớp + `isActive=true` → không có → 404 `NOT_FOUND`.
3. **Giảm quyền:** nếu `member.role == MANAGER` và `newRole != MANAGER` → gọi `assertNotLastManager` (đếm active MANAGER <=1 → 409 `LAST_MANAGER_CANNOT_BE_REMOVED`).
4. **Thăng quyền:** nếu `newRole == MANAGER` và `member.role != MANAGER` → đếm active MANAGER; nếu >0 → 409 `MANAGER_ALREADY_ASSIGNED`.
5. Set `member.role = newRole`, `updatedAt = now`, save.
6. Trả `WorkspaceMemberResponse` (kèm fullName/email từ `User` nếu có `userId`).

## 5. Dependencies

| Chiều | Mô tả |
|---|---|
| Chặn bởi | `WorkspaceMember`, `countByWorkspaceIdAndRoleAndIsActiveTrue` (đã có) |
| Bị chặn | `View Workspace Members` (3.4.18) — hiển thị role mới sau khi update |

## 6. Rủi ro kỹ thuật

- **Dùng chung `assertNotLastManager` với 3.4.16/3.4.21** — sửa logic guard 1 chỗ ảnh hưởng cả 3 FR, cần test lại đủ 3 FR khi đổi.
- **`@RequireRole` check theo `user.getWorkspaceId()`** (workspace active của principal), không theo `@PathVariable workspaceId` — nếu member muốn đổi role ở workspace khác với workspace đang active, aspect sẽ chặn nhầm. Đây là giới hạn có sẵn của annotation, chấp nhận vì FE luôn gọi trong context workspace đang thao tác.
- **No-op đổi role cùng giá trị** — không có guard chặn, trả 200 bình thường. Cân nhắc thêm check idempotent nếu FE cần tín hiệu "không có gì thay đổi".
