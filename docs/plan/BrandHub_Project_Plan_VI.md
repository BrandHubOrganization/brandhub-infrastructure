# BrandHub — Kế hoạch Epic & Sprint Dự án

> Bản tiếng Việt của BrandHub_Project_Plan.md. Thuật ngữ kỹ thuật giữ nguyên tiếng Anh.

---

## THÔNG TIN NHÓM & DỰ ÁN

| Trường | Chi tiết |
|---|---|
| Dự án | BrandHub — AI-Powered Multi-Channel Content Platform |
| Nhóm | Trung (Leader), Lộc (Frontend), Tuấn (AI), Ân (AI), Phước (Publisher) |
| Tổng số Sprint | 16 Sprints (2 tuần mỗi sprint) + 4 AI Parallel Iterations |
| Thời lượng | ~32 tuần |
| Stack | Java Spring Boot 3, Python FastAPI, React 18, React Native, MongoDB, PostgreSQL, Redis, ChromaDB, RabbitMQ, AWS S3 |

---

## TÓM TẮT CÔNG NGHỆ

| Tầng | Công nghệ |
|---|---|
| Web Frontend | React 18 + Vite + TypeScript + Tailwind CSS + shadcn/ui |
| Mobile | React Native + Expo |
| Backend Business | Java 21 + Spring Boot 3 + Spring Security |
| Backend AI | Python 3.11 + FastAPI + LangChain |
| Backend Publisher | Java 21 + Spring Boot 3 |
| API Gateway | Spring Cloud Gateway |
| Primary DB | MongoDB (documents, content, social accounts) |
| Relational DB | PostgreSQL (payments, subscriptions, audit logs) |
| Cache | Redis (JWT blacklist, rate limit, OAuth state, trending cache) |
| Vector DB | ChromaDB (brand embeddings for RAG) |
| Message Queue | RabbitMQ (async publishing queue) |
| File Storage | AWS S3 |
| LLM | Llama 3 via Groq API + Claude API (fallback) |
| Image Gen | Stability AI API (SDXL) |
| Video Gen | Google Veo API |
| Virtual Ambassador | InstantID + InsightFace + ControlNet |
| Auth | JWT (Access: 15 min, Refresh: 30 days) + Google OAuth |
| Container | Docker + Docker Compose |
| CI/CD | GitHub Actions |
| Quản lý dự án | Linear (sprints) + GitHub (code) |

---

## KIẾN TRÚC HỆ THỐNG

```
[Web Dashboard]  [Mobile App]
       |               |
   [API Gateway — Spring Cloud Gateway — Port 8080]
       |         |              |
[Business Svc] [AI Svc]  [Publisher Svc]
   Port 8081   Port 8082    Port 8083
       |           |              |
  [MongoDB]  [ChromaDB]     [RabbitMQ]
  [PostgreSQL] [AWS S3]     [Social APIs]
  [Redis]
```

**7 Repositories:** brandhub-business-service, brandhub-ai-service, brandhub-publisher-service, brandhub-api-gateway, brandhub-web-dashboard, brandhub-mobile-app, brandhub-infrastructure

---

## VAI TRÒ

| Vai trò | Mô tả |
|---|---|
| `ADMIN` | Quản trị viên hệ thống — quản lý người dùng, gói dịch vụ, nền tảng |
| `AGENCY_OWNER` | Tạo workspace, quản lý nhóm & khách hàng, thanh toán |
| `ACCOUNT_MANAGER` | Quản lý khách hàng được phân công, xem xét nội dung, gửi báo cáo |
| `CONTENT_CREATOR` | Tạo nội dung AI, quản lý knowledge base, lên lịch đăng bài |
| `BRAND_CLIENT` | Cổng thông tin khách hàng chỉ xem: duyệt/từ chối nội dung, xem báo cáo |
| `GUEST` | Chưa xác thực — chỉ xem landing page + đăng ký |

---

## CHÚ THÍCH ĐỘ ƯU TIÊN

| Ký hiệu | Ý nghĩa |
|---|---|
| 🔴 Nghiêm trọng | Chặn các task khác, kiến trúc cốt lõi, xác thực, schema database |
| 🟡 Cao | Tính năng quan trọng, CI/CD, các API endpoint chính |
| 🟢 Trung bình | Tài liệu, kiểm thử, tính năng phụ |

---

## GIAI ĐOẠN 1 — Khởi động & Tài liệu

---

## Sprint 1 — Khởi động Dự án (Tuần 1–2)

### EPIC E01 — Khởi động Dự án

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E01-01 | Brainstorm và thống nhất ý tưởng đề tài BrandHub, xác định scope và MVP | Cả nhóm | 🔴 Nghiêm trọng |
| DA-E01-02 | Họp nhóm xác nhận vai trò và trách nhiệm từng thành viên | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E01-03 | Tìm và liên hệ mentor phù hợp với đề tài AI + microservices | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E01-04 | Xác định khả năng kỹ thuật của từng thành viên (Java, Python, React, AI tools) | Cả nhóm | 🟡 Cao |
| DA-E01-05 | Điền form đăng ký đề tài trên hệ thống Call4project (insideuni.fpt.edu.vn) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E02 — Thiết lập Quản lý Dự án

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E02-01 | Tạo Linear workspace, thiết lập sprint cadence 2 tuần, tạo issue templates | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E02-02 | Tạo GitHub Organization và 7 repos theo polyrepo structure | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E02-03 | Thiết lập branch protection rules, PR template, commit convention (Conventional Commits) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E02-04 | Tạo email dự án và tài khoản các service (AWS, GitHub Actions, Groq, Stability AI, etc.) | Trung (Leader) | 🔴 Nghiêm trọng |

---

## Sprint 2 — Yêu cầu & Kiến trúc (Tuần 3–4)

### EPIC E03 — Tài liệu Use Case

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E03-01 | Liệt kê và phân nhóm toàn bộ 60 UC theo 6 roles (Admin, Agency Owner, Account Manager, Content Creator, Brand Client, Guest) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E03-02 | Viết mô tả chi tiết UC 01–20 (Admin + Agency Owner flows) — actor, description, main flow, alt flows | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E03-03 | Viết mô tả chi tiết UC 21–40 (Account Manager + Content Creator flows) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E03-04 | Viết mô tả chi tiết UC 41–60 (Brand Client + Social Publishing flows) | Phước (Publisher) | 🟡 Cao |
| DA-E03-05 | Review UC list với mentor, cập nhật sau feedback | Cả nhóm | 🟡 Cao |
| DA-E03-06 | Finalize UC table vào file Excel (BrandHub_UseCases.xlsx) | Phước (Publisher) | 🟢 Trung bình |

