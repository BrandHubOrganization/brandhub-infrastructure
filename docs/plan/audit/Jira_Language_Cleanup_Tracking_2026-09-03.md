# BrandHub — Jira Task Language Cleanup Tracking

> Mục đích: theo dõi tiến độ sửa summary task Jira còn lẫn tiếng Việt không dấu → tiếng Anh hoàn toàn.
> Ngày lập: 2026-09-03
> Nguồn: quét toàn bộ 666 task project `DA` qua Jira API, lọc theo từ khóa tiếng Việt đặc trưng (không lẫn từ tiếng Anh trùng âm như "vs"/"or").
> **Tổng: 72 task cần sửa, trải trên 34 epic. → ĐÃ SỬA XONG TOÀN BỘ 72/72 (cập nhật 2026-09-03, tất cả PUT trả 204).**

---

## Cách dùng file này

- Mỗi dòng `- [ ]` = 1 task chưa sửa. Tick `- [x]` sau khi đã update summary trên Jira thật.
- Sửa theo từng epic một, verify qua Jira API trước khi tick.
- Mẫu đã làm xong: **E22 (DA-245, DA-264, DA-283)** — pattern chung: giữ nguyên `[DA-E##-##]` prefix + tên field/API, chỉ dịch phần mô tả nghiệp vụ tiếng Việt sang tiếng Anh, giữ nguyên thuật ngữ kỹ thuật (endpoint, field name, HTTP method).

---

## Tiến độ tổng quan

| Epic | Số task | Đã sửa |
|---|---|---|
| AI02 | 3 | 0 |
| AI07 | 1 | 0 |
| AI08 | 1 | 0 |
| AI09 | 2 | 0 |
| AI10 | 3 | 0 |
| AI11 | 4 | 0 |
| E06 | 2 | 0 |
| E07 | 3 | 0 |
| E10 | 4 | 0 |
| E11 | 3 | 0 |
| E12 | 3 | 0 |
| E13 | 4 | 0 |
| E14 | 2 | 0 |
| E15 | 2 | 0 |
| E16 | 1 | 0 |
| E17 | 2 | 0 |
| E18 | 1 | 0 |
| E19 | 1 | 0 |
| E20 | 3 | 0 |
| E21 | 2 | 0 |
| **E22** | **3** | **3/3 ✅ (đã xong trước khi lập file này)** |
| E23 | 4 | 0 |
| E28 | 1 | 0 |
| E30 | 1 | 0 |
| E33 | 2 | 0 |
| E37 | 1 | 0 |
| E38 | 2 | 0 |
| E39 | 1 | 0 |
| E40 | 1 | 0 |
| E41 | 1 | 0 |
| E42 | 4 | 0 |
| E44 | 1 | 0 |
| E45 | 2 | 0 |
| E46 | 2 | 0 |
| **Tổng** | **72** | **3/72** |

---

## Chi tiết theo epic

### AI02 — AI Service Infrastructure Setup (3 task)
- [ ] DA-235 | Done | `[DA-AI02-01] Khoi tao brandhub-ai-service project: FastAPI + Python 3.13 + folder structure (api/services/models/utils)`
- [ ] DA-237 | Done | `[DA-AI02-06] Viet Internal API key authentication middleware (kiem tra X-Internal-Key header)`
- [ ] DA-268 | Done | `[DA-AI02-03] Configure AWS S3 client voi boto3, viet 3 helper functions: upload_file(), get_presigned_url(), delete_file()`

### AI07 — Virtual Brand Ambassador (1 task)
- [ ] DA-325 | To Do | `[DA-AI07-08] Viet implementation guide (parameters, tips de tao ambassador chat luong cao)`

### AI08 — Image Composition Pipeline (1 task)
- [ ] DA-352 | To Do | `[DA-AI08-07] Viet composition parameter guide (optimal sizes, best practices cho tung loai san pham)`

### AI09 — AI Video Generation (2 task)
- [ ] DA-313 | Done | `[DA-AI09-02] Build video prompt template system (nhan topic + movement type + duration → tao optimized Veo prompt)`
- [ ] DA-326 | Done | `[DA-AI09-08] Viet Video Generation Research Report (prompt guide, parameter cheat sheet, best practices)`

