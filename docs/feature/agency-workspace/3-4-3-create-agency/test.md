# Test — Create Agency (FR 3.4.3)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). Cập nhật trạng thái Pass/Fail khi verify.

| Test case ID | Mô tả (input/điều kiện) | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | `createAgency_savesWithCurrentUserAsOwnerAndCreatesOwnerMember` — full request + token hợp lệ | AC1, AC2 | `201 Created`; `data.ownerId == currentUser.id`, `data.status == ACTIVE`; kèm `AgencyMember(OWNER)` được tạo | Happy path | Pass — **xác nhận 2026-09-21, test thật đã tồn tại trong `AgencyServiceImplTest`** |
| TC-02 | `createAgency_minimalRequest_leavesOptionalFieldsNull` — chỉ `{name}` | AC1 | `201`; `logoUrl`/`description` = null; vẫn tạo thành công | Happy path | Pass |
| TC-03 | `name` = `""` hoặc chỉ khoảng trắng | AC1, Error | `400 VALIDATION_ERROR` (do `@NotBlank`), không tạo bản ghi | Error case | Chưa xác nhận — không thấy method riêng cho blank-name trong `AgencyServiceImplTest` (có thể ở `AgencyControllerTest`, chưa đọc chi tiết trong lượt này) |
| TC-04 | Không kèm token / token hết hạn | (ngầm định từ role USER) | `401 UNAUTHORIZED`/`TOKEN_EXPIRED`, không tạo Agency | Error case | Chưa xác nhận — thuộc tầng filter chung, không nằm trong `AgencyServiceImplTest` |
| TC-05 | User đã sở hữu Agency khác, tạo thêm Agency mới | Edge case (spec mục 7) | `201`; tạo thêm Agency thứ 2 thành công (không giới hạn số lượng, `owner_id` không unique) | Edge case | Chưa xác nhận — không có method test riêng cho case "sở hữu 2+ agency", nhưng logic code không có gì chặn (không unique, không check count) |
| TC-06 | `createAgency_trimsSurroundingWhitespaceInName` — `name` có khoảng trắng 2 đầu | AC1 | `data.name` đã trim | Edge case | Pass |
| TC-07 | Kiểm tra `ownerId` không đổi sau khi tạo | AC2, DoD | `ownerId` giữ nguyên, không có API đổi owner trong phạm vi FR | Edge case | Pass — xác nhận qua đọc code, không có endpoint transfer-owner nào tồn tại |

## Ghi chú

- AC1 = "Form nhập name (bắt buộc), description, logo (optional)".
- AC2 = "Submit → tạo Agency với ownerId = currentUser.id".
- DoD = "Tạo Agency thành công, ownerId gắn đúng user hiện tại, không đổi được sau khi tạo".