### EPIC E04 — Yêu cầu Chức năng & Phi chức năng

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E04-01 | Viết Functional objectives theo từng role (6 roles x features) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E04-02 | Viết Non-functional requirements (UI, Performance, Security, Reliability, Usability) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E04-03 | Thêm AI Performance requirements (latency, throughput, model accuracy thresholds) vào Non-functional | Ân (AI) | 🟡 Cao |
| DA-E04-04 | Thêm Mobile requirements (FCM, offline draft, camera) vào Non-functional | Lộc (Frontend) | 🟡 Cao |
| DA-E04-05 | Điền và hoàn thiện Capstone Register form (BrandHub_Capstone_Register.docx) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E05 — Thiết kế Kiến trúc Hệ thống

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E05-01 | Vẽ system architecture overview diagram (7 services + 5 databases + RabbitMQ + clients) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E05-02 | Định nghĩa service responsibilities và boundaries (7 services làm gì, KHÔNG làm gì) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E05-03 | Vẽ database ownership diagram (service nào sở hữu DB nào, cross-DB reference strategy) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E05-04 | Document service-to-service communication (REST: business-ai, RabbitMQ: business-publisher, HTTP callback: publisher-business) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E05-05 | Viết Architecture Decision Records (ADRs) cho 4 quyết định chính: polyrepo, MongoDB+PostgreSQL split, RabbitMQ, Spring Cloud Gateway | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E05-06 | Vẽ sequence diagrams cho 4 core flows: content creation, approval workflow, auto-publishing, OAuth token refresh | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E05-07 | Viết phần AI architecture trong Technical Document (ai-service internal design, ChromaDB schema, LLM routing strategy) | Tuấn (AI) | 🟡 Cao |
| DA-E05-08 | Compile full technical document (BrandHub_Technical_Document.md) | Trung (Leader) | 🟡 Cao |

---

## Sprint 3 — Thiết kế Database, API & UI (Tuần 5–6)

### EPIC E06 — Thiết kế Database

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E06-01 | Định nghĩa database strategy: data nào vào MongoDB, data nào vào PostgreSQL, và tại sao | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E06-02 | Thiết kế 12 MongoDB collections với đầy đủ field types, required/optional, default values | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E06-03 | Thiết kế 5 PostgreSQL tables với constraints, foreign keys nội bộ | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E06-04 | Định nghĩa indexing strategy cho MongoDB và PostgreSQL | Tuấn (AI) | 🟡 Cao |
| DA-E06-05 | Viết DBML code cho dbdiagram.io (MongoDB + PostgreSQL + Enums + Refs + TableGroups) | Tuấn (AI) | 🟡 Cao |
| DA-E06-06 | Document Redis key patterns (JWT blacklist, rate limit, OAuth state, trending cache) | Ân (AI) | 🟡 Cao |
| DA-E06-07 | Viết database initialization scripts (init-mongo.js + init-postgres.sql) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E06-08 | Viết database access rules documentation (mọi query phải có workspaceId filter, BRAND_CLIENT thêm clientId filter) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E07 — Thiết kế API & Swagger Spec

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E07-01 | Định nghĩa tất cả endpoints cho business-service (Auth, User, Workspace, Client, Post, ContentRequest, SocialAccount, Analytics, Report, Subscription, Admin) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E07-02 | Định nghĩa endpoints cho ai-service (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/rag, /ai/trends) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E07-03 | Định nghĩa RabbitMQ message format cho publisher-service (publish job + callback message contract) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E07-04 | Viết API response format chuẩn (ApiResponse wrapper, error codes, HTTP status codes) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E07-05 | Viết OpenAPI YAML spec cho business-service | Trung (Leader) | 🟡 Cao |
| DA-E07-06 | Viết OpenAPI YAML spec cho ai-service (tất cả internal + public endpoints) | Tuấn (AI) | 🟡 Cao |
| DA-E07-07 | Document social platform API specs: FB Graph API, TikTok Content API, Threads API, Zalo OA API (versions, rate limits, payload formats) | Phước (Publisher) | 🟡 Cao |

### EPIC E08 — Wireframe UI/UX

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E08-01 | Vẽ Figma wireframe cho tất cả màn hình chính (Login, Dashboard, Workspace, Content Editor, Calendar, Client Portal, Analytics) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E08-02 | Thiết kế component system (Button, Input, Modal, Table, Badge, Toast styles) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E08-03 | Vẽ user flow diagrams cho 3 main flows: content creation, approval, publishing | Lộc (Frontend) | 🟡 Cao |
| DA-E08-04 | Wireframe Client Portal (read-only calendar, approve/reject, analytics view) | Lộc (Frontend) | 🟡 Cao |

---

## GIAI ĐOẠN 2 — Thiết lập Hạ tầng

---

## Sprint 4 — Hạ tầng, CI/CD & Gateway (Tuần 7–8)

### EPIC E09 — Thiết lập Môi trường Phát triển

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E09-01 | Viết docker-compose.yml chạy toàn bộ infrastructure: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E09-02 | Viết init-mongo.js (tạo collections + indexes) và init-postgres.sql (tạo tables + seed subscription plans) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E09-03 | Viết .env.example tổng hợp tất cả environment variables của 6 services | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E09-04 | Viết clone-all.sh script để clone 7 repos về máy với 1 lệnh | Trung (Leader) | 🟡 Cao |
| DA-E09-05 | Viết README.md cho infrastructure repo (hướng dẫn setup từng bước) | Phước (Publisher) | 🟢 Trung bình |

