# Sprint 4 Report — Infrastructure, CI/CD & Gateway

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 4 |
| Timeline | Weeks 7–8 (Jul 1–14, 2026) |
| Phase | Phase 2 — Infrastructure Setup |
| Goal | Full local dev via Docker Compose, CI/CD for all services, API Gateway with JWT validation + rate limiting |
| Report date | *(Điền ngày nộp)* |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E09 — Development Environment Setup | 5 | | | | | |
| E10 — CI/CD Pipeline | 5 | | | | | |
| E11 — API Gateway | 5 | | | | | |
| **Tổng** | **15** | | | | | |

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Trung (Leader) | — | — | — | |
| Tuấn (AI) | — | — | — | |
| Phước (Publisher) | — | — | — | |
| Lộc (Frontend) | — | — | — | |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng |
|---|---|---|---|
| docker-compose.yml | `docker-compose.yml` | Trung | |
| init scripts | `scripts/init-mongo.js` + `init-postgres.sql` | Trung | |
| .env.example | `.env.example` | Trung | |
| clone-all.sh | `scripts/clone-all.sh` | Trung | |
| CI/CD business-service | `.github/workflows/business.yml` | Trung | |
| CI/CD publisher-service | `.github/workflows/publisher.yml` | Phước | |
| CI/CD ai-service | `.github/workflows/ai.yml` | Tuấn | |
| CI/CD web-dashboard | `.github/workflows/dashboard.yml` | Lộc | |
| API Gateway project | `brandhub-api-gateway/` | Trung | |

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| *(Điền nếu có)* | | | | |

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh

*(Điền)*

### 5.2 Vấn đề gặp phải

*(Điền)*

### 5.3 Technical debt

*(Điền)*

---

## 6. Blocked tasks & Dependencies

*(Điền nếu có)*

---

## 7. Individual highlights

*(Điền)*

---

## 8. Sprint Retrospective

### 8.1 What went well?

*(Điền)*

### 8.2 What didn't go well?

*(Điền)*

### 8.3 Action items cho Sprint 5

| Action | Owner | Deadline |
|---|---|---|
| *(Điền)* | | |

---

## 9. Kế hoạch Sprint 5

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E12-01/02/03/04 Auth APIs | Trung | |
| 🔴 Critical | DA-E14-01/02/03 RBAC | Trung | |
| 🟡 High | DA-E13-03/04 Admin user mgmt | Ân | |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 4 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub PRs — gateway | https://github.com/BrandHubOrganization/brandhub-api-gateway/pulls |

---

*Deadline nộp: 2026-07-14*
