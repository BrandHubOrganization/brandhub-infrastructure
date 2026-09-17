# 09 — Admin Management

> [<< Về Overview](00-overview.md)

## Danh sách FR đầy đủ (3.10.1 – 3.10.12)

| FR | Tên | Mô tả |
|---|---|---|
| 3.10.1 | Push Notification | Tạo thông báo toàn hệ thống, có phân chia theo nhóm user |
| 3.10.2 | Platform Statistics Overview | Dashboard tổng quan hệ thống — chart về user, doanh thu, agency đang hoạt động |
| 3.10.3 | System Health Monitoring | Xem tài nguyên server tại thời điểm hiện tại (%CPU, %RAM...) trong hệ thống microservice, server còn sống không |
| 3.10.4 | Content Moderation Queue | Hiển thị content của Creator bị dính chính sách kiểm duyệt — Admin check lại xem quyết định hệ thống đúng hay không |
| 3.10.5 | User Management (Verify/Disable/Delete) | Chuyển đổi trạng thái user trực tiếp — thiết kế để KHÔNG tách quá nhiều FR riêng lẻ |
| 3.10.6 | View User | Xem danh sách User trong hệ thống |
| 3.10.7 | Create User | Tạo User mới vào hệ thống |
| 3.10.8 | Update User | Chỉnh sửa thông tin User |
| 3.10.9 | Deactivate User | Tạm khóa Account người dùng |
| 3.10.11 | View Revenue Dashboard | Xem doanh thu hệ thống thu được từ Plan và Credit |
| 3.10.12 | Export Report File PDF | Xuất báo cáo cho các trang quản lý User, Revenue... dạng PDF |

Toàn bộ role: ADMIN. Admin tách biệt hoàn toàn khỏi cấu trúc Agency→Workspace — xem [01-organization-structure.md](01-organization-structure.md) mục 6.

**Lưu ý số hiệu FR**: CSV gốc nhảy từ 3.10.9 sang 3.10.11 (không có 3.10.10) — giữ nguyên số hiệu như nguồn gốc, không tự đánh số lại để tránh lệch tham chiếu khi đối chiếu về sau.

## Quyền hạn giữa các Admin [CONFIRMED 2026-09-17]

CSV gốc tại FR 3.10.9 (Deactivate User) có note treo:
> "admin có xoá được admin không? hệ thống có bao nhiêu admin?"

Đã confirm với Trung:
- **Admin KHÔNG xóa/deactivate được Admin khác** — không có phân cấp Super Admin trong phạm vi RBAC (mọi Admin ngang quyền, không ai override được Admin khác qua API).
- Số lượng Admin: không giới hạn cứng trong hệ thống — việc tạo/gỡ Admin xử lý ngoài luồng RBAC ứng dụng (ví dụ: qua thao tác trực tiếp DB/vận hành nội bộ), không thuộc phạm vi feature cần code trong `docs/feature`.

## Content Moderation Queue (3.10.4) — liên kết với Compliance Check

- FR này liên quan trực tiếp tới **Check Compliance Content** (FR 3.6.33, xem [05-content-task-workflow.md](05-content-task-workflow.md) mục 8) — khi hệ thống tự động phát hiện content vi phạm chính sách, nó vào hàng đợi Content Moderation Queue để Admin review lại quyết định (đúng/sai) của hệ thống tự động, không phải Admin tự kiểm duyệt từ đầu.

## User Management gộp FR (3.10.5)

- Thiết kế có chủ đích: **không tách CRUD trạng thái user thành nhiều FR nhỏ** (verify/disable/delete riêng lẻ) — gộp vào 1 FR "chuyển đổi trạng thái" để Admin điều chỉnh trực tiếp, giảm số lượng FR/API endpoint cần maintain.
