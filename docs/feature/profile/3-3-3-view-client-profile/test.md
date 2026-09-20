# Test — View Client Profile (FR 3.3.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /client-profile/me` trả displayName, company, phone, note | AC | 200; đủ field | Happy path | Pass |
| TC-02 | Chưa có hồ sơ | AC | 404 `CLIENT_PROFILE_NOT_FOUND`, FE hiển thị empty state | Error case | Pass |
| TC-03 | `company`/`phone`/`note` null | Edge | 200; FE hiển thị "—" | Edge case | Pass |

## Ghi chú

- AC = "Hiển thị displayName, company, phone, note; không hiển thị email (lấy từ User)".
- Unit test: `ClientProfileServiceImplTest.getMyProfile_returnsFields`, `getMyProfile_throwsWhenNotFound`.
