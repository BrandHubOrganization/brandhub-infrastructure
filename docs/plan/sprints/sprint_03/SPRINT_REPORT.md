# Sprint 3 Report — Database, API & UI Design

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 3 |
| Timeline | Weeks 5–6 (Jun 16–30, 2026) |
| Phase | Phase 1 — Initiation & Documentation |
| Goal | Finalize database schema, define all API contracts, produce wireframes for all main screens |
| Report date | 2026-06-29 |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E06 — Database Design | 8 | 2 | 5 | 0 | 1 | 87.5% |
| E07 — API Design & Swagger | 7 | 0 | 4 | 0 | 3 | 57% |
| E08 — UI/UX Wireframe | 5 | 2 | 3 | 0 | 0 | 100% delivery |
| **Tổng** | **20** | **4** | **12** | **0** | **4** | **80%** |

> **Lưu ý:** "In Review" = committed lên GitHub, đang chờ merge vào `develop`. Thực chất đã hoàn thành về nội dung.

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Trung (Leader) | 8 | 8 | 0 | Tất cả committed, chờ merge |
| Tuấn (AI) | 4 | 1 | 3 | DA-E06-04 done; DA-E07-02, E07-06, E06-05 chưa bắt đầu |
| Ân (AI) | 1 | 0 | 1 | DA-E06-06 To Do |
| Phước (Publisher) | 3 | 0 | 3 | DA-E07-03, E07-07, E07-01 partial chưa xong |
| Lộc (Frontend) | 5 | 5 | 0 | Tất cả committed/merged |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File | Tác giả | Size | Chất lượng |
|---|---|---|---|---|
| Database Strategy | `docs/database/Database_Strategy.md` | Trung | 284 dòng | ⭐⭐⭐⭐⭐ |
| MongoDB Schema (8 collections) | `docs/database/brandhub_schema_diagram.html` | Trung | ERD interactive | ⭐⭐⭐⭐ |
| PostgreSQL Schema (15 tables) | `docs/database/brandhub_dbml.dbml` | Trung/Tuấn | 18.5KB | ⭐⭐⭐⭐⭐ |
| Indexing Strategy | `docs/database/DA-E06-04_Indexing_Strategy.md` | Trung | đầy đủ | ⭐⭐⭐⭐ |
| DBML diagram | `docs/database/brandhub_dbml.dbml` | Tuấn | 18.5KB | ⭐⭐⭐⭐ |
| DB init scripts | `scripts/init-mongo.js` + `init-postgres.sql` | Trung | 296 + 314 dòng | ⭐⭐⭐⭐⭐ |
| DB Access Rules | `docs/database/DA-E06-08_Database_Access_Rules.md` | Trung | 291 dòng | ⭐⭐⭐⭐⭐ |
| Business-service endpoints | `docs/api/endpoints/` (12 files) | Trung | 70 endpoints | ⭐⭐⭐⭐⭐ |
| ApiResponse format | `docs/api/DA-E07-04_API_Response_Format.md` | Trung | 805 dòng | ⭐⭐⭐⭐⭐ |
| OpenAPI YAML | `brandhub-business-service/docs/openapi.yaml` | Trung | 3379 dòng | ⭐⭐⭐⭐⭐ |
| Wireframes (7 màn hình) | `docs/wireframe/DA-E08-01_Wireframe_Report.md` | Lộc | shadcn annotated | ⭐⭐⭐⭐ |
| Component system | `docs/wireframe/brandhub_components_Report.md` | Lộc | atomic/molecule/organism | ⭐⭐⭐⭐ |
| User flow diagrams | `docs/wireframe/brandhub_flows_Report.md` | Lộc | 3 flows | ⭐⭐⭐⭐ |
| Client Portal wireframe | Trong DA-E08-01 | Lộc | 3 views | ⭐⭐⭐⭐ |
| Docs website (VitePress) | `frontend/` | Lộc | Auto-serve docs | ⭐⭐⭐⭐⭐ |

**Tổng:** 15 deliverables | ~6000+ dòng docs | ~4500+ dòng scripts/YAML

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| DA-184 (E06-06) | Redis key patterns | Ân | Chưa bắt đầu | Carry over Sprint 4, tuần 1 |
| DA-179 (E07-02) | ai-service endpoints | Tuấn | Chưa bắt đầu | Carry over Sprint 4 — **blocks DA-E07-06** |
| DA-155 (E07-06) | OpenAPI YAML ai-service | Tuấn | Blocked by DA-E07-02 | Sau khi DA-E07-02 xong |
| DA-196 (E07-03) | RabbitMQ message format | Phước | Chưa bắt đầu | Carry over Sprint 4, tuần 1 |
| DA-172 (E07-07) | Social platform API specs | Phước | Chưa bắt đầu | Carry over Sprint 4 |

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh của sprint này

- **Init scripts vượt yêu cầu:** MongoDB schema validation (`$jsonSchema`) — hầu hết team không làm điều này, giúp phát hiện bugs sớm ngay trong dev
- **97 error codes có catalogue:** Toàn bộ error codes được document, tránh ad-hoc string errors trong code sau này
- **Wireframe annotated theo shadcn/ui:** Frontend có thể mapping thẳng từ wireframe component vào import — tiết kiệm thời gian Sprint 5+
- **VitePress docs site:** Toàn bộ docs có thể xem trực quan tại localhost — không phải mở từng file Markdown
- **6 lỗi role trong endpoint doc gốc được phát hiện và sửa:** BRAND_CLIENT missing từ analytics/clients, content-requests, reports

