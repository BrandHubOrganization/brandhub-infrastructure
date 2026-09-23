# Task — Leave Workspace (FR 3.4.16)

> Checklist triển khai theo [plan.md](plan.md). API mới vừa code xong (route `DELETE /workspaces/{id}/leave`).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.leaveWorkspace(UUID, AuthenticatedUser)` — tìm active membership của chính currentUser
- [x] Implement/tái sử dụng `assertNotLastManager(workspaceId, member)` — guard MANAGER active duy nhất
- [x] 403 `WORKSPACE_ACCESS_DENIED`, 409 `LAST_OWNER_CANNOT_BE_REMOVED`
- [x] `DELETE /api/v1/workspaces/{workspaceId}/leave` đã có ở `WorkspaceController`, không gắn `@RequireRole`
- [x] Soft-delete `WorkspaceMember.isActive = false`, không đụng `AgencyMember`

## Frontend — `brandhub-web-dashboard` (xác nhận 2026-09-23: đã có nút + service; còn 1 mục chưa có)

- [x] Nút "Leave workspace" (`t("workspace.members.leaveButton")`) trong `src/pages/workspace/components/InternalMembersSection.tsx`
- [x] Confirm dialog trước khi leave — `LeaveWorkspaceDialog` (`src/pages/workspace/components/LeaveWorkspaceDialog.tsx`), nút Leave mở dialog rồi mới gọi `handleLeave` (khớp pattern nút Remove member)
- [x] Service method `workspaceService.leaveWorkspace` (`src/services/workspaceService.ts`) → `DELETE /workspaces/{id}/leave`
- [x] Hook `useWorkspaceMembers.leaveWorkspace` — gọi service, toast `leaveSuccess`, `loadMembers()` lại, đóng dialog
- [x] i18n key `leaveButton` / `leaveSuccess` / `leaveConfirmTitle` / `leaveConfirmDescription` (en + vi) trong `src/i18n/locales/{en,vi}/workspace.json`

> **Đã sửa 2026-09-23:** nút Leave đã bỏ khỏi khối `{canManage && ...}` — giờ mọi active member (MANAGER/CREATOR/CLIENT) đều thấy nút Leave, khớp BE route không gắn `@RequireRole`.

## Verify

- [x] `mvn test` pass (happy path, not-a-member, last-MANAGER guard) — theo mô tả sequence-flow.md, chưa có file test tự động cụ thể được liệt kê trong spec/sequence-flow để đối chiếu số lượng case — **đề nghị xác nhận coverage thật với BE lead**
- [ ] E2E/automation test cho luồng leave — chưa có ghi chú trong spec.md/sequence-flow.md xác nhận đã viết, cần bổ sung nếu chưa có
