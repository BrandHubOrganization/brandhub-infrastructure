# Test — Create Workspace (FR 3.4.12)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Agency member tạo Workspace, không kèm `assignMembers` | AC1, AC2 | 200; Workspace tạo thành công, người tạo là MANAGER duy nhất | Happy path | Pass |
| TC-02 | Tạo kèm `assignMembers` có 1 người khác role MANAGER | AC3 | 200; người tạo xuống CREATOR, người được chỉ định là MANAGER | Happy path | Pass |
| TC-03 | Tạo kèm `assignMembers` chọn chính mình làm MANAGER | Edge (mục 7) | 200; người tạo vẫn giữ MANAGER bình thường (không coi là "người khác") | Edge case | Pass |
| TC-04 | `name` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-05 | `agencyId` thiếu | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-06 | `assignMembers` có 2 người cùng role MANAGER | Error (mục 6) | 409 `MANAGER_ALREADY_ASSIGNED` | Error case | Pass |
| TC-07 | User không phải AgencyMember của `agencyId` gọi tạo | Sequence-flow error | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-08 | `assignMembers` có entry `userId` không phải AgencyMember của agency | Sequence-flow error | 403 `NOT_AGENCY_MEMBER` | Error case | Pass |
| TC-09 | `assignMembers` có entry `userId` không tồn tại trong `users` | Sequence-flow error | Lỗi `USER_NOT_FOUND` | Error case | Pass |

## Ghi chú

- TC-08, TC-09 lấy từ sequence-flow.md (2 nhánh lỗi chưa được liệt kê đầy đủ ở spec.md mục 6 — xem plan.md mục 6).
