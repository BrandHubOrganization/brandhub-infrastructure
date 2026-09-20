# Task — View Client Profile (FR 3.3.3)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `ClientProfileResponse`: `{ id, userId, displayName, company, phone, note, createdAt, updatedAt }`
- [x] `ClientProfileServiceImpl.getMyProfile()` trả về profile theo `userId`
- [x] `GET /api/v1/client-profile/me` đã có ở `ClientProfileController`

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.getMyProfile()` fetch profile thật
- [x] Trang `/client-profile`: view mode + empty state `notFound`

## Verify

- [x] `mvn test` pass (`ClientProfileServiceImplTest.getMyProfile_*`)
- [x] `tsc --noEmit` pass
