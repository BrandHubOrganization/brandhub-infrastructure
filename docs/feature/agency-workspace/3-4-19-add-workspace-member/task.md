# Task — Add Workspace Member (FR 3.4.19)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.inviteMember(UUID, AuthenticatedUser, InviteWorkspaceMemberRequest)` — check duplicate, check pending, check MANAGER trùng, insert invitation, gửi mail
- [x] Implement `WorkspaceServiceImpl.assignMembers(UUID, AuthenticatedUser, AssignMembersRequest)` → `assignMembersInternal` — check AgencyMember, skip nếu đã active, check MANAGER trùng, insert
- [x] Implement `WorkspaceServiceImpl.acceptInvitation(AcceptInvitationRequest)` — validate token/status/expiry/email, insert WorkspaceMember
- [x] `@RequireRole({MemberRole.MANAGER})` trên invite/assign
- [x] 403 `FORBIDDEN`, 409 `ALREADY_IN_WORKSPACE`, 409 `INVITATION_ALREADY_PENDING`, 409 `MANAGER_ALREADY_ASSIGNED`, 403 `NOT_AGENCY_MEMBER`, `USER_NOT_FOUND`, 400 `VALIDATION_ERROR`
- [x] Endpoint đã có ở `WorkspaceController`: `POST /{workspaceId}/members/invite`, `POST /{workspaceId}/members/assign`, `POST /invitations/accept`

## Verify

- [x] `mvn test` pass (invite happy path, assign happy path, accept happy path, tất cả error case ở test.md)
- [x] `AssignMembersResponse.skippedUserIds` liệt kê đúng, không im lặng bỏ qua
