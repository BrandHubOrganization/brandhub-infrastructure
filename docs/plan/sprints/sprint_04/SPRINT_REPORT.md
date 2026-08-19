# Sprint 4 Report — Infrastructure, CI/CD & Gateway

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 4 |
| Timeline | Weeks 7–8 (Jul 1–14, 2026) |
| Phase | Phase 2 — Infrastructure Setup |
| Goal | Full local dev via Docker Compose, CI/CD for all services, API Gateway with JWT validation + rate limiting |
| Report date | 2026-08-02 |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E09 — Development Environment Setup | 13 | 8 | 4 | 1 | 0 | 62% |
| E10 — CI/CD Pipeline | 6 | 4 | 1 | 0 | 1 | 67% |
| E11 — API Gateway | 7 | 1 | 6 | 0 | 0 | 14% |
| E06 — Database Design (carry over) | 1 | 1 | 0 | 0 | 0 | 100% |
| E07 — API Design (carry over) | 2 | 2 | 0 | 0 | 0 | 100% |
| **Tổng** | **31** | **17** | **11** | **1** | **2** | **55%** |

> E09 và E11 có nhiều task phát sinh (🆕) so với plan gốc 5/5/5. E06 và E07 là carry over từ Sprint 3.

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done | In Review | In Progress | To Do | Ghi chú |
|---|---|---|---|---|---|---|
| Trung (Leader) | 11 | 3 | 7 | 0 | 1 | Gateway + Auth backend + CI business-service + báo cáo |
| Tuấn (AI) | 9 | 0 | 7 | 1 | 1 | Docker Compose + init scripts + .env + rate limiting + ChromaDB + LLM keys + Dockerfile gateway |
| Lộc (AI Sub-lead) | 6 | 6 | 0 | 0 | 0 | CI web-dashboard + Frontend key + domain + AI service init + S3 + Dockerfile AI |
| Phước (Publisher) | 4 | 4 | 0 | 0 | 0 | RabbitMQ contract + Social API specs + README + CI publisher-service |
| Ân (AI) | 1 | 1 | 0 | 0 | 0 | Redis key patterns document |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng |
|---|---|---|---|
| docker-compose.yml (3-file structure) | `docker/docker-compose.{infra,dev,apps}.yml` | Tuấn | ⭐⭐⭐⭐ |
| init-postgres.sql (schema + seed) | `scripts/init-postgres.sql` | Tuấn | ⭐⭐⭐⭐ |
| .env.example (all 6 services) | `docker/.env.example` | Tuấn | ⭐⭐⭐⭐ |
| clone-all.sh | `scripts/clone-all.sh` | Trung | ⭐⭐⭐ |
| README.md (setup guide) | `README.md` | Phước | ⭐⭐⭐⭐ |
| CI/CD business-service | `.github/workflows/business.yml` | Trung | ⭐⭐⭐⭐ |
| CI/CD publisher-service | `.github/workflows/ci.yml` (publisher-service repo) | Phước | ⭐⭐⭐⭐ |
| CI/CD ai-service | `.github/workflows/ai.yml` | Lộc / Tuấn | ⭐⭐⭐⭐ |
| CI/CD web-dashboard | `.github/workflows/ci.yml` (web-dashboard repo) | Lộc | ⭐⭐⭐⭐ |
| API Gateway project + JWT filter + routing + logging | `brandhub-api-gateway/` | Trung | ⭐⭐⭐⭐⭐ |
| Rate limiting filter design | `docs/api/DA-E11-03_Redis_Rate_Limiting_Filter.md` | Tuấn | ⭐⭐⭐⭐ |
| ChromaDB collection design | `docs/database/DA-AI02-07_ChromaDB_Collection_Design.md` | Tuấn | ⭐⭐⭐⭐ |
| Redis key patterns | `docs/database/DA-E06-06_Redis_Key_Patterns.md` | Ân | ⭐⭐⭐⭐⭐ |
| RabbitMQ publisher contract | `docs/architecture/rabbitmq_publisher_contract.html` | Phước | ⭐⭐⭐⭐ |
| Social platform API specs (5 platforms) | `docs/architecture/social_platforms_api_specs.html` | Phước | ⭐⭐⭐⭐⭐ |
| AI service project init + S3 helper + Dockerfile | `brandhub-ai-service/` | Lộc | ⭐⭐⭐⭐ |
| Gateway Dockerfile | `brandhub-api-gateway/Dockerfile` | Tuấn | ⭐⭐⭐⭐ |
| Register API + Login API (RS256 JWT) | `brandhub-business-service/` | Trung | ⭐⭐⭐⭐⭐ |
| Refresh Token API (rolling refresh) | `brandhub-business-service/` | Trung | ⭐⭐⭐⭐⭐ |
| Forgot/Reset Password + OTP verification | `brandhub-business-service/` | Trung | ⭐⭐⭐⭐⭐ |
| Logout API (Redis blacklist) | `brandhub-business-service/` | Trung | ⭐⭐⭐⭐⭐ |
| Frontend key (.env) | `brandhub-web/.env.example` | Lộc | ⭐⭐⭐ |
| BrandHub domain registered | DNS | Lộc | ⭐⭐⭐⭐ |

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| DA-452 (E47-28) | Finalize and commit Sprint 4 report | Trung | Đang tổng hợp 5 member reports | Hoàn thành 2026-08-02 |
| DA-537 (E48-01) | AI Iteration 1 report — Tuấn | Tuấn | Chưa bắt đầu | Sprint 5 |

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh

