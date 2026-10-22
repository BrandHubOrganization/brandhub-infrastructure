# Test — View and Decline My Invitations (FR 3.4.8b)

> Test cases derived from sequence diagram and business logic in [report4_sequence.puml](report4_sequence.puml).

| Test case ID | Mô tả | Đầu vào / Điều kiện | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-3.4.8b-01 | Xem danh sách lời mời đang chờ xử lý thành công | Người dùng đăng nhập có lời mời trạng thái PENDING | 200 OK; Danh sách lời mời chưa hết hạn kèm thông tin Agency và Workspace | Happy path | Pass |
| TC-3.4.8b-02 | Xem danh sách lời mời khi user không tồn tại | Token auth không tìm thấy user tương ứng trong DB | 404 `USER_NOT_FOUND` | Error case | Pass |
| TC-3.4.8b-03 | Lọc bỏ các lời mời đã hết hạn (`expiresAt < now`) | DB có lời mời PENDING nhưng đã quá hạn | 200 OK; Danh sách kết quả không chứa lời mời quá hạn | Edge case | Pass |
| TC-3.4.8b-04 | Từ chối lời mời hợp lệ thành công | Token lời mời PENDING còn hạn | 200 OK; Trạng thái lời mời cập nhật thành `REVOKED` | Happy path | Pass |
| TC-3.4.8b-05 | Từ chối lời mời với token không tồn tại | Token không tìm thấy trong DB | 400 `INVALID_INVITATION` | Error case | Pass |
| TC-3.4.8b-06 | Từ chối lời mời đã quá hạn hoặc đã xử lý | Token có status != PENDING hoặc quá hạn | 400 `INVALID_INVITATION` | Error case | Pass |
