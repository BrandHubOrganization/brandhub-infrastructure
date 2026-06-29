# Sprint 1 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Lê Trí Trung |
| GitHub | [@trungle](https://github.com/trungle) |
| Role | Leader / Backend Engineer |
| Sprint | Sprint 1 |
| Ngày nộp | 2026-06-29 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-E01-01 | [DA-E01-01](https://letritrung2605.atlassian.net/browse/DA-E01-01) | Brainstorm BrandHub topic, define scope & MVP | 🔴 Critical | ✅ Done |
| DA-E01-02 | [DA-E01-02](https://letritrung2605.atlassian.net/browse/DA-E01-02) | Team meeting to confirm roles and responsibilities | 🔴 Critical | ✅ Done |
| DA-E01-03 | [DA-E01-03](https://letritrung2605.atlassian.net/browse/DA-E01-03) | Find and contact a mentor | 🔴 Critical | ✅ Done |
| DA-E01-05 | [DA-E01-05](https://letritrung2605.atlassian.net/browse/DA-E01-05) | Submit project registration on Call4project | 🔴 Critical | ✅ Done |
| DA-E02-01 | [DA-E02-01](https://letritrung2605.atlassian.net/browse/DA-E02-01) | Create Jira workspace + 2-week sprint cadence | 🔴 Critical | ✅ Done |
| DA-E02-02 | [DA-E02-02](https://letritrung2605.atlassian.net/browse/DA-E02-02) | Create GitHub Organization + 7 repos | 🔴 Critical | ✅ Done |
| DA-E02-03 | [DA-E02-03](https://letritrung2605.atlassian.net/browse/DA-E02-03) | Branch protection rules + Conventional Commits | 🔴 Critical | ✅ Done |
| DA-E02-04 | [DA-E02-04](https://letritrung2605.atlassian.net/browse/DA-E02-04) | Service accounts (AWS, Groq, Stability AI, GitHub Actions) | 🔴 Critical | ✅ Done |

**Tổng:** 8 tasks | ✅ Done: 8 | In Review: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

### [DA-E01-01/02] — Brainstorm + Team kickoff meeting

- Tổ chức họp nhóm lần đầu, xác định đề tài BrandHub — AI-Powered Multi-Channel Content Platform
- Output: 1-page brief gồm problem statement, target users (Agency Owner/Content Creator/Brand Client), MVP feature list, out-of-scope list
- Phân công role: Trung (Leader/Backend), Lộc (Frontend), Tuấn (AI), Ân (AI), Phước (Publisher)
- Xác định tech stack: Java Spring Boot 3, Python FastAPI, React 18, React Native, MongoDB + PostgreSQL + Redis + ChromaDB + RabbitMQ

### [DA-E01-03] — Mentor contact

- Tìm và liên hệ mentor có background Java microservices + AI/ML
- Chuẩn bị 1-paragraph project pitch để trình bày

### [DA-E01-05] — Submit capstone registration

- Nộp đăng ký đề tài trên hệ thống Call4project (insideuni.fpt.edu.vn) đúng deadline FPT

### [DA-E02-01] — Jira setup

- Tạo Jira project `DA`, cấu hình 2-week sprint cadence
- Tạo issue templates, Epic/Story/Task hierarchy
- Import toàn bộ task từ sprint plan vào Jira với priority + assignee

### [DA-E02-02] — GitHub Organization + 7 repos

- Tạo GitHub Organization: [BrandHubOrganization](https://github.com/BrandHubOrganization)
- Tạo 7 repos: `brandhub-business-service`, `brandhub-ai-service`, `brandhub-publisher-service`, `brandhub-api-gateway`, `brandhub-web-dashboard`, `brandhub-mobile-app`, `brandhub-infrastructure`
- Invite toàn bộ team members vào GitHub Org

### [DA-E02-03] — Branch protection + commit convention

- Branch strategy: `main` (prod), `develop` (integration), `feature/*`, `fix/*`, `docs/*`
- Branch protection: require 1 approval + passing CI để merge vào `develop`; require 2 approvals cho `main`
- PR template: commit vào `docs/rule/`

### [DA-E02-04] — Service accounts

- AWS: tạo IAM user với S3 access policy, lưu credentials vào shared password manager
- Groq API key: đăng ký account, lấy key cho LLM inference
- Stability AI API key: đăng ký cho image generation
- GitHub Actions secrets: cấu hình `GHCR_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

---

## 4. Tasks chưa hoàn thành

*Không có.*

---

## 5. Đóng góp ngoài tasks chính

- Scaffold `brandhub-infrastructure` repo với Docker Compose stack đầy đủ:
  - `docker-compose.yml` với 5 services: MongoDB, PostgreSQL, Redis, RabbitMQ, ChromaDB — kèm healthchecks
  - `scripts/init-mongo.js` + `scripts/init-postgres.sql` — init scripts chạy tự động lần đầu
  - `docker/.env.example` — consolidate tất cả env vars
  - Start scripts: `start-all.sh`, `start-all.ps1`, `start-no-mobile.sh/.ps1`
  - pgAdmin config: `pgadmin-servers.json` để auto-connect
- Commit: `67fca93` (Jun 1), `4e42c2b` (Jun 1)
- **Ghi chú:** Task này thuộc Sprint 4 (DA-E09-01/02) nhưng được thực hiện sớm trong Sprint 1 để unblock toàn bộ team dev environment

---

## 6. Học được gì trong sprint này

1. **Polyrepo organization trên GitHub** — cách manage 7 repos dưới 1 GitHub Org, cấu hình team permissions, branch protection rules theo từng repo
2. **Jira project setup từ đầu** — tạo Epic/Story hierarchy, sprint cadence, issue templates sao cho phù hợp với nhóm 5 người
3. **Docker Compose multi-service stack** — cách wire healthchecks giữa các services phụ thuộc nhau (MongoDB → business-service, PostgreSQL → business-service), troubleshoot container startup order

---

## 7. Feedback & Đề xuất

- Sprint 1 thiên về setup hành chính và infra — không có technical deliverable nào được review bởi mentor. Đề xuất: ở các sprint sau, mỗi sprint nên có ít nhất 1 technical artifact để mentor review.
- Team chưa có kinh nghiệm Jira → mất thời gian setup issue templates. Lần sau nên dùng template có sẵn.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Tất cả tasks done trước ngày 29/05 |
| Chất lượng deliverable | 4/5 | Docker Compose vượt yêu cầu Sprint 1; Jira cần fine-tune |
| Giao tiếp với team | 4/5 | Kickoff meeting tốt; follow-up async qua GitHub Issues |
| Chủ động xử lý blocker | 5/5 | Scaffold infra sớm để team không bị block ở Sprint 2 |
| **Tổng** | **18/20** | |

---

*Deadline nộp: 2026-05-29 | Nộp bổ sung: 2026-06-29*
