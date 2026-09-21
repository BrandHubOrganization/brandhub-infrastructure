# Task — View Client Profile (FR 3.3.3)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `ClientProfileResponse`: `{ id, userId, agencyId, displayName, company, phone, note, ..., createdAt, updatedAt }` — **[SỬA 2026-09-21]** thêm `agencyId`.
- [x] `ClientProfileServiceImpl.getMyProfile(currentUser, agencyId)` trả về profile theo `(userId, agencyId)` — đổi từ theo `userId` số ít.
- [x] `GET /api/v1/client-profile/me?agencyId=...` — `agencyId` bắt buộc (`@RequestParam UUID agencyId`).
- [x] `ClientProfile.java` entity thêm cột `agency_id`; `ClientProfileRepository.findByUserIdAndAgencyId()` thay `findByUserId()`.

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.getMyProfile(agencyId)` — thêm tham số bắt buộc.
- [x] Trang `/client-profile`: lấy `agencyId` từ URL query (`useSearchParams`) — view mode + empty state `notFound` + state mới `missingAgencyId` khi thiếu param.
- [x] i18n key `clientProfile.missingAgencyId` (vi/en).
- [ ] **Chưa có nơi nào trong FE dẫn tới `/client-profile?agencyId=...` với agencyId thật** — route hiện là orphan, chưa gắn vào flow điều hướng thật nào (ví dụ từ Workspace member list khi click vào 1 Client). Cần task riêng để nối route.

## Verify

- [x] `mvn test` pass (`ClientProfileServiceImplTest` — bao gồm test case mới `getMyProfile_sameUserDifferentAgency_returnsDifferentProfiles`)
- [x] `tsc --noEmit` pass
