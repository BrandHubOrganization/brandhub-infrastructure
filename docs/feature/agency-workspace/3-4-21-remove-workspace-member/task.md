# Task — Remove Workspace Member (FR 3.4.21)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.removeMember(UUID workspaceId, UUID memberId)` — tìm member, filter workspaceId + isActive, soft-delete (`isActive=false`)
- [x] Guard last-MANAGER: `member.role == MANAGER` → `assertNotLastManager` → 409 `LAST_OWNER_CANNOT_BE_REMOVED`
- [x] `@RequireRole({MemberRole.MANAGER})` trên endpoint
- [x] 404 `NOT_FOUND` khi memberId không tồn tại/không active/không thuộc workspace
- [x] Không đụng `agency_members` (member vẫn còn trong Agency)
- [x] Endpoint đã có ở `WorkspaceController`: `DELETE /{workspaceId}/members/{memberId}`

## Frontend — `brandhub-web-dashboard`

- [ ] Nút Remove + confirm dialog trong bảng Members ở `/workspaces/:id/members`
- [ ] Gọi `DELETE /workspaces/{id}/members/{memberId}`
- [ ] Hiển thị lỗi 409 (xóa MANAGER cuối) rõ ràng cho user

## Verify

- [x] `mvn test` pass (happy path soft-delete, guard last-MANAGER, 404 NOT_FOUND)
- [ ] Test tay: xóa member CREATOR → thành công; xóa MANAGER duy nhất → bị chặn 409
