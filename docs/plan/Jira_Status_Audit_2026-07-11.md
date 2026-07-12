# BrandHub — Jira Status Audit

> Nguồn: Jira project `DA` — https://letritrung2605.atlassian.net
> Phạm vi: issuetype = Task (không tính Epic, Subtask, Bug)
> Cập nhật lần 2 — số liệu đã đối soát lại toàn bộ 406 task (lần audit đầu bị lỗi đếm do cursor phân trang sai, dẫn đến tổng ảo 455 và unassigned ảo 221 — số đúng là 406 / 172)

---

## 1. Tổng quan theo Status

| Status | Số lượng | Tỉ lệ |
|---|---|---|
| To Do — có assignee | 122 | 30.0% |
| To Do — **chưa assign** | 172 | 42.4% |
| In Review | 46 | 11.3% |
| In Progress | 8 | 2.0% |
| Done | 58 | 14.3% |
| **Tổng** | **406** | 100% |

**Đọc nhanh:** 14.3% công việc hoàn thành. 42.4% backlog **chưa có ai phụ trách**. Đây vẫn là rủi ro lớn nhất, dù tỉ lệ thấp hơn số đã báo cáo lần trước.

---

## 2. Ma trận theo thành viên × Status

| Thành viên | To Do | In Review | In Progress | Done | Tổng | Tỉ lệ Done |
|---|---|---|---|---|---|---|
| Trung | 39 | 13 | 2 | 23 | 77 | 29.9% |
| Lộc | 23 | 3 | 4 | 11 | 41 | 26.8% |
| Ân | 24 | 8 | 1 | 7 | 40 | 17.5% |
| Tuấn | 16 | 11 | 1 | 7 | 35 | 20.0% |
| Phước | 20 | 11 | 0 | 3 | 34 | 8.8% |
| Team (chung) | 0 | 0 | 0 | 7 | 7 | 100% |
| **Chưa assign** | 172 | — | — | — | 172 | — |
| **Tổng** | 294 | 46 | 8 | 58 | 406 | 14.3% |

**Nhận xét:**
- Trung gánh khối lượng lớn nhất (77 task, ~19% tổng dự án) — đúng vai trò leader nhưng cũng là điểm nghẽn tiềm ẩn nếu Trung bận việc quản lý
- **Phước**: 0 task In Progress, Done thấp nhất (8.8%) — nhưng có 11 task đang In Review, nhiều thứ 2 sau Trung. Không hẳn trễ — phần lớn task Publisher Service theo plan gốc chỉ bắt đầu Sprint 7-8, team hiện ở Sprint 3-4
- **Ân**: Done thấp nhất về tỉ lệ trong nhóm có việc từ đầu (17.5%) — cần theo dõi

---

## 3. In Progress — chi tiết (8 tasks)

| Key | Task | Assignee |
|---|---|---|
| DA-358 | [DA-AI09-05] Video generate endpoint | Ân |
| DA-328 | [DA-AI09-03] Movement parameter mapping | Ân |
| DA-313 | [DA-AI09-02] Video prompt template system | Ân |
| DA-299 | [DA-AI09-06] Upload video to S3 + thumbnail | Ân |
| DA-451 | [DA-E47-27] Team sprint report — Sprint 4 | Trung |
| DA-446 | [DA-E47-22] Individual sprint report — Sprint 4 | Trung |
| DA-537 | [DA-E48-01] AI iteration report — Iteration 1 | Tuấn |
| DA-423 | [DA-E09-12] Register brandhub domain (phát sinh) | Lộc |

4/8 task In Progress đều của Ân, tất cả thuộc AI09 (Video Generation) — đúng 1 chuỗi công việc liên tục, hợp lý không phải dàn trải nhiều việc cùng lúc.

---

## 4. Task phát sinh — không có trong `BrandHub_Task_Details.md`

So khớp toàn bộ 406 task Jira với plan gốc (415 task ID định nghĩa sẵn). Phát hiện **10 task thật sự phát sinh** ngoài plan (loại trừ các task cũ DA-1 đến DA-144 chỉ thiếu format `[DA-XXX]` trong summary — bản thân chúng khớp plan, chỉ là style đặt tên lúc đầu dự án).

