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

> ⚠️ **Thành viên chưa nộp report.** Bản này đang cập nhật theo Jira board Sprint 4; cần rà soát lại lần cuối trước khi nộp chính thức.

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-59 | [DA-59](https://letritrung2605.atlassian.net/browse/DA-59) | Investigate and Analyze 3 AI Fashion Model Generation Platforms | — | 🔄 In Review |
| DA-184 | [DA-184](https://letritrung2605.atlassian.net/browse/DA-184) | DA-E06-06 Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | 🟡 High | 🔄 In Review |
| DA-179 | [DA-179](https://letritrung2605.atlassian.net/browse/DA-179) | DA-E07-02 Định nghĩa endpoints cho ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends) | 🔴 Critical | ✅ Done |
| DA-155 | [DA-155](https://letritrung2605.atlassian.net/browse/DA-155) | DA-E07-06 Viết OpenAPI YAML spec cho ai-service (tất cả internal + public endpoints) | 🟡 High | ❌ To Do |
| DA-173 | [DA-173](https://letritrung2605.atlassian.net/browse/DA-173) | DA-E09-01 Write docker-compose.yml to run the full infrastructure stack: PostgreSQL, Redis, RabbitMQ, ... | 🔴 Critical | ❌ To Do |
| DA-187 | [DA-187](https://letritrung2605.atlassian.net/browse/DA-187) | DA-E09-02 Integrated init-postgres.sql (create tables + seed subscription plans) | 🔴 Critical | ❌ To Do |
| DA-209 | [DA-209](https://letritrung2605.atlassian.net/browse/DA-209) | DA-E11-03 Viết rate limiting filter dùng Redis (100 requests/minute/user) | 🔴 Critical | ❌ To Do |
| DA-415 | [DA-415](https://letritrung2605.atlassian.net/browse/DA-415) | DA-E09-07 AI Service — LLM keys + Payment Gateway | — | ❌ To Do |
| DA-441 | [DA-441](https://letritrung2605.atlassian.net/browse/DA-441) | DA-E47-17 Write individual sprint report for Sprint 3 — Tuấn | — | ❌ To Do |
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn | — | 🟡 In Progress |

**Tổng:** 10 tasks | Done: 1 | In Review: 2 | In Progress: 1 | Chưa hoàn thành: 6

---

## 3. Chi tiết công việc đã làm

---

### [DA-59] — Investigate and Analyze 3 AI Fashion Model Generation Platforms

**Jira status:** In Review  
**Branch:** `docs/DA-59-analyze-ai-fashion-model-platforms`  
**Commit chính:** *(đang chờ review / cập nhật sau)*  
**File tạo ra / thay đổi:**
- `docs/AI_Models/DA-59_AI_Fashion_Model_Generation_Platforms.md` — tài liệu nghiên cứu và so sánh nền tảng AI fashion model generation

**Mô tả công việc đã làm:**

Nghiên cứu và so sánh các nền tảng AI fashion/model generation theo tiêu chí khả năng tạo ảnh người mẫu, chất lượng ảnh, API/integration, chi phí, rủi ro bản quyền và mức phù hợp với BrandHub.

**Kết quả đạt được:**
- [x] Có tài liệu phân tích để team review
- [x] Có cơ sở chọn hướng tích hợp AI fashion/model generation
- [ ] Chờ feedback để chốt recommendation cuối cùng

**Thời gian thực tế:** *(cập nhật sau)*

---

### [DA-184] — DA-E06-06 Document Redis key patterns

**Jira status:** In Review  
**Branch:** *(cập nhật sau)*  
**Commit chính:** *(cập nhật sau)*  
**File tạo ra / thay đổi:**
- *(cập nhật sau khi review xong)*

**Mô tả công việc đã làm:**

Document các nhóm Redis key pattern chính gồm JWT blacklist, rate limit, OAuth state và trending cache. Task đang ở trạng thái In Review nên cần reviewer xác nhận naming convention, TTL và format key có khớp với gateway/publisher/AI service không.

**Kết quả đạt được:**
- [x] Redis key pattern được đưa vào review
- [x] Có phân nhóm theo use case: auth, rate limit, OAuth, trend cache
- [ ] Cần cập nhật file/commit cụ thể sau khi review hoàn tất

**Thời gian thực tế:** *(cập nhật sau)*

---

### [DA-179] — DA-E07-02 Define endpoints cho ai-service

**Jira status:** Done  
**Branch:** `docs/DA-E07-02-define-endpoint-ai`  
**Commit chính:** `7c3d8c5` — `docs(DA-179): dinh nghia endpoints ai-service`  
**File tạo ra / thay đổi:**
- `docs/api/endpoints/DA-E07-02_AI-service-endpoints.md` — tài liệu contract chi tiết cho toàn bộ endpoint group của `ai-service`
- `docs/plan/sprints/sprint_04/members/tuannm.md` — cập nhật trạng thái và mô tả kết quả task DA-E07-02

**Mô tả công việc đã làm:**

Viết tài liệu endpoint contract cho `brandhub-ai-service`, bao phủ đầy đủ 6 nhóm endpoint được yêu cầu: `/ai/content`, `/ai/image`, `/ai/video`, `/ai/ambassador`, `/ai/rag`, `/ai/trends`. Tài liệu xác định base URL nội bộ `http://ai-service:8082`, API prefix `/api/v1`, cơ chế gọi nội bộ bằng `X-Internal-Key`, response envelope theo DA-E07-04 `ApiResponse<T>`, mã lỗi phổ biến và constraints đầu vào.

Trong từng nhóm endpoint, bổ sung method, request path, request body mẫu, response body mẫu, validation rules và lỗi thường gặp. Với các tác vụ chạy lâu như image/video/ambassador generation, tài liệu nêu rõ hướng async job/polling để DA-E07-06 có thể chuyển tiếp thành OpenAPI YAML mà không phải đoán contract.

**Kết quả đạt được:**
- [x] `/ai/content` được mô tả với generate và regenerate flow
- [x] `/ai/image` được mô tả với request tạo ảnh và response asset URL
- [x] `/ai/video` được mô tả với async generate job và endpoint polling status
- [x] `/ai/ambassador` được mô tả cho face-consistent generation
- [x] `/ai/rag` được mô tả cho upload, query và delete knowledge document
- [x] `/ai/trends` được mô tả với query params và response trend suggestions
- [x] Có validation/input constraints và common error notes cho từng nhóm endpoint
- [x] Unblock cho DA-E07-06 OpenAPI YAML spec cho ai-service

**Khó khăn gặp phải:** Cần thống nhất giữa endpoint prefix trong plan (`/ai/*`) và FastAPI README hiện tại (`/api/v1/ai/*`). Chọn ghi rõ `API prefix: /api/v1` và path đầy đủ `/api/v1/ai/...` để khớp cấu trúc service hiện có.

**Thời gian thực tế:** ~3 giờ

---

### [DA-448] — DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn

**Jira status:** In Progress  
**Branch:** `docs/DA-E07-02-define-endpoint-ai`  
**Commit chính:** *(cập nhật sau khi report hoàn tất)*  
**File tạo ra / thay đổi:**
- `docs/plan/sprints/sprint_04/members/tuannm.md` — cập nhật report cá nhân Sprint 4

**Mô tả công việc đã làm:**

Cập nhật lại report cá nhân Sprint 4 theo đúng danh sách task trên Jira board, bổ sung phần chi tiết công việc đã làm cho DA-E07-02 và giữ các task còn lại ở trạng thái hiện tại.

**Kết quả đạt được:**
- [x] Task list Sprint 4 khớp danh sách 10 task từ Jira board
- [x] DA-E07-02 được cập nhật Done
- [x] Có phần mô tả file đã tạo/cập nhật cho task DA-E07-02
- [ ] Cần cập nhật tiếp khi các task còn lại chuyển trạng thái

**Thời gian thực tế:** *(cập nhật sau)*

---

## 4. Tasks chưa hoàn thành

| Task ID | Lý do chưa hoàn thành | Mức độ ảnh hưởng | Hành động tiếp theo |
|---|---|---|---|
| DA-155 | Phụ thuộc trực tiếp vào DA-179; hiện DA-179 đã Done nên có thể bắt đầu | Cao — cần để có OpenAPI YAML cho ai-service | Dùng `DA-E07-02_AI-service-endpoints.md` làm nguồn viết OpenAPI YAML |
| DA-173 | Chưa triển khai trong phạm vi cập nhật hiện tại | Cao — ảnh hưởng local dev infrastructure | Xác định service list, ports, volumes, healthchecks trước khi viết compose |
| DA-187 | Chưa triển khai trong phạm vi cập nhật hiện tại | Cao — ảnh hưởng database bootstrap | Viết và test init-postgres.sql trong PostgreSQL container |
| DA-209 | Chưa triển khai trong phạm vi cập nhật hiện tại | Cao — ảnh hưởng API Gateway rate limit | Thống nhất Redis key pattern từ DA-184 trước khi implement |
| DA-415 | Chưa triển khai trong phạm vi cập nhật hiện tại | Trung bình/Cao — ảnh hưởng AI service config | Rà soát env vars, secret handling và tài liệu setup |
| DA-441 | Chưa hoàn tất trong report này | Thấp/Trung bình — ảnh hưởng hồ sơ sprint trước | Hoàn thiện report Sprint 3 riêng, không trộn với Sprint 4 |

---

## 5. Đóng góp ngoài tasks chính

- Chuẩn hóa contract endpoint để business-service, ai-service và OpenAPI spec dùng cùng một nguồn tham chiếu.
- Ghi rõ các constraints và common errors để giảm rủi ro hiểu sai khi implement FastAPI hoặc viết OpenAPI YAML.
- Cập nhật lại report Sprint 4 theo danh sách task thực tế trên Jira board.

---

## 6. Học được gì trong sprint này

1. **API contract cần đủ chi tiết trước OpenAPI:** Nếu chỉ liệt kê path thì DA-E07-06 vẫn bị block vì thiếu schema, status code và error cases.
2. **AI endpoint nên phân biệt sync/async rõ ràng:** Content/RAG query có thể sync, còn video/image/ambassador cần thiết kế theo job để tránh timeout.
3. **Report sprint phải bám Jira board thực tế:** Không được dùng template cũ 2 task khi Sprint 4 đã có danh sách task mới.

---

## 7. Feedback & Đề xuất

- Nên dùng `docs/api/endpoints/DA-E07-02_AI-service-endpoints.md` làm nguồn chính khi viết DA-E07-06 OpenAPI YAML.
- Cần rà soát lại implementation trong `brandhub-ai-service` để đảm bảo path thực tế, model Pydantic và error code khớp tài liệu.
- Nên cập nhật report theo trạng thái Jira mỗi cuối ngày, tránh mất task hoặc ghi sai trạng thái.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | /5 | Chưa chấm — sprint chưa kết thúc |
| Chất lượng deliverable | /5 | DA-E07-02 đã có endpoint contract chi tiết; các task khác cần cập nhật tiếp |
| Giao tiếp với team | /5 | Cần cập nhật lại sau khi có review feedback từ DA-59 và DA-184 |
| Chủ động xử lý blocker | /5 | DA-179 đã Done, unblock DA-155 |
| **Tổng** | **/20** | Chưa đánh giá chính thức |

---

*Sprint 4: 2026-07-03 đến 2026-07-17*
