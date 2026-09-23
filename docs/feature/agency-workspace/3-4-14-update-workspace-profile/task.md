# Task — Update Workspace Profile (FR 3.4.14)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.updateSettings(UUID, AuthenticatedUser, UpdateWorkspaceSettingsRequest)` — partial update, merge `settings` JSON
- [x] Implement `WorkspaceServiceImpl.updateLogo(UUID, AuthenticatedUser, MultipartFile)` — upload storage, set `logoUrl`
- [x] `@RequireRole({MemberRole.MANAGER})` trên cả 2 endpoint
- [x] 403 `FORBIDDEN`, 404 `WORKSPACE_NOT_FOUND`, 400 `FILE_READ_ERROR`
- [x] `PATCH /{workspaceId}/settings`, `POST /{workspaceId}/logo` đã có ở `WorkspaceController`

## Verify

- [x] `mvn test` pass (happy path settings, happy path logo, non-manager, not-found, IOException logo)
- [x] Partial update: field không gửi giữ nguyên giá trị cũ
