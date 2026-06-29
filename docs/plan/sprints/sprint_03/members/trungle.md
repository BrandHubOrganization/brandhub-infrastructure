# Sprint 3 — Individual Report

> **Ví dụ mẫu đã điền đầy đủ — Leader (Trung).** Xem file này để hiểu cách viết.

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Lê Trí Trung |
| GitHub | [@letritrung] |
| Role | Leader / Business Service Engineer |
| Sprint | Sprint 3 |
| Ngày nộp | 2026-06-29 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-188 | [DA-188](https://letritrung2605.atlassian.net/browse/DA-188) | DA-E06-01 Define database strategy: MongoDB vs PostgreSQL | 🔴 Critical | ✅ Done |
| DA-204 | [DA-204](https://letritrung2605.atlassian.net/browse/DA-204) | DA-E06-02 Design 8 MongoDB collections | 🔴 Critical | 🔄 In Review |
| DA-132 | [DA-132](https://letritrung2605.atlassian.net/browse/DA-132) | DA-E06-03 Design 15 PostgreSQL tables | 🔴 Critical | 🔄 In Review |
| DA-201 | [DA-201](https://letritrung2605.atlassian.net/browse/DA-201) | DA-E06-07 Write init scripts (init-mongo.js + init-postgres.sql) | 🔴 Critical | 🔄 In Review |
| DA-146 | [DA-146](https://letritrung2605.atlassian.net/browse/DA-146) | DA-E06-08 Write database access rules documentation | 🔴 Critical | ✅ Done |
| DA-162 | [DA-162](https://letritrung2605.atlassian.net/browse/DA-162) | DA-E07-01 Define all 70 endpoints for business-service | 🔴 Critical | 🔄 In Review |
| DA-210 | [DA-210](https://letritrung2605.atlassian.net/browse/DA-210) | DA-E07-04 Write standard ApiResponse format | 🔴 Critical | 🔄 In Review |
| DA-143 | [DA-143](https://letritrung2605.atlassian.net/browse/DA-143) | DA-E07-05 Write OpenAPI YAML spec for business-service | 🟡 High | 🔄 In Review |

**Tổng:** 8 tasks | Done: 2 | In Review: 6 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

---

### [DA-188] — Define database strategy: which data goes into MongoDB vs PostgreSQL

**Jira status:** Done  
**Branch:** `docs/DA-188-define-database-strategy`  
**Commit chính:** `c8fe7e7` — `feat(DA-188): Refactor database strategy and structure`  
**File tạo ra / thay đổi:**
- `docs/database/Database_Strategy.md` — 284 dòng, quyết định kiến trúc database toàn hệ thống

**Mô tả công việc đã làm:**

Viết document xác định rõ nguyên tắc phân chia dữ liệu giữa MongoDB và PostgreSQL. Định nghĩa 6 tiêu chí để chọn MongoDB (schema linh hoạt, write throughput cao, multi-tenant isolation đơn giản) và 6 tiêu chí cho PostgreSQL (ACID transaction, FK constraint, immutable audit trail). Lập bảng mapping 23 entities vào đúng database. Xác định cross-DB reference strategy (soft reference bằng UUID, không dùng JOIN cross-DB). Làm rõ scope của Redis (cache only) và ChromaDB (vector store for RAG).

**Kết quả đạt được:**
- [x] Decision rules rõ ràng, có thể áp dụng cho entities mới sau này
- [x] Hard rules không có ngoại lệ — developer không phải đoán
- [x] Blocks cho DA-E06-02 và DA-E06-03 được unblock

**Khó khăn gặp phải:** Phải quyết định `users` nằm ở PostgreSQL hay MongoDB. Chọn PostgreSQL vì auth yêu cầu FK với `user_refresh_tokens` và `user_oauth_providers`.

**Thời gian thực tế:** ~4 giờ

---

### [DA-204] — Design 8 MongoDB collections with all field types

**Jira status:** In Review  
**Branch:** `docs/DA-204-design-database`  
**Commit chính:** `f1330aa` — `Add database schema diagram for BrandHub`  
**File tạo ra / thay đổi:**
- `docs/database/brandhub_schema_diagram.html` — Interactive ERD diagram
- `docs/database/brandhub_erd.puml` — PlantUML source

**Mô tả công việc đã làm:**

Thiết kế 8 MongoDB collections (`posts`, `content_requests`, `social_accounts`, `notifications`, `publish_logs`, `ai_usage_logs`, `report_jobs`, `knowledge_documents`) với đầy đủ field types, required/optional flags, default values. Tạo ERD diagram tương tác dạng HTML để team có thể xem trực quan. Mỗi collection có compound index đặt tên rõ ràng theo pattern `idx_{collection}_{fields}`.

**Kết quả đạt được:**
- [x] 8/8 collections thiết kế đầy đủ
- [x] ERD diagram có thể xem trực tiếp trên browser
- [x] workspaceId đứng đầu mọi compound index (theo access rules)

**Thời gian thực tế:** ~5 giờ

---

### [DA-201] — Write database initialization scripts

**Jira status:** In Review  
**Branch:** `docs/DA-201-init-database`  
**Commit chính:** `239dd0f` — `feat(DA-201): enhance MongoDB and PostgreSQL initialization scripts`  
**File tạo ra / thay đổi:**
- `scripts/init-mongo.js` — 296 dòng, schema validation cho mọi collection
- `scripts/init-postgres.sql` — 314 dòng, idempotent, đủ enums + tables + FK + indexes

**Mô tả công việc đã làm:**

Viết `init-mongo.js` với `$jsonSchema` validation cho từng collection (bsonType, required fields, enum values). Dùng `validationAction: 'warn'` thay vì `'error'` để schema có thể evolve mà không crash app trong dev. Script idempotent: `createCollection` và `createIndex` là no-op nếu đã tồn tại. Với PostgreSQL: mọi enum dùng `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$` để safe re-run. Seed 4 subscription plans (FREE, BASIC, PRO, ENTERPRISE) với `INSERT ... ON CONFLICT DO NOTHING`.

**Kết quả đạt được:**
- [x] `mongosh brandhub < init-mongo.js` chạy lần 2 không lỗi
- [x] `psql -f init-postgres.sql` chạy lần 2 không lỗi
- [x] Schema validation active — developer biết ngay nếu insert thiếu field required

**Thời gian thực tế:** ~6 giờ

---

### [DA-146] — Write database access rules documentation

**Jira status:** Done  
**Branch:** `docs/DA-146-database-rule`  
**Commit chính:** `d779ea0` — `feat(DA-146): document mandatory data access rules`  
**File tạo ra / thay đổi:**
- `docs/database/DA-E06-08_Database_Access_Rules.md` — 291 dòng, 5 rules với code examples

**Mô tả công việc đã làm:**

Viết implementation contract (không phải guideline) gồm 5 rules bắt buộc: (1) `workspaceId` trong mọi MongoDB query, (2) `BRAND_CLIENT` thêm `clientId` bắt buộc, (3) `workspaceId` lấy từ JWT không phải request body, (4) Enforce tại Repository layer không phải Service, (5) PostgreSQL financial queries cũng cần `workspace_id`. Mỗi rule có code example ✅ ĐÚNG và ❌ SAI dùng Spring Data MongoDB để developer không phải đoán.

**Kết quả đạt được:**
- [x] 5 rules đầy đủ, không ambiguous
- [x] Java code examples cho cả 3 pattern: Repository method name, `@Query`, `MongoTemplate`
- [x] Decision matrix cuối file để tra cứu nhanh

**Thời gian thực tế:** ~3 giờ

---

### [DA-162] — Define all endpoints for business-service

**Jira status:** In Review  
**Branch:** `docs/DA-162-api-enpoint-document`  
**Commit chính:** `e84168a` — `Add API documentation for new endpoints`  
**File tạo ra / thay đổi:**
- `docs/api/DA-E07-01_Business_Service_Endpoints.md` — Index file
- `docs/api/endpoints/00_conventions.md` — Conventions + summary table 70 endpoints
- `docs/api/endpoints/01_auth.md` through `11_admin.md` — 11 group files

**Mô tả công việc đã làm:**

Tách file gốc 1732 dòng thành index + 12 files nhỏ theo group. Rà soát và sửa 6 lỗi trong file gốc: BRAND_CLIENT thiếu trong content-requests, analytics/clients, reports/{jobId}; DELETE posts sai role; self-read permission thiếu; UNSUPPORTED_PLATFORM error thiếu. Thêm role-based data isolation, workflow diagram cho post status, RabbitMQ trigger points, rate limiting notes.

**Kết quả đạt được:**
- [x] 70 endpoints across 11 groups, đầy đủ request/response
- [x] 6 lỗi role từ file gốc đã được sửa
- [x] Base path nhất quán `/api/v1/`

**Thời gian thực tế:** ~8 giờ

---

### [DA-210] — Write standard API response format

**Jira status:** In Review  
**Branch:** `docs/DA-210-api-response`  
**Commit chính:** `7cfd848` — `docs(DA-210): Add standard API response format documentation`  
**File tạo ra / thay đổi:**
- `docs/api/DA-E07-04_API_Response_Format.md` — 805 dòng

**Mô tả công việc đã làm:**

Định nghĩa `ApiResponse<T>` envelope với 7 fields: `success`, `data`, `error`, `meta`, `requestId`, `version`, `timestamp`. Viết Java record với factory methods (`ok()`, `error()`, `noContent()`). Viết Pydantic Generic model tương đương cho ai-service. Xây dựng error code catalogue 97 codes, 14 domains. Định nghĩa 10 rules không thể vi phạm (204 never used, requestId never null, v.v.). Thêm frontend contract section.

**Kết quả đạt được:**
- [x] Java record + Pydantic model sẵn sàng copy-paste
- [x] 97 error codes phủ toàn bộ business domains
- [x] 10 rules không ambiguous

**Thời gian thực tế:** ~6 giờ

---

### [DA-143] — Write OpenAPI YAML spec for business-service

**Jira status:** In Review  
**Branch:** `docs/DA-143—Write-OpenAPI-YAML` (infra) + `feat/DA-143—Write-OpenAPI-YAML` (business-service)  
**Commit chính:** `fba9717` — `docs(DA-143): Add OpenAPI YAML specification`  
**File tạo ra / thay đổi:**
- `brandhub-business-service/docs/openapi.yaml` — 3379 dòng, OpenAPI 3.1.0
- `docs/api/DA-E07-05_OpenAPI_Spec.md` — 192 dòng, hướng dẫn tích hợp
- `brandhub-business-service/pom.xml` — thêm `springdoc-openapi-starter-webmvc-ui:2.6.0`

**Mô tả công việc đã làm:**

Viết full OpenAPI 3.1.0 YAML với 58 paths (70 operations), 30+ reusable schemas, 4 reusable responses, 3 reusable parameters. Tất cả response wrap `ApiResponse<T>` envelope theo DA-E07-04. Gateway-injected headers (`X-User-Id`, `X-User-Role`, `X-Workspace-Id`) documented trên mỗi secured endpoint. Thêm dependency SpringDoc để auto-serve tại `/swagger-ui.html`. MongoDB ObjectId và UUID được phân biệt rõ ràng theo entity type.

**Kết quả đạt được:**
- [x] 70 endpoints đầy đủ trong YAML
- [x] Tất cả error response dùng code từ DA-E07-04 catalogue
- [x] 204 không có trong spec — đúng rule #8

**Thời gian thực tế:** ~7 giờ

---

## 4. Tasks chưa hoàn thành

*Không có task nào chưa hoàn thành.*

---

## 5. Đóng góp ngoài tasks chính

- Review và góp ý kiến trúc cho DA-E08-01 wireframe của Lộc (component naming theo shadcn/ui đồng nhất với API response format)
- Hỗ trợ Tuấn setup môi trường để chạy `init-postgres.sql` lần đầu
- Viết `git-commit-convention.md` (DA-408) để cả team follow Conventional Commits

---

## 6. Học được gì trong sprint này

1. **MongoDB `$jsonSchema` validation:** Lần đầu dùng `bsonType` validator trong `createCollection`. Biết được sự khác nhau giữa `validationAction: 'warn'` vs `'error'` và khi nào nên dùng cái nào.
2. **OpenAPI 3.1.0 vs 3.0.x:** 3.1.0 dùng `type: "null"` thay vì `nullable: true`. Một số tools chưa hỗ trợ đầy đủ 3.1.0 — SpringDoc 2.x thì OK.
3. **requestId propagation pattern:** Gateway generate UUID → inject header `X-Request-Id` → service echo vào response. Fallback khi bypass gateway là generate UUID mới tại service, không để `null`.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Việc tách branch per-task (mỗi DA có branch riêng) hoạt động tốt — PR nhỏ, dễ review. Vấn đề: một số branch chưa được merge vào `develop` do chờ review, gây ra impression "chưa làm xong" khi nhìn vào develop. Đề xuất: set deadline merge PR trong 2 ngày sau khi tạo.

### 7.2 Về tools

Nên dùng `editor.swagger.io` để validate YAML trước khi commit — tránh syntax errors lọt vào PR.

### 7.3 Đề xuất cho Sprint tiếp theo

- DA-E07-02 (ai-service endpoints) cần Tuấn bắt đầu ngay tuần 1 Sprint 4 — nếu delay tiếp sẽ block DA-E07-06
- Nên họp team 30 phút đầu Sprint 4 để align về Docker Compose environment trước khi mỗi người tự setup

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 4/5 | Tất cả commit đúng deadline; một số PR chờ merge |
| Chất lượng deliverable | 5/5 | Code examples, 97 error codes, schema validation vượt yêu cầu |
| Giao tiếp với team | 4/5 | Cần chủ động hơn trong việc unblock teammate |
| Chủ động xử lý blocker | 5/5 | Phát hiện 6 lỗi trong DA-E07-01 gốc và sửa luôn |
| **Tổng** | **18/20** | |

---

*Nộp: 2026-06-29 | Sprint 3 ends: 2026-06-30*