### 5.2 Vấn đề gặp phải

| Vấn đề | Ảnh hưởng | Trạng thái |
|---|---|---|
| 4 branches Trung chưa merge vào develop | Nhìn vào develop thiếu nhiều files | ⏳ Cần tạo PR và merge |
| Tuấn chưa làm DA-E07-02 | Block DA-E07-06 — ai-service không có OpenAPI spec | ❌ Carry over |
| Ân chưa làm DA-E06-06 | Redis patterns không được document chính thức | ❌ Carry over |
| Phước chưa làm DA-E07-03 | RabbitMQ contract chưa defined — publisher-service implementation bị block | ❌ Carry over |

### 5.3 Technical debt để lại

- [ ] DA-E07-02 chưa xong → block DA-E07-06 → ai-service không có OpenAPI spec khi Sprint 5 bắt đầu
- [ ] RabbitMQ message format chưa defined → publisher-service Sprint 8 phải reverse engineer
- [ ] `docs/api/` và `scripts/` chỉ có trong feature branches — cần merge vào develop trước EOD Sprint 3

---

## 6. Blocked tasks & Dependencies

| Task bị block | Block bởi | Impact | Action |
|---|---|---|---|
| DA-155 (E07-06 OpenAPI ai-service) | DA-179 (E07-02 ai endpoints) chưa xong | ai-service không có Swagger UI khi dev | Tuấn phải xong DA-E07-02 trước Sprint 4 Week 2 |
| Sprint 8 publisher-service impl | DA-196 (E07-03 RabbitMQ) chưa xong | Phước sẽ implement mà không có contract | DA-E07-03 phải xong trước Sprint 8 |

---

## 7. Individual highlights

**Trung (Leader):** Hoàn thành 8/8 tasks — tất cả committed lên GitHub. Điểm nổi bật: init scripts với MongoDB `$jsonSchema` validation, 97 error codes catalogue, 70-endpoint OpenAPI YAML 3379 dòng. Phát hiện và sửa 6 lỗi role trong endpoint doc gốc.

**Tuấn (AI):** Hoàn thành DA-E06-04 Indexing Strategy và DA-E06-05 DBML diagram đúng chất lượng. Tuy nhiên DA-E07-02 (ai-service endpoints) — task Critical — chưa được bắt đầu. Cần prioritize ngay Sprint 4.

**Ân (AI):** DA-E06-06 Redis key patterns — task duy nhất — chưa được bắt đầu. Carry over sang Sprint 4.

**Phước (Publisher):** DA-E07-03 RabbitMQ và DA-E07-07 Social platform specs chưa được bắt đầu. Cả hai là blocking dependencies cho Sprint 8.

**Lộc (Frontend):** Hoàn thành toàn bộ 5 tasks. Wireframe annotated shadcn/ui chất lượng tốt — sẽ tiết kiệm thời gian đáng kể khi implement Sprint 12. VitePress docs site là bonus deliverable ngoài yêu cầu.

---

## 8. Sprint Retrospective

### 8.1 What went well?

- Trung và Lộc hoàn thành 100% tasks được giao — không delay
- Chất lượng deliverables của Trung vượt yêu cầu (schema validation, error catalogue, OpenAPI YAML)
- VitePress docs site do Lộc xây dựng giúp cả team access documentation dễ dàng hơn
- Endpoint documentation split thành 12 files nhỏ thay vì 1 file 1732 dòng — dễ review hơn nhiều

### 8.2 What didn't go well?

- Tuấn, Ân, Phước chưa hoàn thành các tasks được giao — 5 tasks carry over
- Không có mid-sprint check-in → leader không biết sớm về blockers của teammates
- Feature branches chưa được merge vào develop → state của develop misleading

### 8.3 Action items cho Sprint 4

| Action | Owner | Deadline |
|---|---|---|
| Merge 4 branches Trung vào develop | Trung | Sprint 4 Day 1 |
| Bắt đầu và hoàn thành DA-E07-02 (ai-service endpoints) | Tuấn | Sprint 4 Week 1 |
| Hoàn thành DA-E06-06 Redis key patterns | Ân | Sprint 4 Week 1 |
| Bắt đầu DA-E07-03 RabbitMQ format | Phước | Sprint 4 Week 1 |
| Tổ chức mid-sprint check-in (thứ 4 giữa sprint) | Trung | Mỗi sprint từ nay |

---

## 9. Kế hoạch Sprint 4

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E09-01 Docker Compose full stack | Trung | Sprint 4 main focus |
| 🔴 Critical | DA-E11-01/02 API Gateway + JWT filter | Trung | Critical path |
| 🔴 Critical | DA-E07-02 ai-service endpoints | Tuấn | **Carry over — must finish Week 1** |
| 🔴 Critical | DA-E07-03 RabbitMQ format | Phước | **Carry over** |
| 🟡 High | DA-E06-06 Redis key patterns | Ân | **Carry over** |
| 🟡 High | DA-E10-01/02/03/04 CI/CD pipelines | All | Each person own service |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 3 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub PRs — infrastructure | https://github.com/BrandHubOrganization/brandhub-infrastructure/pulls |
| GitHub PRs — business-service | https://github.com/BrandHubOrganization/brandhub-business-service/pulls |
| Docs website | https://brandhub-infrastructure.vercel.app |
| OpenAPI YAML | `brandhub-business-service/docs/openapi.yaml` |

---

*Report generated: 2026-06-29 | Sprint 3 ends: 2026-06-30 | Next sprint starts: 2026-07-01*