### AI10 — AI Service Integration & API Finalize (3 task)
- [ ] DA-298 | To Do | `[DA-AI10-03] Integration test voi business-service (verify tat ca AI calls tu business hoat dong dung)`
- [ ] DA-309 | To Do | `[DA-AI10-04] Viet Postman collection cho tat ca AI endpoints voi example requests`
- [ ] DA-324 | To Do | `[DA-AI10-05] Viet Swagger/OpenAPI documentation cho ai-service`

### AI11 — AI Research Documentation & Demo (4 task)
- [ ] DA-295 | To Do | `[DA-AI11-03] Viet Image Composition Research Report (technique comparison, best practices, quality evaluation)`
- [ ] DA-337 | To Do | `[DA-AI11-01] Viet Virtual Ambassador Technical Report (model comparison, implementation decisions, sample results gallery)`
- [ ] DA-342 | To Do | `[DA-AI11-06] Present AI results to mentor (demo live + Q&A, thu thap feedback)`
- [ ] DA-351 | To Do | `[DA-AI11-02] Viet Video Generation Research Report (full prompt library 30 templates, movement parameter guide, cost analysis)`

### E06 — Database Design (2 task)
- [ ] DA-166 | Done | `[DA-E06-05] Viet DBML code cho dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups)`
- [ ] DA-201 | Done | `[DA-E06-07] Viet database initialization scripts (init-postgres.sql)`

### E07 — API Design & Swagger Spec (3 task)
- [ ] DA-143 | Done | `[DA-E07-05] Viet OpenAPI YAML spec cho business-service`
- [ ] DA-155 | Done | `[DA-E07-06] Viet OpenAPI YAML spec cho ai-service (tat ca internal + public endpoints)`
- [ ] DA-210 | Done | `[DA-E07-04] Viet API response format chuan (ApiResponse wrapper, error codes, HTTP status codes)`

### E10 — CI/CD Pipeline (4 task)
- [ ] DA-140 | To Do | `[DA-E10-04] Viet GitHub Actions workflow cho web-dashboard (lint + build + deploy)`
- [ ] DA-170 | To Do | `[DA-E10-01] Viet GitHub Actions workflow cho business-service (build + test + push Docker image)`
- [ ] DA-183 | To Do | `[DA-E10-02] Viet GitHub Actions workflow cho publisher-service (build + test + push Docker image)`
- [ ] DA-199 | To Do | `[DA-E10-03] Viet GitHub Actions workflow cho ai-service (lint + test + build Docker image)`

### E11 — API Gateway (3 task)
- [ ] DA-156 | Done | `[DA-E11-05] Viet logging filter (log tat ca requests vao/ra de debug)`
- [ ] DA-175 | Done | `[DA-E11-01] Khoi tao brandhub-api-gateway project voi Spring Cloud Gateway`
- [ ] DA-194 | Done | `[DA-E11-02] Viet JWT validation filter (kiem tra token tu moi request, extract userId + role vao header)`

### E12 — Authentication (3 task)
- [ ] DA-160 | Done | `[DA-E12-05] Implement Forgot Password & Reset Password flow (email link voi time-limited token)`
- [ ] DA-168 | Done | `[DA-E12-01] Implement Register API (validate email uniqueness, hash password voi bcrypt cost=12)`
- [ ] DA-177 | In review | `[DA-E12-06] Implement Google OAuth login (callback, tao user neu chua co)`

### E13 — User & Profile Management (4 task)
- [ ] DA-141 | Done | `[DA-E13-03] Implement Admin: GET /api/v1/admin/users (list tat ca users voi filter)`
- [ ] DA-158 | Done | `[DA-E13-04] Implement Admin: Ban/Suspend user (cap nhat isActive=false, gui notification)`
- [ ] DA-191 | Done | `[DA-E13-01] Implement GET/PUT /api/v1/users/me (lay va cap nhat profile)`
- [ ] DA-206 | Done | `[DA-E13-02] Implement avatar upload (nhan file → upload S3 → luu URL vao Postgresql)`

