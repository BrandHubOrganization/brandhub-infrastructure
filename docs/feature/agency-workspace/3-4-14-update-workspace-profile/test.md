# Test — Update Workspace Profile (FR 3.4.14)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | MANAGER gửi `PATCH .../settings` đổi `name` + `timezone` | AC1 | 200; `WorkspaceResponse` cập nhật đúng, các field không gửi giữ nguyên | Happy path | Pass |
| TC-02 | MANAGER upload logo hợp lệ | Ghi chú mục 5 | 200; `logoUrl` cập nhật | Happy path | Pass |
| TC-03 | CREATOR/CLIENT gọi `PATCH .../settings` | Error (mục 6) | 403 `FORBIDDEN` | Error case | Pass |
| TC-04 | MANAGER gọi update trên `workspaceId` không tồn tại | Sequence-flow error | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-05 | Upload logo, đọc file lỗi (IOException) | Error (mục 6) | 400 `FILE_READ_ERROR` | Error case | Pass |
| TC-06 | Update chỉ `defaultPlatforms`, không gửi `timezone` | Route note | 200; `timezone` cũ giữ nguyên, `defaultPlatforms` cập nhật | Edge case | Pass |

## Ghi chú

- Route `/settings` tách biệt route xem chi tiết `GET /{workspaceId}` — chỉ MANAGER mới đổi được, khác View Workspace Profile (mọi role xem được).
