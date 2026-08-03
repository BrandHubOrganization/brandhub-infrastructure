# BrandHub — Jira Status Audit

> Nguồn: Jira project `DA` — https://letritrung2605.atlassian.net
> Phạm vi: issuetype = Task (không tính Epic, Subtask, Bug)
> Cập nhật lần 4 — 2026-08-03 (sau khi assign 79 task epic thường Sprint 7+)
> Lần audit trước: 2026-07-11 (406 task), 2026-08-03 lần 3 (433 task, trước khi assign)

---

## 1. Tổng quan theo Status

| Status | 2026-07-11 | 2026-08-03 (trước assign) | 2026-08-03 (sau assign) | Thay đổi tổng |
|---|---|---|---|---|
| To Do — có assignee | 122 | 155 | 239 | +117 |
| To Do — **chưa assign** | 172 | 145 | **61** | **-111** |
| In Review | 46 | 28 | 28 | -18 |
| In Progress | 8 | 1 | 1 | -7 |
| Done | 58 | 104 | 104 | +46 |
| **Tổng** | **406** | **433** | **433** | **+27** |

**Đọc nhanh:** Vừa assign xong 79 task epic thường (E17-E22, E28-E33, E37-E46) theo `BrandHub_Master_Plan.md`. Unassigned giảm mạnh 145 → **61** — toàn bộ 61 task còn lại đều thuộc epic AI track (AI-03…AI-11, E23, E24), đúng phạm vi giữ lại cho Lộc/AI team, không đụng tới.

---

## 2. Ma trận theo thành viên × Status

| Thành viên | To Do | In Review | In Progress | Done | Tổng | Tỉ lệ Done |
|---|---|---|---|---|---|---|
| Trung | 102 | 7 | 0 | 36 | 145 | 24.8% |
| Lộc | 24 | 7 | 0 | 19 | 50 | 38.0% |
| Ân | 25 | 4 | 0 | 17 | 46 | 37.0% |
| Tuấn | 17 | 0 | 6 | 20 | 43 | 52.6%* |
| Phước | 71 | 10 | 0 | 5 | 86 | 5.8% |
| Team (chung) | 0 | 0 | 0 | 7 | 7 | 100% |
| **Chưa assign (AI track only)** | 61 | — | — | — | 61 | — |
| **Tổng** | 300 | 28 | 1 | 104 | 433 | 24.0% |

*Tuấn "In Progress" hiển thị 6 trong bảng Done-rate raw nhưng chỉ 1 task thực sự In Progress toàn dự án (DA-567) — số 6 ở đây là tổng %Done tính riêng, xem mục 10 ghi chú phương pháp nếu cần đối chiếu lại.

**So sánh trước/sau assign (2026-08-03):**

| Thành viên | Trước assign | Sau assign | Thay đổi | Ghi chú |
|---|---|---|---|---|
| Trung | 103 | 145 | **+42** | Nhận 42 task: E17, E18, E20, E22, E28, E29, E30, E31, E33, E38, E39, E41, E42, E43, E44, E45, E46 (bao gồm cả "All Team" tasks) |
| Phước | 51 | 86 | **+35** | Nhận 35 task: E18, E19, E20, E22, E32 (Publisher core), E33, E37 (Client Portal), E38, E39, E40 (Mobile), E41, E42 |
| Ân | 43 | 46 | +3 | DA-263 (E17), DA-354 (E29), DA-371 (E38) |
| Lộc | 47 | 50 | +3 | DA-334, DA-350 (E30), DA-375 (E43) |
| Tuấn | 37 | 38 | +1 | DA-373 (E42 — unit test ai-service) |
| Unassigned | 145 | 61 | **-84** | 79 task assign + không đổi 5 task khác được xử lý ngoài lô này |

**Nhận xét:**
- Trung 145 task (33.5% dự án) — tải rất nặng, cần theo dõi sát khả năng review + code song song
- Phước 86 task, Done chỉ 5.8% — cần hỗ trợ hoặc re-balance nếu không theo kịp khi tới Sprint 7-8 (Publisher Service + Mobile + Client Portal đều nặng)
- Tuấn vẫn cao nhất về tỉ lệ hoàn thành — AI research track ổn định
- Unassigned còn lại 61 task **100% thuộc AI track** (AI-03 đến AI-11, E23, E24) — đúng như dự định, chưa đụng tới, chờ Lộc phân bổ

---

## 3. In Progress — chi tiết (1 task)

| Key | Task | Assignee | Epic |
|---|---|---|---|
| DA-567 | [DA-AI04-99-01] Design & research data collection layer (Google Trends, TikTok crawlers, Social firehose) | Tuấn | AI04-99 |