| Key | Task | Status | Assignee | Sprint/Epic gốc gần nhất | Ghi chú |
|---|---|---|---|---|---|
| DA-405 | [DA-E08-05] Create a view local document website automation | Done | Lộc | E08 (UI/UX Wireframe) | Không có trong plan gốc — tooling phụ, hợp lý |
| DA-407 | [DA-E010-07] Create landing page UI | Done | Lộc | E10 (đánh số nhầm "E010") | Landing page không nằm trong scope 46 epic gốc |
| DA-408 | Create git-commit-convention rule | Done | Trung | — (không gắn epic) | Housekeeping, hợp lý phát sinh sớm |
| DA-409 | [DA-E08-08] Integrated .html for view document | Done | Trung | E08 | Liên quan DA-405, tooling doc site |
| DA-410 | Research Google OMI API: capabilities, pricing, rate limits... | Done | Ân | Gần AI-01 (research) | Google OMI không nằm trong tech stack gốc (Veo được chọn) — cần xác nhận đây có phải hướng nghiên cứu mới hay nhầm với Veo |
| DA-423 | [DA-E09-12] Register brandhub domain | In Progress | Lộc | E09 (Dev Environment) | Hợp lý — cần domain cho deploy/demo |
| DA-558 | [DA-E09-13] Update diagram, dbml and html file for database | In Review | Trung | E09/E06 | Bảo trì tài liệu DB sau khi schema đổi (users/workspaces chuyển sang PostgreSQL) |
| DA-559 | [DA-E11-14] Add all model from database for business repo + repository files | Done | Trung | E11 (API Gateway) — **gắn nhầm epic**, thực chất là business-service JPA layer | Code thật đã chạy, đúng hướng nhưng lại gắn epic E11 (Gateway) thay vì phải là epic riêng cho business-service data layer |
| DA-560 | [DA-E12-07] Research the HS256 vs RS256 vs ES256 | In Review | Trung | E12 (Authentication) | Hợp lý — quyết định thuật toán JWT trước khi code Auth |
| DA-561 | [Da-AI05-07] Brainstorm AI crawl idea | In Review | Trung | AI05 (Trend Crawler) | Có lỗi chính tả prefix "Da-" thay vì "DA-"; nội dung hợp lý mở rộng AI05 |
| DA-562 | test slack | To Do | Tuấn | — | **Rác — không phải task dự án thật, cần xoá** |

### Nhận xét về task phát sinh

- **9/10 task phát sinh hợp lý** — đa số là tooling (doc site, domain, git convention) hoặc quyết định kỹ thuật cần thiết trước khi code (JWT algorithm, DB diagram update)
- **DA-559 gắn sai epic** — nội dung là business-service data layer nhưng gắn vào E11 (API Gateway). Nên tách thành epic riêng hoặc sửa lại liên kết
- **DA-410 (Google OMI API)** cần xác nhận với Ân — tech stack gốc chọn Google Veo cho video gen, không phải Google OMI. Có thể là đánh giá thêm phương án, hoặc nhầm tên
- **DA-561 lỗi chính tả prefix** `Da-AI05-07` thay vì `DA-AI05-07` — không ảnh hưởng chức năng nhưng nên sửa cho nhất quán khi báo cáo/thống kê tự động

---

## 5. Unassigned backlog — 172 tasks, breakdown theo Epic

| Epic | Unassigned | Nội dung |
|---|---|---|
| AI03 | 8 | RAG Knowledge Base Pipeline |
| AI04 | 8 | LLM Content Generation |
| AI07 | 8 | Virtual Brand Ambassador |
| E32 | 8 | Publishing System |
| AI08 | 7 | Image Composition Pipeline |
| AI05 | 6 | Trend Crawler Service |
| AI11 | 6 | AI Research Documentation |
| E40 | 6 | Mobile App Core |
| E34 | 5 | Design System |
| E23 | 5 | AI Service Internal API Wiring |
| E36 | 5 | Content Management Pages |
| E42 | 5 | Testing |
| E15 | 5 | Workspace Management |
| AI10 | 5 | AI Service Integration & Finalize |
| AI06 | 5 | Image Generation Pipeline |
| E38 | 4 | Analytics & Reporting |
| E37 | 4 | Client Portal |
| E44 | 4 | Production Deployment |
| E35 | 4 | Auth & Dashboard Pages |
| E41 | 4 | Mobile Notifications |
| E31 | 4 | Approval Workflow |
| E46 | 4 | Final Report & Presentation |
| E45 | 4 | Final Documentation |
| E19 | 4 | TikTok/Threads/Zalo OAuth |
| E18 | 4 | Meta OAuth |
| E17 | 4 | Subscription & Billing |
| E16 | 4 | Client & Agency Management |
| E14 | 4 | RBAC |
| E30 | 4 | Content Calendar & Scheduling |
| E29 | 3 | Task Assignment & Tracking |
| E33 | 3 | Publish Error Handling |
| E24 | 3 | Business Service AI Integration |
| E22 | 3 | Publish Callback & Error Handling |
| E20 | 3 | Token Lifecycle Management |
| E39 | 3 | Notification System |
| E43 | 3 | Bug Fixes & Polish |
| E28 | 3 | Content Request Management |

