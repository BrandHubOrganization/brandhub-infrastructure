# Test — Create Agency (FR 3.4.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). Cập nhật trạng thái Pass/Fail khi verify.

| Test case ID | Mô tả (input/điều kiện) | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Gửi `POST /api/v1/agencies` với `{name:"Star Media", logoUrl:"https://...", description:"..."}` + token user hợp lệ | AC1, AC2 | `201 Created`; `data.id` là UUID, `data.ownerId == currentUser.id`, `data.status == ACTIVE`, `data.name == "Star Media"` | Happy path | Chưa test |
| TC-02 | Gửi chỉ `{name:"Agency A"}` (không logo/description) | AC1 | `201`; `logoUrl`/`description` = null; vẫn tạo thành công | Happy path | Chưa test |
| TC-03 | `name` = `""` hoặc chỉ khoảng trắng | AC1, Error | `400` `VALIDATION_ERROR` (do `@NotBlank`), không tạo bản ghi | Error case | Chưa test |
| TC-04 | Không kèm token / token hết hạn | (ngầm định từ role USER) | `401` `UNAUTHORIZED` / `TOKEN_EXPIRED`, không tạo Agency | Error case | Chưa test |
| TC-05 | User đã sở hữu Agency khác, tạo thêm Agency mới | Edge case (spec mục 7) | `201`; tạo thêm Agency thứ 2 thành công (không giới hạn số lượng, `owner_id` không unique) | Edge case | Chưa test |
| TC-06 | `name` có khoảng trắng 2 đầu, vd `"  Agency X  "` | AC1 | `data.name == "Agency X"` (đã trim) | Edge case | Chưa test |
| TC-07 | Kiểm tra `ownerId` không đổi sau khi tạo (gọi `getAgency` / DB) | AC2, DoD | `ownerId` giữ nguyên, không có API đổi owner trong phạm vi FR | Edge case | Chưa test |

## Ghi chú

- AC1 = "Form nhập name (bắt buộc), description, logo (optional)".
- AC2 = "Submit → tạo Agency với ownerId = currentUser.id".
- DoD = "Tạo Agency thành công, ownerId gắn đúng user hiện tại, không đổi được sau khi tạo".