### EPIC E10 — CI/CD Pipeline

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E10-01 | Viết GitHub Actions workflow cho business-service (build + test + push Docker image) | Trung (Leader) | 🟡 Cao |
| DA-E10-02 | Viết GitHub Actions workflow cho publisher-service (build + test + push Docker image) | Phước (Publisher) | 🟡 Cao |
| DA-E10-03 | Viết GitHub Actions workflow cho ai-service (lint + test + build Docker image) | Tuấn (AI) | 🟡 Cao |
| DA-E10-04 | Viết GitHub Actions workflow cho web-dashboard (lint + build + deploy) | Lộc (Frontend) | 🟡 Cao |
| DA-E10-05 | Thiết lập branch protection rules (require 1 approval trước khi merge vào develop) | Trung (Leader) | 🟢 Trung bình |

### EPIC E11 — API Gateway

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E11-01 | Khởi tạo brandhub-api-gateway project với Spring Cloud Gateway | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E11-02 | Viết JWT validation filter (kiểm tra token từ mọi request, extract userId + role vào header) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E11-03 | Viết rate limiting filter dùng Redis (100 requests/minute/user) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E11-04 | Config routing rules (ánh xạ URL path đến đúng service) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E11-05 | Viết logging filter (log tất cả requests vào/ra để debug) | Trung (Leader) | 🟢 Trung bình |

---

## GIAI ĐOẠN 3 — Backend Cốt lõi

---

## Sprint 5 — Xác thực & RBAC (Tuần 9–10)

### EPIC E12 — Xác thực

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E12-01 | Implement Register API (validate email uniqueness, hash password với bcrypt cost=12) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E12-02 | Implement Login API (verify password, issue JWT access token 15 phút + refresh token 30 ngày) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E12-03 | Implement Refresh Token API (verify refresh token, issue new access token) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E12-04 | Implement Logout API (thêm JWT jti vào Redis blacklist, clear cookie) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E12-05 | Implement Forgot Password & Reset Password flow (email link với time-limited token) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E12-06 | Implement Google OAuth login (callback, tạo user nếu chưa có) | Trung (Leader) | 🟡 Cao |

### EPIC E13 — Quản lý Người dùng & Hồ sơ

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E13-01 | Implement GET/PUT /api/v1/users/me (lấy và cập nhật profile) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E13-02 | Implement avatar upload (nhận file → upload S3 → lưu URL vào MongoDB) | Trung (Leader) | 🟡 Cao |
| DA-E13-03 | Implement Admin: GET /api/v1/admin/users (list tất cả users với filter) | Ân (AI) | 🟡 Cao |
| DA-E13-04 | Implement Admin: Ban/Suspend user (cập nhật isActive=false, gửi notification) | Ân (AI) | 🟡 Cao |

### EPIC E14 — Kiểm soát Truy cập theo Vai trò (RBAC)

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E14-01 | Viết RBAC annotation/middleware cho business-service (@RequireRole) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E14-02 | Implement workspace isolation filter (mọi query MongoDB phải có workspaceId filter) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E14-03 | Implement client isolation cho BRAND_CLIENT (chỉ được xem data của clientId mình) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E14-04 | Viết permission matrix document (6 roles x tất cả endpoints = được/không được) | Phước (Publisher) | 🟢 Trung bình |

---

## Sprint 6 — Workspace, Client & Subscription (Tuần 11–12)

### EPIC E15 — Quản lý Workspace

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E15-01 | Implement POST /api/v1/workspaces (tạo workspace mới, AGENCY_OWNER role) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E15-02 | Implement GET /api/v1/workspaces/mine (lấy workspace của user hiện tại) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E15-03 | Implement POST /api/v1/workspaces/{id}/members (invite thành viên qua email) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E15-04 | Implement DELETE /api/v1/workspaces/{id}/members/{userId} (remove thành viên) | Trung (Leader) | 🟡 Cao |
| DA-E15-05 | Implement workspace settings (timezone, default platforms, report frequency) | Trung (Leader) | 🟡 Cao |

### EPIC E16 — Quản lý Client & Agency

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E16-01 | Implement POST /api/v1/clients (AGENCY_OWNER tạo brand client mới) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E16-02 | Implement PUT /api/v1/clients/{id}/assign (AGENCY_OWNER assign Account Manager) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E16-03 | Implement PUT /api/v1/clients/{id}/service-package (set giới hạn bài/tháng, platforms) | Trung (Leader) | 🟡 Cao |
| DA-E16-04 | Implement GET /api/v1/clients (AGENCY_OWNER và ACCOUNT_MANAGER xem danh sách) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E17 — Subscription & Billing

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E17-01 | Implement Admin CRUD cho subscription plans (Free/Basic/Pro/Enterprise) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E17-02 | Implement POST /api/v1/subscriptions/subscribe (AGENCY_OWNER đăng ký gói) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E17-03 | Implement payment flow (tích hợp payment gateway, tạo invoice) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E17-04 | Implement GET /api/v1/subscriptions/invoices (lịch sử hóa đơn) | Ân (AI) | 🟡 Cao |

---

## GIAI ĐOẠN 4 — Tích hợp Mạng xã hội & AI Pipeline

---

## Sprint 7 — Social OAuth & Quản lý Token (Tuần 13–14)

### EPIC E18 — Meta OAuth (Facebook + Instagram)

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E18-01 | Implement Facebook Fanpage OAuth flow (redirect → callback → token exchange) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E18-02 | Implement Instagram Business account connection (linked via Facebook Business) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E18-03 | Implement AES-256 encryption cho access token + refresh token trước khi lưu MongoDB | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E18-04 | Implement disconnect flow (revoke token tại Meta, xóa khỏi MongoDB) | Phước (Publisher) | 🟡 Cao |

### EPIC E19 — TikTok, Threads & Zalo OA OAuth

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E19-01 | Implement TikTok for Business OAuth (Client Credentials Flow) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E19-02 | Implement Threads OAuth (dùng Meta Graph API, scope: threads_basic + threads_content_publish) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E19-03 | Implement Zalo Official Account OAuth | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E19-04 | Implement token status dashboard API (xem trạng thái ACTIVE/EXPIRED/REVOKED cho mọi accounts) | Trung (Leader) | 🟡 Cao |

### EPIC E20 — Quản lý Vòng đời Token

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E20-01 | Implement scheduled token refresh job (chạy lúc 2:00 AM mỗi ngày, refresh tokens hết hạn trong 7 ngày) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E20-02 | Implement alert notification khi token refresh fail (gửi thông báo cho Account Manager) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E20-03 | Implement manual token refresh API (Account Manager trigger thủ công) | Phước (Publisher) | 🟡 Cao |

