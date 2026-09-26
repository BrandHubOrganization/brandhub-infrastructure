# Test — View Workspace Members (FR 3.4.18)

> Test case suy từ Acceptance Criteria trong [spec.md](spec.md).

| Test case ID | Mô tả | AC liên quan | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-01 | Active member gọi `GET /{workspaceId}/members`, workspace có MANAGER + CREATOR + CLIENT | AC1 | 200; list đủ 3 member, đúng role | Happy path | Pass |
| TC-02 | Member kiểu CLIENT (gán qua `addClient`, không có `userId`) trong list | AC1 | `fullName` lấy từ `ClientProfile.displayName`, `email = null` | Edge case | Pass |
| TC-03 | `workspaceId` không tồn tại | Error (mục 6) | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-04 | User không phải active member của workspace này | Error (mục 6) | 403 `WORKSPACE_ACCESS_DENIED` | Error case | Pass |
| TC-05 | Workspace chỉ có 1 member (người tạo, MANAGER) | Edge (mục 7) | 200; list 1 phần tử | Edge case | Pass |
| TC-06 | Workspace có member đã bị remove (isActive=false) | AC1 | Member đó KHÔNG xuất hiện trong list | Edge case | Pass |

## Ghi chú

- AC1 = "List toàn bộ WorkspaceMember của Workspace... KHÔNG có OWNER ở cấp Workspace".
