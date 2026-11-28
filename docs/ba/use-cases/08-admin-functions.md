# UC 08 — Admin Functions (`UC-128` – `UC-141`)

> [<< 07-subscription.md](./07-subscription.md) | [UC Index](./README.md) | [Domain BA Spec: 09-admin-functions.md](../09-admin-functions.md) | [BA Overview >>](../README.md)
>
> Đồng bộ chuẩn xác 1-đối-1 với `Các FR của hệ thống - Feature_Function Requirement.csv` và `AGENTS.md`. Chỉ sử dụng **6 Vai trò Hệ thống Chuẩn (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`)**.

---

## 1. Bảng Tổng Hợp Use Cases (14 UCs)

| UC ID | Use Case Title | Canonical Actor(s) | Related FR | Business Rules |
| :-: | :--- | :--- | :-: | :--- |
| `UC-128` | Push Notification | `Admin` | `3.10.1` | `BR-62, BR-65` |
| `UC-129` | Platform Statistics Overview | `Admin` | `3.10.2` | `BR-61, BR-62` |
| `UC-130` | System Health Monitoring | `Admin` | `3.10.3` | `BR-62, BR-65` |
| `UC-131` | Content Moderation Queue | `Admin` | `3.10.4` | `BR-42, BR-62, BR-63, BR-65` |
| `UC-132` | Update User Violation Status | `Admin` | `3.10.5` | `BR-62, BR-63, BR-65` |
| `UC-133` | View User | `Admin` | `3.10.6` | `BR-62` |
| `UC-134` | Create User | `Admin` | `3.10.7` | `BR-01, BR-62, BR-65` |
| `UC-135` | Update User | `Admin` | `3.10.8` | `BR-11, BR-15, BR-62, BR-65` |
| `UC-136` | Deactivate User | `Admin` | `3.10.9` | `BR-05, BR-62, BR-63, BR-65` |
| `UC-137` | View AI Credit Price List | `Owner`, `Admin` | `3.10.10` | `BR-48, BR-62, BR-64` |
| `UC-138` | Update AI Credit Price | `Admin` | `3.10.11` | `BR-48, BR-62, BR-64, BR-65` |
| `UC-139` | Import AI Credit Price CSV | `Admin` | `3.10.12` | `BR-62, BR-64, BR-65` |
| `UC-140` | View Revenue Dashboard | `Admin` | `3.10.13` | `BR-59, BR-61, BR-62` |
| `UC-141` | Export Report File PDF | `Admin` | `3.10.14` | `BR-61, BR-62, BR-65` |

---

## UC-128 — Push Notification

- **Related FR:** `3.10.1` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-62, BR-65`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG58`
- **Specification & Flow:** Tạo và phát thông báo toàn hệ thống (System Broadcast / Push Notification — /admin/notifications). Cho phép Admin soạn tiêu đề, nội dung, mức độ ưu tiên và phân nhóm đối tượng người nhận cụ thể (Tất cả người dùng, chỉ Owners, theo gói đăng ký Basic/Pro/Enterprise hoặc theo vai trò) để đẩy thông báo thời gian thực qua WebSocket, FCM Mobile và Email (BR-62).

---

## UC-129 — Platform Statistics Overview

- **Related FR:** `3.10.2` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-61, BR-62`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG36`
- **Specification & Flow:** Xem bảng điều khiển thống kê tổng quan toàn nền tảng (Platform Statistics Overview — /admin/dashboard). Hiển thị các chỉ số vận hành cốt lõi và biểu đồ tăng trưởng: Tổng số người dùng, Số lượng Agency & Workspace đang hoạt động, Tổng số bài đăng xuất bản thành công qua 4 mạng xã hội, Lưu lượng gọi AI và Tổng doanh thu hệ thống (BR-62).

---

## UC-130 — System Health Monitoring

- **Related FR:** `3.10.3` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-62, BR-65`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Giám sát sức khỏe và mức tiêu thụ tài nguyên thời gian thực của toàn bộ cụm Microservices (System Health Monitoring — /admin/health). Hiển thị trạng thái sống (UP/DOWN/DEGRADED), tỷ lệ % CPU, % RAM, độ trễ phản hồi API, độ dài hàng đợi RabbitMQ và kết nối cơ sở dữ liệu (PostgreSQL, MongoDB, Redis, ChromaDB, Neo4j) của từng dịch vụ (API Gateway, Business, Publisher, AI Service) (BR-62).

---

## UC-131 — Content Moderation Queue

- **Related FR:** `3.10.4` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-42, BR-62, BR-63, BR-65`
- **System Messages:** `MSG02, MSG07, MSG36, MSG58`
- **Specification & Flow:** Xem và xử lý hàng đợi kiểm duyệt các nội dung bị gắn cờ vi phạm chính sách toàn hệ thống (Content Moderation Queue — /admin/moderation). Hiển thị các nội dung do người dùng/AI tạo ra bị bộ lọc tự động nghi ngờ vi phạm tiêu chuẩn an toàn; Admin kiểm tra chi tiết bằng chứng để đưa ra quyết định phê duyệt cho phép lưu hành (Approve/Dismiss) hoặc xác nhận vi phạm để gỡ bỏ và cảnh cáo (Confirm Violation) (BR-42, BR-63).

---

## UC-132 — Update User Violation Status

- **Related FR:** `3.10.5` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-62, BR-63, BR-65`
- **System Messages:** `MSG02, MSG07, MSG36, MSG59`
- **Specification & Flow:** Cập nhật trực tiếp trạng thái xử lý vi phạm và xác minh của tài khoản người dùng trên hệ thống (Update User Violation Status — /admin/users/:userId/status). Cho phép Admin chuyển đổi trạng thái tài khoản giữa ACTIVE (Hoạt động bình thường / Đã xác minh), WARNED (Cảnh cáo vi phạm), SUSPENDED (Tạm đình chỉ có thời hạn) và BANNED (Khóa vĩnh viễn kèm thu hồi toàn bộ phiên đăng nhập trên Redis); bắt buộc ghi lý do vào nhật ký kiểm toán (Audit Log, BR-65, BR-63, BR-65).

---

## UC-133 — View User

- **Related FR:** `3.10.6` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-62`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem, tìm kiếm và lọc danh sách toàn bộ tài khoản người dùng trên hệ thống (View User — /admin/users). Hỗ trợ tìm kiếm theo Họ tên, Email, lọc theo Vai trò hệ thống, Trạng thái tài khoản (ACTIVE, PENDING_VERIFICATION, SUSPENDED, BANNED, DELETED) và xem chi tiết danh sách Agency/Workspace mà người dùng đó tham gia (BR-62).

---

## UC-134 — Create User

- **Related FR:** `3.10.7` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-01, BR-62, BR-65`
- **System Messages:** `MSG02, MSG04, MSG07, MSG08, MSG59`
- **Specification & Flow:** Tạo mới tài khoản người dùng trực tiếp từ cổng quản trị hệ thống (Create User — /admin/users/new). Admin nhập Họ tên, Email (kiểm tra duy nhất BR-01), Vai trò hệ thống và mật khẩu khởi tạo (hoặc gửi email thiết lập mật khẩu); hệ thống băm mật khẩu (BR-65), kích hoạt tài khoản và ghi nhận vào Audit Log (BR-62, BR-65).

---

## UC-135 — Update User

- **Related FR:** `3.10.8` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-11, BR-15, BR-62, BR-65`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG59`
- **Specification & Flow:** Chỉnh sửa thông tin hồ sơ hành chính và phân quyền cấp hệ thống của tài khoản người dùng (Update User — /admin/users/:userId/edit). Cho phép Admin cập nhật Họ tên, Số điện thoại, Vai trò hệ thống; ngăn chặn việc tự hạ quyền hoặc khóa tài khoản Admin cuối cùng đang hoạt động trên hệ thống (BR-62, BR-65, BR-65).

---

## UC-136 — Deactivate User

- **Related FR:** `3.10.9` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-05, BR-62, BR-63, BR-65`
- **System Messages:** `MSG02, MSG03, MSG07, MSG36, MSG59`
- **Specification & Flow:** Tạm khóa / vô hiệu hóa tài khoản người dùng từ cổng quản trị (Deactivate User — /admin/users/:userId). Chuyển trạng thái tài khoản sang INACTIVE/DEACTIVATED, lập tức thu hồi toàn bộ JWT token đang hoạt động trên Redis (BR-63), chặn đăng nhập mới (BR-05) nhưng vẫn bảo toàn dữ liệu lịch sử và ghi vết Audit Log (BR-63, BR-65).

---

## UC-137 — View AI Credit Price List

- **Related FR:** `3.10.10` (3.10 Admin Functions)
- **Canonical Actor(s):** `Owner`, `Admin`
- **Business Rules:** `BR-48, BR-62, BR-64`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem bảng cấu hình đơn giá tiêu hao AI Credit hiện hành của toàn hệ thống (View AI Credit Price List — /admin/credit-prices). Hiển thị danh mục đầy đủ các tác vụ AI (Generate Caption, Generate Image Qwen Image 2.1 (ComfyUI GPU)/LoRA, Generate Video Veo, Generate Virtual Ambassador, Suggest Hashtag...), đơn giá AI Credit tương ứng, trạng thái kích hoạt và lịch sử cập nhật giá (BR-64).

---

## UC-138 — Update AI Credit Price

- **Related FR:** `3.10.11` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-48, BR-62, BR-64, BR-65`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG60`
- **Specification & Flow:** Cập nhật trực tiếp đơn giá tiêu hao AI Credit cho từng loại tác vụ AI trên giao diện quản trị (Update AI Credit Price — /admin/credit-prices). Hệ thống kiểm tra đơn giá phải là số nguyên dương hợp lệ; đơn giá mới được áp dụng ngay cho các yêu cầu sinh AI kế tiếp mà không làm thay đổi số credit đã khóa của các tiến trình AI đang chạy dở (BR-48, BR-64, BR-65).

---

## UC-139 — Import AI Credit Price CSV

- **Related FR:** `3.10.12` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-62, BR-64, BR-65`
- **System Messages:** `MSG02, MSG03, MSG07, MSG22, MSG60`
- **Specification & Flow:** Tải lên, kiểm tra xem trước (Preview) và nhập hàng loạt bảng đơn giá AI Credit từ tệp CSV (Import AI Credit Price CSV — /admin/credit-prices/import). Hệ thống phân tích cú pháp từng dòng trong tệp CSV (feature_code, model_tier, credit_cost, description), báo lỗi chi tiết nếu có mã tác vụ không tồn tại hoặc đơn giá âm, và áp dụng cập nhật nguyên tử (all-or-nothing transaction) khi Admin xác nhận (BR-64, BR-65).

---

## UC-140 — View Revenue Dashboard

- **Related FR:** `3.10.13` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-59, BR-61, BR-62`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07`
- **Specification & Flow:** Xem bảng điều khiển phân tích doanh thu toàn hệ thống (View Revenue Dashboard — /admin/revenue). Thống kê tổng doanh thu thực thu từ các giao dịch đã thanh toán thành công (PAID), biểu đồ xu hướng doanh thu theo Ngày/Tuần/Tháng/Quý, cơ cấu doanh thu giữa Gói đăng ký (Subscription Plans: Basic, Pro, Enterprise) và Gói mua thêm AI Credit (Top-up Packs) (BR-61, BR-62).

---

## UC-141 — Export Report File PDF

- **Related FR:** `3.10.14` (3.10 Admin Functions)
- **Canonical Actor(s):** `Admin`
- **Business Rules:** `BR-61, BR-62, BR-65`
- **System Messages:** `MSG01, MSG02, MSG03, MSG07, MSG60`
- **Specification & Flow:** Kết xuất và tải xuống tệp báo cáo quản trị định dạng PDF (Export Report File PDF — /admin/reports/export). Cho phép Admin chọn loại báo cáo (Báo cáo Doanh thu & Giao dịch, Báo cáo Tăng trưởng Người dùng & Agency, Báo cáo Tiêu thụ AI Credit) và khoảng thời gian lọc để hệ thống tổng hợp số liệu, biểu đồ và xuất ra tệp PDF chuẩn phục vụ lưu trữ và báo cáo (BR-62, BR-65).
