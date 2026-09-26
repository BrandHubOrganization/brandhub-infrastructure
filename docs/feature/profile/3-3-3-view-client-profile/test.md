# Test — View Client Profile (FR 3.3.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /client-profile/me?agencyId=...` trả displayName, company, phone, note, agencyId | AC | 200; đủ field | Happy path | Pass |
| TC-02 | Chưa có hồ sơ cho `(userId, agencyId)` đó | AC | 404 `CLIENT_PROFILE_NOT_FOUND`, FE hiển thị empty state | Error case | Pass |
| TC-03 | `company`/`phone`/`note` null | Edge | 200; FE hiển thị "—" | Edge case | Pass |
| TC-04 | `getMyProfile_sameUserDifferentAgency_returnsDifferentProfiles` — cùng 1 user, 2 agencyId khác nhau | AC (đa-profile theo BA) | 2 profile độc lập, không lẫn dữ liệu | Edge case | Pass — **[MỚI 2026-09-21]**, xác nhận sửa gap kiến trúc thành công |
| TC-05 | Thiếu `agencyId` khi gọi API | Error | `400 VALIDATION_ERROR` (Spring `@RequestParam` bắt buộc, không có default) | Error case | Chưa test — cần test riêng ở `ClientProfileControllerTest` (chưa tồn tại file này) |

## Ghi chú

- AC = "Hiển thị displayName, company, phone, note; không hiển thị email (lấy từ User)".
- Unit test: `ClientProfileServiceImplTest.getMyProfile_returnsClientProfileFields`, `getMyProfile_notFound_throwsClientProfileNotFound`, `getMyProfile_sameUserDifferentAgency_returnsDifferentProfiles`.
