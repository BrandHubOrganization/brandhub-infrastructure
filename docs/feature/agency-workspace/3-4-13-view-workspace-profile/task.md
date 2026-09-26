# Task — View Workspace Profile (FR 3.4.13)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.getWorkspace(UUID, AuthenticatedUser)` — `findWorkspaceOrThrow` + `assertMember` + `toResponse`
- [x] Parse `settings` JSON an toàn (fallback khi lỗi, không throw)
- [x] 404 `WORKSPACE_NOT_FOUND`, 403 `WORKSPACE_ACCESS_DENIED`
- [x] `GET /api/v1/workspaces/{workspaceId}` đã có ở `WorkspaceController`

## Verify

- [x] `mvn test` pass (happy path, not-found, không phải member)
- [x] `settings` JSON lỗi → không throw, fallback `{timezone: null, defaultPlatforms: null}`
