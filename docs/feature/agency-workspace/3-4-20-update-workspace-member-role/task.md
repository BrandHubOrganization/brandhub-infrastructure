# Task — Update Workspace Member Role (FR 3.4.20)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.updateMemberRole(UUID workspaceId, UUID memberId, MemberRole newRole)` — tìm member, filter workspaceId + isActive, set role, save
- [x] Guard giảm quyền: `member.role == MANAGER && newRole != MANAGER` → `assertNotLastManager` → 409 `LAST_OWNER_CANNOT_BE_REMOVED`
- [x] Guard thăng quyền: `newRole == MANAGER && member.role != MANAGER` → đếm active MANAGER >0 → 409 `MANAGER_ALREADY_ASSIGNED`
- [x] `@RequireRole({MemberRole.MANAGER})` trên endpoint
- [x] 404 `NOT_FOUND` khi memberId không tồn tại/không active/không thuộc workspace
- [x] Endpoint đã có ở `WorkspaceController`: `PATCH /{workspaceId}/members/{memberId}/role`
- [x] DTO `UpdateMemberRoleRequest { role: MemberRole }` (field `@NotNull`)

## Frontend — `brandhub-web-dashboard` (xác nhận 2026-09-23: ĐÃ CÓ)

- [x] Dropdown đổi role trong bảng Members ở `/workspaces/:id/members` — `src/pages/workspace/components/MembersTable.tsx` dùng `Select` với `WORKSPACE_ROLES = ["MANAGER", "CREATOR", "CLIENT"]` (không có OWNER/không cho tự hạ role qua dropdown)
- [x] Gọi `workspaceService.updateMemberRole(workspaceId, memberId, role)` → `PATCH /workspaces/{id}/members/{memberId}/role` (`src/services/workspaceService.ts`; hook `useWorkspaceMembers.updateMemberRole`)
- [x] Hiển thị kết quả cho user: toast `roleUpdateSuccess`/lỗi từ API (409 mất MANAGER cuối / trùng MANAGER) — i18n `roleUpdateSuccess` (en + vi)
- [x] i18n key `roleUpdateSuccess` trong `src/i18n/locales/{en,vi}/workspace.json`

## Verify

- [x] `mvn test` pass (happy path đổi role, 2 guard, 404 NOT_FOUND)
- [ ] Test tay: đổi role MANAGER duy nhất xuống CREATOR → bị chặn 409; thăng role khi đã có MANAGER → 409
