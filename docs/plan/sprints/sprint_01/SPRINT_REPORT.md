# Sprint 1 Report — Project Kickoff

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 1 |
| Timeline | Weeks 1–2 (May 16–29, 2026) |
| Phase | Phase 1 — Initiation & Documentation |
| Goal | Register the capstone project, confirm team roles, and set up all project management infrastructure |
| Report date | 2026-06-29 |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E01 — Project Initiation | 5 | 5 | 0 | 0 | 0 | 100% |
| E02 — Project Management Setup | 4 | 4 | 0 | 0 | 0 | 100% |
| **Tổng** | **9** | **9** | **0** | **0** | **0** | **100%** |

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Trung (Leader) | 6 cá nhân + 2 team | 8 | 0 | Hoàn thành 100%, vượt scope với Docker Compose scaffold |
| Tuấn (AI) | 2 team (E01-01, E01-04) | 2 | 0 | Tham gia brainstorm + skill assessment |
| Ân (AI) | 2 team (E01-01, E01-04) | 2 | 0 | Tham gia brainstorm + skill assessment |
| Phước (Publisher) | 2 team (E01-01, E01-04) | 2 | 0 | Tham gia brainstorm + skill assessment |
| Lộc (Frontend) | 2 team (E01-01, E01-04) | 2 | 0 | Tham gia brainstorm + skill assessment |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Chất lượng | Ghi chú |
|---|---|---|---|---|
| Project brief (1-page) | Google Docs | All (Team) | ⭐⭐⭐⭐ | Problem statement, MVP features, out-of-scope |
| Team roles confirmed | Jira + GitHub | Trung | ⭐⭐⭐⭐⭐ | 5 roles rõ ràng, mỗi người own service riêng |
| Mentor contact made | Email | Trung | ⭐⭐⭐⭐ | Mentor Java microservices + AI |
| Capstone registration submitted | Call4project | Trung | ⭐⭐⭐⭐⭐ | Nộp đúng deadline FPT |
| Jira workspace + sprint cadence | [DA Project](https://letritrung2605.atlassian.net/jira/software/projects/DA/boards) | Trung | ⭐⭐⭐⭐⭐ | 16 sprints, Epic/Story/Task hierarchy |
| GitHub Org + 7 repos | [BrandHubOrganization](https://github.com/BrandHubOrganization) | Trung | ⭐⭐⭐⭐⭐ | Polyrepo structure chuẩn |
| Branch protection + commit convention | `docs/rule/git-commit-convention.md` | Trung | ⭐⭐⭐⭐⭐ | Conventional Commits, PR template |
| Service accounts (AWS, Groq, Stability AI) | Shared pw manager | Trung | ⭐⭐⭐⭐ | 3 API keys, IAM user S3 |
| **Bonus:** Docker Compose scaffold | `docker/docker-compose.yml` | Trung | ⭐⭐⭐⭐⭐ | MongoDB + PostgreSQL + Redis + RabbitMQ + ChromaDB — kèm healthchecks, init scripts, start scripts, pgAdmin |

**Tổng:** 9 deliverables | 5 service accounts secured | 7 repos initialized

---

## 4. Deliverables chưa hoàn thành

*Không có. Sprint 1 đạt 100% completion.*

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh

- **Polyrepo setup đầy đủ ngay Sprint 1:** GitHub Organization với đủ 7 repos, branch protection, commit convention — không cần refactor sau này
- **Docker Compose scaffold vượt scope:** Sprint 1 không yêu cầu Docker, nhưng Trung làm sớm để toàn bộ team có dev environment từ day 1. MongoDB + PostgreSQL + Redis + RabbitMQ + ChromaDB, healthchecks, init scripts, start-all.sh/ps1 — đầy đủ cho cả dự án
- **Jira được cấu hình kỹ:** Epic/Story/Task hierarchy, 2-week sprint cadence, issue templates — team không mất thời gian "học Jira" sau này
- **Service accounts được tạo sớm:** API keys (Groq, Stability AI, AWS) sẵn sàng trước khi cần dùng trong code

### 5.2 Vấn đề gặp phải

| Vấn đề | Ảnh hưởng | Trạng thái |
|---|---|---|
| Team chưa quen Jira/GitHub flow | Mất thời gian đào tạo async | ✅ Resolved: docs convention được viết (Sprint 2) |
| Chưa có docs site để xem tài liệu | Architecture diagrams chỉ xem qua HTML files | ✅ Resolved Sprint 3: VitePress setup bởi Lộc |

### 5.3 Technical debt để lại

- Không có. Sprint 1 là sprint khởi động, không có code.

---

## 6. Blocked tasks & Dependencies

*Không có blocking dependencies trong Sprint 1.*

---

## 7. Individual highlights

**Trung (Leader):** Hoàn thành 8/8 tasks, drive toàn bộ sprint. Điểm nổi bật: Docker Compose scaffold với 5 services + healthchecks + init scripts + start scripts — làm sớm từ Sprint 1 thay vì đợi Sprint 4. GitHub Org + 7 repos với branch protection rules. Jira workspace được cấu hình đầy đủ 16 sprint cadence.

**Tuấn (AI):** Tham gia brainstorm ý tưởng BrandHub, đóng góp input về AI capabilities (LLM routing, RAG, ChromaDB). Skill assessment: Python FastAPI, LangChain.

**Ân (AI):** Tham gia brainstorm, research các AI model options (Llama 3 vs Claude vs GPT). Skill assessment: AI/ML pipeline, prompt engineering.

**Phước (Publisher):** Tham gia brainstorm, research social platform APIs (Meta, TikTok, Zalo). Skill assessment: Java Spring Boot, REST APIs.

**Lộc (Frontend):** Tham gia brainstorm, research UI framework options (React + shadcn/ui vs Next.js). Skill assessment: React 18, TypeScript, Tailwind, React Native.

---

## 8. Sprint Retrospective

### 8.1 What went well?

- Team alignment tốt ngay từ đầu — 5 người đồng thuận về đề tài, scope, tech stack
- Trung chủ động scaffold infra sớm → team có dev env từ tuần 2
- Jira + GitHub được setup theo industry standard practices (branch protection, conventional commits)
- Tất cả service accounts được tạo sớm → không bị block khi đến Sprint code

### 8.2 What didn't go well?

- Team chưa quen quy trình Jira → mất vài ngày để hiểu Epic/Story/Task hierarchy
- Chưa có mentor review vào cuối sprint → nên lên lịch họp mentor từ Sprint 2
- Các thành viên chưa push code lên GitHub trong Sprint 1 → chưa có thói quen commit sớm/commit thường xuyên

### 8.3 Action items cho Sprint 2

| Action | Owner | Deadline |
|---|---|---|
| Thiết lập lịch họp mentor hàng tuần | Trung | Sprint 2 Day 1 |
| Viết Git commit convention guide | Trung | Sprint 2 Week 1 |
| Tất cả thành viên push code lên GitHub từ Sprint 2 | All | Sprint 2 Day 3 |
| Tổ chức mid-sprint check-in | Trung | Sprint 2 Day 7 |

---

## 9. Kế hoạch Sprint 2

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E03-01 List 60 use cases by role | Phước | Must finish trước E03-02/03/04 |
| 🔴 Critical | DA-E03-02 Write UC 01–20 | Trung | Admin + Agency Owner flows |
| 🔴 Critical | DA-E03-03 Write UC 21–40 | Phước | Account Manager + Content Creator |
| 🔴 Critical | DA-E04-01 Functional requirements per role | Trung | 6 roles × features matrix |
| 🔴 Critical | DA-E04-02 Non-functional requirements | Trung | Performance, Security, Reliability |
| 🔴 Critical | DA-E04-05 Capstone Register form | Trung | FPT deadline |
| 🔴 Critical | DA-E05-01 System architecture diagram | Trung | 7 services + 5 DBs |
| 🔴 Critical | DA-E05-05 4 ADRs | Trung | Polyrepo, MongoDB+PG, RabbitMQ, Gateway |
| 🔴 Critical | DA-E05-06 Sequence diagrams (4 flows) | Tuấn | Content creation, approval, publishing, token refresh |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 1 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub Organization | https://github.com/BrandHubOrganization |
| Docker Compose | `brandhub-infrastructure/docker/docker-compose.yml` |
| Commit Convention | `brandhub-infrastructure/docs/rule/git-commit-convention.md` |

---

*Report generated: 2026-06-29 | Sprint 1 ended: 2026-05-29*
