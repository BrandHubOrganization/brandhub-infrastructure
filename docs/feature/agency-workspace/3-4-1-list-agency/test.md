# Test — List Agency (FR 3.4.1)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | User sở hữu 2 Agency → gọi `GET /api/v1/agencies` | AC1 | 200; list đủ 2 Agency, `ownerId == currentUser.id` | Happy path | Pass |
| TC-02 | User là Member của 1 Agency (không Owner) → gọi list | AC1, Edge (mục 7) | Agency đó xuất hiện trong list | Happy path | Pass |
| TC-03 | User mới, chưa có Agency nào | AC4 (empty state) | 200; list rỗng, không lỗi | Edge case | Pass |
| TC-04 | 1 Agency đã `SOFT_DELETED`, user vẫn là member | DoD | Agency đó KHÔNG xuất hiện | Edge case | Pass |
| TC-05 | User vừa Owner vừa Member của cùng 1 Agency | DoD | Agency chỉ xuất hiện 1 lần (không duplicate) | Edge case | Pass |

## Ghi chú

- AC1 = "List tất cả Agency có ownerId = current user".
- DoD = "List đúng chỉ các Agency user là Owner". Code hiện trả cả Agency user làm Member — ghi nhận lệch spec (xem plan.md mục 6), cần BA confirm.