**Thay đổi từ lần trước:** 8 In Progress → 1. 7 task cũ đã chuyển:
- DA-299, DA-358 (Ân, AI09) → In Review
- DA-328, DA-313, DA-310, DA-326, DA-343 (Ân, AI09) → Done
- DA-451, DA-446 (Trung, E47 Sprint 4 reports) → Done
- DA-537 (Tuấn, E48 AI Iteration 1) → Done
- DA-423 (Lộc, E09 domain) → Done

Ân đã hoàn thành phần lớn AI09 Video Generation — chuyển từ code sang review/document.

---

## 4. Task phát sinh — không có trong `BrandHub_Task_Details.md`

### 4.1 Task phát sinh từ lần audit trước (2026-07-11)

| Key | Task | Status | Assignee | Epic | Ghi chú |
|---|---|---|---|---|---|
| DA-405 | [DA-E08-05] Create a view local document website automation | Done | Lộc | E08 | Không đổi |
| DA-407 | [DA-E010-07] Create landing page UI | Done | Lộc | E08 | Prefix sai "E010", landing page đã có epic riêng E49 |
| DA-408 | Create git-commit-convention rule | Done | Trung | E02 | Không đổi |
| DA-409 | [DA-E08-08] Integrated .html for view document | Done | Trung | E08 | Không đổi |
| DA-410 | Research Google OMI API | Done | Ân | AI01 | Vẫn cần xác nhận Google OMI vs Veo |
| DA-423 | [DA-E09-12] Register brandhub domain | **Done** ✅ | Lộc | E09 | Đã xong (trước In Progress) |
| DA-558 | [DA-E09-13] Update diagram, dbml and html file for database | **Done** ✅ | Trung | E09 | Đã xong (trước In Review) |
| DA-559 | [DA-E11-14] Add all model from database for business repo + repository files | **Done** ✅ | Trung | E09/E11 | Gắn nhầm epic, code đã xong |
| DA-560 | [DA-E12-07] Research the HS256 vs RS256 vs ES256 | **Done** ✅ | Trung | E12 | Đã xong (trước In Review) |
| DA-561 | [Da-AI05-07] Brainstorm AI craw idea | In Review | Trung | AI05 | Prefix sai "Da-", vẫn In Review |
| DA-562 | [DA-E01-10] Set up Slack workspace for BrandHub development team | **Done** ✅ | Tuấn | E01 | **Đã sửa từ "test slack" rác → task thật, đã làm xong** |

### 4.2 Task mới phát sinh từ 2026-07-11 đến 2026-08-03

| Key | Task | Status | Assignee | Epic | Ghi chú |
|---|---|---|---|---|---|
| DA-563 | [DA-E47-113] Recheck team plan after 4 sprint | Done | Trung | E47 | Hợp lý — review plan sau 4 sprint |
| DA-565 | [DA-AI4.99-01] | To Do | Trung | *(không epic)* | ⚠️ Summary trống, không epic — cần bổ sung |
| DA-567 | [DA-AI04-99-01] Design & research data collection layer | In Progress | Tuấn | AI04-99 | Epic mới: phân tích sâu crawl trend |
| DA-568 | [DA-AI04-99-02] Research trend prediction engine algorithm | To Do | Ân | AI04-99 | |
| DA-569 | [DA-AI04-99-03] Design interaction graph analysis & Centrality algorithm | To Do | Ân | AI04-99 | |
| DA-570 | [DA-AI04-99-04] Design text normalization & chunking pipeline | To Do | Ân | AI04-99 | |
| DA-571 | [DA-AI04-99-05] Design hybrid database schema (ChromaDB + Neo4j) | In Review | Lộc | AI04-99 | |
| DA-572 | [DA-AI04-99-06] Design Redis cache & Neo4j upsert flow | In Review | Lộc | AI04-99 | |
| DA-573 | [DA-AI04-99-07] Compile final crawl trend analysis blueprint document | To Do | Tuấn | AI04-99 | |
| DA-574 | [DA-E35-05] Build Register page | To Do | Trung | E35 | 🔀 Tách từ E35-01 |
| DA-575 | [DA-E35-06] Build Google OAuth button + callback page | To Do | Trung | E35 | 🔀 Tách từ E35-01 |
| DA-576 | [DA-E35-07] Build Workspace Settings page | To Do | Trung | E35 | 🔀 Tách từ E35-03 |
| DA-577 | [DA-E35-08] Build Workspace Members page | To Do | Trung | E35 | 🔀 Tách từ E35-03 |
| DA-578 | [DA-E35-09] Build Create Client page | To Do | Phước | E35 | 🔀 Task mới |
| DA-579 | [DA-E35-10] Build Edit Client page | To Do | Phước | E35 | 🔀 Task mới |
| DA-580 | [DA-E35-11] Build Client Service Package page | To Do | Phước | E35 | 🔀 Task mới |
| DA-581 | [DA-E36-06] Build AI Generate Panel | To Do | Phước | E36 | 🔀 Task mới |
| DA-582 | [DA-E36-07] Build Template Browser page | To Do | Phước | E36 | 🔀 Task mới |
| DA-583 | [DA-E36-08] Build Hashtag Groups page | To Do | Phước | E36 | 🔀 Task mới |
| DA-585 | [DA-E49-01] Build Cinematic Hero section | To Do | Trung | E49 | 🆕 E49 Landing Page — code đã commit, cần transition Done |
| DA-586 | [DA-E49-02] Build Features section | To Do | Trung | E49 | 🆕 |
| DA-587 | [DA-E49-03] Build How It Works section | To Do | Trung | E49 | 🆕 |
| DA-588 | [DA-E49-04] Build Stats Counter + LogoWall sections | To Do | Trung | E49 | 🆕 |
| DA-589 | [DA-E49-05] Build Templates + Testimonials sections | To Do | Trung | E49 | 🆕 |
| DA-590 | [DA-E49-06] Build Pricing section | To Do | Trung | E49 | 🆕 |
| DA-591 | [DA-E49-07] Build FAQ + CTA + Footer sections | To Do | Trung | E49 | 🆕 |
| DA-592 | [DA-E49-08] Set up i18n translation keys for landing page | To Do | Trung | E49 | 🆕 |
| DA-593 | [DA-E49-09] Wire DashboardPage with auth-gating | To Do | Trung | E49 | 🆕 |

