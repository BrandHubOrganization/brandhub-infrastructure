# Sequence Flow — Update Workspace Member Role

> Bổ sung cho `spec.md` (FR 3.4.20). File này liệt kê từng bước actor → action → hệ thống, đủ chi tiết để vẽ sequence diagram trực tiếp — không diễn giải nghiệp vụ (xem spec.md cho phần đó).
>
> Cập nhật: 2026-09-23. Khớp code thật (`WorkspaceController.updateMemberRole`, `WorkspaceServiceImpl.updateMemberRole` + `assertNotLastManager`).

## Actors

- **MANAGER** — MANAGER của Workspace, người đổi role.
- **FE** — brandhub-web-dashboard (React).
- **BE** — brandhub-business-service (Spring Boot).
- **DB** — PostgreSQL (`workspace_members`, `users`).

---

## Flow A — Đổi role một Member (không liên quan MANAGER)

1. MANAGER → FE: trong `/workspaces/:id/members`, chọn dropdown đổi role cho 1 Member (ví dụ CREATOR → CLIENT).
2. FE → BE: `PATCH /api/v1/workspaces/{workspaceId}/members/{memberId}/role` `{role}`.
3. BE: `@RequireRole({MemberRole.MANAGER})` chặn trước — không phải MANAGER của workspace này → `403 FORBIDDEN`.
4. BE (`WorkspaceServiceImpl.updateMemberRole`):
   a. `workspaceMemberRepository.findById(memberId)`, filter `member.workspaceId == workspaceId && member.isActive` — không thỏa → `404 NOT_FOUND`.
   b. `member.role == MANAGER && newRole != MANAGER`? — false (role cũ không phải MANAGER) → bỏ qua guard last-MANAGER.
   c. `newRole == MANAGER && member.role != MANAGER`? — false (role mới không phải MANAGER) → bỏ qua guard MANAGER trùng.
   d. Set `member.role = newRole`, `updatedAt = now()`, save.
   e. Query `User` theo `member.userId` (nếu có) để build response `fullName`/`email`.
5. BE → DB: 1 SELECT (find member) + 1 UPDATE + 1 SELECT (user, nếu applicable).
6. BE → FE: `200 { data: WorkspaceMemberResponse }` (role đã cập nhật).
7. FE: cập nhật dropdown/bảng thành viên.

## Flow B — Giảm quyền MANAGER duy nhất (bị chặn)

1. MANAGER → FE: đổi role của member đang là MANAGER duy nhất sang CREATOR.
2. FE → BE: `PATCH .../{memberId}/role` `{role: CREATOR}`.
3. BE: `@RequireRole` pass (caller là MANAGER).
4. BE (`updateMemberRole`):
   a. Tìm member — tồn tại, active.
   b. `member.role == MANAGER && newRole != MANAGER` → true → gọi `assertNotLastManager(workspaceId, member)`: đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu `<= 1` → `409 LAST_OWNER_CANNOT_BE_REMOVED`. Không update.
5. BE → FE: `409 { error: LAST_OWNER_CANNOT_BE_REMOVED }`.
6. FE: hiển thị lỗi, yêu cầu chuyển giao MANAGER cho người khác trước.

## Flow C — Thăng quyền lên MANAGER khi đã có MANAGER khác (bị chặn)

1. MANAGER → FE: đổi role của 1 member (hiện là CREATOR) sang MANAGER, trong khi workspace đã có 1 MANAGER active khác.
2. FE → BE: `PATCH .../{memberId}/role` `{role: MANAGER}`.
3. BE (`updateMemberRole`):
   a. Tìm member — tồn tại, active, role hiện tại = CREATOR.
   b. `member.role == MANAGER && newRole != MANAGER` → false → bỏ qua guard last-MANAGER.
   c. `newRole == MANAGER && member.role != MANAGER` → true → đếm `countByWorkspaceIdAndRoleAndIsActiveTrue(workspaceId, MANAGER)` — nếu `> 0` (đã có MANAGER active khác) → `409 MANAGER_ALREADY_ASSIGNED`. Không update.
4. BE → FE: `409 { error: MANAGER_ALREADY_ASSIGNED }`.

---

## Error paths tổng hợp

| Bước | Điều kiện lỗi | HTTP | ErrorCode |
|---|---|---|---|
| Update role | Không phải MANAGER của Workspace | 403 | `FORBIDDEN` |
| Update role | `memberId` không tồn tại/không active/không thuộc workspace | 404 | `NOT_FOUND` |
| Update role | Member là MANAGER duy nhất, role mới ≠ MANAGER | 409 | `LAST_OWNER_CANNOT_BE_REMOVED` |
| Update role | Role mới = MANAGER, workspace đã có MANAGER active khác | 409 | `MANAGER_ALREADY_ASSIGNED` |

## Ghi chú khác biệt so với spec.md gốc

- Không có — FR này đã chuyển từ Draft sang Implemented; spec.md và sequence-flow viết lại hoàn toàn khớp `WorkspaceController.updateMemberRole` / `WorkspaceServiceImpl.updateMemberRole`, dùng chung guard `assertNotLastManager` với FR 3.4.16 và 3.4.21, và dùng chung logic đếm MANAGER active với `inviteMember`/`assignMembersInternal`/`acceptInvitation` (đảm bảo tối đa 1 MANAGER active/workspace theo mọi code path).
