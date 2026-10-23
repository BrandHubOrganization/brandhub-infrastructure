# Test — G3 Agency / Workspace (Mobile)

> [plan.md](./plan.md) | [task.md](./task.md)

| ID | Mô tả | AC/Edge | Kết quả mong đợi | Trạng thái |
|---|---|---|---|---|
| TC-01 | Agency List chỉ hiện agency mình sở hữu | FR 3.4.1 | Chỉ agency `ownerId=currentUser`, không thấy agency khác | Chưa test |
| TC-02 | Agency Dashboard hiển thị stats | FR 3.4.2 | `GET /stats` đúng số liệu, lọc theo `from`/`to` nếu có | Chưa test |
| TC-03 | Invite Agency Member thành công | FR 3.4.7 | Tạo invitation, hiện trong Pending List phía Owner | Chưa test |
| TC-04 | Invite Agency Member email đã là member | Error case 409 | Toast lỗi rõ ràng, không tạo invitation trùng | Chưa test |
| TC-05 | Invitation tự hết hạn sau 3 ngày | Mục 6 business rule | Status hiển thị đúng "Expired" không cần action | Chưa test |
| TC-06 | Remove Agency Member | FR 3.4.9 | Member bị xoá khỏi list, KHÔNG xoá tài nguyên họ tạo, không cảnh báo mất dữ liệu | Chưa test |
| TC-07 | Workspace List — Owner thấy toàn bộ | FR 3.4.10 | Owner thấy mọi workspace trong Agency | Chưa test |
| TC-08 | Workspace List — Member chỉ thấy workspace mình có mặt | FR 3.4.10 | Member không thấy workspace mình không tham gia | Chưa test |
| TC-09 | Workspace Detail tab Profile | FR 3.4.13, chặn bởi timezoneConfig | Nếu backend đã bổ sung field: hiện đúng timezone; nếu chưa: ẩn field, không hiện lỗi/trống | Chưa test |
| TC-10 | Invite/Assign Member — email chưa là Agency Member | Mục 6 business rule | UI chặn trước, gợi ý "Invite to Agency first", KHÔNG gọi API rồi nhận 409 | Chưa test |
| TC-11 | Invite/Assign Member modal chỉ hiện khi MANAGER | FR 3.4.19 role gate | CREATOR/CLIENT không thấy nút Invite | Chưa test |
| TC-12 | Update Member Role | FR 3.4.20 | Chỉ MANAGER làm được, role mới áp dụng ngay | Chưa test |
| TC-13 | Remove Workspace Member | FR 3.4.21 | Chỉ xoá khỏi Workspace, Agency membership giữ nguyên | Chưa test |
| TC-14 | Re-assign MANAGER mới | Mục 6, đúng 1 MANAGER/workspace | MANAGER cũ tự động bị revoke, mobile chỉ hiển thị kết quả không validate client-side | Chưa test |
| TC-15 | Leave Workspace | FR 3.4.16 | Rời khỏi Workspace nhưng KHÔNG rời Agency | Chưa test |
| TC-16 | Workspace Switcher đổi currentWorkspace | Mục 5 state | Store cập nhật, mọi màn hình phụ thuộc (G4-G7) đọc đúng workspace mới | Chưa test |
| TC-17 | Logout rồi login lại user khác | Mục 5, clear store khi logout | `currentWorkspace` bị clear, không lẫn dữ liệu session cũ | Chưa test |
| TC-18 | Mở app lại sau khi đã chọn workspace | Mục 5, persist id only | Fetch lại `GET /workspaces/{id}` thay vì dùng object đã persist (tránh stale) | Chưa test |
