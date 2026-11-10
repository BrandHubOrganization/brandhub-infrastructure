# Task — Update Client Profile (FR 3.3.4)

> Checklist triển khai theo [plan.md](plan.md). V2 (2026-10-02): mô hình `agency_id` (2026-09-21) đã bị revert.

## Backend — `brandhub-business-service`

- [x] `ClientProfileRequest`: đủ 19 field (bao gồm brand fields bổ sung 2026-09-27), không có `email`, không có `agencyId`.
- [x] `ClientProfile` entity: có `userId`, không có `agencyId` (cột đã bị xoá, migration `2026-10-02-drop-client-profile-agency-id.sql`).
- [x] `ClientProfileRepository.findByUserId(UUID)` — không có `findByUserIdAndAgencyId`.
- [x] `ClientProfileServiceImpl.createProfile(currentUser, request)` / `updateById(currentUser, profileId, request)` / `deleteById(currentUser, profileId)` — tách biệt create/update/delete, không còn upsert theo agency.
- [x] `findOwnedProfileOrThrow` — check `userId` khớp caller, 403 `CLIENT_PROFILE_NOT_OWNED` nếu không.
- [x] Delete chặn bởi `CLIENT_PROFILE_IN_USE` nếu còn `workspace_members` active liên kết.

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.create(data)` / `updateById(profileId, data)` / `deleteById(profileId)` — không có tham số `agencyId`.
- [x] Trang `/client-profiles`: list + form create/edit, email read-only từ authStore, không có agency selector.

## Verify

- [x] `mvn -q -o clean compile` pass sau khi xoá `agencyId`.
- [x] `ClientProfileServiceImplTest` cập nhật: `createProfile_savesOwnedByUser`, `updateById_ownedProfile_updatesFields`, `deleteById_notInUse_deletesProfile`, `deleteById_stillAttachedToActiveWorkspace_throwsInUse`.
- [x] `tsc --noEmit` pass.
- [x] Migration `2026-10-02-drop-client-profile-agency-id.sql` đã apply lên DB local — xác nhận `client_profiles` không còn cột `agency_id`.
