# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer / Infrastructure Support |
| Sprint | Sprint 4 |
| Ngày nộp | *(Chưa nộp — sprint: 2026-07-03 đến 2026-07-17)* |

---

> ⚠️ **Thành viên chưa nộp report.** Bản này đã cập nhật task list theo Jira board Sprint 4; cần cập nhật lại kết quả cuối sprint trước khi nộp.

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Epic/Label | Status hiện tại |
|---|---|---|---|---|
| DA-59 | [DA-59](https://letritrung2605.atlassian.net/browse/DA-59) | Investigate and Analyze 3 AI Fashion Model Generation Platforms | AI-01 — AI Model Research | In Review |
| DA-184 | [DA-184](https://letritrung2605.atlassian.net/browse/DA-184) | [DA-E06-06] Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | E06 — Database Design | In Review |
| DA-179 | [DA-179](https://letritrung2605.atlassian.net/browse/DA-179) | [DA-E07-02] Định nghĩa endpoints cho ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, ...) | E07 — API Design & Integration | To Do |
| DA-155 | [DA-155](https://letritrung2605.atlassian.net/browse/DA-155) | [DA-E07-06] Viết OpenAPI YAML spec cho ai-service (tất cả internal + public endpoints) | E07 — API Design & Integration | To Do |
| DA-173 | [DA-173](https://letritrung2605.atlassian.net/browse/DA-173) | [DA-E09-01] Write docker-compose.yml to run the full infrastructure stack: PostgreSQL, Redis, RabbitMQ, ... | E09 — Development Environment Setup | To Do |
| DA-187 | [DA-187](https://letritrung2605.atlassian.net/browse/DA-187) | [DA-E09-02] Integrated init-postgres.sql (create tables + seed subscription plans) | E09 — Development Environment Setup | To Do |
| DA-209 | [DA-209](https://letritrung2605.atlassian.net/browse/DA-209) | [DA-E11-03] Viết rate limiting filter dùng Redis (100 requests/minute/user) | E11 — API Gateway | To Do |
| DA-415 | [DA-415](https://letritrung2605.atlassian.net/browse/DA-415) | [DA-E09-07] AI Service — LLM keys + Payment Gateway | E09 — Development Environment Setup | To Do |
| DA-441 | [DA-441](https://letritrung2605.atlassian.net/browse/DA-441) | [DA-E47-17] Write individual sprint report for Sprint 3 — Tuấn | E47 — Sprint Report | To Do |
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | [DA-E47-24] Write individual sprint report for Sprint 4 — Tuấn | E47 — Sprint Report | In Progress |

**Tổng:** 10 tasks | Done: 0 | In Review: 2 | In Progress: 1 | To Do: 7

---

## 3. Chi tiết công việc đã làm

### DA-59 — Investigate and Analyze 3 AI Fashion Model Generation Platforms

- Đã hoàn thành phần nghiên cứu và đang đưa vào trạng thái review.
- Nội dung tập trung vào so sánh nền tảng AI fashion/model generation để chọn hướng tích hợp phù hợp cho AI service.
- Cần chờ feedback review để chốt recommendation cuối cùng.

### DA-184 / DA-E06-06 — Document Redis key patterns

- Đã document các nhóm Redis key pattern chính: JWT blacklist, rate limit, OAuth state và trending cache.
- Task đang ở trạng thái In Review.
- Cần chờ reviewer xác nhận naming convention, TTL và format key có khớp với gateway/publisher/AI service không.

### DA-448 / DA-E47-24 — Sprint 4 individual report

- Đã bắt đầu cập nhật report cá nhân Sprint 4.
- Đã đồng bộ lại danh sách task theo Jira board Sprint 4 trong ảnh được cung cấp.
- Cần cập nhật tiếp kết quả thực tế khi các task chuyển trạng thái trong sprint.

---

## 4. Tasks chưa hoàn thành

| Task ID | Status | Lý do / Ghi chú | Hành động tiếp theo |
|---|---|---|---|
| DA-179 | To Do | Chưa bắt đầu định nghĩa chi tiết endpoint contract cho ai-service | Chốt endpoint list, request/response schema, error codes và internal auth header |
| DA-155 | To Do | Phụ thuộc vào DA-179; chưa có endpoint contract thì chưa viết OpenAPI YAML chuẩn được | Làm sau khi DA-179 đủ rõ |
| DA-173 | To Do | Chưa triển khai docker-compose full infrastructure stack | Xác định service list, ports, volumes, healthchecks |
| DA-187 | To Do | Chưa tích hợp init-postgres.sql tạo bảng và seed subscription plans | Viết script init và test với PostgreSQL container |
| DA-209 | To Do | Chưa viết Redis rate limiting filter cho gateway | Thống nhất key pattern với DA-184 rồi implement filter |
| DA-415 | To Do | Chưa cấu hình LLM keys và payment gateway cho AI service | Rà soát env vars, secret handling và tài liệu setup |
| DA-441 | To Do | Report Sprint 3 của Tuấn chưa hoàn tất theo Jira board | Hoàn thiện report Sprint 3 riêng, tránh trộn với Sprint 4 |

---

## 5. Đóng góp ngoài tasks chính

- Cập nhật lại task list cá nhân Sprint 4 theo Jira board thực tế.
- Phân tách rõ các nhóm việc AI research, API contract, infrastructure, gateway và sprint report để dễ theo dõi tiến độ.

---

## 6. Học được gì trong sprint này

- Các task AI service có dependency rõ: phải chốt endpoint contract trước rồi mới viết OpenAPI spec.
- Redis key pattern cần thống nhất sớm vì ảnh hưởng trực tiếp tới JWT blacklist, rate limit, OAuth state và cache.
- Với các task infrastructure/gateway, cần test bằng container thực tế thay vì chỉ viết tài liệu.

---

## 7. Feedback & Đề xuất

- Nên ưu tiên xử lý DA-179 trước DA-155 vì OpenAPI YAML phụ thuộc trực tiếp vào endpoint contract.
- Nên chốt Redis key convention từ DA-184 trước khi làm DA-209 để tránh sửa lại rate limiting filter.
- Sprint report nên cập nhật theo trạng thái Jira mỗi cuối ngày, tránh dồn vào cuối sprint.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | /5 | Chưa chấm — sprint chưa kết thúc |
| Chất lượng deliverable | /5 | Chưa chấm — DA-59 và DA-184 đang In Review |
| Giao tiếp với team | /5 | Chưa chấm — cần cập nhật khi có review feedback |
| Chủ động xử lý blocker | /5 | Chưa chấm — cần ưu tiên DA-179 và DA-184 để unblock các task sau |
| **Tổng** | **/20** | Chưa đánh giá chính thức |

---

*Sprint 4: 2026-07-03 đến 2026-07-17*
