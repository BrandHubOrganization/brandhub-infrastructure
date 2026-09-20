# Task — Update Client Profile (FR 3.3.4)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `ClientProfileRequest`: `{ displayName, company?, phone?, note? }` (bỏ email/brandName/industry/logoUrl)
- [x] `ClientProfile` entity: `linkedUserId` → `userId`, drop email/brandName/industry/logoUrl
- [x] `ClientProfileRepository.findByUserId(UUID)`
- [x] `ClientProfileServiceImpl.upsertMyProfile()` upsert theo `userId`

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.updateMyProfile()` gọi `PUT /client-profile/me`
- [x] Trang `/client-profile`: edit mode (displayName/company/phone/note), email read-only từ authStore

## Verify

- [x] `mvn test` pass (`ClientProfileServiceImplTest.upsertMyProfile_*`)
- [x] `tsc --noEmit` pass
- [ ] Chạy migration SQL (xem plan.md) trước khi deploy