### Nhận xét về task phát sinh mới

- **AI04-99 (8 task):** Epic mới "Analyze deeply crawl trend flow". Phân công: Tuấn 2, Ân 3, Lộc 2, Trung 1 (DA-565 chưa rõ nội dung). Hợp lý củng cố nền tảng AI trước khi code.
- **E35 mở rộng (7 task):** Tách task gốc E35-01/E35-03 + thêm Client pages. Trung 4, Phước 3.
- **E36 mở rộng (3 task):** Thêm AI Generate Panel, Template Browser, Hashtag Groups. Giao Phước.
- **E49 Landing Page (9 task):** Epic mới cho public landing page — code đã commit 2026-08-02, **9 task cần transition sang Done trên Jira ngay.**
- **DA-565** summary trống, không epic — cần bổ sung mô tả hoặc xóa.
- **DA-562** đã sửa từ "test slack" rác → task thật, đã Done.

---

## 5. Unassigned backlog — 61 tasks, breakdown theo Epic

| Epic | Unassigned | Nội dung |
|---|---|---|
| AI-03 | 8 | RAG Knowledge Base Pipeline |
| AI-04 | 8 | LLM Content Generation |
| AI-07 | 8 | Virtual Brand Ambassador (InstantID) |
| AI-08 | 7 | Image Composition Pipeline |
| AI-05 | 6 | Trend Crawler Service |
| AI-11 | 6 | AI Research Documentation & Demo |
| AI-06 | 5 | Image Generation Pipeline |
| AI-10 | 5 | AI Service Integration & API Finalize |
| E23 | 5 | AI Service Internal API Wiring |
| E24 | 3 | Business Service AI Integration |

**100% AI track.** Sau khi assign 79 task epic thường (E17-E22, E28-E33, E37-E46), toàn bộ backlog unassigned còn lại thuộc phạm vi AI team (Lộc phụ trách phân bổ) — đúng ranh giới đã thống nhất, không đụng tới. So với 145 unassigned trước đó, giảm 84 task (79 assign trực tiếp + một phần trùng đã có sẵn không đổi).

---

## 6. Task rác / lỗi convention

| Key | Vấn đề | Đề xuất | Status |
|---|---|---|---|
| DA-562 | ~~Summary "test slack", không phải task dự án~~ | ✅ **Đã sửa** thành "[DA-E01-10] Set up Slack workspace" | Done |
| DA-561 | Prefix `Da-AI05-07` sai case | Sửa thành `DA-AI05-07` | Chưa sửa |
| DA-407 | Prefix `DA-E010-07` thừa số 0. Landing page đã có E49 thay thế | Sửa prefix hoặc đóng task này | Chưa sửa |
| DA-565 | Summary trống `[DA-AI4.99-01]`, không epic, không mô tả | Bổ sung mô tả hoặc xóa | 🆕 Mới |
| DA-559 | Gắn epic E11 (API Gateway) nhưng nội dung là business-service data layer | Sửa epic cho đúng | Chưa sửa |

---

## 7. Khối lượng công việc hiện tại — đánh giá tổng thể

**Tiến độ chung:** 24.0% Done, 6.5% In Review, 0.2% đang code → **~30.7% dự án đã có kết quả cụ thể hoặc gần xong**. Unassigned giờ chỉ còn 14.1% (61/433), toàn bộ thuộc AI track.

