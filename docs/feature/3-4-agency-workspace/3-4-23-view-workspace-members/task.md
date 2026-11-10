# Task — View Workspace Members (FR 3.4.18)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.listMembers(UUID, AuthenticatedUser)` — `findWorkspaceOrThrow` + `assertMember` + batch load User/ClientProfile
- [x] Map `WorkspaceMember` → `WorkspaceMemberResponse` (2 nguồn `fullName`: User hoặc ClientProfile)
- [x] 404 `WORKSPACE_NOT_FOUND`, 403 `WORKSPACE_ACCESS_DENIED`
- [x] `GET /api/v1/workspaces/{workspaceId}/members` đã có ở `WorkspaceController`

## Verify

- [x] `mvn test` pass (happy path đủ member userId + clientProfileId, not-found, không phải member)
- [x] Batch `findAllById` không lỗi khi danh sách `userId`/`clientProfileId` rỗng
