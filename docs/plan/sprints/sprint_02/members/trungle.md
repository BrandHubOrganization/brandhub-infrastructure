# Sprint 2 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Lê Trí Trung |
| GitHub | [@trungle](https://github.com/trungle) |
| Role | Leader / Backend Engineer |
| Sprint | Sprint 2 |
| Ngày nộp | 2026-06-29 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E03-02 | [DA-E03-02](https://letritrung2605.atlassian.net/browse/DA-E03-02) | Write UC 01–20 (Admin + Agency Owner flows) | 🔴 Critical | ✅ Done |
| DA-E04-01 | [DA-E04-01](https://letritrung2605.atlassian.net/browse/DA-E04-01) | Write functional objectives per 6 roles | 🔴 Critical | ✅ Done |
| DA-E04-02 | [DA-E04-02](https://letritrung2605.atlassian.net/browse/DA-E04-02) | Write non-functional requirements | 🔴 Critical | ✅ Done |
| DA-E04-05 | [DA-E04-05](https://letritrung2605.atlassian.net/browse/DA-E04-05) | Fill + finalize Capstone Register form | 🔴 Critical | ✅ Done |
| DA-E05-01 | [DA-E05-01](https://letritrung2605.atlassian.net/browse/DA-E05-01) | System architecture overview diagram | 🔴 Critical | ✅ Done |
| DA-E05-02 | [DA-E05-02](https://letritrung2605.atlassian.net/browse/DA-E05-02) | Service responsibilities and boundaries | 🔴 Critical | ✅ Done |
| DA-E05-03 | [DA-E05-03](https://letritrung2605.atlassian.net/browse/DA-E05-03) | Database ownership diagram | 🔴 Critical | ✅ Done |
| DA-E05-04 | [DA-E05-04](https://letritrung2605.atlassian.net/browse/DA-E05-04) | Service-to-service communication doc | 🔴 Critical | ✅ Done |
| DA-E05-05 | [DA-E05-05](https://letritrung2605.atlassian.net/browse/DA-E05-05) | 4 ADRs (polyrepo, MongoDB+PG, RabbitMQ, Gateway) | 🔴 Critical | ✅ Done |
| DA-E05-08 | [DA-E05-08](https://letritrung2605.atlassian.net/browse/DA-E05-08) | Compile full technical document | 🟡 High | ✅ Done |

**Tổng:** 10 tasks | ✅ Done: 10 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### [DA-E03-02] — Use Cases 01–20

- Viết detailed descriptions cho 20 UC thuộc ADMIN (UC01–10) và AGENCY_OWNER (UC11–20)
- Format: Actor | UC ID | Name | Description | Precondition | Main Flow | Alt Flow | Postcondition
- Output: section trong `BrandHub_Capstone_Register.docx`

### [DA-E04-01/02/05] — Requirements + Capstone Register

- **Functional objectives:** 6 roles × feature matrix — mỗi role có danh sách tính năng được phép làm
- **Non-functional requirements:**
  - Performance: API p95 < 500ms (non-AI), AI content p95 < 10s, AI image p95 < 20s
  - Security: JWT RS256, bcrypt cost=12, AES-256-GCM token encryption
  - Reliability: 99.5% uptime, retry với exponential backoff
  - Scalability: support 200 concurrent users
- **Capstone Register form:** điền đầy đủ `BrandHub_Capstone_Register.docx` và nộp đúng deadline FPT

### [DA-E05-01] — System Architecture Diagram

- **File:** `docs/architecture/brandhub_architecture.html`
- **Commit:** `d74c885` (Jun 8)
- Interactive HTML diagram, 518 lines, vẽ full stack: Web Dashboard + Mobile App → API Gateway → 3 backend services → 5 databases (MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ) → AWS S3 + Social APIs
- Styled với custom CSS, icon Tabler Icons, color-coded theo service type

### [DA-E05-02/03/04] — Service boundaries + DB ownership + Inter-service communication

- **DA-E05-02:** Document rõ what each service does/does NOT do — tránh scope creep khi implement
  - business-service: auth, workspace, clients, posts, subscriptions — KHÔNG gọi social APIs trực tiếp
  - ai-service: LLM, RAG, image/video gen — KHÔNG biết về workspaceId/clientId logic
  - publisher-service: nhận message từ RabbitMQ, gọi platform APIs — KHÔNG có DB riêng ngoài state queue
- **DA-E05-03:** Database ownership diagram — `docs/architecture/brandhub_db_ownership_diagram.html`
  - Commit: `b5f66d3` (Jun 8), 569 lines HTML
  - Vẽ rõ: MongoDB → business-service (documents), PostgreSQL → business-service (payments/audit), ChromaDB → ai-service, RabbitMQ → business↔publisher
- **DA-E05-04:** Communication patterns:
  - REST sync: business-service → ai-service (`/internal/ai/*` với X-Internal-Key)
  - RabbitMQ async: business-service → publisher-service (PublishJobMessage)
  - HTTP callback: publisher-service → business-service (`/internal/posts/{id}/publish-result`)

### [DA-E05-05] — 4 ADRs

Viết 4 Architecture Decision Records, format: Context | Decision | Rationale | Consequences | Alternatives:

1. **ADR-001: Polyrepo** — 7 repos riêng biệt thay vì monorepo. Lý do: team nhỏ, mỗi người own 1 service, độc lập CI/CD, tránh merge conflict cross-service. Trade-off: phức tạp hơn khi clone và cross-service changes.
2. **ADR-002: MongoDB + PostgreSQL split** — MongoDB cho documents/content (schema-flexible, nhiều thay đổi), PostgreSQL cho payments/subscriptions/audit (ACID required, relational). Trade-off: 2 DB để maintain.
3. **ADR-003: RabbitMQ async publishing** — Chosen over direct HTTP để đảm bảo delivery (at-least-once), retry tự động, DLQ cho failed messages. Trade-off: thêm dependency, cần manage queue.
4. **ADR-004: Spring Cloud Gateway** — Centralized JWT validation + rate limiting + routing thay vì mỗi service tự validate. Trade-off: single point of failure nếu không HA.

Included trong `BrandHub_Project_Plan.md`

### [DA-E05-08] — Full Technical Document + Project Plan

- **File:** `docs/plan/BrandHub_Project_Plan.md`
- **Commit:** `5a55296` (Jun 15), 791 lines
- Bao gồm: team info, tech stack, system architecture, RBAC roles, 16 sprint plans đầy đủ (Sprint 1–16) + 4 AI iterations, Epic/Task breakdown với assignees + priorities
- **File:** `docs/plan/BrandHub_Project_Plan_VI.md` — bản dịch tiếng Việt

### [DA-E05-01 bonus] — Polyrepo Structure Diagram + Architecture Reference

- `docs/architecture/brandhub_polyrepo_structure.html` — commit `bf70f70` (Jun 8), 584 lines
  - Visual diagram 7 repos với service dependencies, port assignments, language per service
- `docs/architecture/brandhub_arch_reference_style.html` — style reference cho team dùng khi vẽ diagrams

---

## 4. Tasks chưa hoàn thành

*Không có.*

---

## 5. Đóng góp ngoài tasks chính

### [DA-408] — Git Commit Convention

- **File:** `docs/rule/git-commit-convention.md`
- **Commit:** `7c5d38a` (Jun 18), 237 lines
- Viết đầy đủ Conventional Commits guidelines: format, types (feat/fix/docs/chore/refactor), scope, breaking changes, examples, bad vs good commit messages
- PR template + pull request process guide (`95af6d7`)

### [DA-409] — VitePress HTML Viewer

- **Commit:** `84095ab` (Jun 19)
- Implement custom `HtmlViewer.vue` component trong VitePress để render các file `.html` (architecture diagrams) trực tiếp trong docs site thay vì download
- Update routing config trong `.vitepress/config.js` — 94 lines changes
- Đây là prerequisite để toàn bộ HTML diagrams (architecture, DB ownership, polyrepo) có thể xem được tại VitePress docs site

### Sprint Plans Sprint 10–16

- **Commit:** `5a55296` (Jun 15)
- Viết detailed sprint plans cho Sprint 10–16 (còn lại của dự án) — 1,300+ lines covering content workflow, frontend, mobile, testing, deployment
- 4 AI Iteration plans: `AI_Iteration_1` → `AI_Iteration_4` tổng cộng 474 lines

---

## 6. Học được gì trong sprint này

1. **Architecture Decision Records** — cách document architectural decisions sao cho rõ context + tradeoffs, tránh "tại sao lại chọn cái này" khi reviewer hỏi sau 3 tháng
2. **HTML interactive diagrams không cần thư viện** — dùng pure CSS Grid + Flexbox để vẽ architecture diagrams đẹp mà không cần Mermaid hay Draw.io — load nhanh hơn, fully customizable
3. **VitePress plugin architecture** — cách thêm custom Vue components vào VitePress theme, register globally, handle routing cho non-markdown files

---

## 7. Feedback & Đề xuất

- Sprint 2 heavy với 10 tasks chính + 3 bonus tasks — workload không đều với team (Trung làm phần lớn E04+E05, Phước làm E03). Cần phân công cân bằng hơn từ Sprint 3.
- Architecture diagrams dạng HTML rất tốt để xem, nhưng khó edit khi cần update. Đề xuất: Sprint sau dùng Mermaid trong Markdown để vừa editable vừa render được trong VitePress.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | Tasks xong nhưng commit vào Jun 8–15, sau deadline Sprint 2 (Jun 12) |
| Chất lượng deliverable | 5/5 | Architecture diagrams + ADRs + project plan vượt yêu cầu về depth và completeness |
| Giao tiếp với team | 4/5 | Cung cấp context đủ cho team; cần improve async update frequency |
| Chủ động xử lý blocker | 5/5 | VitePress HTML Viewer giải quyết vấn đề view diagrams trước khi bị block |
| **Tổng** | **18/20** | |

---

*Deadline nộp: 2026-06-12 | Nộp bổ sung: 2026-06-29*
