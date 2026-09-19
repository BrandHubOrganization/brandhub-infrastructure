# Task — Remove Agency (FR 3.4.6)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.removeAgency(UUID, AuthenticatedUser)` — owner-check → soft-delete
- [x] 403 `NOT_AGENCY_OWNER` khi non-owner
- [x] `DELETE /api/v1/agencies/{agencyId}` đã có ở `AgencyController`
- [ ] TODO: `POST /{id}/restore` + cascade Workspace (chờ DA-E16-10)

## Verify

- [x] `mvn test` pass
- [x] Sau delete, `status == SOFT_DELETED`; list không trả Agency đó nữa
