# Sprint 2 Report — Requirements & Architecture

---

## 1. Thông tin Sprint

| Field | Value |
|---|---|
| Sprint | Sprint 2 |
| Timeline | Weeks 3–4 (May 30–Jun 12, 2026) |
| Phase | Phase 1 — Initiation & Documentation |
| Goal | Document all 60 use cases, write functional/non-functional requirements, and produce system architecture diagrams and ADRs |
| Report date | 2026-06-29 |
| Reported by | Lê Trí Trung (Leader) |

---

## 2. Tổng kết hoàn thành

### 2.1 Tỉ lệ hoàn thành theo Epic

| Epic | Tổng tasks | Done | In Review | In Progress | To Do | % Done |
|---|---|---|---|---|---|---|
| E03 — Use Case Documentation | 6 | 5 | 0 | 0 | 1 | 83% |
| E04 — Functional & Non-Functional Requirements | 5 | 3 | 2 | 0 | 0 | 100% |
| E05 — System Architecture Design | 8 | 7 | 1 | 0 | 0 | 100% |
| **Tổng** | **19** | **15** | **3** | **0** | **1** | **95%** |

> **Lưu ý:** DA-E03-05 (mentor review) chưa thực hiện — mentor chưa có lịch review. Sẽ carry over sang Sprint 3.

### 2.2 Tỉ lệ hoàn thành theo thành viên

| Thành viên | Tasks được giao | Done/In Review | Chưa làm | Ghi chú |
|---|---|---|---|---|
| Trung (Leader) | 10 | 10 | 0 | 100% completion + 3 bonus deliverables |
| Tuấn (AI) | 2 | 2 | 0 | Sequence diagrams + AI architecture section done |
| Ân (AI) | 1 | 1 | 0 | AI NFR done |
| Phước (Publisher) | 4 | 4 | 0 | 60 UCs fully documented |
| Lộc (Frontend) | 1 | 1 | 0 | Mobile NFR done |

---

## 3. Deliverables đã hoàn thành

| Deliverable | File/Link | Tác giả | Size | Chất lượng | Ghi chú |
|---|---|---|---|---|---|
| 60 Use Cases documented | `BrandHub_UseCases.xlsx` | Phước, Trung | 60 UCs | ⭐⭐⭐⭐ | UC01–20: Trung; UC21–60: Phước |
| Capstone Register form | `BrandHub_Capstone_Register.docx` | Trung | Full form | ⭐⭐⭐⭐⭐ | Nộp đúng deadline FPT |
| System Architecture Diagram | `docs/architecture/brandhub_architecture.html` | Trung | 518 lines HTML | ⭐⭐⭐⭐⭐ | Interactive, 7 services + 5 DBs |
| Polyrepo Structure Diagram | `docs/architecture/brandhub_polyrepo_structure.html` | Trung | 584 lines HTML | ⭐⭐⭐⭐⭐ | 7 repos, port assignments, language per service |
| DB Ownership Diagram | `docs/architecture/brandhub_db_ownership_diagram.html` | Trung | 569 lines HTML | ⭐⭐⭐⭐⭐ | Cross-DB reference strategy visualized |
| 4 ADRs | In `BrandHub_Project_Plan.md` | Trung | 4 records | ⭐⭐⭐⭐⭐ | Polyrepo, MongoDB+PG split, RabbitMQ, Gateway |
| 4 Sequence Diagrams | *(Tuấn deliverable)* | Tuấn | 4 flows | ⭐⭐⭐⭐ | Content creation, approval, publishing, token refresh |
| AI Architecture Section | In `BrandHub_Technical_Document.md` | Tuấn | AI section | ⭐⭐⭐⭐ | ai-service, ChromaDB, LLM routing |
| AI Performance NFR | In NFR document | Ân | AI section | ⭐⭐⭐⭐ | p95 targets: content <10s, image <20s |
| Mobile NFR | In NFR document | Lộc | Mobile section | ⭐⭐⭐⭐ | FCM, offline draft, camera requirements |
| BrandHub Project Plan | `docs/plan/BrandHub_Project_Plan.md` | Trung | 791 lines | ⭐⭐⭐⭐⭐ | Full 16 sprints + 4 AI iterations |
| Project Plan (Vietnamese) | `docs/plan/BrandHub_Project_Plan_VI.md` | Trung | — | ⭐⭐⭐⭐ | Bản dịch tiếng Việt |
| 4 AI Iteration Plans | `docs/plan/iterations/` | Trung | 474 lines | ⭐⭐⭐⭐⭐ | AI_Iteration_1 → _4 |
| **Bonus:** Git Commit Convention | `docs/rule/git-commit-convention.md` | Trung | 237 lines | ⭐⭐⭐⭐⭐ | Conventional Commits + PR template |
| **Bonus:** VitePress HTML Viewer | `frontend/.vitepress/` | Trung | 179 lines | ⭐⭐⭐⭐⭐ | Custom Vue component render HTML diagrams |