---

## Sprint 8 — Publisher Service (Tuần 15–16)

### EPIC E21 — Publisher Service Cốt lõi

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E21-01 | Khởi tạo brandhub-publisher-service project (Spring Boot 3, RabbitMQ consumer setup) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-02 | Implement RabbitMQ consumer: nhận PublishJobMessage (postId, platform, content, mediaUrls, scheduledAt) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-03 | Implement Facebook publish adapter (Graph API v19: /me/feed + /me/photos) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-04 | Implement Instagram publish adapter (Content Publishing API: create container → publish) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-05 | Implement TikTok publish adapter (Content Posting API v2) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-06 | Implement Threads publish adapter (Threads API: tạo container → publish, max 500 chars) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E21-07 | Implement Zalo OA publish adapter (Article API + Photo API) | Phước (Publisher) | 🔴 Nghiêm trọng |

### EPIC E22 — Publish Callback & Xử lý Lỗi

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E22-01 | Implement HTTP callback về business-service sau khi publish xong (POST /internal/posts/{id}/publish-result) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E22-02 | Implement retry logic: thất bại → retry tối đa 3 lần với exponential backoff (1m, 5m, 15m) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E22-03 | Implement business-service handler cho publish callback (cập nhật post status, tạo notification) | Trung (Leader) | 🔴 Nghiêm trọng |

---

## Sprint 9 — Kết nối AI Service & Tích hợp Business (Tuần 17–18)

### EPIC E23 — Kết nối Internal API của AI Service

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E23-01 | Expose /internal/ai/content/generate endpoint (nhận topic + clientId + platform → trả caption + hashtags) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E23-02 | Expose /internal/ai/image/generate endpoint (nhận prompt + style → trả S3 URL) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E23-03 | Expose /internal/ai/ambassador/generate endpoint (nhận faceImage + productImage → trả S3 URL) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E23-04 | Expose /internal/ai/video/generate endpoint (nhận script + style → trả S3 URL, async with polling) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-E23-05 | Expose /internal/ai/trends/fetch endpoint (trả top trending topics theo platform + region) | Ân (AI) | 🟡 Cao |

### EPIC E24 — Tích hợp AI vào Business Service

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E24-01 | Implement AI content generation flow trong business-service: ContentRequest → call ai-service → lưu draft Post | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E24-02 | Implement image/ambassador generation trigger từ Post editor (user chọn AI generate image) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E24-03 | Implement AI usage tracking (đếm ai_credits_per_month theo subscription plan) | Trung (Leader) | 🟡 Cao |

---

## AI PARALLEL TRACK — Nghiên cứu & Triển khai AI

> **Ghi chú:** AI Track chạy song song với Sprints 5–12. Mỗi AI Iteration kéo dài 2 tuần.

---

## AI Iteration 1 — Nghiên cứu & Đánh giá (Song song với Sprints 5–6)

### EPIC AI-01 — Nghiên cứu & Đánh giá Mô hình AI

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI01-01 | Research và so sánh InstantID vs IP-Adapter vs ControlNet cho face-consistent virtual ambassador generation | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI01-02 | Test 3 virtual ambassador tools trên 5 ảnh sample, viết bảng so sánh (chất lượng, tốc độ, chi phí) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI01-03 | Research Google Veo API: capabilities, pricing, rate limits, movement parameters | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI01-04 | Thu thập và test 20+ video generation prompts với các movement parameters khác nhau, phân loại kết quả | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI01-05 | Research các kỹ thuật ghép ảnh sản phẩm + model: ControlNet inpainting, DALL-E edit, rembg + composite | Lộc (Frontend) | 🟡 Cao |
| DA-AI01-06 | Test 3 phương pháp ghép ảnh trên 10 cặp ảnh sản phẩm + model, đánh giá độ tự nhiên và chi phí compute | Lộc (Frontend) | 🟡 Cao |
| DA-AI01-07 | So sánh Llama 3 (Groq) vs Claude API: chất lượng caption tiếng Việt, tốc độ, chi phí/call | Cả nhóm | 🔴 Nghiêm trọng |
| DA-AI01-08 | Viết AI Research Summary Document tổng hợp kết quả của cả 3 mảng, lưu vào docs/ repo | Ân (AI) | 🟢 Trung bình |

### EPIC AI-02 — Thiết lập Hạ tầng AI Service

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI02-01 | Khởi tạo brandhub-ai-service project: FastAPI + Python 3.11 + folder structure (api/services/models/utils) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI02-02 | Configure 4 API clients từ .env: ChromaDB client, Groq API client, Anthropic client, Stability AI client | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI02-03 | Configure AWS S3 client với boto3, viết 3 helper functions: upload_file(), get_presigned_url(), delete_file() | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI02-04 | Setup Pydantic base schemas cho tất cả request/response models | Ân (AI) | 🟡 Cao |
| DA-AI02-05 | Viết Dockerfile cho ai-service + thêm service ai-service vào docker-compose.yml ở infrastructure repo | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI02-06 | Viết Internal API key authentication middleware (kiểm tra X-Internal-Key header) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI02-07 | Document ChromaDB collection design (collection naming per client, metadata schema, query patterns) | Tuấn (AI) | 🟡 Cao |

---

## AI Iteration 2 — RAG, LLM & Xu hướng (Song song với Sprints 7–8)

### EPIC AI-03 — RAG Knowledge Base Pipeline

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI03-01 | Implement document upload endpoint (nhận PDF/DOCX/TXT/URL, lưu file lên S3) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI03-02 | Build document chunking service dùng LangChain RecursiveCharacterTextSplitter (chunk_size=500, overlap=50) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI03-03 | Build embedding pipeline (text chunk → vector via embedding model → store ChromaDB với metadata: documentId, clientId, chunkIndex) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI03-04 | Implement semantic search (query → embedding → top-K retrieval từ ChromaDB theo clientId) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI03-05 | Build RAG context builder (format top-K chunks thành context string cho LLM prompt) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI03-06 | Document deletion endpoint (xóa chunks khỏi ChromaDB + file khỏi S3) | Lộc (Frontend) | 🟡 Cao |
| DA-AI03-07 | Test RAG accuracy (upload 3 brand documents thực tế, verify retrieved context đúng và không hallucinate) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI03-08 | Viết RAG pipeline documentation (architecture, tuning parameters, evaluation methodology) | Ân (AI) | 🟢 Trung bình |

