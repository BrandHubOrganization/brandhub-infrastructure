# Test — List Workspace (FR 3.4.10)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | User là member (bất kỳ role) của 3 Workspace → gọi `GET /api/v1/workspaces` | AC1 | 200; list đủ 3 Workspace | Happy path | Pass |
| TC-02 | User chưa tham gia Workspace nào → gọi list | Edge (mục 7) | 200; list rỗng, không lỗi | Edge case | Pass |
| TC-03 | User là MANAGER của 2 Workspace, CREATOR của 1 Workspace → gọi `GET /api/v1/workspaces/my-managed` | Ghi chú mục 5 | 200; chỉ trả 2 Workspace user là MANAGER, kèm `role`, `memberCount` đúng | Happy path | Pass |
| TC-04 | Workspace có 5 member active, 2 inactive → `my-managed` cho Workspace đó | Ghi chú mục 5 | `memberCount = 5` (chỉ đếm active) | Edge case | Pass |
| TC-05 | Chưa đăng nhập gọi `GET /api/v1/workspaces` | Error (mục 6) | 401 | Error case | Pass |

## Ghi chú

- AC1 = "Trả về toàn bộ Workspace mà current user có WorkspaceMember record (không phân biệt role)".
- Không có ErrorCode nghiệp vụ riêng ở tầng WorkspaceService cho 2 flow này (chỉ đọc theo currentUser).