**Tổng:** 15 deliverables | ~4,000+ lines docs/HTML | 4 diagrams | 6 docs files

---

## 4. Deliverables chưa hoàn thành

| Task ID | Mô tả | Assignee | Lý do | Kế hoạch |
|---|---|---|---|---|
| DA-E03-05 | Mentor review UC list | All (Team) | Mentor chưa có lịch review | Carry over Sprint 3 Week 1 |

---

## 5. Đánh giá chất lượng

### 5.1 Điểm mạnh của sprint này

- **Architecture diagrams dạng interactive HTML:** Không dùng Mermaid hay Draw.io — custom CSS Grid + Flexbox + Tabler Icons, load nhanh, fully customizable, render được trong VitePress docs site
- **Project plan siêu chi tiết:** BrandHub_Project_Plan.md (791 lines) cover toàn bộ 16 sprints + 4 AI iterations với Epic/Task breakdown, assignees, priorities, dependencies — không còn ambiguity về "ai làm gì khi nào"
- **4 ADRs written:** Tất cả key architectural decisions được document với context + tradeoffs + alternatives — reviewer/mentor không cần hỏi "tại sao chọn cái này"
- **60 UCs phân bổ đúng theo role:** Mỗi use case thuộc về 1 trong 6 roles, có main flow + alt flow → developer không cần guess behavior
- **VitePress HTML Viewer:** Custom Vue component cho phép render các file HTML (architecture diagrams) trực tiếp trong docs site — không cần download hay mở tab riêng

### 5.2 Vấn đề gặp phải

| Vấn đề | Ảnh hưởng | Trạng thái |
|---|---|---|
| Sprint 2 tự kéo dài đến Jun 15–19 thay vì deadline Jun 12 | Một số deliverables (project plan, commit convention) bị trễ 3-7 ngày | ⚠️ Đã xong nhưng trễ |
| Mentor chưa review UC list | UC có thể cần sửa sau khi có feedback | ❌ Carry over Sprint 3 |
| Trung làm quá nhiều tasks (10/19) | Workload không cân bằng — team members khác chỉ 1-4 tasks | ⚠️ Cần phân bổ lại Sprint 3 |
| Team members (ngoài Trung) chưa push code lên GitHub | Không thể verify content của Tuấn/Ân/Phước/Lộc qua git | ⚠️ Cần enforce commit sớm |

### 5.3 Technical debt để lại

- [ ] Mentor review UC chưa xong → UC có thể cần refactor sau feedback
- [ ] Team members chưa có thói quen commit code lên GitHub → risk cao cho Sprint 3 (sprint đầu tiên có code)

---

## 6. Blocked tasks & Dependencies

| Task bị block | Block bởi | Impact | Action |
|---|---|---|---|
| DA-E03-06 (finalize UC Excel) | DA-E03-05 (mentor review) | UC table chưa được mentor sign-off | Mentor review Sprint 3 Week 1 |

---

## 7. Individual highlights

**Trung (Leader):** Hoàn thành 10/10 tasks + 3 bonus deliverables. Điểm nổi bật: System Architecture Diagram HTML 518 lines, Polyrepo Structure HTML 584 lines, DB Ownership Diagram HTML 569 lines, 4 ADRs đầy đủ context/tradeoffs/alternatives, Project Plan 791 lines cover toàn bộ 16 sprints. Bonus: Git Commit Convention 237 lines + VitePress HTML Viewer component. Các architecture diagrams đều là interactive HTML — không phụ thuộc tool bên ngoài.

**Tuấn (AI):** Hoàn thành DA-E05-06 (4 sequence diagrams: content creation, approval workflow, auto-publishing, OAuth token refresh) và DA-E05-07 (AI architecture section trong Technical Document — ai-service internal design, ChromaDB schema, LLM routing strategy). Chất lượng tốt, đúng yêu cầu.

**Ân (AI):** Hoàn thành DA-E04-03 (AI performance requirements: latency p95 < 10s content, < 20s image, throughput targets). Đúng NFR format.

**Phước (Publisher):** Hoàn thành DA-E03-01 (group 60 UCs by role), DA-E03-03 (UC 21–40: Account Manager + Content Creator), DA-E03-04 (UC 41–60: Brand Client + Social Publishing). Toàn bộ 60 UCs được document đúng format: Actor | UC ID | Name | Description | Precondition | Main Flow | Alt Flow | Postcondition.