### EPIC AI-04 — LLM Tạo Nội dung

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI04-01 | Build prompt template system (nhận topic + RAG context + trend data + tone → tạo full prompt) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI04-02 | Integrate Llama 3 via Groq API (system prompt enforce: only use provided context, do not fabricate) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI04-03 | Integrate Claude API làm fallback khi Groq rate limit hoặc quality thấp | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI04-04 | Implement platform-specific optimization (tự động truncate caption: FB 63k, Threads 500, TikTok 4k chars) | Lộc (Frontend) | 🟡 Cao |
| DA-AI04-05 | Implement hashtag generation endpoint (gọi Llama 3 với prompt đơn giản) | Lộc (Frontend) | 🟡 Cao |
| DA-AI04-06 | Implement regenerate with feedback (nhận previous output + feedback → tạo cải tiến) | Ân (AI) | 🟡 Cao |
| DA-AI04-07 | Anti-hallucination test (verify 20 generated captions — mọi claim đều có nguồn từ brand context) | Cả nhóm | 🔴 Nghiêm trọng |
| DA-AI04-08 | Viết Prompt Engineering Documentation (template design, system prompt best practices, tone guide) | Ân (AI) | 🟢 Trung bình |

### EPIC AI-05 — Dịch vụ Trend Crawler

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI05-01 | Implement Google Trends crawler (pytrends) lấy top trending keywords tại Việt Nam | Ân (AI) | 🟡 Cao |
| DA-AI05-02 | Implement TikTok trending hashtag crawler (web scraping hoặc unofficial API) | Ân (AI) | 🟡 Cao |
| DA-AI05-03 | Normalize trend data thành format chuẩn: {keyword, score, platform, relatedTopics[]} | Ân (AI) | 🟡 Cao |
| DA-AI05-04 | Implement Redis cache cho trend data (TTL 6 giờ, key: trends:vn:{date}:{category}) | Ân (AI) | 🟡 Cao |
| DA-AI05-05 | Implement trend suggestions API endpoint (GET /ai/trends?category=fashion&limit=20) | Ân (AI) | 🟡 Cao |
| DA-AI05-06 | Setup APScheduler để auto-crawl mỗi 6 giờ | Ân (AI) | 🟢 Trung bình |

---

## AI Iteration 3 — Ảnh, Ambassador & Ghép ảnh (Song song với Sprints 9–10)

### EPIC AI-06 — Pipeline Tạo Ảnh

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI06-01 | Integrate Stability AI API (SDXL): text-to-image với style, aspect ratio, negative prompt params | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI06-02 | Build image generation endpoint (POST /ai/image/generate → trả về S3 URL) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI06-03 | Implement batch generation (tạo 3 variations cùng lúc để user chọn) | Lộc (Frontend) | 🟡 Cao |
| DA-AI06-04 | Brand safety filter (negative prompts mặc định tránh content không phù hợp) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI06-05 | Test 20 product prompts thực tế, đánh giá chất lượng và thời gian generate | Lộc (Frontend) | 🟡 Cao |

### EPIC AI-07 — Virtual Brand Ambassador (InstantID)

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI07-01 | Setup InstantID pipeline (load model, face encoder InsightFace, ControlNet depth) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI07-02 | Implement reference photo processing (face detection + face embedding extraction) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI07-03 | Build face-consistent generation endpoint (POST /ai/ambassador/generate: 1 reference + prompt → generated image giữ nguyên khuôn mặt) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI07-04 | Test face consistency (generate 15 ảnh khác nhau: pose/background/outfit từ 1 reference → đo facial similarity score) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI07-05 | Build ambassador gallery management (lưu reference + generated images vào S3 theo clientId) | Tuấn (AI) | 🟡 Cao |
| DA-AI07-06 | Apply ambassador endpoint (POST /ai/ambassador/apply: ambassador key + background key → composed image) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI07-07 | Benchmark InstantID vs IP-Adapter trên bộ test 20 ảnh, document final decision | Tuấn (AI) | 🟡 Cao |
| DA-AI07-08 | Viết implementation guide (parameters, tips để tạo ambassador chất lượng cao) | Tuấn (AI) | 🟢 Trung bình |

### EPIC AI-08 — Pipeline Ghép ảnh

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI08-01 | Implement background removal cho product images (rembg library, U2Net model) → output PNG transparent | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI08-02 | Implement background removal cho model/ambassador images | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI08-03 | Build layer compositing service (product layer + model layer + background layer → single image dùng Pillow) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI08-04 | Implement shadow + lighting adjustment để merge trông tự nhiên | Lộc (Frontend) | 🟡 Cao |
| DA-AI08-05 | Build composition endpoint (POST /ai/compose: product S3 key + model S3 key + background S3 key → composed image) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI08-06 | Test 20 cặp product + model, evaluate realistic score, document các case fail | Lộc (Frontend) | 🟡 Cao |
| DA-AI08-07 | Viết composition parameter guide (optimal sizes, best practices cho từng loại sản phẩm) | Lộc (Frontend) | 🟢 Trung bình |

---

## AI Iteration 4 — Video, Tích hợp & Tài liệu (Song song với Sprints 11–12)

### EPIC AI-09 — AI Tạo Video

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI09-01 | Integrate Google Veo API (authentication, generate request, async polling cho status) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI09-02 | Build video prompt template system (nhận topic + movement type + duration → tạo optimized Veo prompt) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI09-03 | Implement movement parameter mapping (camera_pan, zoom_in, zoom_out, subject_walk → Veo params) | Ân (AI) | 🟡 Cao |
| DA-AI09-04 | Tạo prompt library: 10 loại marketing video x 3 movement styles = 30 prompt templates | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI09-05 | Build video generation endpoint (POST /ai/video/generate → async, trả về jobId → GET /ai/video/{jobId}/status để poll) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI09-06 | Upload generated video lên S3, extract thumbnail, trả về {videoUrl, thumbnailUrl, duration} | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI09-07 | Benchmark 30 prompts (quality, generation time, cost per video) → document kết quả | Ân (AI) | 🟡 Cao |
| DA-AI09-08 | Viết Video Generation Research Report (prompt guide, parameter cheat sheet, best practices) | Ân (AI) | 🟡 Cao |

