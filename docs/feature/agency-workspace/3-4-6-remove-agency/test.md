# Test — Remove Agency (FR 3.4.6)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner `DELETE /api/v1/agencies/{id}` | AC2 | 200; `status == SOFT_DELETED`, `deletedAt != null` | Happy path | Pass |
| TC-02 | User không phải Owner xóa | AC1, Error (mục 6) | 403 `NOT_AGENCY_OWNER`, không đổi data | Error case | Pass |
| TC-03 | Agency đã soft-delete → gọi list | AC2, Edge (mục 7) | KHÔNG còn xuất hiện trong list | Edge case | Pass |

## Ghi chú

- AC2 = "Set status = SOFT_DELETED, deletedAt = now". Restore/job xóa cứng ngoài scope (chưa test).
