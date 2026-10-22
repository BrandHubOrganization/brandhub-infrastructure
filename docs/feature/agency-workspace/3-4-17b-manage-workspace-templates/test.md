# Test — Manage Workspace Templates (FR 3.4.17b)

> Test cases derived from sequence diagram and business logic in [report4_sequence.puml](report4_sequence.puml).

| Test case ID | Mô tả | Đầu vào / Điều kiện | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-3.4.17b-01 | Liệt kê danh sách template của agency thành công | Agency owner/member đã xác thực, agency tồn tại | 200 OK; Danh sách WorkspaceTemplateResponse | Happy path | Pass |
| TC-3.4.17b-02 | Liệt kê template khi agency không tồn tại | User không thuộc agency nào | 404 `AGENCY_NOT_FOUND` | Error case | Pass |
| TC-3.4.17b-03 | Xóa template thành công | Owner của agency sở hữu template gửi yêu cầu xóa templateId | 200 OK; Template bị xóa khỏi DB | Happy path | Pass |
| TC-3.4.17b-04 | Xóa template không tồn tại | `templateId` ngẫu nhiên không có trong DB | 404 `NOT_FOUND` | Error case | Pass |
| TC-3.4.17b-05 | Xóa template thuộc về agency khác | User thuộc Agency A nhưng yêu cầu xóa template của Agency B | 403 `FORBIDDEN` | Security case | Pass |
