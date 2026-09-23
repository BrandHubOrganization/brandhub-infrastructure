# Test — Remove Member (FR 3.4.9)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner `DELETE /{agencyId}/members/{memberId}` (member thường) | AC1, AC2 | 200; member bị xóa khỏi `agency_members` | Happy path | Pass |
| TC-02 | Cố xóa chính Owner | Error (mục 6) | 409 `CANNOT_REMOVE_OWNER`, owner giữ nguyên | Error case | Pass |
| TC-03 | User không phải Owner xóa member | Error (mục 6) | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-04 | `memberId` không thuộc Agency đó | Edge | 404 `NOT_FOUND` | Edge case | Pass |
| TC-05 | Tài nguyên member tạo (Task/Material) | AC3 | Vẫn còn nguyên (không cascade delete) | Edge case | Pass |

## Ghi chú

- AC2 = "Xóa AgencyMember record — mất quyền truy cập ngay".
- AC3 = "Tài nguyên KHÔNG bị xóa" — cover bằng TC-05 (không có cascade). Auto-unassign Task ngoài scope (spec mục 7).