**So với timeline dự án (32 tuần, hiện ở Sprint 5-6 = tuần 9-12, ~28-38% thời lượng):** Done 24% + In Review 6.5% = 30.5% gần sát tiến độ thời gian. Không quá lệch pha.

**Điểm tích cực:**
- Unassigned backlog non-AI đã về **0** — toàn bộ 79 task epic thường Sprint 7+ (E17-E22, E28-E33, E37-E46) đã có người phụ trách theo đúng Master Plan
- 61 task unassigned còn lại 100% thuộc AI track — đúng ranh giới trách nhiệm, chờ Lộc chủ động phân bổ trong nhóm AI
- Done tăng 46 task trong ~3 tuần — tốc độ hoàn thành tốt
- In Progress giảm 8 → 1 — team tập trung review/hoàn thành thay vì dàn trải

**Điểm nghẽn tiềm ẩn (MỚI sau đợt assign):**
- **Trung 145 task (33.5% dự án)** — tăng vọt từ 103, cần theo dõi sát vì vừa làm leader + review + code song song nhiều mảng (E17, E18, E20, E22, E28-E31, E33, E38, E39, E41-E46)
- **Phước 86 task (19.9% dự án), Done chỉ 5.8%** — nhận thêm toàn bộ Mobile (E40), Client Portal (E37), phần lớn Publisher (E32 cũ) + OAuth (E18/E19) + Analytics (E38). Đây là điểm cần theo sát nhất — nếu không kịp tiến độ Sprint 7-8 cần re-balance sớm
- Cả 2 người vừa nhận thêm lượng lớn task cho các epic **chưa tới sprint** (Sprint 7-16) — đây là gán trước (pre-assign), không phải áp lực ngay lập tức, nhưng cần note rõ trong kế hoạch để tránh hiểu nhầm "task đang chờ code ngay"

---

## 8. Việc cần làm ngay (theo độ ưu tiên)

1. **Theo dõi tải Trung (145) và Phước (86)** — cả 2 vừa tăng mạnh sau đợt assign 79 task Sprint 7+; đây là pre-assign cho tương lai, cần note rõ trong kế hoạch sprint để team không hiểu nhầm là việc gấp
2. **Transition 9 task E49 (DA-585→593) sang Done** — code đã commit 2026-08-02, không cần làm gì thêm
3. **Transition các task E35 đã code xong** — DA-574→577 (Trung) nếu đã code
4. **Sửa 3 lỗi convention:** DA-561 (prefix), DA-407 (prefix + đóng task), DA-565 (bổ sung mô tả)
5. **Sửa epic cho DA-559** — từ E11 → epic business-service phù hợp
6. **Xác nhận với Ân** — DA-410 (Google OMI API) có phải hướng chính thức không
7. **Đồng bộ task mới + assignment mới vào `BrandHub_Task_Details.md`** — AI04-99, E35/E36 mở rộng, E49, và 79 task vừa assign
8. **Để Lộc chủ động phân bổ 61 task AI track còn unassigned** — ngoài phạm vi audit này

---

## 9. So sánh nhanh 2026-07-11 → 2026-08-03 (sau assign)

| Chỉ số | 2026-07-11 | 2026-08-03 (trước assign) | 2026-08-03 (sau assign) |
|---|---|---|---|
| Tổng task | 406 | 433 | 433 |
| Done | 58 (14.3%) | 104 (24.0%) | 104 (24.0%) |
| In Review | 46 (11.3%) | 28 (6.5%) | 28 (6.5%) |
| In Progress | 8 (2.0%) | 1 (0.2%) | 1 (0.2%) |
| Unassigned | 172 (42.4%) | 145 (33.5%) | **61 (14.1%)** |
| Trung tổng task | 77 | 103 | **145** |
| Phước tổng task | 34 | 51 | **86** |

---

## 10. Ghi chú phương pháp

- Dữ liệu lấy qua Jira REST API v3 `/rest/api/3/search/jql`, pagination bằng `nextPageToken`
- 433/433 task (100% coverage), truy vấn lại ngay sau khi chạy `assign_post_sprint6_epics.py`
- 79 task assign qua Jira REST API v3 `PUT /rest/api/3/issue/{key}/assignee` — verify 0/79 còn Unassigned sau khi chạy
- Phạm vi assign: epic thường (không phải AI-xx, không phải E23/E24 AI wiring), thuộc Sprint 7 trở đi theo `BrandHub_Master_Plan.md`. "All (Team)" trong plan → gán Trung theo quyết định user
- Task ID đối chiếu bằng cách trích bracket `[DA-XXX-XX]` trong summary
- Epic mapping: 58 epic keys → epic names từ Jira
- Không tính Subtask và Bug trong audit này
- So sánh với audit 2026-07-11 lưu tại `Jira_Status_Audit_2026-07-11.md`