- **Gateway code chất lượng cao:** Trung implement 33/33 tests pass (business-service) + 31/31 tests pass (gateway), RS256 + Redis blacklist + OTP verification + rolling refresh token đầy đủ. Tự phát hiện và fix 5+ bugs (filter naming convention, health check, Windows Surefire, key mismatch, rate-limit prefix, env-only keys).
- **Infrastructure docs toàn diện:** Tuấn thiết kế 3-file docker-compose (infra core + dev override + app stack), init scripts idempotent, .env.example bao phủ toàn bộ 6 service, ChromaDB collection design + rate limiting contract đầy đủ.
- **Social platform specs xuất sắc:** Phước document 5 nền tảng (Facebook, Instagram, TikTok, Threads, Zalo) dạng HTML card-based visualization, mỗi platform có API version, auth, endpoints, rate limits, gotchas.
- **Redis key patterns rõ ràng:** Ân thiết kế 4 key families với naming convention, TTL, ownership matrix — unblock DA-E11-03.
- **AI service bootstrapped:** Lộc init FastAPI project, S3 client với 100% test coverage (moto mock), Dockerfile multi-stage với Torch CPU optimization.

### 5.2 Vấn đề gặp phải

- **Task reassignment không documented:** E09-01/02/03 được plan giao cho Trung nhưng thực tế Tuấn làm. Plan và thực tế bị lệch — cần update Master Plan.
- **Carry over từ Sprint 3:** 3 tasks (DA-E06-06, DA-E07-03, DA-E07-07) bị delay từ Sprint 3, hoàn thành trong Sprint 4. Estimate ban đầu thiếu buffer cho research/design docs.
- **2/5 member nộp report muộn:** Ân và Phước nộp sau deadline 19 ngày.
- **API Gateway rate limiting chưa implement:** DA-E11-03 mới dừng ở design document (Tuấn), chưa code trong gateway.

### 5.3 Technical debt

- `application.yml` của gateway cần sync với docker-compose: JWT config trong compose còn dùng `JWT_SECRET` (HMAC) trong khi gateway code đã chuyển sang `jwt.public-key-path` (RS256).
- Business-service cần gen RSA key pair và issue RS256 token trước khi docker-compose fix.
- `init-postgres.sql` cần manual migration trên production DB (`last_password_change` column, `audit_action` enum update).

---

