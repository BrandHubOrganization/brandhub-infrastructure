# Task — Update Client Profile (FR 3.3.4)

> Checklist triển khai theo [plan.md](plan.md).

## Backend — `brandhub-business-service`

- [x] `ClientProfileRequest`: `{ displayName, company?, phone?, note?, logoUrl?, website?, industry?, location?, description?, socialLinks? }` — đủ 10 field, không chỉ 4 như dòng cũ ghi.
- [x] `ClientProfile` entity: có `userId`, drop email/brandName cũ — **[SỬA 2026-09-21]** thêm `agencyId`.
- [x] `ClientProfileRepository.findByUserIdAndAgencyId(UUID, UUID)` — đổi từ `findByUserId(UUID)`.
- [x] `ClientProfileServiceImpl.upsertMyProfile(currentUser, agencyId, request)` upsert theo `(userId, agencyId)`.

## Frontend — `brandhub-web-dashboard`

- [x] `clientProfileService.updateMyProfile(agencyId, data)` gọi `PUT /client-profile/me?agencyId=...` — thêm tham số bắt buộc.
- [x] Trang `/client-profile`: edit mode (đủ field), email read-only từ authStore, `agencyId` lấy từ URL query.

## Verify

- [x] `mvn test` pass (`ClientProfileServiceImplTest.upsertMyProfile_*`, cộng test case đa-agency mới)
- [x] `tsc --noEmit` pass
- [ ] Chạy migration SQL thêm cột `agency_id` trước khi deploy (bảng chưa có data thật, `ALTER TABLE ADD COLUMN agency_id UUID` — cần viết migration file thật nếu dùng Flyway/Liquibase, chưa xác nhận repo dùng công cụ nào).
