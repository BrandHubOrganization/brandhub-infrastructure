# Sprint 5 — Individual Report

---

## 1. Thông tin cá nhân

| Field    | Value                                         |
| -------- | --------------------------------------------- |
| Họ tên   | Nguyễn Chơn Phước                             |
| GitHub   | [@phuocnc]                                    |
| Role     | Publisher Engineer / Frontend (Web Dashboard) |
| Sprint   | Sprint 5                                      |
| Ngày nộp | 06-08-2026                                    |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
| ------- | --------- | ----- | -------- | ------------------ |

| DA-E21-03 (DA-242) | [DA-E21-03](https://letritrung2605.atlassian.net/browse/DA-E21-03) | Implement Facebook publish adapter (Graph API v26.0) | 🔴 Critical | Done |
| DA-E21-06 | [DA-E21-06](https://letritrung2605.atlassian.net/browse/DA-E21-06) | Implement Threads publish adapter | 🔴 Critical | Done |
| DA-E21-02 | [DA-E21-02](https://letritrung2605.atlassian.net/browse/DA-E21-02) | Implement RabbitMQ consumer: route to correct platform adapter | 🔴 Critical | |
| DA-E21-04 | [DA-E21-04](https://letritrung2605.atlassian.net/browse/DA-E21-04) | Implement Instagram publish adapter | 🔴 Critical | Done |

> 🔀 E14-04 (Permission matrix) dời sang Sprint 6. E34 được dời từ Sprint 12 lên Sprint 5 sau rebalance. Cập nhật thêm các task DA-E21-03, DA-E21-06, DA-E21-02, DA-E21-04.

**Tổng:** 4 tasks | Done: 3 | In Review: 0 | Chưa hoàn thành: 1

---

## 3. Chi tiết công việc đã làm

- **DA-E21-03 (Facebook Publish Adapter):**
  - Đã triển khai thành công `FacebookPublishAdapter` và `FacebookPublishServiceImpl` để đăng bài viết (text và hình ảnh) lên Facebook Pages thông qua Graph API v26.0.
  - Tích hợp giải mã Access Token (`CryptoUtils.decrypt`).
  - Hỗ trợ truyền `targetId` để đăng bài lên đúng Fanpage mong muốn (không bị lỗi deprecated `publish_actions`).
  - Refactor tách biệt logic gọi API sang `FacebookPublishService` theo chuẩn MVC.
  - Cập nhật Data Transfer Object (`PublishResult`) để trả về `platform` và `errorCode` theo đúng chuẩn thiết kế.
  - Test thành công thông qua `TestController` và fix triệt để các lỗi về Page Access Token.

- **DA-E21-04 (Instagram Publish Adapter):**
  - Đã triển khai luồng 2-step creation flow để đăng ảnh lên Instagram (Graph API v26.0).
  - Bổ sung hỗ trợ đăng nhiều ảnh (Carousel) bằng cách tạo các container con và gom nhóm bằng parent container.
  - Thêm ghi chú kỹ thuật (document) về việc đăng Reels sử dụng endpoint riêng `/reels` và nằm ngoài phạm vi hiện tại.
  - Tích hợp logic xử lý vòng lặp (polling) kiểm tra trạng thái container tự động với giới hạn 30 giây (tránh treo luồng).
  - Tự động cắt gọn (truncate) caption nếu vượt quá giới hạn 2200 ký tự của Instagram.
  - Tái sử dụng chuẩn cấu trúc Service/Adapter MVC đã dựng ở task Facebook.

- **DA-E21-06 (Threads Publish Adapter):**
  - Đã hoàn thiện và tích hợp Adapter xử lý đăng bài cho nền tảng Threads.
  - Thực hiện tái cấu trúc (Refactor) `TestController`: Tách bạch các DTO request (`FacebookPublishRequest`, `InstagramPublishRequest`, `ThreadsPublishRequest`) đưa về đúng thư mục `dto` của từng platform để đảm bảo tính đóng gói thay vì viết chung trong Controller.

---

## 4. Tasks chưa hoàn thành

_(Đang tiến hành các task Frontend DA-E34)_

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ làm rõ luồng OAuth 2.0 cấp quyền Facebook Page và phân tích nguyên nhân lỗi `publish_actions`.
- Chủ động refactor lại `TestController` của service, tách các DTO dùng chung thành các Request DTO độc lập theo từng nền tảng (Facebook, Instagram, Threads) để clean code và dễ mở rộng.
- Phân tích và làm rõ lỗi validation định dạng ảnh (mã lỗi 9004) của Instagram API, hỗ trợ team sử dụng đúng chuẩn dữ liệu (JPEG) khi test.

---

## 6. Học được gì trong sprint này

- Hiểu rõ sự khác biệt giữa User Access Token và Page Access Token trong hệ thống Graph API của Meta.
- Quy trình lấy Page Access Token thông qua endpoint `me/accounts` hoặc `/{page_id}?fields=access_token`.
- Hiểu được cơ chế 2-step upload (container -> publish) của Instagram API (kể cả luồng tạo Carousel).
- Có thêm kinh nghiệm trong việc tái cấu trúc (refactoring) các Data Transfer Object (DTO) phân chia rành mạch theo platform.
- Hiểu sâu hơn về kiến trúc Event-Driven của `publisher-service` (lắng nghe RabbitMQ) và tại sao lại dùng `TestController` như một backdoor để test thay vì tạo REST API thông thường.
- Biết được sự khắt khe của Instagram Graph API về định dạng media (chỉ hỗ trợ tốt JPEG, từ chối PNG), từ đó cẩn trọng hơn trong việc thiết lập dữ liệu test.

---

## 7. Feedback & Đề xuất

- Nên có thông báo rõ ràng cho user ở phía Frontend khi API `/me/accounts` trả về rỗng để họ biết cách tick chọn Fanpage lúc cấp quyền OAuth.
- Đề xuất phía Frontend (Web Dashboard) cần bổ sung validation bắt buộc người dùng tải lên đúng định dạng ảnh (ví dụ: chỉ cho phép upload/chọn `.jpg` hoặc video hợp lệ đối với Instagram) để chặn từ sớm lỗi 9004 từ Meta Graph API.

---

## 8. Self-assessment

| Tiêu chí                 | Điểm (1-5) | Ghi chú                                          |
| ------------------------ | ---------- | ------------------------------------------------ |
| Hoàn thành đúng deadline | 2/5        | Đã hoàn thành DA-E21-03 kịp thời gian            |
| Chất lượng deliverable   | 4/5        | Code clean, áp dụng đúng Service/Adapter pattern |
| Giao tiếp với team       | 2/5        |                                                  |
| Chủ động xử lý blocker   | 4/5        | Tự research fix lỗi Facebook Graph API token     |
| **Tổng**                 | **12/20**  |                                                  |

---

_Deadline nộp: 2026-07-28_
