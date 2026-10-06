# Chuyển Đổi Nghiệp Vụ: Hỗ Trợ Agency Cá Nhân (Personal / Solo Creator Mode)
## BrandHub — Technical & Business Specification Index

Tài liệu này tổng hợp toàn bộ phân tích nghiệp vụ, kiến trúc kỹ thuật, thiết kế cơ sở dữ liệu và đặc tả giao diện cho tính năng: **Cho phép người dùng tạo và sử dụng Agency cho mục đích Cá nhân (Solo Creator / Freelancer / Tự sản xuất và đăng bài), đồng thời tự động chuyển đổi thẳng vào không gian làm việc để sử dụng ngay mà không bị rào cản bởi quy trình quản lý khách hàng (Client Management) của Agency truyền thống.**

---

## 📂 Danh Mục Tài Liệu Chi Tiết

| STT | Tài liệu | Nội dung chính |
|:---:|:---|:---|
| **01** | [01_BUSINESS_REQUIREMENTS_AND_USER_FLOW.md](./01_BUSINESS_REQUIREMENTS_AND_USER_FLOW.md) | Phân tích bài toán, so sánh As-Is vs To-Be, User Journeys, Business Rules và Use Cases chi tiết cho Cá nhân vs Doanh nghiệp. |
| **02** | [02_TECHNICAL_ARCHITECTURE_AND_DATA_FLOW.md](./02_TECHNICAL_ARCHITECTURE_AND_DATA_FLOW.md) | Kiến trúc luồng dữ liệu, Diagram tương tác PlantUML / Mermaid giữa FE - Gateway - Business Service - DB, API Contracts mở rộng. |
| **03** | [03_DATABASE_SCHEMA_CHANGES.md](./03_DATABASE_SCHEMA_CHANGES.md) | Thiết kế Database, DDL Migration PostgreSQL (`agency_type` ENUM), kịch bản Auto-provisioning Workspace cá nhân, Entity Java & DTO mapping. |
| **04** | [04_UI_UX_AND_SCREEN_SPEC.md](./04_UI_UX_AND_SCREEN_SPEC.md) | Thiết kế màn hình Tạo Agency mới (lựa chọn mục đích), cơ chế Personal Mode trên Sidebar/Navigation (ẩn tính năng Client), luồng đăng bài không cần chờ duyệt. |
| **05** | [05_IMPLEMENTATION_PLAN_AND_TASKS.md](./05_IMPLEMENTATION_PLAN_AND_TASKS.md) | Kế hoạch triển khai chi tiết qua 4 giai đoạn, phân rã đầu việc (Task breakdown) và tiêu chí kiểm thử (Acceptance Criteria). |

---

## 🎯 Tóm Tắt Mục Tiêu Cốt Lõi

1. **Phân loại mục đích sử dụng ngay từ đầu**:
   - `PERSONAL` (Cá nhân / Solo Creator): Người dùng tự sản xuất nội dung, kết nối kênh mạng xã hội và đăng bài cho chính thương hiệu của mình.
   - `BUSINESS` (Doanh nghiệp / Agency truyền thông): Quản lý đội ngũ nhân sự, tạo workspace cho từng khách hàng, đàm phán gói truyền thông và gửi duyệt bài cho khách hàng.
2. **Zero-friction Onboarding ("Tạo xong dùng luôn")**:
   - Khi chọn `PERSONAL`, hệ thống tự động sinh 1 Workspace mặc định cá nhân (đồng bộ tên, logo, màu sắc) và gán quyền Quản trị (`MANAGER`).
   - Chuyển hướng người dùng thẳng vào không gian làm việc (`/workspaces/:id/dashboard` hoặc `/content-writing`) thay vì trang xem thông tin Agency rỗng.
3. **Giao diện tinh gọn (Personal Workspace Mode)**:
   - Ẩn toàn bộ các menu dư thừa: Khách hàng, Hồ sơ khách hàng, Lời mời khách hàng, Cổng duyệt bài Portal, Phân quyền vai trò phức tạp.
   - Luồng viết bài cho phép Đăng ngay / Lên lịch trực tiếp mà không cần qua bước Chờ Client phê duyệt (`PENDING_CLIENT_APPROVAL`).
