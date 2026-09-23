# Test — Remove Agency (FR 3.4.6)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Owner `DELETE /api/v1/agencies/{id}` | AC2 | 200; `status == SOFT_DELETED`, `deletedAt != null` | Happy path | Pass |
| TC-02 | User không phải Owner xóa | AC1, Error (mục 6) | 403 `NOT_AGENCY_OWNER`, không đổi data | Error case | Pass |
| TC-03 | Agency đã soft-delete → gọi list | AC2, Edge (mục 7) | KHÔNG còn xuất hiện trong list | Edge case | Pass |

| TC-04 | `restoreAgency_ownerWithinWindow_setsActiveAndClearsDeletedAt` | AC restore | 200; `status == ACTIVE`, `deletedAt == null` | Happy path | Pass — xác nhận 2026-09-21 |
| TC-05 | `restoreAgency_nonOwner_throwsNotAgencyOwner` | Error | 403 `NOT_AGENCY_OWNER` | Error case | Pass |
| TC-06 | `restoreAgency_notDeleted_throwsAgencyNotDeleted` | Edge | 400 `AGENCY_NOT_DELETED` khi agency đang ACTIVE, không phải SOFT_DELETED | Edge case | Pass |
| TC-07 | `restoreAgency_pastWindow_throwsRestoreWindowExpired` | Edge | 410 `RESTORE_WINDOW_EXPIRED` khi `deletedAt` quá 30 ngày | Edge case | Pass |
| TC-08 | Xóa Agency có Workspace con | AC cascade | Workspace con `status == SOFT_DELETED`, `deletedAt != null` | Happy path | Chưa test tự động |
| TC-09 | Restore Agency | AC cascade restore | Mọi Workspace con `status == ACTIVE`, `deletedAt == null` | Happy path | Chưa test tự động |
| TC-10 | Restore Agency khi 1 Workspace con đã bị xóa độc lập trước đó (FR 3.4.15) | Edge (xem spec "Cần xác nhận") | Workspace đó cũng bị set `ACTIVE` (hành vi hiện tại — "hồi sinh" ngoài ý muốn) | Edge case | Chưa test tự động |

## Ghi chú

- AC2 = "Set status = SOFT_DELETED, deletedAt = now". Restore đã code + test (TC-04..07).
- Cascade Workspace con đã code (2026-09-23): TC-08/TC-09 mô tả hành vi mong đợi, **chưa thấy test tự động riêng** trong repo — cần BE lead xác nhận đã có test hay chưa.
- Job xóa cứng tự động sau 30 ngày vẫn ngoài scope (chưa làm).
