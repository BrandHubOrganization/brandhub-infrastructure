# Test — Save Workspace Template (FR 3.4.17)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | User tạo Template với `name`, `configSnapshot`, không kèm `sourceWorkspaceId` | AC1 | 200; Template tạo thành công, `agencyId`/`createdBy` tự set | Happy path | Pass |
| TC-02 | User tạo Template kèm `sourceWorkspaceId` hợp lệ | AC1 | 200; Template lưu `sourceWorkspaceId` | Happy path | Pass |
| TC-03 | `name` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-04 | `configSnapshot` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | Pass |
| TC-05 | User xem danh sách Template | AC2 | 200; list đúng Template của Agency | Happy path | Pass |
| TC-06 | User xem chi tiết 1 Template theo `templateId` | AC2 | 200; trả đúng `WorkspaceTemplateResponse` | Happy path | Pass |
| TC-07 | Xem chi tiết `templateId` không tồn tại | Sequence-flow error | 404 `NOT_FOUND` | Error case | Pass |
| TC-08 | Xóa Template hợp lệ | AC2 | 200; Template bị xóa khỏi list | Happy path | Pass |
| TC-09 | Xóa `templateId` không tồn tại | Sequence-flow error | 404 `NOT_FOUND` | Error case | Pass |
| TC-10 | Workspace gốc (`sourceWorkspaceId`) bị xóa sau khi đã lưu Template | Edge (mục 7) | Template vẫn tồn tại độc lập, không lỗi | Edge case | Pass |

## Ghi chú

- Chưa có test case xác nhận phân quyền theo Agency/role vì `@RequireRole` chưa rõ ràng trên endpoint này (xem plan.md mục 6) — đề nghị bổ sung sau khi BE xác nhận.
