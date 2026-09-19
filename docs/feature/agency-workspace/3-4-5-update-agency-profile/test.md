# Test — Update Agency Profile (FR 3.4.5)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner gửi `{name:"New Name", description:"...", logoUrl:"..."}` | AC1, AC2 | 200; `data.name == "New Name"` | Happy path | Pass |
| TC-02 | User không phải Owner gửi update | AC2, Error (mục 6) | 403 `NOT_AGENCY_OWNER`, không đổi data | Error case | Pass |
| TC-03 | `name` = `""` hoặc khoảng trắng | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-04 | `name` có khoảng trắng 2 đầu | AC1 | `data.name` đã trim | Edge case | Pass |

## Ghi chú

- AC1 = "Form sửa name, description, logoUrl". AC2 = "Chỉ Owner được sửa".
