# Sprint 4 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Chơn Phước |
| GitHub | [@phuocnc] |
| Role | Publisher Engineer |
| Sprint | Sprint 4 |
| Ngày nộp | 2026-08-02 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E07-03 | [DA-E07-03](https://letritrung2605.atlassian.net/browse/DA-E07-03) | RabbitMQ message format — define PublishJobMessage contract giữa business-service và publisher-service *(carry over từ Sprint 3)* | 🔴 Critical | ✅ Done |
| DA-E07-07 | [DA-E07-07](https://letritrung2605.atlassian.net/browse/DA-E07-07) | Social platform API specs — document Facebook, Instagram, TikTok, Threads, Zalo APIs *(carry over từ Sprint 3)* | 🟡 High | ✅ Done |
| DA-E09-05 | [DA-E09-05](https://letritrung2605.atlassian.net/browse/DA-E09-05) | Write README.md for infrastructure repo (step-by-step setup guide) | 🟢 Medium | ✅ Done |
| DA-E10-02 | [DA-E10-02](https://letritrung2605.atlassian.net/browse/DA-E10-02) | GitHub Actions CI for publisher-service (build + test + push Docker image) | 🟡 High | ✅ Done |

> DA-E07-03 và DA-E07-07 là carry over từ Sprint 3.

**Tổng:** 4 tasks | Done: 4 | In Review: 0 | Chưa hoàn thành: 0

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

### DA-E07-07 — Social Platform API Specifications

**Jira status:** Done
**File tạo ra:**
- `docs/architecture/social_platforms_api_specs.html`

**Mô tả công việc đã làm:**
- Tổng hợp và document API specs cho 5 nền tảng social media:
  1. **Facebook** — Graph API v19: `/me/feed` (text post), `/me/photos` (image post), page access token
  2. **Instagram** — Content Publishing API: 2-step create container → publish, business account required
  3. **TikTok** — Content Posting API v2: direct post, video upload with polling
  4. **Threads** — Threads API (Meta): create container → publish, max 500 chars
  5. **Zalo** — Official Account API: Article API (text+image) + Photo API (image only)
- Mỗi platform document: API version, authentication method, post creation endpoint, media upload method, rate limits, error response format.
- Ghi chú các gotchas: Instagram cần Facebook Page linked, TikTok cần approved app, Zalo cần OA verified.

**Kết quả đạt được:**
- [x] 5 platform API specs hoàn chỉnh, sẵn sàng cho Sprint 7-8 (Publisher Service implementation).
- [x] HTML card-based layout — mỗi platform 1 card với API version, auth, endpoints, rate limits, gotchas.

---

### DA-E09-05 — README.md for Infrastructure Repo

**Jira status:** Done
**File tạo ra:**
- `README.md` (root của brandhub-infrastructure)

**Mô tả công việc đã làm:**
- Viết step-by-step setup guide cho developer mới clone repo về chạy được trong < 10 phút.
- Cấu trúc README: Overview → Prerequisites (Docker, Git, Java 21, Python 3.11, Node 20) → Clone repo → Environment setup (copy .env.example) → Docker Compose up → Verify services → Troubleshooting.
- Document cấu trúc thư mục: `docker/` (compose files + .env), `scripts/` (init SQL + Mongo).

**Kết quả đạt được:**
- [x] New developer có thể `docker-compose up` full stack theo README.

---

### DA-E10-02 — GitHub Actions CI for Publisher Service

**Jira status:** Done
**Repo:** `brandhub-publisher-service`
**File tạo ra:**
- `.github/workflows/ci.yml`

**Mô tả công việc đã làm:**
- Thiết lập CI workflow cho publisher-service: trigger on push/pull request vào `develop` và `main`.
- Pipeline steps: Checkout → Set up Java 21 + Maven cache → `mvn test` → `docker build` → `docker push ghcr.io`.
- Tận dụng Maven dependency cache để giảm thời gian build.

**Kết quả đạt được:**
- [x] CI tự động chạy test + build Docker image cho publisher-service.
- [x] Image push lên GitHub Container Registry.

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Hỗ trợ team review docker-compose structure và góp ý về cách tổ chức multi-file compose (infra core + dev override + app stack).
- Các file HTML architecture docs (rabbitmq_publisher_contract, social_platforms_api_specs) được thiết kế dạng card-based visualization — dễ reference hơn markdown thuần cho technical specs phức tạp.

---

## 6. Học được gì trong sprint này

1. **RabbitMQ contract design:** Exchange type, routing key, queue binding, dead-letter queue — cần được thiết kế trước khi code publisher-service để tránh refactor message format sau này.
2. **Social platform API diversity:** Mỗi platform có auth flow, rate limit, và content format khác nhau. Facebook/Instagram/Threads dùng chung Meta Graph API nhưng scope khác. TikTok và Zalo là hệ sinh thái riêng.
3. **README là first impression:** Developer mới quyết định ở lại hay bỏ cuộc trong 10 phút đầu. README phải ngắn gọn, có step-by-step, có troubleshooting.

---

## 7. Feedback & Đề xuất

- Nên có một `docs/architecture/README.md` index để liệt kê tất cả architecture docs trong thư mục — hiện tại có 6 file HTML, khó biết file nào cho mục đích gì nếu không đọc từng file.
- DA-E07-03 và DA-E07-07 ban đầu assign ở Sprint 3 nhưng bị delay do phụ thuộc vào thiết kế tổng thể. Các task research/design document nên được estimate buffer time.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 3/5 | 2/4 task carry over từ Sprint 3, hoàn thành trong Sprint 4 |
| Chất lượng deliverable | 5/5 | Document đầy đủ, HTML visualization trực quan, README dễ làm theo |
| Giao tiếp với team | 4/5 | Align RabbitMQ contract với Trung, phối hợp CI setup |
| Chủ động xử lý blocker | 4/5 | Tự research 5 platform APIs, tổng hợp thành specs rõ ràng |
| **Tổng** | **16/20** | |

---

*Deadline nộp: 2026-07-14 | Nộp muộn: 2026-08-02*