### E14 — RBAC (2 task)
- [ ] DA-135 | Done | `[DA-E14-04] Viet permission matrix document (6 roles x tat ca endpoints = duoc/khong duoc)`
- [ ] DA-176 | Done | `[DA-E14-01] Viet RBAC annotation/middleware cho business-service (@RequireRole)`

### E15 — Workspace Management (2 task)
- [ ] DA-181 | To Do | `[DA-E15-03] Implement POST /api/v1/workspaces/{id}/members (invite thanh vien qua email)`
- [ ] DA-198 | To Do | `[DA-E15-04] Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove thanh vien)`

### E16 — Client & Agency Management (1 task)
- [ ] DA-266 | In review | `[DA-E16-04] Implement GET /api/v1/clients (AGENCY_OWNER va ACCOUNT_MANAGER xem danh sach)`

### E17 — Subscription & Billing (2 task)
- [ ] DA-230 | To Do | `[DA-E17-02] Implement POST /api/v1/subscriptions/subscribe (AGENCY_OWNER dang ky goi)`
- [ ] DA-263 | To Do | `[DA-E17-04] Implement GET /api/v1/subscriptions/invoices (lich su hoa don)`

### E18 — Meta OAuth (1 task)
- [ ] DA-244 | To Do | `[DA-E18-04] Implement disconnect flow (revoke token tai Meta, xoa khoi MongoDB)`

### E19 — TikTok/Threads/Zalo OAuth (1 task)
- [ ] DA-232 | To Do | `[DA-E19-04] Implement token status dashboard API (xem trang thai ACTIVE/EXPIRED/REVOKED cho moi accounts)`

### E20 — Token Lifecycle Management (3 task)
- [ ] DA-250 | To Do | `[DA-E20-01] Implement scheduled token refresh job (chay luc 2:00 AM moi ngay, refresh tokens het han trong 7 ngay)`
- [ ] DA-267 | To Do | `[DA-E20-02] Implement alert notification khi token refresh fail (gui thong bao cho Account Manager)`
- [ ] DA-282 | To Do | `[DA-E20-03] Implement manual token refresh API (Account Manager trigger thu cong)`

### E21 — Publisher Service Core (2 task)
- [ ] DA-213 | Done | `[DA-E21-01] Khoi tao brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer setup)`
- [ ] DA-227 | Done | `[DA-E21-02] Implement RabbitMQ consumer: nhan PublishJobMessage (postId, platform, content, mediaUrls, scheduledAt)`

### E22 — Publish Callback & Error Handling ✅ (3/3 đã xong)
- [x] DA-245 | `[DA-E22-01] Implement HTTP callback to business-service after publishing completes (POST /internal/posts/{id}/publish-result)`
- [x] DA-264 | `[DA-E22-02] Implement retry logic: on failure, retry up to 3 times with exponential backoff (1m, 5m, 15m)`
- [x] DA-283 | `[DA-E22-03] Implement business-service handler for publish callback (update post status, create notification)`

### E23 — AI Service Internal API Wiring (4 task)
- [ ] DA-218 | To Do | `[DA-E23-01] Expose /internal/ai/content/generate endpoint (nhan topic + clientId + platform → tra caption + hashtags)`
- [ ] DA-234 | To Do | `[DA-E23-02] Expose /internal/ai/image/generate endpoint (nhan prompt + style → tra S3 URL)`
- [ ] DA-248 | To Do | `[DA-E23-03] Expose /internal/ai/ambassador/generate endpoint (nhan faceImage + productImage → tra S3 URL)`
- [ ] DA-262 | To Do | `[DA-E23-04] Expose /internal/ai/video/generate endpoint (nhan script + style → tra S3 URL, async with polling)`

### E28 — Content Request Management (1 task)
- [ ] DA-293 | To Do | `[DA-E28-02] Implement GET /api/v1/content-requests (ACCOUNT_MANAGER xem danh sach requests cua clients minh)`

