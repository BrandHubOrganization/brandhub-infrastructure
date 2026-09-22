# Task — Update Agency Profile (FR 3.4.5)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.updateAgency(UUID, AuthenticatedUser, AgencyRequest)` — owner-check → set field → save
- [x] 403 `NOT_AGENCY_OWNER` khi user không phải Owner
- [x] `@Valid` trên body → 400 `VALIDATION_ERROR` khi `name` trống
- [x] `PUT /api/v1/agencies/{agencyId}` đã có ở `AgencyController`

## Verify

- [x] `mvn test` pass
- [x] Chỉ Owner sửa được; non-owner → 403
