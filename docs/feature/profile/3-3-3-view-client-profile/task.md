# Task — View Client Profile (FR 3.3.3)

> Checklist triển khai theo [plan.md](plan.md). V2 (2026-10-02): mô hình `agency_id` (2026-09-21) đã bị revert — xem plan.md §6.

## Backend — `brandhub-business-service`

- [x] `ClientProfileResponse`: `{ id, userId, displayName, company, phone, note, ..., createdAt, updatedAt }` — không còn `agencyId`.
- [x] `ClientProfileServiceImpl.listMine(currentUser)` trả toàn bộ profile theo `userId`, không filter agency.
- [x] `GET /api/v1/client-profile/mine` — không còn tham số `agencyId`.
- [x] `ClientProfile.java` entity: cột `agency_id` đã bị xoá (migration `2026-10-02-drop-client-profile-agency-id.sql`); `ClientProfileRepository.findByUserId()` là query chính.
- [x] Xoá method/endpoint legacy: `getMyProfile(agencyId)`, `upsertMyProfile(agencyId, ...)`, `listByAgency(agencyId)`, repository method `findByUserIdAndAgencyId`/`findByAgencyId`.

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.listMine()` — không còn tham số `agencyId`.
- [x] Trang `/client-profiles`: list toàn bộ profile của user, không phụ thuộc URL query `agencyId`.
- [x] Xoá i18n key `clientProfile.missingAgencyId` (không còn khái niệm agency bắt buộc).
- [x] Workspace Client list (`/workspaces/:id/clients`, mới) — tách khỏi trang Thành viên, lấy data qua `workspaceService.listMembers()` filter role CLIENT.

## Verify

- [x] `mvn -q -o clean compile` pass sau khi xoá `agencyId`.
- [x] `ClientProfileServiceImplTest` cập nhật — xoá test case legacy `getMyProfile_sameUserDifferentAgency_returnsDifferentProfiles` (phản ánh đúng mô hình sai cũ), thêm `createProfile_savesOwnedByUser`.
- [x] `tsc --noEmit` pass.
- [x] Browser-verified: tạo 2 ClientProfile (vd "Nike", "Adidas") cho cùng 1 user, gắn mỗi profile vào workspace của agency khác nhau — xác nhận dùng chung được, không bị chặn `CLIENT_PROFILE_NOT_IN_AGENCY` (lỗi này đã bị xoá khỏi codebase).
