# Test — View Agency Profile (FR 3.4.4)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `GET /api/v1/agencies/{id}` với id hợp lệ | AC1 | 200; `data.name`/`logoUrl`/`description` đúng | Happy path | Pass |
| TC-02 | id không tồn tại | Error (mục 6) | 404 `AGENCY_NOT_FOUND` | Error case | Pass |

## Ghi chú

- AC1 = "Hiển thị name, logo, description". Portfolio/năm hoạt động ngoài scope, không test.
