# Test — Update Client Profile (FR 3.3.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). V2 (2026-10-02): mô hình `agency_id` (2026-09-21) đã bị revert.

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `createProfile_savesOwnedByUser` — tạo profile mới | AC | 200; `userId` = caller, không có `agencyId` | Happy path | Pass |
| TC-02 | `updateById_ownedProfile_updatesFields` — update profile đang sở hữu | AC | 200; cập nhật đủ field | Happy path | Pass |
| TC-03 | `company`/`phone`/`note` rỗng | Edge | 200; set null | Edge case | Pass |
| TC-04 | `displayName` rỗng | Error | 400 `@NotBlank` violation | Error case | Chưa xác nhận — không thấy method riêng trong `ClientProfileServiceImplTest` cho case này (validation ở tầng bean `@Valid`, chưa có ControllerTest) |
| TC-05 | `getById_notOwned_throwsClientProfileNotOwned` — update/xem profile của người khác | AC | 403 `CLIENT_PROFILE_NOT_OWNED` | Error case | Pass |
| TC-06 | `deleteById_notInUse_deletesProfile` / `deleteById_stillAttachedToActiveWorkspace_throwsInUse` | AC | Xoá được nếu không linked workspace active; 409 `CLIENT_PROFILE_IN_USE` nếu còn linked | Happy + error | Pass |
| TC-07 | Cùng 1 profile dùng ở nhiều workspace/agency, update 1 lần | AC (đa-agency theo BA) | Thay đổi phản ánh ở mọi nơi profile được linked, không có "bản sao theo agency" | Edge case | Pass (theo thiết kế — single record, không duplicate) |

## Ghi chú

- AC = "Cập nhật displayName, company, phone, note (và các field mở rộng: logoUrl/website/industry/location/description/socialLinks, cùng brand fields); không sửa email".
- Unit test: `ClientProfileServiceImplTest.createProfile_savesOwnedByUser`, `updateById_ownedProfile_updatesFields`, `getById_notOwned_throwsClientProfileNotOwned`, `deleteById_notInUse_deletesProfile`, `deleteById_stillAttachedToActiveWorkspace_throwsInUse`.
- TC-01/TC-05 cũ (upsert theo `(userId, agencyId)`) đã bị xoá cùng field `agencyId` — xem `3-3-3-view-client-profile/plan.md` §6.
