# PROJECT CONTEXT: BRANDHUB (BH)

## 1. Tổng quan dự án (Project Overview)
* **Tên dự án:** BrandHub (Tên viết tắt: BH)
* **Định nghĩa:** Nền tảng sản xuất và phân phối nội dung đa kênh ứng dụng trí tuệ nhân tạo (AI-Powered) dành cho các công ty truyền thông (Marketing Agencies).
* **Mục tiêu cốt lõi:**
    * Tự động hóa quy trình tạo nội dung (caption, hình ảnh, video ngắn) từ text input.
    * Đảm bảo tính chính xác và nhất quán thương hiệu bằng hệ thống RAG (Retrieval-Augmented Generation) kết hợp Vector Database.
    * Quản lý tập trung nhiều khách hàng (Brand Clients) trên cùng một nền tảng, chia theo không gian làm việc (Workspaces).
    * Cung cấp Client Portal để khách hàng duyệt, theo dõi và phê duyệt bài viết.
    * Quét (crawl) xu hướng thời gian thực từ Google Trends, TikTok, Facebook để gợi ý ý tưởng.
    * Lên lịch và tự động đăng bài an toàn qua các kênh: Facebook, Instagram, TikTok, Threads, Zalo OA bằng hệ thống Message Queue.

## 2. Kiến trúc & Công nghệ (Tech Stack)
* **Kiến trúc:** Microservices (Gồm Business Service, Publisher Service và AI Service giao tiếp qua Spring Cloud Gateway).
* **Front-end:** React + Vite, Tailwind CSS (Web Dashboard); React Native (Android App).
* **Back-end:** Java Spring Boot, Python FastAPI (AI Service).
* **Database:** MongoDB (Query < 200ms trên indexed fields), PostgreSQL, Redis, VectorDB (lưu tài liệu thương hiệu).
* **Message Queue:** RabbitMQ (Đảm bảo thứ tự FIFO, cơ chế Acknowledgement, tự động retry 3 lần khi lỗi).
* **Lưu trữ & Hạ tầng:** AWS S3 (Lưu media, truy cập qua presigned URL), Docker & Docker Compose, GitHub Actions (CI/CD).

## 3. Phân quyền & Luồng vận hành (User Roles & Workflows)
Hệ thống áp dụng mãnh liệt cơ chế bảo mật RBAC và cô lập dữ liệu hoàn toàn giữa các không gian làm việc (cross-workspace isolation). Có 6 vai trò chính:
* **Admin:** Quản trị toàn hệ thống, cấu hình gói subscription (Free, Basic, Pro, Enterprise), quản lý người dùng, xem báo cáo doanh thu/sử dụng AI.
* **Agency Owner:** Tạo và cấu hình Workspace cho agency; Onboard client (tạo profile riêng); Mời và phân quyền cho Account Manager (AM) và Content Creator; Theo dõi hiệu suất tổng thể.
* **Account Manager (AM):** Tiếp nhận content request từ Client -> Giao việc cho Creator -> Duyệt bài do Creator nộp -> Chuyển bài cho Client duyệt -> Đặt lịch lên nội dung trên Calendar sau khi được duyệt hoàn toàn -> Kết nối tài khoản mạng xã hội của client.
* **Content Creator:** Nhận brief -> Dùng AI sinh caption/hài hòa theo brand guidelines (RAG) -> Dùng AI sinh ảnh/video -> Tối ưu hóa độ dài/định dạng theo từng platform -> Preview hiển thị realtime -> Gửi AM duyệt.
* **Brand Client:** Đăng nhập Client Portal riêng biệt -> Gửi Content Request -> Theo dõi tiến độ task -> Xem preview, Duyệt/Từ chối bài viết kèm feedback -> Xem lịch đăng bài (Read-only Calendar) và lịch sử bài đã đăng.
* **Guest:** Xem Landing page, đăng ký/đăng nhập (hỗ trợ Google OAuth).

## 4. Các ràng buộc phi chức năng quan trọng (Key Non-Functional Requirements)
* **Giao diện (UI/UX):** Phải responsive (Desktop 1440px làm chuẩn; Mobile 375px đáp ứng các luồng cốt lõi: Xem Calendar, Phê duyệt bài viết, Check status). Hiển thị thông báo dạng Toast, có thanh Loading indicator khi AI đang xử lý nội dung.
* **Hiệu năng (Performance):** API chuẩn phản hồi < 1s. AI tạo Text < 10s, Tạo Ảnh < 30s, Tạo Video < 3 phút. Hàng đợi đăng bài phân phối trong vòng 30s so với lịch hẹn. Hỗ trợ tối thiểu 200 người dùng đồng thời.
* **Bảo mật (Security):** Token JWT ngắn hạn (15 phút) kết hợp Refresh Token (30 ngày) lưu trong HttpOnly cookie. Mật khẩu hash hoàn toàn. Mọi hành động phê duyệt, quản trị phải được ghi Log hệ thống (Audit Logs).
* **Ngôn ngữ:** Hỗ trợ đa ngôn ngữ Anh/Việt (Localization định dạng ngày giờ, tiền tệ VND/USD).