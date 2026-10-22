# Test — Accept Agency Invitation (FR 3.4.7b)

> Test cases derived from sequence diagram and business logic in [report4_sequence.puml](report4_sequence.puml).

| Test case ID | Mô tả | Đầu vào / Điều kiện | Kết quả mong đợi | Loại | Trạng thái |
|---|---|---|---|---|---|
| TC-3.4.7b-01 | Invitee chấp nhận lời mời thành công | Token hợp lệ, trạng thái PENDING, email khớp `currentUser` | 200 OK; Status = ACCEPTED; tạo AgencyMember thành công | Happy path | Pass |
| TC-3.4.7b-02 | Token không tồn tại | Token ngẫu nhiên không có trong DB | 400 `INVALID_INVITATION` | Error case | Pass |
| TC-3.4.7b-03 | Lời mời đã hết hạn (`expiresAt < now`) | Token hết hạn 30 ngày | 400 `INVALID_INVITATION` | Error case | Pass |
| TC-3.4.7b-04 | Lời mời đã được chấp nhận trước đó | Status != PENDING (ACCEPTED) | 400 `INVALID_INVITATION` | Error case | Pass |
| TC-3.4.7b-05 | Email đăng nhập không khớp với email được mời | Token gửi cho `a@x.com`, người dùng đăng nhập là `b@x.com` | 400 `INVALID_INVITATION` | Error case | Pass |
| TC-3.4.7b-06 | Chấp nhận lời mời với role CLIENT và liên kết Workspace | Invitation có `role=CLIENT`, `workspaceId` hợp lệ | 200 OK; tạo WorkspaceMember role CLIENT và tạo ClientProfile liên kết | Happy path | Pass |
