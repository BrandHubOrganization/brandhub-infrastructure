**3.10.3 System Health Monitoring (Giám Sát Sức Khỏe Hệ Thống Microservices)**

**Function Trigger**

Bắt đầu khi Quản trị viên (ADMIN) truy cập trang giám sát tại /admin/system-health.

**Function Description**

- **Actors / Roles**: ADMIN. Quản trị viên kỹ thuật giám sát tình trạng hạ tầng microservices.
- **Purpose**: Giám sát trạng thái hoạt động (UP, DEGRADED, DOWN), mức sử dụng CPU/RAM và độ trễ phản hồi của 7 microservices trong hệ thống BrandHub.
- **Interface**: Màn hình Giám Sát Sức Khỏe Hệ Thống (SCR-ADM-03), gồm lưới trạng thái các service, biểu đồ tài nguyên thời gian thực và nhật ký cảnh báo sự cố.
- **Data Processing**: Hệ thống gửi yêu cầu kiểm tra sức khỏe (/actuator/health) đến 7 microservices (BR-65), đo thời gian phản hồi (latency), thu thập mức tải CPU/RAM, xác định trạng thái tổng thể, và kích hoạt cảnh báo nếu service bị lỗi.

**Screen Layout**

Figure — Bảng điều khiển Giám Sát Sức Khỏe Hệ Thống (SCR-ADM-03):

- Left/Header: Sidebar điều hướng Admin; Top Header hiển thị tiêu đề "Giám sát Sức khỏe Hệ thống", nhãn trạng thái chung ("7/7 Dịch vụ Hoạt động tốt") và nút "Ping kiểm tra toàn bộ".
- Center: Lưới thẻ 7 microservices (api-gateway, auth-service, business-service, ai-service, publisher-service, notification-service, payment-service): Mỗi thẻ hiển thị Tên service, Badge trạng thái (UP màu xanh, DEGRADED màu vàng, DOWN màu đỏ), Độ trễ phản hồi (ms), % CPU, % RAM, Thời gian hoạt động liên tục (uptime); Khung biểu đồ độ trễ 24 giờ qua; Bảng sự cố gần đây.
- Buttons: Nút "Ping kiểm tra toàn bộ" (màu xanh), Nút "Làm mới", Bộ lọc trạng thái service (Tất cả, Đang lỗi, Cảnh báo).
- Footer: Dấu thời gian lần kiểm tra gần nhất và chu kỳ tự động làm mới (mặc định mỗi 30 giây).

**Function Details**
- **Data Specifications**
    - **Input required**: Không có (hệ thống tự động thăm dò định kỳ 30 giây một lần).
    - **Input optional**: serviceName (lọc theo service cụ thể), refreshInterval (chu kỳ làm mới: 10s, 30s, 60s).
    - **System data**: servicesList (mảng 7 service), status (UP, DEGRADED, DOWN), latencyMs, cpuUsagePercent, memoryUsagePercent, diskFreeBytes, lastPingTimestamp.
    - **Output**: Danh sách chi tiết sức khỏe các microservices kèm mã phản hồi HTTP 200 OK.

- **Business Rules**
    - **BR-65**: Giám sát sức khỏe hệ thống microservices là khu vực kỹ thuật độc quyền của vai trò ADMIN.
    - **BR-35**: Xác thực quyền hạn ADMIN trước khi tiếp nhận và trả về các chỉ số nhạy cảm của hạ tầng.
    - **BR-16**: Các sự cố gián đoạn dịch vụ hoặc chuyển trạng thái DOWN/DEGRADED đều được tự động lưu vào nhật ký kiểm toán hệ thống.

- **Validation**
    - Người dùng không có quyền ADMIN -> Display: **MSG39**
    - Dịch vụ microservice không phản hồi hoặc mất kết nối -> Display: **MSG38**

**Functionalities**
- **Normal Flow**
    1. Admin truy cập màn hình Giám sát Sức khỏe (/admin/system-health).
    2. Hệ thống xác thực quyền ADMIN theo BR-35, BR-65.
    3. Hệ thống gửi yêu cầu kiểm tra sức khỏe (/actuator/health) tới 7 microservices.
    4. Hệ thống tiếp nhận phản hồi, tính toán độ trễ, CPU, RAM và xác định trạng thái của từng service.
    5. Hệ thống hiển thị trạng thái các service lên màn hình SCR-ADM-03 theo dải màu trực quan.
    6. Cứ sau mỗi 30 giây, hệ thống tự động kiểm tra lại và cập nhật trạng thái mới nhất.

- **Abnormal Cases**
    - 2.a1: Nếu người dùng không có vai trò ADMIN, hệ thống từ chối truy cập và hiển thị **MSG39**.
    - 4.a1: Nếu một service không phản hồi sau 3000ms, hệ thống đánh dấu trạng thái DOWN màu đỏ và hiển thị **MSG38**.

**Post-Conditions**

- Dữ liệu sức khỏe microservices được cập nhật liên tục trên màn hình giám sát.
- Các sự cố gián đoạn dịch vụ được lưu vào bảng system_health_logs (BR-16).
