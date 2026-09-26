# Task — Create Workspace (FR 3.4.12)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `WorkspaceServiceImpl.createWorkspace(AuthenticatedUser, WorkspaceRequest)` — owner-check AgencyMember → insert workspace + member
- [x] Xử lý chuyển giao MANAGER khi `assignMembers` có người khác role MANAGER (`anotherManagerChosen`)
- [x] `assignMembersInternal` xử lý từng entry `assignMembers` (check AgencyMember, check trùng MANAGER, idempotent nếu đã active)
- [x] 403 `NOT_AGENCY_OWNER`, 403 `NOT_AGENCY_MEMBER`, 409 `MANAGER_ALREADY_ASSIGNED`, `USER_NOT_FOUND`
- [x] `POST /api/v1/workspaces` đã có ở `WorkspaceController`

## Verify

- [x] `mvn test` pass (happy path không assignMembers, happy path có chuyển giao MANAGER, non-agency-member, MANAGER trùng)
- [x] `name`/`agencyId` validation qua `@Valid` → 400 `VALIDATION_ERROR`