**Điểm khác biệt so với báo cáo lần 1:** Unassigned trải đều qua hầu hết epic (3-8 task/epic), không tập trung riêng vào "Phase 5-7" như nhận định ban đầu. Kể cả epic Sprint 4-6 (E14-E20, đang gần với timeline hiện tại) cũng có 3-4 unassigned mỗi epic. **Đây là vấn đề cấp bách hơn báo cáo lần 1 nhận định** — vì cả những epic sắp tới (không chỉ epic xa) cũng thiếu người phụ trách.

---

## 6. Task rác / lỗi convention

| Key | Vấn đề | Đề xuất |
|---|---|---|
| DA-562 | Summary "test slack", không phải task dự án | Xoá khỏi backlog |
| DA-561 | Prefix `Da-AI05-07` sai case | Sửa thành `DA-AI05-07` |
| DA-407 | Prefix `DA-E010-07` — thừa số 0 (nên là E10 không phải E010) | Sửa lại prefix chuẩn |

---

## 7. Khối lượng công việc hiện tại — đánh giá tổng thể

**Tiến độ chung:** 14.3% Done, 11.3% In Review (gần xong chờ duyệt), 2% đang code → tổng cộng ~27.6% dự án đã có kết quả cụ thể hoặc gần xong. 42.4% chưa ai động vào.

**So với timeline dự án (32 tuần, hiện ở Sprint 3-4 = tuần 5-8):** Ở mốc thời gian ~19-25% của tổng thời lượng dự án, tiến độ Done 14.3% không quá lệch pha — nhưng **backlog unassigned lan rộng cả epic gần (Sprint 4-6)** là dấu hiệu cần PM chủ động gán việc ngay, không đợi tới sprint đó mới làm.

**Điểm nghẽn tiềm ẩn:**
- Trung ôm 77 task (19% dự án) — nếu Trung là bottleneck review (13 task In Review + việc leader), các task khác chờ Trung duyệt sẽ dồn ứ
- 46 task In Review toàn dự án — cần biết trung bình đang chờ bao lâu, ai duyệt

---

## 8. Việc cần làm ngay (theo độ ưu tiên)

1. **Xoá `DA-562`**, sửa 2 lỗi convention (DA-561, DA-407)
2. **Assign 172 unassigned task** — ưu tiên các epic gần timeline hiện tại trước (E14-E24, AI03-AI06), không chỉ epic xa
3. **Đồng bộ 10 task phát sinh vào `BrandHub_Task_Details.md`** — đặc biệt sửa epic gắn sai của DA-559
4. **Xác nhận với Ân** — DA-410 (Google OMI API) có phải hướng nghiên cứu chính thức không, hay nhầm với Google Veo
5. **Check 46 task In Review** — đo thời gian chờ duyệt trung bình, ai là bottleneck (Trung 13, Phước 11, Tuấn 11, Ân 8, Lộc 3)
6. **Theo dõi Ân** — tỉ lệ Done 17.5% thấp nhất trong nhóm có việc từ đầu dự án

---

## 9. Ghi chú phương pháp

- Dữ liệu lấy qua Jira MCP `searchJiraIssuesUsingJql`, `ORDER BY key ASC`, phân trang qua `nextPageToken`, gộp toàn bộ 406/406 task (100% coverage — khác với audit lần 1 chỉ đọc được mẫu ~150/221 task unassigned)
- Task ID đối chiếu bằng cách trích bracket `[DA-EXX-XX]` trong summary, so khớp với 415 task ID định nghĩa trong `BrandHub_Task_Details.md`
- Task cũ dạng DA-1 đến DA-144 không có bracket prefix trong summary nhưng khớp nội dung với plan — không tính là "phát sinh", chỉ là quy ước đặt tên khác ở giai đoạn đầu
- Không tính Subtask và Bug trong audit này