## 6. Blocked tasks & Dependencies

- **DA-E11-03 (rate limiting implementation) blocked by:** chưa có người code — Tuấn mới design, Trung bận gateway core + auth backend.
- **Docker-compose JWT config blocked by:** business-service chưa implement RS256 (đang ở Sprint 5 — DA-E12-02).

---

## 7. Individual highlights

- **Trung:** 11 tasks, 33+31 tests pass, tự fix 5+ bugs. Gateway + Auth backend hoàn chỉnh: RS256 JWT, Redis blacklist, OTP email verification, forgot/reset password, rolling refresh token. Code production-ready.
- **Lộc:** 6/6 Done. CI web-dashboard, AI service init (FastAPI + Python 3.13), S3 client với 100% test coverage (moto), Docker multi-stage build giảm 2GB image size (Torch CPU).
- **Tuấn:** 7/9 In Review. Docker Compose 3-file structure, init-postgres.sql idempotent, .env.example 6 services, ChromaDB collection design, rate limiting contract, gateway Dockerfile.
- **Phước:** 4/4 Done. RabbitMQ publisher contract, social platform API specs (5 platforms HTML visualization), README setup guide, CI publisher-service.
- **Ân:** 1/1 Done. Redis key patterns document — 4 key families, naming convention, ownership matrix, acceptance checklist đầy đủ.

---

## 8. Sprint Retrospective

### 8.1 What went well?

- Gateway + Auth backend code chất lượng cao, test coverage tốt (64 tests pass, không regression).
- Infrastructure setup toàn diện: Docker Compose 3-layer, init scripts, .env.example, CI/CD cho tất cả services.
- Document đầy đủ: Redis key patterns, ChromaDB design, RabbitMQ contract, social platform specs.
- Team tự xử lý blocker hiệu quả (Trung fix 5+ bugs, Lộc optimize Docker image, Tuấn thiết kế rate limiting atomic).

### 8.2 What didn't go well?

- Task assignment trong plan và thực tế bị lệch (E09-01/02/03).
- 3 task carry over từ Sprint 3.
- 2/5 member nộp report muộn.
- Rate limiting chưa code xong trong sprint.

### 8.3 Action items cho Sprint 5

| Action | Owner | Deadline |
|---|---|---|
| Update Master Plan E09 assignment (match thực tế) | Trung | Sprint 5 Week 1 |
| Implement rate limiting filter trong gateway | Tuấn / Trung | Sprint 5 Week 1 |
| Sync docker-compose JWT config với gateway RS256 | Trung | Sau khi business-service RS256 done |
| Nộp report đúng deadline | All | Sprint 5 end |
| Hoàn thành AI Iteration 1 report (DA-537) | Tuấn | Sprint 5 Week 1 |

---

## 9. Kế hoạch Sprint 5

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E12-01/02/03/04 Auth APIs | Trung | Register, Login, Refresh, Logout |
| 🔴 Critical | DA-E12-05/06 Forgot Password + Google OAuth | Trung | |
| 🔴 Critical | DA-E14-01/02/03 RBAC | Trung | @RequireRole, workspace/client isolation |
| 🔴 Critical | DA-E34-01→05 Design System | Phước | shadcn/ui + components + stores |
| 🟡 High | DA-E13-01/02 User profile + Avatar | Trung | |
| 🟡 High | DA-E13-03/04 Admin user mgmt | Ân | |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 4 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub — gateway | https://github.com/BrandHubOrganization/brandhub-api-gateway |
| GitHub — business-service | https://github.com/BrandHubOrganization/brandhub-business-service |
| GitHub — ai-service | https://github.com/BrandHubOrganization/brandhub-ai-service |
| GitHub — web-dashboard | https://github.com/BrandHubOrganization/brandhub-web |
| GitHub — publisher-service | https://github.com/BrandHubOrganization/brandhub-publisher-service |

---

*Deadline nộp: 2026-07-14 | Nộp muộn: 2026-08-02*
