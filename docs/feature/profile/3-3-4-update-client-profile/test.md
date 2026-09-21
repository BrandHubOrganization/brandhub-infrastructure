# Test — Update Client Profile (FR 3.3.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `upsertMyProfile_createsWhenMissing` — chưa có hồ sơ cho `(userId, agencyId)` | AC | 200; tạo mới với userId + agencyId hiện tại | Happy path | Pass |
| TC-02 | `upsertMyProfile_updatesExisting` — đã có hồ sơ | AC | 200; cập nhật đủ field | Happy path | Pass |
| TC-03 | `company`/`phone`/`note` rỗng | Edge | 200; set null | Edge case | Pass |
| TC-04 | `displayName` rỗng | Error | 400 `@NotBlank` violation | Error case | Chưa xác nhận — không thấy method riêng trong `ClientProfileServiceImplTest` cho case này (validation ở tầng bean `@Valid`, chưa có ControllerTest) |
| TC-05 | Cùng user, update profile ở agencyA rồi update profile ở agencyB — không ghi đè lẫn nhau | AC (đa-profile theo BA) | 2 bản ghi độc lập trong DB | Edge case | Pass — cover bởi `getMyProfile_sameUserDifferentAgency_returnsDifferentProfiles` ở `3-3-3` |

## Ghi chú

- AC = "Cập nhật displayName, company, phone, note (và các field mở rộng: logoUrl/website/industry/location/description/socialLinks); không sửa email".
- Unit test: `ClientProfileServiceImplTest.upsertMyProfile_createsWhenMissing`, `upsertMyProfile_updatesExisting`.
- **[SỬA 2026-09-21]** Gap đa-profile-theo-Agency đã sửa — xem `3-3-3-view-client-profile/plan.md` mục 3.
