# Test — View Workspace Profile (FR 3.4.13)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Active member (MANAGER/CREATOR/CLIENT) gọi `GET /api/v1/workspaces/{workspaceId}` | AC1 | 200; đầy đủ field `WorkspaceResponse`, kể cả `settings.timezone` | Happy path | Pass |
| TC-02 | `workspaceId` không tồn tại | Error (mục 6) | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-03 | User không phải active member của workspace này gọi xem | Error (mục 6) | 403 `WORKSPACE_ACCESS_DENIED` | Error case | Pass |
| TC-04 | `settings` JSON trong DB bị corrupt/parse lỗi | Plan mục 6 | 200; `settings.timezone`/`defaultPlatforms` fallback `null`, không lỗi 500 | Edge case | Pass |
| TC-05 | User đã leave workspace (inactive) gọi lại xem | AC3 | 403 `WORKSPACE_ACCESS_DENIED` (không còn active) | Edge case | Pass |

## Ghi chú

- AC3 = "Caller phải là active WorkspaceMember của chính workspace đang xem".
