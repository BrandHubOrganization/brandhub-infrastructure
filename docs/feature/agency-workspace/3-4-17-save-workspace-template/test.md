# Test — Save Workspace Template (FR 3.4.17)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md). ⚠ **Cột "Trạng thái" dưới đây trước ghi "Pass" cho toàn bộ — sai so với code thật.** `WorkspaceTemplateServiceImpl` hiện là stub (mọi method throw `UnsupportedOperationException`), nên không test case nào ở đây có thể thực sự pass cho tới khi backend được implement. Giữ nguyên mô tả test case (vẫn đúng là các case cần cover), chỉ sửa lại cột kết quả thật.

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | User tạo Template với `name`, `configSnapshot`, không kèm `sourceWorkspaceId` | AC1 | 200; Template tạo thành công, `agencyId`/`createdBy` tự set | Happy path | **Blocked — backend stub** |
| TC-02 | User tạo Template kèm `sourceWorkspaceId` hợp lệ | AC1 | 200; Template lưu `sourceWorkspaceId` | Happy path | **Blocked — backend stub** |
| TC-03 | `name` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | **Blocked — backend stub** |
| TC-04 | `configSnapshot` trống | Error (mục 6) | 400 `VALIDATION_ERROR` | Error case | **Blocked — backend stub** |
| TC-05 | User xem danh sách Template | AC2 | 200; list đúng Template của Agency | Happy path | **Blocked — backend stub** |
| TC-06 | User xem chi tiết 1 Template theo `templateId` | AC2 | 200; trả đúng `WorkspaceTemplateResponse` | Happy path | **Blocked — backend stub; cũng không có FE detail route (xem spec.md)** |
| TC-07 | Xem chi tiết `templateId` không tồn tại | Sequence-flow error | 404 `NOT_FOUND` | Error case | **Blocked — backend stub** |
| TC-08 | Xóa Template hợp lệ | AC2 | 200; Template bị xóa khỏi list | Happy path | **Blocked — backend stub** |
| TC-09 | Xóa `templateId` không tồn tại | Sequence-flow error | 404 `NOT_FOUND` | Error case | **Blocked — backend stub** |
| TC-10 | Workspace gốc (`sourceWorkspaceId`) bị xóa sau khi đã lưu Template | Edge (mục 7) | Template vẫn tồn tại độc lập, không lỗi | Edge case | **Blocked — backend stub** |

## Ghi chú

- Chưa có test case xác nhận phân quyền theo Agency/role vì `@RequireRole` chưa rõ ràng trên endpoint này (xem plan.md mục 6) — đề nghị bổ sung sau khi BE xác nhận.
- ⚠ Toàn bộ test case trên đang **Blocked**: `WorkspaceTemplateServiceImpl` là stub (`UnsupportedOperationException`), không method nào chạy được logic thật. Trạng thái "Pass" trước đó trong tài liệu là sai so với code — đã sửa lại theo lần đọc code này.
