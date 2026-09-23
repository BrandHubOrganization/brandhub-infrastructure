# Test — View Agency Profile (FR 3.4.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /api/v1/agencies/{id}` với id hợp lệ, user là OWNER | AC1 | 200; `data.name`/`logoUrl`/`description` đúng | Happy path | Pass |
| TC-02 | id không tồn tại | Error (mục 6) | 404 `AGENCY_NOT_FOUND` | Error case | Pass |
| TC-03 | User đã đăng nhập nhưng **không phải OWNER và không phải MEMBER** của Agency | Error (mục 6) | 400 `NOT_AGENCY_MEMBER` | Error case | Pass |
| TC-04 | User là MEMBER (`AgencyMember`) của Agency | AC quyền xem | 200; xem được profile dù không phải owner | Happy path | Pass |
| TC-05 | Không gửi token / token hết hạn | Error (mục 6) | 401 `UNAUTHORIZED` (chặn ở `JwtAuthenticationFilter`) | Error case | Pass |

## Ghi chú

- AC1 = "Hiển thị name, logo, description". Portfolio/năm hoạt động ngoài scope, không test.
- Quyền xem đã siết lại (2026-09-23): trước đây endpoint không check gì, nay chỉ OWNER/MEMBER (`NOT_AGENCY_MEMBER` nếu ngoài Agency).