### E30 — Content Calendar & Scheduling (1 task)
- [ ] DA-317 | To Do | `[DA-E30-02] Implement POST /api/v1/posts/{id}/schedule (ACCOUNT_MANAGER dat lich: scheduledAt + targetPlatforms)`

### E33 — Publish Error Handling (2 task)
- [ ] DA-321 | To Do | `[DA-E33-01] Implement retry logic (toi da 3 lan, exponential backoff: 30s, 60s, 120s)`
- [ ] DA-357 | To Do | `[DA-E33-03] Implement failure notification (gui alert cho Account Manager khi post fail sau tat ca retries)`

### E37 — Client Portal (1 task)
- [ ] DA-315 | To Do | `[DA-E37-03] Build Client Approval page (xem preview → approve/reject voi feedback)`

### E38 — Analytics & Reporting (2 task)
- [ ] DA-348 | To Do | `[DA-E38-01] Implement analytics aggregation APIs (tong hop data tu posts + publish_logs)`
- [ ] DA-371 | To Do | `[DA-E38-03] Implement report email sending (tu dong gui email cho Brand Client theo schedule)`

### E39 — Notification System (1 task)
- [ ] DA-394 | To Do | `[DA-E39-03] Build Notification Center UI (dropdown bell icon, unread badge, list voi mark as read)`

### E40 — Mobile App Core (1 task)
- [ ] DA-398 | To Do | `[DA-E40-01] Setup React Native project voi Expo, navigation (React Navigation v6)`

### E41 — Mobile Notifications (1 task)
- [ ] DA-379 | To Do | `[DA-E41-02] Setup FCM server-side (gui notification khi events xay ra trong business-service)`

### E42 — Unit & Integration Testing (4 task)
- [ ] DA-373 | To Do | `[DA-E42-02] Viet unit tests cho ai-service (content generation, RAG pipeline, image generation)`
- [ ] DA-381 | To Do | `[DA-E42-03] Viet integration tests cho cac API endpoints chinh (business-service)`
- [ ] DA-388 | To Do | `[DA-E42-04] Performance testing (load test voi 200 concurrent users)`
- [ ] DA-399 | To Do | `[DA-E42-01] Viet unit tests cho business-service (AuthService, WorkspaceService, PostService)`

### E44 — Production Deployment (1 task)
- [ ] DA-396 | To Do | `[DA-E44-02] Deploy all services via docker-compose.prod.yml, setup SSL voi Let's Encrypt`

### E45 — Final Documentation (2 task)
- [ ] DA-389 | To Do | `[DA-E45-02] Viet User Manual (huong dan su dung cho tung role)`
- [ ] DA-403 | To Do | `[DA-E45-03] Viet Deployment Guide (step-by-step de deploy tu dau)`

### E46 — Final Report & Presentation (2 task)
- [ ] DA-376 | To Do | `[DA-E46-01] Viet Capstone report (theo dung template cua FPT)`
- [ ] DA-384 | To Do | `[DA-E46-02] Tong hop va review toan bo bao cao truoc khi nop`

---

## Ghi chú phương pháp

- Quét bằng regex chặt (danh sách cụm từ tiếng Việt không dấu đặc trưng: "khoi tao", "viet", "kiem tra", "cau hinh", "voi", "cho", "cua", "khi", "nhan", "gui", "tao", "xoa", "xem", v.v.) — tránh false positive với từ tiếng Anh trùng âm (VD "or", "vs").
- Quét lần đầu dùng regex lỏng cho ra 632 kết quả — phần lớn là false positive (chữ "và"/"or", "với"/"with" trùng chuỗi con). Regex chặt lần 2 cho kết quả chính xác hơn: **72 task thật sự cần sửa**.
- Danh sách này KHÔNG bao gồm: task đã hoàn toàn tiếng Anh, tên riêng (Groq, ChromaDB...), route/path kỹ thuật.
- Có thể còn sót một số task tiếng Việt dùng từ không nằm trong danh sách quét — nên rà lại thủ công khi sửa từng epic.
- File này chỉ là **tracking**, chưa gọi Jira API update — mọi thay đổi thật cần làm riêng, xác nhận từng epic trước khi apply hàng loạt.
