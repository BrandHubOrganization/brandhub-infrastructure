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
| DA-203 | [DA-203](https://letritrung2605.atlassian.net/browse/DA-203) | DA-E09-03 Write .env.example consolidating all environment variables across 6 services | 🔴 Critical | 🔄 In Review |
| DA-209 | [DA-209](https://letritrung2605.atlassian.net/browse/DA-209) | DA-E11-03 Write rate limiting filter dùng Redis (100 requests/minute/user) | 🔴 Critical | 🔄 In Review |
| DA-254 | [DA-254](https://letritrung2605.atlassian.net/browse/DA-254) | DA-AI02-07 Document ChromaDB collection design (collection naming per client, metadata schema, query patterns) | 🟡 High | 🔄 In Review |
| DA-415 | [DA-415](https://letritrung2605.atlassian.net/browse/DA-415) | DA-E09-07 AI Service — LLM keys + Payment Gateway | 🟡 High | 🔄 In Review |
| DA-419 | [DA-419](https://letritrung2605.atlassian.net/browse/DA-419) | DA-E11-06 Write Dockerfile for api-gateway | 🟡 High | 🔄 In Review |
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn | 🟣 Medium | 🚧 In Progress |
| DA-537 | [DA-537](https://letritrung2605.atlassian.net/browse/DA-537) | DA-E48-01 Write individual AI iteration report for Iteration 1 — Tuấn | 🟢 Medium | ⏳ To Do |

**Tổng:** 9 tasks | Done: 0 | In Review: 7 | In Progress: 1 | To Do: 1

---

## 3. Chi tiết công việc đã làm cho 7 task In Review

---

### [DA-173] — Write docker-compose.yml to run the full infrastructure stack

**Jira status:** In Review
**Phạm vi:** cấu hình Docker Compose cho môi trường local/dev, tách rõ phần infrastructure core, phần expose port phục vụ development, và phần app stack.

**File liên quan:**
- `docker/docker-compose.infra.yml`
- `docker/docker-compose.dev.yml`
- `docker/docker-compose.apps.yml`
- `docker/README.md`
- `docker/run-compose.bat`

**Công việc đã thực hiện:**
- Tạo cấu hình core infrastructure cho PostgreSQL và Redis, có named volumes để giữ dữ liệu qua các lần recreate container.
- Mount `scripts/init-postgres.sql` vào PostgreSQL để init schema khi volume DB được tạo lần đầu.
- Cấu hình healthcheck cho PostgreSQL và Redis để các service phụ thuộc có thể đợi trạng thái healthy.
- Tách `docker-compose.dev.yml` để expose host ports và pgAdmin, tránh để dev-only port binding nằm trong file infra core.
- Chuẩn hóa network chung `brandhub-network` để infra, app services và dev tools giao tiếp bằng Docker DNS.
- Chuẩn bị cấu trúc compose theo hướng có thể mở rộng thêm RabbitMQ và ChromaDB khi team chốt image/version và bật lại các service này.

**Kết quả đạt được:**
- Local infra có thể chạy theo mô hình tách lớp: infra core + dev override + app stack.
- PostgreSQL, Redis và pgAdmin có cấu hình rõ ràng, dễ chạy cho developer mới.
- Các app service có nền network chung để kết nối DB/cache/message broker qua service name.

**Ghi chú review:** RabbitMQ và ChromaDB đã được định hướng trong compose nhưng cần chốt version/healthcheck trước khi bật mặc định trong infra core.

---

### [DA-187] — Integrated init-postgres.sql

**Jira status:** In Review
**Phạm vi:** tích hợp script PostgreSQL để tạo schema ban đầu và seed subscription plans.

**File liên quan:**
- `scripts/init-postgres.sql`
- `docker/docker-compose.infra.yml`

**Công việc đã thực hiện:**
- Viết init script idempotent, có thể chạy lại an toàn trên môi trường development.
- Bật extension `pgcrypto` để dùng `gen_random_uuid()` cho các bảng UUID.
- Tạo enum cho user status, OAuth provider, workspace role, plan, subscription status, invoice status, payment status và audit action.
- Tạo các nhóm bảng PostgreSQL chính:
  - Identity: `users`, `user_oauth_providers`, `user_refresh_tokens`, `user_system_roles`, `password_reset_tokens`.
  - Workspace: `workspaces`, `workspace_members`, `workspace_invitations`, `workspace_member_permissions`, `clients`.
  - Billing: `subscription_plans`, `workspace_subscriptions`, `invoices`, `payments`, `audit_logs`.
- Thêm indexes cần thiết cho email, token, workspace, subscription, invoice, payment và audit query.
- Thêm trigger `set_updated_at()` cho các bảng cần tracking `updated_at`.
- Thêm trigger chặn update/delete `audit_logs` để giữ tính append-only.
- Seed 4 subscription plans: Free, Basic, Pro, Enterprise với quota member/client/post/AI credits và feature list.

**Kết quả đạt được:**
- PostgreSQL có schema ban đầu đủ cho identity, workspace và billing.
- Subscription plan seed chạy tự động khi PostgreSQL container khởi tạo lần đầu.
- Script bám đúng nguyên tắc financial/billing nằm ở PostgreSQL, không mirror dữ liệu MongoDB.

---

### [DA-203] — Write .env.example consolidating all environment variables across 6 services

**Jira status:** In Review
**Phạm vi:** gom các biến môi trường dùng cho local Docker/dev stack vào một file mẫu chung.

**File liên quan:**
- `docker/.env.example`
- `docker/docker-compose.infra.yml`
- `docker/docker-compose.dev.yml`
- `docker/docker-compose.apps.yml`

**Công việc đã thực hiện:**
- Tạo cấu trúc `.env.example` theo nhóm rõ ràng: runtime profile, Docker host ports, PostgreSQL, MongoDB, internal URLs, Redis, RabbitMQ, pgAdmin, security, rate limiting, AWS S3, LLM providers, image/video generation, social OAuth, service port aliases và PayOS.
- Bổ sung host port cho các service chính: API Gateway, Business Service, AI Service, Publisher Service, Web Dashboard, PostgreSQL, Redis, RabbitMQ, ChromaDB và pgAdmin.
- Chuẩn hóa biến nội bộ giữa các service: `BUSINESS_SERVICE_URL`, `AI_SERVICE_URL`, `INTERNAL_SERVICE_KEY`.
- Bổ sung nhóm rate limit dùng chung cho gateway và các workflow nhạy cảm: auth, AI text/image/video, publish.
- Bổ sung biến LLM/payment: `GROQ_API_KEY`, `ANTHROPIC_API_KEY`, `LLM_PROVIDER`, `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`, `PAYOS_CHECKSUM_KEY`, `PAYOS_WEBHOOK_URL`.
- Bổ sung biến OAuth/social callback cho Facebook, Instagram, TikTok, Threads.

**Kết quả đạt được:**
- Developer có một file mẫu trung tâm để copy thành `.env` trước khi chạy Docker Compose.
- Các compose files có source biến thống nhất, giảm hard-code trong file compose.
- Những key nhạy cảm được để trống hoặc placeholder, không commit secret thật.

---

### [DA-209] — Write rate limiting filter dùng Redis

**Jira status:** In Review
**Phạm vi:** thiết kế và document Redis rate limiting cho API Gateway với default 100 requests/minute/user.

**File liên quan:**
- `docs/api/DA-E11-03_Redis_Rate_Limiting_Filter.md`
- `docs/database/DA-E06-06_Redis_Key_Patterns.md`
- `docker/.env.example`

**Công việc đã thực hiện:**
- Xác định vị trí filter trong gateway pipeline: chạy sau JWT validation và trước khi forward request xuống downstream service.
- Định nghĩa Redis key contract: `ratelimit:gateway:{userId}:{minute}` để tránh đụng key với các limiter service-level sau này.
- Chọn thuật toán fixed-window theo minute bucket, dùng `INCR` + `EXPIRE` với TTL 60 giây.
- Đề xuất Lua script để đảm bảo `INCR` và conditional `EXPIRE` chạy atomic, tránh lỗi key không có TTL khi có race condition.
- Định nghĩa cấu hình:
  - `RATE_LIMIT_PER_MINUTE`
  - `RATE_LIMIT_TTL_SECONDS`
  - `RATE_LIMIT_FAIL_OPEN`
- Định nghĩa response khi vượt limit: HTTP `429`, headers `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`, và error body theo format API chung.
- Viết checklist test cho 100 request đầu, request thứ 101, TTL, thiếu `X-User-Id`, Redis failure và thứ tự filter.

**Kết quả đạt được:**
- Có contract kỹ thuật rõ ràng để implement rate limiter trong `brandhub-api-gateway`.
- Redis key pattern nhất quán với tài liệu database/cache.
- Có hướng mở rộng cho auth, AI generation và publish workflow với limit riêng.

---

### [DA-254] — Document ChromaDB collection design

**Jira status:** In Review
**Phạm vi:** tài liệu hóa thiết kế collection ChromaDB cho RAG pipeline của AI service.

**File liên quan:**
- `docs/database/DA-AI02-07_ChromaDB_Collection_Design.md`

**Công việc đã thực hiện:**
- Chốt convention collection theo client: `client_{clientId}`.
- Ghi rõ lý do chọn collection-per-client: tránh leak context giữa client, search tập trung theo brand/client, phù hợp request RAG có `clientId`.
- Định nghĩa deterministic chunk ID: `{documentId}:{chunkIndex}` để hỗ trợ re-index idempotent và delete theo document.
- Định nghĩa metadata bắt buộc cho mỗi chunk:
  - `documentId`
  - `clientId`
  - `chunkIndex`
  - `source`
  - `uploadedAt`
- Viết pattern ghi dữ liệu: validate request, get/create collection, chunk text, embed, store chunk text + vector + metadata, sync chunk IDs về MongoDB `knowledge_documents.chunkIds`.
- Viết query pattern top-K semantic search có filter `where={"clientId": {"$eq": client_id}}`.
- Viết optional document-scoped search dùng `$and` cho debug hoặc rebuild context.
- Viết delete pattern: fetch chunk IDs theo `documentId` rồi delete theo IDs, không xóa toàn collection.
- Ghi rõ giới hạn ChromaDB: không cross-collection query, không dùng làm primary document registry.

**Kết quả đạt được:**
- AI/RAG downstream tasks có contract rõ cho chunking, embedding, semantic search và delete.
- MongoDB vẫn là source of truth cho document lifecycle; ChromaDB chỉ là vector retrieval index.
- Tài liệu unblock các task DA-AI03-02, DA-AI03-03, DA-AI03-04.

---

### [DA-415] — AI Service — LLM keys + Payment Gateway

**Jira status:** In Review
**Phạm vi:** rà soát và bổ sung nhóm biến môi trường cho AI service, LLM provider và payment gateway vào cấu hình chung.

**File liên quan:**
- `docker/.env.example`
- `docker/docker-compose.apps.yml`

**Công việc đã thực hiện:**
- Tách nhóm LLM provider config trong `.env.example`: `LLM_PROVIDER`, `GROQ_API_KEY`, `ANTHROPIC_API_KEY`.
- Bổ sung nhóm image/video generation keys: `STABILITY_AI_API_KEY`, `GOOGLE_VEO_API_KEY`.
- Bổ sung nhóm AWS S3 dùng cho media generated/uploaded bởi AI và các service liên quan.
- Bổ sung nhóm PayOS payment gateway: `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`, `PAYOS_CHECKSUM_KEY`, `PAYOS_WEBHOOK_URL`.
- Đảm bảo các key nhạy cảm chỉ xuất hiện dưới dạng placeholder, không commit value thật.
- Kiểm tra cách các biến này được truyền vào app compose để không hard-code provider key trong Docker Compose.

**Kết quả đạt được:**
- `.env.example` đã bao phủ các key cần thiết cho AI generation và payment integration.
- Các integration nhạy cảm có vị trí cấu hình tập trung, dễ chuyển sang secret manager về sau.
- Giảm rủi ro mỗi service tự đặt tên biến khác nhau cho cùng một nhóm cấu hình.

---

### [DA-419] — Write Dockerfile for api-gateway

**Jira status:** In Review
**Phạm vi:** tạo Dockerfile để build và chạy `brandhub-api-gateway` bằng Java 21.

**File liên quan:**
- `brandhub-api-gateway/Dockerfile`
- `brandhub-api-gateway/docker-compose.yml`
- `docker/docker-compose.apps.yml`

**Công việc đã thực hiện:**
- Viết Dockerfile multi-stage:
  - Stage build dùng `maven:3.9-eclipse-temurin-21`.
  - Stage runtime dùng `eclipse-temurin:21-jre-alpine`.
- Copy `pom.xml` trước và chạy `mvn dependency:go-offline` để tận dụng Docker layer cache cho dependency.
- Copy source và build jar bằng `mvn package -DskipTests`.
- Runtime image chỉ copy jar từ build stage, giảm kích thước image so với chạy full Maven image.
- Cấu hình JVM container support qua `JAVA_OPTS` và `JAVA_TOOL_OPTIONS` với `MaxRAMPercentage=75.0`.
- Expose port `8080` và chạy app bằng `java -jar app.jar`.
- Liên kết Dockerfile vào compose của gateway/app stack để build image local.

**Kết quả đạt được:**
- API Gateway có Dockerfile độc lập, build được image chạy trên Java 21 runtime.
- Compose có thể build gateway từ source repo khi chạy full app stack.
- Runtime image gọn hơn và tách biệt khỏi build tooling.

---

## 4. Tasks chưa hoàn thành / chưa chuyển review

| Task ID | Jira Link | Mô tả | Trạng thái | Ghi chú |
|---|---|---|---|---|
| DA-448 | [DA-448](https://letritrung2605.atlassian.net/browse/DA-448) | DA-E47-24 Write individual sprint report for Sprint 4 — Tuấn | In Progress | Đang cập nhật báo cáo cá nhân Sprint 4 theo 7 task In Review |
| DA-537 | [DA-537](https://letritrung2605.atlassian.net/browse/DA-537) | DA-E48-01 Write individual AI iteration report for Iteration 1 — Tuấn | To Do | Chưa bắt đầu trong phạm vi Sprint 4 report này |

---

## 5. Đóng góp ngoài tasks chính

- Rà lại danh sách task Sprint 4 để tránh ghi trùng các task đã báo cáo ở Sprint 3.
- Đồng bộ lại trạng thái giữa bảng task tổng quan và phần chi tiết công việc.
- Làm rõ artifact/file liên quan cho từng task để reviewer có thể kiểm tra nhanh.
- Ghi chú các điểm cần review tiếp thay vì báo cáo như đã Done tuyệt đối.

---

## 6. Học được gì trong sprint này

1. **Infra cần tách core và dev override:** File infra core nên tập trung vào service/volume/network, còn host ports và tool như pgAdmin nên nằm ở dev compose.
2. **.env.example là contract giữa các repo:** Nếu thiếu hoặc đặt tên biến không thống nhất, Docker Compose vẫn có thể chạy nhưng service nhận cấu hình rỗng hoặc sai endpoint.
3. **Redis rate limiting cần atomic operation:** `INCR` và `EXPIRE` tách rời có thể tạo key không TTL nếu có lỗi/race, nên Lua script là hướng an toàn hơn.
4. **ChromaDB không phải primary DB:** Chỉ nên dùng làm retrieval index, còn document lifecycle và metadata nghiệp vụ phải giữ ở MongoDB.
5. **Report cần nhất quán với Jira status:** `In Review` không nên bị đưa vào mục `To Do`, nếu không báo cáo tự mâu thuẫn.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Nên chốt một nguồn task chính cho từng sprint trước khi viết report cá nhân. Nếu dùng ảnh Jira để cập nhật, cần đối chiếu với plan và artifact thực tế để tránh ghi sai trạng thái.

### 7.2 Về tài liệu

Các report cá nhân nên ghi cả Jira key (`DA-173`) và mã plan nội bộ (`DA-E09-01`) vì ảnh Jira dùng key số, còn tài liệu plan dùng mã epic/task.

### 7.3 Đề xuất cho sprint tiếp theo

- Chạy lại compose full stack sau khi bật RabbitMQ/ChromaDB mặc định hoặc xác nhận chúng vẫn nằm ngoài scope local core.
- Thêm checklist verify cụ thể cho từng service trong README/setup guide.
- Hoàn tất task `DA-537` để đồng bộ báo cáo Sprint và báo cáo AI iteration.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---:|---|
| Hoàn thành đúng deadline | 4/5 | 7 task chính đã ở trạng thái In Review, còn report iteration chưa làm |
| Chất lượng deliverable | 4/5 | Artifact có cấu trúc rõ, nhưng một số phần infra như RabbitMQ/ChromaDB cần review thêm trước khi bật mặc định |
| Giao tiếp với team | 4/5 | Đã làm rõ file/artifact liên quan cho từng task |
| Chủ động xử lý blocker | 4/5 | Nhận diện mâu thuẫn giữa status task và phần chưa hoàn thành trong report |
| **Tổng** | **16/20** | |

---

*Nộp: 2026-07-14 | Sprint 4 ends: 2026-07-14*
