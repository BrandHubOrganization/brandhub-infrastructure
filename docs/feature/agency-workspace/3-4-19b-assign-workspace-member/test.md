# Test — Assign Workspace Member from Agency (FR 3.4.19b)

> Test cases derived from sequence diagram and business logic in [report4_sequence.puml](report4_sequence.puml).

| Test case ID | Mô tả | Đầu vào / Điều kiện | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-3.4.19b-01 | Gán thành viên agency vào workspace thành công | Workspace MANAGER gửi danh sách userIds hợp lệ thuộc agency | 200 OK; WorkspaceMember mới được tạo và lưu trữ | Happy path | Pass |
| TC-3.4.19b-02 | Gán thành viên khi người gọi không phải MANAGER | User không có role MANAGER trong workspace | 403 `FORBIDDEN` | Security case | Pass |
| TC-3.4.19b-03 | Gán thành viên vào workspace không tồn tại | `workspaceId` không có trong hệ thống | 404 `WORKSPACE_NOT_FOUND` | Error case | Pass |
| TC-3.4.19b-04 | Gán user không thuộc Agency của Workspace | Một hoặc nhiều userIds không phải thành viên agency | 400 `MEMBER_NOT_IN_AGENCY` | Error case | Pass |