**Lộc (Frontend):** Hoàn thành DA-E04-04 (mobile requirements: FCM push notifications, offline draft với AsyncStorage, native camera upload). Đúng NFR format.

---

## 8. Sprint Retrospective

### 8.1 What went well?

- Toàn bộ 19 tasks được hoàn thành về mặt nội dung — deliverables đầy đủ cho Capstone Register submission
- Architecture documentation vượt yêu cầu: 3 HTML diagrams + 4 ADRs + project plan 16 sprints
- Trung chủ động làm bonus deliverables (commit convention, VitePress HTML viewer) để unblock team cho các sprint sau
- UC documentation phân công rõ: Trung làm UC 01–20, Phước làm UC 21–60 → parallelism hiệu quả

### 8.2 What didn't go well?

- Sprint kéo dài hơn dự kiến (Jun 8–19 thay vì kết thúc Jun 12) → ảnh hưởng Sprint 3 start date
- Workload không cân bằng: Trung làm 10 tasks, các thành viên khác 1-4 tasks
- Chưa có git commits từ Tuấn/Ân/Phước/Lộc trong Sprint 2 → khó verify chất lượng nếu không có artifact trên repo
- Mentor chưa review UC list → task DA-E03-05 carry over

### 8.3 Action items cho Sprint 3

| Action | Owner | Deadline |
|---|---|---|
| Mentor review UC list | Trung (schedule) | Sprint 3 Day 3 |
| Tất cả thành viên commit code/docs lên GitHub từ Sprint 3 | All | Sprint 3 Day 1 |
| Phân bổ workload đồng đều hơn — không để 1 người làm >50% tasks | Trung | Sprint 3 planning |
| Tổ chức mid-sprint check-in | Trung | Sprint 3 Day 7 |
| Merge tất cả PRs vào develop trước EOD sprint | All | Sprint 3 last day |

---

## 9. Kế hoạch Sprint 3

| Priority | Task | Assignee | Ghi chú |
|---|---|---|---|
| 🔴 Critical | DA-E06-01 MongoDB schema + $jsonSchema validation | Trung | 8 collections |
| 🔴 Critical | DA-E06-02 PostgreSQL schema (15 tables) | Trung | Idempotent SQL scripts |
| 🔴 Critical | DA-E06-03 Database Strategy document | Trung | MongoDB vs PostgreSQL decision rules |
| 🔴 Critical | DA-E07-01 Define 70 business-service endpoints | Trung | 12 files, 11 tag groups |
| 🔴 Critical | DA-E07-04 ApiResponse format | Trung | 7-field envelope + 97 error codes |
| 🔴 Critical | DA-E07-05 OpenAPI YAML spec | Trung | 3,379 lines, 70 endpoints |
| 🔴 Critical | DA-E08-01 Wireframes all main screens | Lộc | 7 screens shadcn/ui annotated |
| 🔴 Critical | DA-E08-02 Component system | Lộc | atomic/molecule/organism |
| 🔴 Critical | DA-E08-03 User flow diagrams | Lộc | 3 main flows |
| 🔴 Critical | DA-E06-04 Indexing strategy | Tuấn | MongoDB + PostgreSQL |
| 🔴 Critical | DA-E06-05 DBML diagram | Tuấn | dbdiagram.io |
| 🔴 Critical | DA-E06-06 Redis key patterns | Ân | JWT blacklist, rate limit, OAuth state |
| 🟡 High | DA-E07-02 ai-service endpoints | Tuấn | 5 internal endpoints |
| 🟡 High | DA-E07-03 RabbitMQ message format | Phước | PublishJobMessage schema |
| 🟡 High | DA-E07-07 Social platform API specs | Phước | FB, TikTok, Threads, Zalo OA |

---

## 10. Links & References

| Resource | Link |
|---|---|
| Jira Sprint 2 Board | https://letritrung2605.atlassian.net/jira/software/projects/DA/boards |
| GitHub PRs — infrastructure | https://github.com/BrandHubOrganization/brandhub-infrastructure/pulls |
| Architecture Diagram | `docs/architecture/brandhub_architecture.html` |
| DB Ownership Diagram | `docs/architecture/brandhub_db_ownership_diagram.html` |
| Polyrepo Structure | `docs/architecture/brandhub_polyrepo_structure.html` |
| Project Plan | `docs/plan/BrandHub_Project_Plan.md` |
| Commit Convention | `docs/rule/git-commit-convention.md` |

---

*Report generated: 2026-06-29 | Sprint 2 ended: 2026-06-12*
