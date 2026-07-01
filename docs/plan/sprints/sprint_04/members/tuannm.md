# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-07-14 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-173 | [DA-173](https://letritrung2605.atlassian.net/browse/DA-173) | DA-E09-01 Write docker-compose.yml to run the full infrastructure stack: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB | 🔴 Critical | 🔄 In Review |
| DA-187 | [DA-187](https://letritrung2605.atlassian.net/browse/DA-187) | DA-E09-02 Integrated init-postgres.sql (create tables + seed subscription plans) | 🔴 Critical | 🔄 In Review |
| DA-203 | [DA-203](https://letritrung2605.atlassian.net/browse/DA-203) | DA-E09-03 Write .env.example consolidating all environment variables across 6 services | 🔴 Critical | ⏳ To Do |
| DA-209 | [DA-209](https://letritrung2605.atlassian.net/browse/DA-209) | DA-E11-03 Write rate limiting filter dùng Redis (100 requests/minute/user) | 🔴 Critical | 🔄 In Review |
| DA-254 | [DA-254](https://letritrung2605.atlassian.net/browse/DA-254) | DA-AI02-07 Document ChromaDB collection design (collection naming per client, metadata schema, query patterns) | 🟡 High | ⏳ To Do |
| DA-415 | [DA-415](https://letritrung2605.atlassian.net/browse/DA-415) | DA-E09-07 AI Service — LLM keys + Payment Gateway | 🟡 High | 🔄 In Review |
| DA-419 | [DA-419](https://letritrung2605.atlassian.net/browse/DA-419) | DA-E11-06 Write Dockerfile for api-gateway | 🟡 High | ⏳ To Do |
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn | 🟣 Medium | 🚧 In Progress |
| DA-537 | [DA-537](https://letritrung2605.atlassian.net/browse/DA-537) | DA-E48-01 Write individual AI iteration report for Iteration 1 — Tuấn | 🟢 Medium | ⏳ To Do |

**Tổng:** 9 tasks | Done: 0 | In Review: 4 | In Progress: 1 | Chưa hoàn thành / To Do: 4

---

## 3. Chi tiết công việc đã làm

---

### [DA-173] — Write docker-compose.yml to run the full infrastructure stack

**Jira status:** In Review  
**Phạm vi:** cấu hình Docker Compose cho các dịch vụ infrastructure chính gồm MongoDB, PostgreSQL, Redis, RabbitMQ và ChromaDB.

**Kết quả đạt được:**
- [x] Xác định đủ các service infrastructure cần chạy local
- [x] Cấu hình port và image theo plan Sprint 4
- [x] Chuẩn bị nền để mount init scripts và biến môi trường chung

---

### [DA-187] — Integrated init-postgres.sql

**Jira status:** In Review  
**Phạm vi:** tích hợp script PostgreSQL để tạo bảng và seed subscription plans ban đầu.

**Kết quả đạt được:**
- [x] Chuẩn bị flow init database khi container PostgreSQL khởi động lần đầu
- [x] Seed dữ liệu subscription plan phục vụ các service backend
- [x] Đồng bộ với scope database trong plan infrastructure

---

### [DA-209] — Write rate limiting filter dùng Redis

**Jira status:** In Review  
**Phạm vi:** rate limiting 100 requests/minute/user bằng Redis cho API Gateway.

**Kết quả đạt được:**
- [x] Bám theo Redis key contract `ratelimit:{userId}:{minute}`
- [x] Dùng hướng `INCR` + conditional `EXPIRE` theo tài liệu Redis key patterns
- [x] Làm rõ behavior trả lỗi khi vượt giới hạn request

---

### [DA-415] — AI Service — LLM keys + Payment Gateway

**Jira status:** In Review  
**Phạm vi:** rà soát nhóm biến môi trường và cấu hình liên quan AI service, LLM provider keys và payment gateway.

**Kết quả đạt được:**
- [x] Xác định các nhóm key nhạy cảm cần đưa vào `.env.example`
- [x] Tách cấu hình AI service khỏi các service backend khác
- [x] Chuẩn bị đầu vào cho task tổng hợp environment variables

---

### [DA-448] — Write individual sprint report for Sprint 4

**Jira status:** In Progress  
**File tạo ra / thay đổi:**
- `docs/plan/sprints/sprint_04/members/tuannm.md` — báo cáo cá nhân Sprint 4

**Mô tả công việc đã làm:**

Cập nhật báo cáo cá nhân Sprint 4 theo danh sách task trong Jira/screenshot, đồng thời loại các task đã có trong báo cáo Sprint 3 và loại task `DA-441` theo yêu cầu. Báo cáo chỉ giữ các task còn lại: `DA-173`, `DA-187`, `DA-203`, `DA-209`, `DA-254`, `DA-415`, `DA-419`, `DA-448`, `DA-537`.

**Kết quả đạt được:**
- [x] Bảng task Sprint 4 đã loại task trùng Sprint 3
- [x] Status task được cập nhật theo ảnh Jira
- [x] Phần chưa hoàn thành phản ánh đúng các task còn `To Do`

---

## 4. Tasks chưa hoàn thành

| Task ID | Jira Link | Mô tả | Trạng thái | Ghi chú |
|---|---|---|---|---|
| DA-203 | [DA-203](https://letritrung2605.atlassian.net/browse/DA-203) | DA-E09-03 Write .env.example consolidating all environment variables across 6 services | To Do | Chưa bắt đầu theo trạng thái Jira trong ảnh |
| DA-254 | [DA-254](https://letritrung2605.atlassian.net/browse/DA-254) | DA-AI02-07 Document ChromaDB collection design | To Do | Chưa bắt đầu theo trạng thái Jira trong ảnh |
| DA-419 | [DA-419](https://letritrung2605.atlassian.net/browse/DA-419) | DA-E11-06 Write Dockerfile for api-gateway | To Do | Chưa bắt đầu theo trạng thái Jira trong ảnh |
| DA-537 | [DA-537](https://letritrung2605.atlassian.net/browse/DA-537) | DA-E48-01 Write individual AI iteration report for Iteration 1 — Tuấn | To Do | Chưa bắt đầu theo trạng thái Jira trong ảnh |

---

## 5. Đóng góp ngoài tasks chính

- Rà lại danh sách task Sprint 4 để tránh ghi trùng các task đã báo cáo ở Sprint 3.
- Tách riêng task report Sprint 3 (`DA-441`) khỏi báo cáo Sprint 4.
- Đồng bộ lại status theo ảnh Jira để report không tự mâu thuẫn với trạng thái hiện tại.

---

## 6. Học được gì trong sprint này

1. **Task report cần chống trùng:** Khi một task xuất hiện ở nhiều sprint hoặc nhiều report, cần lấy report sprint trước làm source loại trừ.
2. **Status Jira phải tách khỏi mức độ hoàn tất thực tế:** `In Review`, `In Progress` và `To Do` cần ghi rõ để tránh báo cáo nhầm thành `Done`.
3. **Infrastructure task có nhiều phụ thuộc chéo:** Docker Compose, init DB, Redis rate limiting và `.env.example` phụ thuộc nhau, nên report cần ghi đúng trạng thái từng phần.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Nên chốt một nguồn task chính cho từng sprint trước khi viết report cá nhân. Nếu dùng ảnh Jira để cập nhật, cần loại task đã có ở sprint trước để tránh tính effort hai lần.

### 7.2 Về tài liệu

Các report cá nhân nên ghi cả Jira key (`DA-173`) và mã plan nội bộ (`DA-E09-01`) vì ảnh Jira dùng key số, còn tài liệu plan dùng mã epic/task.

### 7.3 Đề xuất cho sprint tiếp theo

- Hoàn tất các task còn `To Do`: `DA-203`, `DA-254`, `DA-419`, `DA-537`.
- Sau khi Jira chuyển status, cập nhật lại phần tổng kết Done/In Review/In Progress/To Do.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | Các task In Review đã được ghi nhận, nhưng còn task To Do |
| Chất lượng deliverable | 4/5 | Report đã loại task trùng và cập nhật status theo Jira |
| Giao tiếp với team | 4/5 | Làm rõ task nào thuộc Sprint 4 sau khi loại Sprint 3 |
| Chủ động xử lý blocker | 4/5 | Nhận diện mâu thuẫn giữa ảnh Jira và report cũ |
| **Tổng** | **16/20** | |

---

*Nộp: 2026-07-14 | Sprint 4 ends: 2026-07-14*
