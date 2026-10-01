# Test — View Client Profile (FR 3.3.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). V2 (2026-10-02): mô hình `agency_id` (2026-09-21) đã bị revert.

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /client-profile/mine` trả toàn bộ profile của caller | AC | 200; list đầy đủ field, không có `agencyId` | Happy path | Pass |
| TC-02 | Chưa có profile nào | AC | 200; list rỗng (không phải 404) | Edge case | Pass |
| TC-03 | `company`/`phone`/`note` null | Edge | 200; FE hiển thị "—" | Edge case | Pass |
| TC-04 | `listMine_returnsAllProfilesForUser` — 1 user có nhiều profile (Nike, Adidas) | AC (đa-profile theo BA) | Trả đủ cả 2, không lẫn dữ liệu | Edge case | Pass |
| TC-05 | Cùng 1 profile dùng ở workspace của 2 agency khác nhau | AC (đa-agency theo BA) | Browser-verified: gắn thành công cả 2 nơi, không bị `CLIENT_PROFILE_NOT_IN_AGENCY` | Edge case | Pass (2026-10-01) |

## Ghi chú

- AC = "Hiển thị displayName, company, phone, note; không hiển thị email (lấy từ User)".
- Unit test: `ClientProfileServiceImplTest.listMine_returnsAllProfilesForUser`.
- TC-04/TC-05 cũ (test theo mô hình `(userId, agencyId)`) đã bị xoá cùng field `agencyId` — xem `3-3-3-view-client-profile/plan.md` §6.
