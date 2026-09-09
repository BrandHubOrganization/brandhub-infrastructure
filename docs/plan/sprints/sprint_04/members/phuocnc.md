# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field    | Value              |
| -------- | ------------------ |
| Họ tên   | Nguyễn Chơn Phước  |
| GitHub   | [@phuocnc]         |
| Role     | Publisher Engineer |
| Sprint   | Sprint 4           |
| Ngày nộp | 2026-07-12         |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link                                                       | Mô tả                                                | Priority    | Status cuối sprint |
| ------- | --------------------------------------------------------------- | ---------------------------------------------------- | ----------- | ------------------ |
| DA-152  | [DA-E09-05](https://letritrung2605.atlassian.net/browse/DA-152) | Write README.md for infrastructure repo              | 🟢 Medium   | ✅ Done            |
| DA-196  | [DA-E07-03](https://letritrung2605.atlassian.net/browse/DA-196) | RabbitMQ message format                              | 🔴 Critical | ✅ Done            |
| DA-172  | [DA-E07-07](https://letritrung2605.atlassian.net/browse/DA-172) | Social platform API specs _(carry over từ Sprint 3)_ | 🟡 High     | ✅ Done            |
| DA-417  | [DA-E09-09](https://letritrung2605.atlassian.net/browse/DA-417) | Publisher Service — Social Platform OAuth            | 🟡 High     | ✅ Done            |
| DA-156  | [DA-E11-05](https://letritrung2605.atlassian.net/browse/DA-156) | Write logging filter                                 | 🟡 High     | ✅ Done            |
| DA-191  | [DA-E13-01](https://letritrung2605.atlassian.net/browse/DA-191) | Implement GET/PUT /api/v1/users/me                   | 🟡 High     | ✅ Done            |
| DA-206  | [DA-E13-02](https://letritrung2605.atlassian.net/browse/DA-206) | Implement avatar upload                              | 🟡 High     | ✅ Done            |
| DA-420  | [DA-E11-07](https://letritrung2605.atlassian.net/browse/DA-420) | Write global error response handler for gateway      | 🟡 High     | ✅ Done            |
| DA-213  | [DA-E21-01](https://letritrung2605.atlassian.net/browse/DA-213) | Khoi tao brandhub-publisher-service project          | 🔴 Critical | ✅ Done            |
| DA-272  | [DA-E21-05](https://letritrung2605.atlassian.net/browse/DA-272) | Implement TikTok publish adapter                     | 🟡 High     | ✅ Done            |

**Tổng:** 10 tasks | Done: 10 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### DA-E07-03 — RabbitMQ Message Format (Publisher Contract)

**Jira status:** Done
**File tạo ra:**
- `docs/architecture/rabbitmq_publisher_contract.html`

**Mô tả công việc đã làm:**
- Thiết kế và document PublishJobMessage contract — định dạng message RabbitMQ giữa business-service (producer) và publisher-service (consumer).
- Xác định cấu trúc message JSON: `postId`, `platform` (facebook/instagram/tiktok/threads/zalo), `content` (caption + hashtags), `mediaUrls[]`, `scheduledAt`, `workspaceId`, `clientId`.
- Định nghĩa queue name, exchange type (direct), routing key pattern, và dead-letter queue cho failed publish jobs.
- Document flow: business-service → RabbitMQ exchange → platform-specific queue → publisher-service adapter → social API → callback kết quả về business-service.
- Thiết kế retry strategy: 3 lần retry với exponential backoff (1m, 5m, 15m) → dead-letter queue nếu vẫn fail.

**Kết quả đạt được:**
- [x] Contract rõ ràng cho DA-E21-02 (RabbitMQ consumer implementation) và DA-E22-01/02 (publish callback + retry).
- [x] HTML visualization trực quan cho team dễ reference.

---

### [DA-172] — Document social platform API specs

**Jira status:** Done  
**Branch:** `docs/DA-172-social-platform-api-specs`  
**Commit chính:** `[commit-hash]` — `docs(DA-172): document FB, TikTok, Threads API specs`  
**File tạo ra / thay đổi:**

- `[filepath]` — Tài liệu đặc tả API của FB, TikTok, Threads

**Mô tả công việc đã làm:**
Nghiên cứu và tài liệu hóa các API của nền tảng mạng xã hội bao gồm Facebook Graph API v19, TikTok Content API v2 và Threads API. Chi tiết các version hiện tại, giới hạn rate limit và định dạng dữ liệu truyền nhận (payload formats) cho việc đăng bài.

**Kết quả đạt được:**

- [x] Hoàn thiện tài liệu specs của 3 nền tảng MXH.
- [x] Sẵn sàng dữ liệu để implement code tích hợp.

**Khó khăn gặp phải:** Không đáng kể.

**Thời gian thực tế:** ~3 giờ

### [DA-196] — Define RabbitMQ message format for publisher-service

**Jira status:** Done  
**Branch:** `feat/DA-196-rabbitmq-message-format`  
**Commit chính:** `[commit-hash]` — `feat(DA-196): define message format for publish job and callback`  
**File tạo ra / thay đổi:**

- `[filepath]/MessageDTO.java` — Định nghĩa cấu trúc DTO cho message RabbitMQ.

**Mô tả công việc đã làm:**
Thiết kế và thống nhất cấu trúc format message RabbitMQ cho publisher-service. Bao gồm định dạng message khi gửi publish job và định dạng callback message trả về kết quả publish.

**Kết quả đạt được:**

- [x] Có format chuẩn để các service giao tiếp qua RabbitMQ.
- [x] Đã thống nhất với team về DTO contract.

**Khó khăn gặp phải:** Cần trao đổi nhiều lần để thống nhất format chuẩn tối ưu.

**Thời gian thực tế:** ~3 giờ

### [DA-152] — Write README.md for the infrastructure repo

**Jira status:** Done  
**Branch:** `docs/DA-152-infrastructure-readme`  
**Commit chính:** `[commit-hash]` — `docs(DA-152): write step-by-step setup guide in README`  
**File tạo ra / thay đổi:**

- `README.md` — Hướng dẫn cài đặt hạ tầng

**Mô tả công việc đã làm:**
Viết tài liệu README.md chi tiết cho repository infrastructure. Cung cấp hướng dẫn từng bước (step-by-step setup guide) để các thành viên trong team có thể tự build và run hạ tầng local.

**Kết quả đạt được:**

- [x] Tài liệu README rõ ràng, dễ hiểu.
- [x] Hỗ trợ team setup môi trường nhanh chóng.

**Khó khăn gặp phải:** Không.

**Thời gian thực tế:** ~2 giờ

### [DA-417] — Publisher Service — Social Platform OAuth

**Jira status:** Done  
**Branch:** `feat/DA-417-social-oauth`  
**Commit chính:** `[commit-hash]` — `feat(DA-417): implement social platform OAuth`  
**File tạo ra / thay đổi:**

- `[filepath]` — Logic xử lý OAuth cho các mạng xã hội.

**Mô tả công việc đã làm:**
Thực hiện implement luồng xác thực OAuth cho các mạng xã hội trong Publisher Service, giúp người dùng có thể kết nối tài khoản mạng xã hội của họ vào hệ thống.

**Kết quả đạt được:**

- [x] Xử lý thành công luồng OAuth.
- [x] Lấy được access token cần thiết để gọi API.

**Khó khăn gặp phải:** Các mạng xã hội có flow OAuth hơi khác nhau, cần xử lý linh hoạt.

**Thời gian thực tế:** ~5 giờ

### [DA-156] — Write logging filter

**Jira status:** Done  
**Branch:** `feat/DA-156-logging-filter`  
**Commit chính:** `[commit-hash]` — `feat(DA-156): add request response logging filter`  
**File tạo ra / thay đổi:**

- `[filepath]/LoggingFilter.java` — Lớp filter bắt và log request/response.

**Mô tả công việc đã làm:**
Viết một Logging Filter global để tự động ghi log toàn bộ các request gửi đến (inbound) và response trả về (outbound). Giúp quá trình debugging và trace lỗi dễ dàng hơn.

**Kết quả đạt được:**

- [x] Filter hoạt động tốt, ghi log đầy đủ thông tin.
- [x] Tối ưu quá trình debug cho team.

**Khó khăn gặp phải:** Xử lý đọc body request nhiều lần (cached body) để không làm mất luồng xử lý chính.

**Thời gian thực tế:** ~3 giờ

### [DA-191] — Implement GET/PUT /api/v1/users/me

**Jira status:** Done  
**Branch:** `feat/DA-191-users-me-api`  
**Commit chính:** `[commit-hash]` — `feat(DA-191): implement get and update user profile api`  
**File tạo ra / thay đổi:**

- `[filepath]/UserController.java` — Các endpoint liên quan đến user profile.

**Mô tả công việc đã làm:**
Xây dựng API cho phép người dùng lấy thông tin cá nhân (GET) và cập nhật thông tin profile của họ (PUT) tại endpoint `/api/v1/users/me`.

**Kết quả đạt được:**

- [x] API lấy và cập nhật profile hoạt động đúng logic.
- [x] Đã handle lỗi và validation input đầy đủ.

**Khó khăn gặp phải:** Không.

**Thời gian thực tế:** ~3 giờ

### [DA-206] — Implement avatar upload

**Jira status:** Done  
**Branch:** `feat/DA-206-avatar-upload`  
**Commit chính:** `[commit-hash]` — `feat(DA-206): implement s3 avatar upload`  
**File tạo ra / thay đổi:**

- `[filepath]/UploadService.java` — Logic xử lý upload file.

**Mô tả công việc đã làm:**
Phát triển tính năng upload ảnh đại diện (avatar). Nhận file từ client, thực hiện upload lên dịch vụ lưu trữ S3, sau đó lưu lại URL của avatar vào cơ sở dữ liệu PostgreSQL.

**Kết quả đạt được:**

- [x] Upload S3 thành công.
- [x] Lưu trữ URL chuẩn xác.

**Khó khăn gặp phải:** Cấu hình chuẩn xác bucket policy và credentials cho S3.

**Thời gian thực tế:** ~4 giờ

### [DA-213] — Khoi tao brandhub-publisher-service project

**Jira status:** Done  
**Branch:** `feat/DA-213-init-publisher-service`  
**Commit chính:** `[commit-hash]` — `chore(DA-213): init spring boot publisher service`  
**File tạo ra / thay đổi:**

- `pom.xml`, `application.yml`, cấu trúc thư mục base.

**Mô tả công việc đã làm:**
Khởi tạo dự án microservice mới từ đầu (brandhub-publisher-service) sử dụng Spring Boot 3. Setup các thư viện cần thiết cơ bản và cấu hình RabbitMQ consumer bean để chuẩn bị nhận message từ các service khác.

**Kết quả đạt được:**

- [x] Service khởi chạy thành công.
- [x] Kết nối được với hệ thống RabbitMQ.

**Khó khăn gặp phải:** Không.

**Thời gian thực tế:** ~2 giờ

### [DA-272] — Implement TikTok publish adapter

**Jira status:** Done  
**Branch:** `feat/DA-272-tiktok-publish-adapter`  
**Commit chính:** `[commit-hash]` — `feat(DA-272): implement direct and creator upload for tiktok`  
**File tạo ra / thay đổi:**

- `[filepath]/TikTokPublishAdapter.java` — Adapter đăng video lên TikTok.

**Mô tả công việc đã làm:**
Phát triển module Adapter để đăng nội dung lên TikTok. Phân luồng logic xử lý 2 trường hợp: Direct Post (cho video ngắn ≤ 60s) và Creator Upload (cho video dài > 60s, cần xử lý chunking).

**Kết quả đạt được:**

- [x] Triển khai Strategy Pattern với `SocialPublishAdapter`.
- [x] Xử lý tốt logic phân nhánh độ dài video.

**Khó khăn gặp phải:** Luồng upload chunk của video > 60s phức tạp, cần nghiên cứu kỹ document và cần TikTok App Credentials để test thực tế.

**Thời gian thực tế:** ~6 giờ

### [DA-420] — Write global error response handler for gateway

**Jira status:** Done  
**Branch:** `feat/DA-420-gateway-error-handler`  
**Commit chính:** `[commit-hash]` — `feat(DA-420): write global error handler for api gateway`  
**File tạo ra / thay đổi:**

- `[filepath]/GlobalErrorWebExceptionHandler.java` — Xử lý lỗi toàn cục.

**Mô tả công việc đã làm:**
Phát triển một Global Error Response Handler cấp API Gateway, dùng để catch tất cả các lỗi xảy ra trong quá trình routing và trả về response format thống nhất cho client (thay vì trang lỗi mặc định của Spring).

**Kết quả đạt được:**

- [x] Standardize lỗi trả về từ Gateway.
- [x] Nâng cao trải nghiệm client khi gặp lỗi mạng/down service.

**Khó khăn gặp phải:** Xử lý custom WebExceptionHandler trong môi trường WebFlux của API Gateway khác với Spring MVC thông thường.

## **Thời gian thực tế:** ~4 giờ

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ team review docker-compose structure và góp ý về cách tổ chức multi-file compose (infra core + dev override + app stack).
- Các file HTML architecture docs (rabbitmq_publisher_contract, social_platforms_api_specs) được thiết kế dạng card-based visualization — dễ reference hơn markdown thuần cho technical specs phức tạp.

---

## 6. Học được gì trong sprint này

- Nắm chắc hơn kỹ năng tạo mới một Spring Boot Microservice từ con số 0 và đấu nối Message Broker.
- Nghiên cứu sâu về tài liệu TikTok API, hiểu được sự phức tạp của việc upload video có chia chunk và cách phân luồng logic hợp lý.
- Hiểu được sức mạnh của việc thiết kế Strategy Pattern kết hợp Interface `SocialPublishAdapter` để dễ dàng mở rộng.

---

## 7. Feedback & Đề xuất

- Đề xuất team mình ưu tiên chốt và đăng ký TikTok App Credentials sớm để mình có thể đắp nốt phần code Upload Chunk và test luồng thực tế.

---

## 8. Self-assessment

| Tiêu chí                 | Điểm (1-5) | Ghi chú                                                                    |
| ------------------------ | ---------- | -------------------------------------------------------------------------- |
| Hoàn thành đúng deadline | 5/5        | Nộp báo cáo đúng hạn (14/07).                                              |
| Chất lượng deliverable   | 4/5        | Mới chỉ có logic chạy được. Chưa tối ưu hoàn toàn.                         |
| Giao tiếp với team       | 4/5        | Chủ động trao đổi khi thiết kế cấu trúc DTO cho RabbitMQ.                  |
| Chủ động xử lý blocker   | 3/5        | Chưa tự xử lý được các lỗi liên quan đến infrastructure ( docker-compose). |
| **Tổng**                 | **16/20**  | Cần tối ưu hơn!                                                            |
