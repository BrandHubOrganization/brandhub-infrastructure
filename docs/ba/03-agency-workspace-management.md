# 03 — Agency & Workspace Management (chi tiết FR)

> [<< Về Overview](00-overview.md) — Xem mô hình tổng quan tại [01-organization-structure.md](01-organization-structure.md) trước khi đọc file này.

File này liệt kê đầy đủ 21 FR nhóm 3.4 kèm chi tiết nghiệp vụ. Phần diễn giải mô hình/quan hệ đã có ở file 01 — file này tập trung vào từng FR cụ thể.

## Danh sách FR đầy đủ

| FR | Tên | Role | Mô tả |
|---|---|---|---|
| 3.4.1 | List Agency | OWNER | Trang list các Agency mà user đang sở hữu (là owner) |
| 3.4.2 | View Agency Dashboard | OWNER | Coi thông tin tổng quan của công ty |
| 3.4.3 | Create Agency | OWNER | Có owner id liên kết 1-1 với id user tạo ra agency |
| 3.4.4 | View Agency Profile | OWNER | Coi thông tin công ty — đại diện để khách hàng hiểu về Agency |
| 3.4.5 | Update Agency Profile | OWNER | Update thông tin Agency |
| 3.4.6 | Remove Agency | OWNER | Xóa mềm, có confirm, khôi phục được trong 30 ngày |
| 3.4.7 | Invite Agency Member | OWNER | Mời qua mail + notification; người được mời không có role gì, chỉ là member thông thường |
| 3.4.8 | View Agency Invitation Status | OWNER / USER (invited) | Cả 2 bên thấy được lời mời; tự hết hạn sau 3 ngày |
| 3.4.9 | Remove Member | OWNER | Xóa member khỏi Agency — mất quyền truy cập nhưng tài nguyên họ tạo ra vẫn giữ (tài sản chung); thêm lại vẫn dùng tiếp được |
| 3.4.10 | List Workspace | OWNER / MEMBER | Member chỉ coi workspace mình có mặt; Owner coi toàn bộ |
| 3.4.11 | View Workspace Dashboard | OWNER / MEMBER | Thông tin chung + thống kê workspace |
| 3.4.12 | Create Workspace | OWNER | Bắt buộc thêm ít nhất 1 thành viên và gán làm Manager của workspace đó, toàn quyền quản lý. **[CONFIRMED 2026-09-15]** Owner được tự gán mình làm Manager. Mỗi Workspace chỉ đúng 1 Manager — không co-manage; đổi Manager = re-assign (Manager cũ mất quyền). |
| 3.4.13 | View Workspace Profile | OWNER / MANAGER | Update được Timezone Configuration — mốc thời gian chuẩn hoạt động của workspace, hỗ trợ tối ưu giờ đăng bài theo địa điểm |
| 3.4.14 | Update Workspace Profile | OWNER / MANAGER | Update thông tin workspace |
| 3.4.15 | Delete Workspace | OWNER | Chỉ Owner xóa được, khôi phục trong 30 ngày; khi xóa toàn bộ member mất quyền truy cập, data chuyển inactive |
| 3.4.16 | Leave Workspace | MEMBER | Rời workspace nhưng vẫn còn trong Agency |
| 3.4.17 | Save Workspace Template | OWNER | Lưu lại workspace hiện có thành template để tái sử dụng khi tạo workspace mới |
| 3.4.18 | View Workspace Members | MEMBER | Coi danh sách thành viên |
| 3.4.19 | Add Workspace Member | OWNER / MANAGER | Thêm member (đã có trong Agency) vào workspace với role cụ thể |
| 3.4.20 | Update Workspace Member Role | OWNER / MANAGER | Đổi role của member trong workspace đó |
| 3.4.21 | Remove Workspace Member | OWNER / MANAGER | Xóa thành viên khỏi workspace (không xóa khỏi Agency) |

## Lưu ý nghiệp vụ quan trọng

### Invitation có thời hạn (3.4.8)
- Lời mời vào Agency **tự động hết hạn sau 3 ngày** nếu không được accept/reject.
- Cả người mời (Owner) và người được mời (User) đều thấy trạng thái lời mời đang chờ.

### Xóa mềm (soft delete) — áp dụng nhất quán
- Remove Agency (3.4.6): 30 ngày khôi phục.
- Delete Workspace (3.4.15): 30 ngày khôi phục.
- Cả 2 đều yêu cầu bước confirm trước khi thực hiện xóa.

### Member vs Role — 2 khái niệm tách biệt hoàn toàn (nhắc lại từ file 01)
- "Thêm vào Agency" (3.4.7) ≠ "Có Role". Vào Agency chỉ là thành viên công ty.
- "Role" chỉ xuất hiện khi thao tác Add Workspace Member (3.4.19) — role đó CHỈ áp dụng cho đúng Workspace đang thêm vào, không lan sang Workspace khác trong cùng Agency.

### Quan hệ Agency Member ↔ Workspace Member
- Điều kiện để add ai đó vào Workspace: **họ phải đã là Member của Agency đó trước** (FR 3.4.19: "Thêm member trong Agency vào workspace với role cụ thể").
- Tức là: chưa vào Agency → không thể trực tiếp vào Workspace của Agency đó.
