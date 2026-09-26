# Task — View Agency Profile (FR 3.4.4)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] Implement `AgencyServiceImpl.getAgency(UUID, AuthenticatedUser)` — `findAgencyOrThrow` → check OWNER/MEMBER → `toResponse`
- [x] `GET /api/v1/agencies/{agencyId}` đã có ở `AgencyController` (nay nhận `@AuthenticationPrincipal AuthenticatedUser`)
- [x] 404 `AGENCY_NOT_FOUND` khi id không tồn tại
- [x] 400 `NOT_AGENCY_MEMBER` khi user không phải OWNER và không có `AgencyMember` — dùng `agencyMemberRepository.findByAgencyIdAndUserId`

## Verify

- [x] `mvn test` pass
- [x] Agency tồn tại → trả đúng profile; id sai → 404; user ngoài Agency → 400 `NOT_AGENCY_MEMBER`