### EPIC AI-10 — Tích hợp AI Service & Finalize API

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI10-01 | Finalize tất cả FastAPI endpoints (/ai/content, /ai/image, /ai/video, /ai/ambassador, /ai/compose, /ai/rag/*, /ai/trends) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-AI10-02 | Error handling & retry cho external AI API calls (exponential backoff, fallback provider) | Cả nhóm | 🟡 Cao |
| DA-AI10-03 | Integration test với business-service (verify tất cả AI calls từ business hoạt động đúng) | Cả nhóm | 🔴 Nghiêm trọng |
| DA-AI10-04 | Viết Postman collection cho tất cả AI endpoints với example requests | Lộc (Frontend) | 🟢 Trung bình |
| DA-AI10-05 | Viết Swagger/OpenAPI documentation cho ai-service | Lộc (Frontend) | 🟢 Trung bình |

### EPIC AI-11 — Tài liệu Nghiên cứu AI & Demo

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-AI11-01 | Viết Virtual Ambassador Technical Report (model comparison, implementation decisions, sample results gallery) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-AI11-02 | Viết Video Generation Research Report (full prompt library 30 templates, movement parameter guide, cost analysis) | Ân (AI) | 🔴 Nghiêm trọng |
| DA-AI11-03 | Viết Image Composition Research Report (technique comparison, best practices, quality evaluation) | Lộc (Frontend) | 🟡 Cao |
| DA-AI11-04 | Compile AI Cost Analysis (chi phí ước tính per feature x average usage x 1000 users/month) | Cả nhóm | 🟡 Cao |
| DA-AI11-05 | Record AI feature demo video (showcase 7 AI features hoạt động thực tế) | Cả nhóm | 🔴 Nghiêm trọng |
| DA-AI11-06 | Present AI results to mentor (demo live + Q&A, thu thập feedback) | Cả nhóm | 🔴 Nghiêm trọng |

---

## GIAI ĐOẠN 5 — Quy trình Nội dung & Đăng bài

---

## Sprint 10 — Yêu cầu Nội dung & Lịch (Tuần 19–20)

### EPIC E28 — Quản lý Yêu cầu Nội dung

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E28-01 | Implement POST /api/v1/content-requests (BRAND_CLIENT submit yêu cầu: topic, platform, tone, deadline) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E28-02 | Implement GET /api/v1/content-requests (ACCOUNT_MANAGER xem danh sách requests của clients mình) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E28-03 | Implement status tracking (SUBMITTED → ASSIGNED → IN_PROGRESS → PENDING_REVIEW → SENT_TO_CLIENT → APPROVED → REJECTED) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E29 — Phân công & Theo dõi Task

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E29-01 | Implement PUT /api/v1/content-requests/{id}/assign (ACCOUNT_MANAGER assign cho CONTENT_CREATOR) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E29-02 | Implement GET /api/v1/content-requests/my-tasks (CONTENT_CREATOR xem tasks được assign) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E29-03 | Implement deadline management (alert khi task sắp quá hạn) | Ân (AI) | 🟡 Cao |

### EPIC E30 — Lịch Nội dung & Lên lịch

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E30-01 | Implement GET /api/v1/posts/calendar (lấy posts theo date range, filter theo platform/status) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E30-02 | Implement POST /api/v1/posts/{id}/schedule (ACCOUNT_MANAGER đặt lịch: scheduledAt + targetPlatforms) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E30-03 | Build ContentCalendar React component (drag-drop rescheduling, color-coded status indicators) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E30-04 | Build PlatformPreview component (hiển thị preview đúng format của FB, IG, TikTok, Threads) | Lộc (Frontend) | 🟡 Cao |

---

## Sprint 11 — Quy trình Duyệt & Đăng bài Đầy đủ (Tuần 21–22)

### EPIC E31 — Quy trình Duyệt bài

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E31-01 | Implement POST /api/v1/posts/{id}/submit (CONTENT_CREATOR submit → PENDING_REVIEW) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E31-02 | Implement POST /api/v1/posts/{id}/account-review (ACCOUNT_MANAGER approve hoặc reject + note) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E31-03 | Implement POST /api/v1/posts/{id}/client-approve (BRAND_CLIENT approve → SCHEDULED) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E31-04 | Implement POST /api/v1/posts/{id}/client-reject (BRAND_CLIENT reject + feedback) | Trung (Leader) | 🔴 Nghiêm trọng |

### EPIC E32 — Hệ thống Đăng bài

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E32-01 | Implement Smart Ingestion (đóng gói post + encrypted token + platform configs thành RabbitMQ message) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E32-02 | Implement RabbitMQ consumer trong publisher-service (FIFO, exactly-once, acknowledgement) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-03 | Implement Facebook adapter (Graph API: IMAGE post và REEL/VIDEO) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-04 | Implement Instagram adapter (2-step: create container → publish) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-05 | Implement TikTok adapter (Direct Post cho video ≤60s, Creator Upload cho video >60s) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-06 | Implement Threads adapter (2-step: create container → publish, max 500 chars) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-07 | Implement Zalo OA adapter | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E32-08 | Implement HTTP callback → business-service sau khi publish (update post status: PUBLISHED/FAILED) | Phước (Publisher) | 🔴 Nghiêm trọng |

### EPIC E33 — Xử lý Lỗi Đăng bài

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E33-01 | Implement retry logic (tối đa 3 lần, exponential backoff: 30s, 60s, 120s) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E33-02 | Implement Dead Letter Queue handler (Admin có thể xem và manual retry/discard failed posts) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E33-03 | Implement failure notification (gửi alert cho Account Manager khi post fail sau tất cả retries) | Trung (Leader) | 🔴 Nghiêm trọng |

---

## GIAI ĐOẠN 6 — Frontend & Analytics

---

## Sprint 12 — Design System & Trang Cốt lõi (Tuần 23–24)

### EPIC E34 — Design System & Components Cơ bản

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E34-01 | Setup shadcn/ui + Tailwind CSS + custom design tokens trong web-dashboard | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E34-02 | Build common components: Button, Input, Modal, Toast, Table, Badge, Spinner, Dropdown | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E34-03 | Build layout components: Sidebar, Navbar, PageWrapper, AuthGuard | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E34-04 | Setup API service layer (Axios instance + interceptors + token refresh) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E34-05 | Setup Zustand stores (authStore, workspaceStore, notificationStore) | Lộc (Frontend) | 🔴 Nghiêm trọng |

### EPIC E35 — Trang Auth & Dashboard

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E35-01 | Build Login/Register pages với Google OAuth button | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E35-02 | Build main Dashboard page (overview: tổng posts, success rate, team activity) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E35-03 | Build Workspace management pages (create, settings, members) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E35-04 | Build Client management pages (list, create, edit, service package) | Lộc (Frontend) | 🔴 Nghiêm trọng |

### EPIC E36 — Trang Quản lý Nội dung

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E36-01 | Build Content Request list page (filter theo status, platform, deadline) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E36-02 | Build Content Editor page với AI Generate Panel (gọi ai-service, hiển thị caption + hashtag + image) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E36-03 | Build Content Calendar page (calendar view + drag-drop rescheduling) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E36-04 | Build Platform Preview modal (preview chính xác format của từng platform) | Lộc (Frontend) | 🟡 Cao |
| DA-E36-05 | Build Content Library page (media browser, template browser, hashtag groups) | Lộc (Frontend) | 🟡 Cao |

---

## Sprint 13 — Client Portal, Analytics & Thông báo (Tuần 25–26)

### EPIC E37 — Client Portal

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E37-01 | Build Client Portal login (isolated, chỉ thấy data của client mình) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E37-02 | Build Client Calendar (read-only, chỉ xem không edit) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E37-03 | Build Client Approval page (xem preview → approve/reject với feedback) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E37-04 | Build Client Analytics page (publishing results, success rate, campaign summary) | Lộc (Frontend) | 🟡 Cao |

### EPIC E38 — Analytics & Báo cáo

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E38-01 | Implement analytics aggregation APIs (tổng hợp data từ posts + publish_logs) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E38-02 | Implement automated report generation (weekly/monthly PDF report cho clients) | Trung (Leader) | 🟡 Cao |
| DA-E38-03 | Implement report email sending (tự động gửi email cho Brand Client theo schedule) | Ân (AI) | 🟡 Cao |
| DA-E38-04 | Build Analytics Dashboard (charts: publishing success rate, platform breakdown, campaign performance) | Lộc (Frontend) | 🔴 Nghiêm trọng |

### EPIC E39 — Hệ thống Thông báo

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E39-01 | Implement notification CRUD APIs (/api/v1/notifications: GET, PUT read, PUT read-all) | Trung (Leader) | 🟡 Cao |
| DA-E39-02 | Implement notification creation khi các events xảy ra (post published, task assigned, token expiry, etc.) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E39-03 | Build Notification Center UI (dropdown bell icon, unread badge, list với mark as read) | Lộc (Frontend) | 🟡 Cao |

---

## GIAI ĐOẠN 7 — Kiểm thử, Triển khai & Báo cáo Cuối kỳ

---

## Sprint 14 — Mobile App (Tuần 27–28)

### EPIC E40 — Mobile App Cốt lõi

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E40-01 | Setup React Native project với Expo, navigation (React Navigation v6) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E40-02 | Build Auth screens (Login, Register, Forgot Password) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E40-03 | Build Dashboard screen (simplified overview) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E40-04 | Build Calendar screen (calendar view, post status) | Lộc (Frontend) | 🟡 Cao |
| DA-E40-05 | Build Approval screen cho BRAND_CLIENT (xem preview, approve/reject) | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E40-06 | Implement offline draft mode (lưu draft vào AsyncStorage khi mất mạng, sync khi có mạng) | Lộc (Frontend) | 🟡 Cao |

### EPIC E41 — Mobile Notifications

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E41-01 | Integrate Firebase Cloud Messaging (FCM) cho push notifications | Lộc (Frontend) | 🔴 Nghiêm trọng |
| DA-E41-02 | Setup FCM server-side (gửi notification khi events xảy ra trong business-service) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E41-03 | Build Notification screen (list notifications, deep link khi tap) | Lộc (Frontend) | 🟡 Cao |
| DA-E41-04 | Integrate native camera + media gallery upload | Lộc (Frontend) | 🟡 Cao |

---

## Sprint 15 — Kiểm thử & Sửa lỗi (Tuần 29–30)

### EPIC E42 — Unit & Integration Testing

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E42-01 | Viết unit tests cho business-service (AuthService, WorkspaceService, PostService) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E42-02 | Viết unit tests cho ai-service (content generation, RAG pipeline, image generation) | Tuấn (AI) | 🔴 Nghiêm trọng |
| DA-E42-03 | Viết integration tests cho các API endpoints chính (business-service) | Phước (Publisher) | 🔴 Nghiêm trọng |
| DA-E42-04 | Performance testing (load test với 200 concurrent users) | Cả nhóm | 🟡 Cao |
| DA-E42-05 | Test publishing flow E2E trên sandbox accounts (FB/IG/TikTok/Threads/Zalo) | Phước (Publisher) | 🔴 Nghiêm trọng |

### EPIC E43 — Sửa lỗi & Hoàn thiện

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E43-01 | Sprint retrospective, compile bug list từ testing | Cả nhóm | 🔴 Nghiêm trọng |
| DA-E43-02 | UI responsive fixes (test trên các screen sizes: 1920px, 1440px, 1280px, mobile) | Lộc (Frontend) | 🟡 Cao |
| DA-E43-03 | Security audit checklist (check SQL injection, XSS, CSRF, token handling) | Trung (Leader) | 🔴 Nghiêm trọng |

---

## Sprint 16 — Triển khai, Tài liệu & Báo cáo Cuối (Tuần 31–32)

### EPIC E44 — Triển khai Production

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E44-01 | Setup VPS/EC2 instance, install Docker, configure nginx | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E44-02 | Deploy all services via docker-compose.prod.yml, setup SSL với Let's Encrypt | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E44-03 | Setup monitoring (uptime check, error alerts) | Trung (Leader) | 🟡 Cao |
| DA-E44-04 | Smoke test trên production environment | Cả nhóm | 🔴 Nghiêm trọng |

### EPIC E45 — Tài liệu Cuối kỳ

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E45-01 | Finalize Swagger API docs cho business-service | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E45-02 | Viết User Manual (hướng dẫn sử dụng cho từng role) | Cả nhóm | 🟡 Cao |
| DA-E45-03 | Viết Deployment Guide (step-by-step để deploy từ đầu) | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E45-04 | Record demo video (5-10 phút showcase tất cả features) | Cả nhóm | 🔴 Nghiêm trọng |

### EPIC E46 — Báo cáo & Thuyết trình Cuối kỳ

| Task ID | Mô tả | Người làm | Độ ưu tiên |
|---|---|---|---|
| DA-E46-01 | Viết Capstone report (theo đúng template của FPT) | Cả nhóm | 🔴 Nghiêm trọng |
| DA-E46-02 | Tổng hợp và review toàn bộ báo cáo trước khi nộp | Trung (Leader) | 🔴 Nghiêm trọng |
| DA-E46-03 | Chuẩn bị slide deck (15-20 slides, có demo screenshots) | Cả nhóm | 🔴 Nghiêm trọng |
| DA-E46-04 | Q&A preparation (anticipate câu hỏi từ mentor về kiến trúc, AI, database design) | Cả nhóm | 🟡 Cao |

---

## BẢNG TÓM TẮT SPRINT

| Sprint | Tuần | Giai đoạn | Sản phẩm bàn giao |
|---|---|---|---|
| Sprint 1 | 1–2 | Khởi động | Đăng ký đề tài, xác nhận vai trò nhóm, tạo workspace + repos |
| Sprint 2 | 3–4 | Yêu cầu | 60 Use Cases được tài liệu hóa, sơ đồ kiến trúc, ADRs, form Capstone |
| Sprint 3 | 5–6 | Thiết kế | Database schema (MongoDB + PostgreSQL), API spec, Figma wireframes |
| Sprint 4 | 7–8 | Hạ tầng | Docker Compose chạy được, CI/CD pipelines hoạt động, API Gateway chạy được |
| Sprint 5 | 9–10 | Auth & RBAC | Register/Login/OAuth hoạt động, JWT + refresh tokens, RBAC được thực thi |
| Sprint 6 | 11–12 | Business Cốt lõi | Workspace CRUD, Client management, Subscription plans hoạt động |
| Sprint 7 | 13–14 | Social OAuth | Tất cả 5 platform OAuth flows hoạt động, AES-256 token encryption, token refresh job |
| Sprint 8 | 15–16 | Publisher | Tất cả 5 platform adapters hoạt động, retry logic, DLQ, callback về business |
| Sprint 9 | 17–18 | AI Wiring | Tất cả AI internal endpoints được expose và gọi được từ business-service |
| AI Iter 1 | 5–6 | Nghiên cứu AI | Báo cáo so sánh model (ambassador, video, composition), scaffolded infrastructure |
| AI Iter 2 | 7–8 | AI RAG + LLM | RAG pipeline hoạt động, LLM tạo nội dung với anti-hallucination, trends crawler |
| AI Iter 3 | 9–10 | AI Image | Image generation, InstantID ambassador, image composition pipeline |
| AI Iter 4 | 11–12 | AI Video + API | Veo integration, tất cả AI endpoints finalized, integration tests, research reports |
| Sprint 10 | 19–20 | Content Flow | Content requests, task assignment, content calendar + scheduling |
| Sprint 11 | 21–22 | Publishing | Approval workflow, hệ thống publishing đầy đủ, error handling |
| Sprint 12 | 23–24 | Frontend Cốt lõi | Design system, auth pages, dashboard, content management pages |
| Sprint 13 | 25–26 | Frontend Đầy đủ | Client portal, analytics dashboard, notification center |
| Sprint 14 | 27–28 | Mobile | React Native app: auth, dashboard, calendar, approval, FCM |
| Sprint 15 | 29–30 | Kiểm thử | Unit + integration + E2E tests, bug fixes, security audit |
| Sprint 16 | 31–32 | Ra mắt | Production deploy, tài liệu cuối, capstone report, thuyết trình |

---

## BẢNG PHÂN CÔNG CÔNG VIỆC

| Thành viên | Vai trò | Số task | Trách nhiệm chính |
|---|---|---|---|
| Trung | Leader / Business Service | 54 | Khởi động dự án, kiến trúc hệ thống, API Gateway, Auth, RBAC, Workspace, Client, Subscription, Content workflow, Approval, Notification, Deployment, Báo cáo cuối |
| Lộc | Frontend / AI Infra | 55 | UI wireframes, web-dashboard (tất cả trang), React Native mobile, AI service project setup, S3 helper, image composition pipeline, image generation UI, ai-service Dockerfile |
| Tuấn | AI Engineer | 54 | Sequence diagrams, DB indexing strategy, API spec cho ai-service, ChromaDB design, AI infra setup, RAG embedding, InstantID ambassador pipeline, unit tests cho ai-service, CI/CD cho ai-service |
| Ân | AI Engineer | 54 | Non-functional AI requirements, Redis key doc, Admin user APIs, RAG chunking & context builder, LLM prompt system, trend crawler, video generation (Veo), AI research summaries |
| Phước | Publisher Engineer | 53 | Use case docs (UC21–60), social platform API specs, RabbitMQ message contract, permission matrix, publisher-service setup, tất cả 5 platform adapters, token manual refresh, integration tests cho publisher |

> **Tổng số task:** ~270 trên tất cả epics và AI track iterations.

---

## GHI CHÚ

- Văn bản tiếng Việt trong mô tả task của file gốc sử dụng dạng phiên âm (không dấu) để đảm bảo tương thích đa nền tảng trong các công cụ như Linear, GitHub Issues và Excel.
- Người thực hiện "Cả nhóm" có nghĩa là task yêu cầu sự tham gia của tất cả thành viên (ví dụ: họp nhóm, review chung, E2E testing).
- Các epic của AI Parallel Track chạy đồng thời với các sprint chính; timeline được căn chỉnh theo phạm vi tuần của sprint.
- Các task 🔴 Nghiêm trọng phải được unblock trước trong mỗi sprint trước khi bắt đầu các task 🟡 Cao.
- Task ID theo format: DA-{EPIC_ID}-{SEQ} (ví dụ: DA-E01-01, DA-AI07-03).
