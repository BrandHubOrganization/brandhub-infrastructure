# Task — View Agency Profile (FR 3.4.4)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.getAgency(UUID)` — `findAgencyOrThrow` → `toResponse`
- [x] `GET /api/v1/agencies/{agencyId}` đã có ở `AgencyController`
- [x] 404 `AGENCY_NOT_FOUND` khi id không tồn tại

## Verify

- [x] `mvn test` pass
- [x] Agency tồn tại → trả đúng profile; id sai → 404
