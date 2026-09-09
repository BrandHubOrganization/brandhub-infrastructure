# BrandHub — Jira Status Audit

> Nguồn: Jira project `DA` — https://letritrung2605.atlassian.net
> Phạm vi: issuetype = Task (không tính Epic, Subtask, Bug)
> Cập nhật lần 5 — 2026-09-03 (sau khi chuyển 186 task tài liệu To Do sang Sprint 7)
> Lần audit trước: 2026-08-03 (433 task)

---

## 1. Tổng quan theo Status

| Status | 2026-07-11 | 2026-08-03 | 2026-09-03 | Thay đổi (từ 08-03) |
|---|---|---|---|---|
| To Do — có assignee | 122 | 239 | 198 | -41 |
| To Do — **chưa assign** | 172 | 61 | **39** | **-22** |
| In Review | 46 | 28 | **106** | **+78** |
| In Progress | 8 | 1 | **16** | **+15** |
| Done | 58 | 104 | **298** | **+194** |
| Cancel | — | — | **9** | +9 (status mới) |
| **Tổng** | **406** | **433** | **666** | **+233** |

**Đọc nhanh:** Dự án đã bổ sung 233 task mới kể từ 08-03 — chủ yếu là 207 task tài liệu SEP490 (Document Plan: D01-D23, xem chi tiết mục 9) cộng thêm ~26 task AI track khác. Done tăng vọt +194 (24.0% → 44.7%), In Review tăng mạnh +78 — team đang ở giai đoạn nộp bài/review dồn dập cho deadline capstone Aug 28. Có **9 task bị Cancel** — trạng thái hoàn toàn mới, chưa từng xuất hiện ở audit trước, cần rà soát nguyên nhân (mục 4).

---

## 2. Ma trận theo thành viên × Status

| Thành viên | To Do | In Review | In Progress | Done | Cancel | Tổng | Tỉ lệ Done |
|---|---|---|---|---|---|---|---|
| Trung | 87 | 27 | 2 | 70 | 0 | 186 | 37.6% |
| Phước | 51 | 46 | 2 | 30 | 5 | 134 | 22.4% |
| Lộc | 24 | 1 | 0 | 83 | 1 | 109 | **76.1%** |
| Ân | 21 | 1 | 12 | 65 | 0 | 99 | 65.7% |
| Tuấn | 15 | 31 | 0 | 43 | 3 | 92 | 46.7% |
| Team (chung) | 0 | 0 | 0 | 7 | 0 | 7 | 100% |
| **Chưa assign** | 39 | — | — | — | — | 39 | — |
| **Tổng** | 237 | 106 | 16 | 298 | 9 | 666 | 44.7% |

**So sánh khối lượng trước/sau (2026-08-03 → 2026-09-03):**

| Thành viên | 08-03 | 09-03 | Thay đổi | Ghi chú |
|---|---|---|---|---|
| Trung | 145 | 186 | **+41** | Chủ yếu nhận task Document Plan (D08, D12, D20-D23, review D21) |
| Phước | 86 | 134 | **+48** | Tăng mạnh nhất — nhận cả code (E-series) lẫn phần lớn task tài liệu D09-D10, D14, D18 |
| Lộc | 50 | 109 | **+59** | Tăng nhiều nhất về số lượng, nhưng Done rate cao nhất (76.1%) — đang xử lý tốt |
| Ân | 46 | 99 | +53 | AI track + D07, D11, D19-D21 tài liệu |
| Tuấn | 43 | 92 | +49 | AI track + D01, D02, D06, D13-D14, D17 tài liệu |
| Unassigned | 61 | 39 | -22 | Giảm — một phần AI backlog đã có người nhận |

**Nhận xét:**
- **Lộc dẫn đầu tỉ lệ hoàn thành 76.1%** — xử lý rất tốt dù khối lượng tăng gấp đôi (50 → 109).
- **Phước tải nặng nhất về số lượng tuyệt đối tăng thêm (+48)**, Done rate vẫn thấp nhất (22.4%) — vẫn là điểm cần theo dõi sát nhất như audit trước đã cảnh báo.
- **Ân giữ tỉ lệ hoàn thành cao (65.7%)** dù đang có 12 task In Progress cùng lúc (AI05 trend engine) — cần chú ý tránh dàn trải quá nhiều việc song song.
- Unassigned giảm về 39, 100% vẫn thuộc AI track (AI06-AI11, E23, E24) — đúng ranh giới trách nhiệm, chờ Lộc phân bổ tiếp.

---

## 3. In Progress — chi tiết (16 task)

| Key | Task | Assignee | Sprint |
|---|---|---|---|
| DA-214 | [DA-E21-06] Implement Threads publish adapter | Phước | Sprint 4-8 |
| DA-240 | [DA-AI04-01] Build prompt template system | Ân | Sprint 8 |
| DA-246 | [DA-AI04-06] Implement regenerate with feedback | Ân | Sprint 8 |
| DA-272 | [DA-E21-05] Implement TikTok publish adapter | Phước | Sprint 4-8 |
| DA-613 | [DA-E12-09] Implement Facebook OAuth login | Trung | Sprint 6, 8 |
| DA-614 | [DA-E12-10] Implement GitHub OAuth login | Trung | Sprint 6, 8 |
| DA-744 | [DA-AI05-06] Underthesea NLP Tokenization | Ân | Sprint 6, 8 |
| DA-745 | [DA-AI05-07] Slang Map & Text Normalization Engine | Ân | Sprint 6, 8 |
| DA-746 | [DA-AI05-08] BM25 Anomaly Calculation | Ân | Sprint 6, 8 |
| DA-747 | [DA-AI05-09] Neo4j Interaction Graph Construction | Ân | Sprint 6, 8 |
| DA-748 | [DA-AI05-10] GDS Engine Scheduled Execution | Ân | Sprint 6, 8 |
| DA-749 | [DA-AI05-11] Degree Filter & Botnet Detection | Ân | Sprint 6, 8 |
| DA-750 | [DA-AI05-12] Personalized PageRank Engine | Ân | Sprint 6, 8 |
| DA-751 | [DA-AI05-13] Betweenness Centrality Engine | Ân | Sprint 6, 8 |
| DA-752 | [DA-AI05-14] Final Scoring Engine | Ân | Sprint 6, 8 |
| DA-753 | [DA-AI05-15] Filter Top 10-20 Trends Engine | Ân | Sprint 6, 8 |

**Đáng chú ý:** Ân đang **12/16 task In Progress cùng lúc** — toàn bộ pipeline AI05 (Knowledge Graph trend scoring, từ NLP tokenization đến final scoring). Đây là một chuỗi công việc liên tục (mỗi task là 1 bước trong pipeline), không hẳn là dàn trải thật sự, nhưng nên xác nhận có đang làm tuần tự đúng thứ tự phụ thuộc hay bị mắc kẹt ở khâu nào.

---

## 4. Cancel — chi tiết (9 task, trạng thái MỚI)

| Key | Task | Assignee | Sprint | Loại |
|---|---|---|---|---|
| DA-639 | [DA-D01-02] Draw System Architecture Diagram | Phước | Sprint 7 | Diagram |
| DA-756 | [DA-AI05-18] Deep Crawl Trigger Engine | Lộc | Sprint 6, 8 | AI track |
| DA-820 | DA-D17-05 — Write FR Anti-Hallucination Guard | Tuấn | Sprint 7 | Tài liệu |
| DA-836 | DA-D17-21 — Write FR Document Chunking | Tuấn | Sprint 7 | Tài liệu |
| DA-837 | DA-D17-22 — Write FR Embedding Generation | Tuấn | Sprint 7 | Tài liệu |
| DA-864 | DA-D18-21 — Write FR Text Broadcast to Zalo OA | Phước | Sprint 7 | Tài liệu |
| DA-865 | DA-D18-22 — Write FR Image Broadcast | Phước | Sprint 7 | Tài liệu |
| DA-866 | DA-D18-23 — Write FR Template Message | Phước | Sprint 7 | Tài liệu |
| DA-867 | DA-D18-24 — Write FR Schedule Broadcast | Phước | Sprint 7 | Tài liệu |

**⚠️ Cần xác nhận:** 7/9 task Cancel là task tài liệu (FR write-up) do Tuấn (3) và Phước (4) tự hủy. Không rõ lý do — có thể trùng lặp nội dung, gộp vào task khác, hoặc quyết định bỏ scope. **Nên hỏi trực tiếp 2 người này trước khi merge report cuối, vì đây đều là mục Functional Requirements bắt buộc trong SRS Report 3** (§3.11.5, §3.15.2, §3.15.3, §3.21.1-3.21.4) — nếu bị bỏ thật sẽ thiếu nội dung report.

Trước đó ghi nhận 18 task "[Delete]"-tagged đã bị **xóa hẳn** khỏi Jira (không phải Cancel) trong phiên làm việc trước — khác hoàn toàn với 9 task Cancel ở đây.

---

## 5. Sprint 7 — điểm nóng mới (215 task, tăng từ ~0 trước đó)

| Sprint | Done | In review | In Progress | To Do | Cancel | Tổng |
|---|---|---|---|---|---|---|
| Sprint 7 | 102 | 91 | 0 | 14 | 8 | **215** |

Sprint 7 vừa nhận thêm **186 task tài liệu To Do** (chuyển thủ công hôm nay, 2026-09-03) cộng với các task đã tồn tại từ trước — tổng hiện tại 215 task, trong đó:
- **102 Done** — phần lớn diagram + report content đã viết xong trước khi chuyển
- **91 In Review** — khối lượng review rất lớn, cần ưu tiên xử lý trước deadline M3 (Aug 23 theo Document Plan — **đã trễ so với kế hoạch gốc**, cần đối chiếu lại timeline thực tế)
- **14 To Do** — phần còn sót lại chưa chuyển hoặc phát sinh mới
- **8 Cancel** — xem mục 4

**Lưu ý quan trọng:** Document Plan gốc ghi deadline capstone là **Aug 28, 2026**. Ngày audit hiện tại là **2026-09-03** — đã qua deadline ghi trong plan 6 ngày. Cần xác nhận với team: deadline thực tế đã dời, hay Document Plan cần cập nhật lại mốc thời gian.

---

## 6. Sprint tổng quan — toàn bộ 666 task

| Sprint | Done | In review | In Progress | To Do | Cancel | Tổng |
|---|---|---|---|---|---|---|
| (Không gắn sprint) | 2 | — | — | 159 | — | 161 |
| Database, API & UI Design | 25 | — | — | — | — | 25 |
| DA Sprint 1 | 13 | — | — | — | — | 13 |
| DA Sprint 2 | 16 | — | — | — | — | 16 |
| DA Sprint 4 | 77 | 2 | 2 | — | — | 81 |
| DA Sprint 5 | 51 | 2 | 2 | 4 | — | 59 |
| DA Sprint 6 | 63 | 19 | 14 | 6 | 1 | 103 |
| **DA Sprint 7** | 102 | 91 | 0 | 14 | 8 | **215** |
| DA Sprint 8 | 3 | 15 | 16 | 22 | 1 | 57 |
| TLM Sprint 2-7 (6 sprint) | — | — | — | 42 | — | 42 |

**161 task vẫn không gắn sprint nào** — 159 To Do, 2 Done. Đây là backlog trôi nổi lớn nhất, gần như không đổi so với trước (164 → 161), chủ yếu là AI track chưa phân bổ + vài task lặt vặt.

---

## 7. Unassigned backlog — 39 task, breakdown theo Epic

| Epic | Unassigned | Nội dung |
|---|---|---|
| AI-07 | 8 | Virtual Brand Ambassador (InstantID) |
| AI-08 | 7 | Image Composition Pipeline |
| AI-11 | 6 | AI Research Documentation & Demo |
| E23 | 5 | AI Service Internal API Wiring |
| AI-10 | 5 | AI Service Integration & API Finalize |
| AI-06 | 4 | Image Generation Pipeline |
| E24 | 3 | Business Service AI Integration |
| AI-04 | 1 | LLM Content Generation (còn sót 1 task) |

**100% vẫn thuộc AI track** — đúng ranh giới đã thống nhất từ audit trước, giảm từ 61 xuống 39 (một phần backlog AI đã được Lộc/Ân/Tuấn nhận thêm khi mở rộng AI05 Knowledge Graph track).

---

## 8. Task rác / lỗi convention

| Key | Vấn đề | Trạng thái |
|---|---|---|
| DA-561 | Prefix `Da-AI05-07` sai case (từ audit trước) | Chưa xác nhận đã sửa |
| DA-407 | Prefix `DA-E010-07` thừa số 0 (từ audit trước) | Chưa xác nhận đã sửa |
| DA-565 | Summary trống, không epic (từ audit trước) | Chưa xác nhận đã sửa |
| DA-559 | Gắn sai epic E11 thay vì business-service phù hợp (từ audit trước) | Chưa xác nhận đã sửa |
| DA-820, 836, 837, 864-867 | 7 task FR tài liệu bị Cancel không rõ lý do | 🆕 Cần xác nhận với Tuấn/Phước — xem mục 4 |
| — | 18 key "[Delete]"-tagged đã bị xóa hẳn khỏi Jira (verify 404 qua API) | 🆕 Không còn tồn tại, không cần xử lý thêm |

> Không đủ dữ liệu trong phiên audit này để verify lại 4 vấn đề convention từ audit 08-03 — cần grep summary trực tiếp DA-561, DA-407, DA-565, DA-559 ở lần cập nhật kế tiếp.

---

## 9. Document Plan (SEP490 Reports) — 207 task tài liệu

Toàn bộ 207 task từ `Document_Plan.md` (Epic D01-D23) đã có mặt trên Jira dưới dạng `DA-D{epic}-{seq}` trong summary.

| Status | Số lượng | % |
|---|---|---|
| Done | ~28* | ~13.5% |
| In Review | ~91* | ~44.0% |
| In Progress | 0 | 0% |
| To Do | ~81* | ~39.1% |
| Cancel | 7 | 3.4% |

*Ước tính dựa trên phân bố Sprint 6 + Sprint 7 (nơi 100% task D01-D23 tập trung) trừ phần task code lẫn trong cùng sprint — số liệu chính xác cần lọc lại theo pattern `DA-D\d+-\d+` riêng, khuyến nghị chạy script riêng cho epic D-series ở audit kế tiếp.

**Diễn biến so với lúc kiểm tra buổi sáng cùng ngày (trước khi chuyển sprint):** 186/207 task To Do đã được chuyển thủ công từ chỗ chưa có sprint rõ ràng sang **Sprint 7**, theo yêu cầu tập trung sprint tới vào công tác viết tài liệu capstone. 21 task còn lại (đã ở trạng thái In Review/In Progress/Done trước đó) giữ nguyên sprint gốc.

---

## 10. Khối lượng công việc — đánh giá tổng thể

**Tiến độ chung:** 44.7% Done, 15.9% In Review, 2.4% In Progress → **~63% dự án đã có kết quả cụ thể hoặc đang xử lý**. Đây là bước tiến lớn so với 30.7% ở audit 08-03.

**Điểm tích cực:**
- Done tăng gần gấp 3 lần (104 → 298) trong 1 tháng — tốc độ hoàn thành rất tốt, đúng giai đoạn nước rút capstone
- Unassigned tiếp tục giảm (61 → 39), vẫn giữ đúng ranh giới AI track
- Lộc đạt tỉ lệ hoàn thành cao nhất dự án (76.1%) dù khối lượng tăng gấp đôi

**Điểm cần theo dõi:**
- **In Review tồn đọng lớn (106 task, 15.9%)** — cần đẩy nhanh review, đặc biệt 91 task ở Sprint 7 (chủ yếu tài liệu) đang chờ duyệt trước khi merge report
- **Deadline capstone Aug 28 đã qua** (audit hôm nay 2026-09-03) — cần xác nhận mốc thời gian thực tế của dự án, khả năng Document_Plan.md cần cập nhật lại timeline
- **7 task FR tài liệu bị Cancel không rõ lý do** — rủi ro thiếu nội dung bắt buộc trong Report 3 SRS nếu không được thay thế bằng nội dung khác
- **Phước vẫn là điểm nghẽn nặng nhất** — 134 task, Done rate thấp nhất (22.4%), tăng thêm 48 task kể từ lần trước
- **161 task chưa gắn sprint** — chủ yếu backlog AI, cần dọn dẹp định kỳ để tránh nhầm lẫn khi audit

---

## 11. Việc cần làm ngay (theo độ ưu tiên)

1. **Xác nhận lý do Cancel 7 task FR tài liệu** (DA-820, 836, 837, 864-867) với Tuấn và Phước — nếu bỏ nhầm cần khôi phục, nếu chủ động bỏ scope cần ghi chú vào Document_Plan.md
2. **Xác nhận mốc deadline thực tế của capstone** — Document_Plan.md ghi Aug 28 nhưng đã qua ngày này 6 ngày tính đến hôm nay
3. **Đẩy nhanh xử lý 91 task In Review ở Sprint 7** — đây là điểm nghẽn lớn nhất hiện tại trước khi có thể merge report
4. **Theo dõi sát Phước (134 task, Done 22.4%)** — vẫn là người tải nặng nhất và chậm nhất, cần hỗ trợ hoặc re-balance
5. **Verify lại 4 lỗi convention cũ** (DA-561, DA-407, DA-565, DA-559) — chưa xác nhận đã sửa từ audit 08-03
6. **Dọn dẹp 161 task chưa gắn sprint** — phần lớn AI backlog, nên gắn sprint để tránh nhầm "quên" trong các audit sau
7. **Để Lộc tiếp tục phân bổ 39 task AI track còn unassigned** (AI06-AI11, E23, E24)

---

## 12. So sánh nhanh 2026-07-11 → 2026-08-03 → 2026-09-03

| Chỉ số | 2026-07-11 | 2026-08-03 | 2026-09-03 |
|---|---|---|---|
| Tổng task | 406 | 433 | **666** |
| Done | 58 (14.3%) | 104 (24.0%) | **298 (44.7%)** |
| In Review | 46 (11.3%) | 28 (6.5%) | **106 (15.9%)** |
| In Progress | 8 (2.0%) | 1 (0.2%) | **16 (2.4%)** |
| Cancel | — | — | **9 (1.4%)** |
| Unassigned | 172 (42.4%) | 61 (14.1%) | **39 (5.9%)** |
| Trung tổng task | 77 | 145 | **186** |
| Phước tổng task | 34 | 86 | **134** |
| Lộc tổng task | — | 50 | **109** |

---

## 13. Ghi chú phương pháp

- Dữ liệu lấy trực tiếp qua Jira REST API v3 `/rest/api/3/search/jql` bằng Personal API Token (Basic Auth), pagination bằng `nextPageToken`. **API cũ `/rest/api/3/search` đã bị Atlassian gỡ bỏ** — phải dùng endpoint mới.
- 666/666 task (100% coverage), field lấy: `summary`, `status`, `assignee`, `customfield_10020` (Sprint).
- Task ID Document Plan đối chiếu bằng pattern `DA-D\d+-\d+` (không có ngoặc vuông bao quanh trong summary thật — khác giả định ban đầu là `[DA-Dxx-xx]`).
- 186 task tài liệu To Do được chuyển sang Sprint 7 (id 79) qua Jira Agile API `POST /rest/agile/1.0/sprint/{id}/issue`, chia batch 50 task/lần — verify 4/4 batch HTTP 204, spot-check 4 task xác nhận sprint field đã cập nhật.
- 18 key "[Delete]"-tagged xử lý ở phiên trước đã bị xác nhận **xóa hẳn khỏi Jira** (HTTP 404 khi truy vấn trực tiếp từng key) — không phải Cancel như dữ liệu MCP báo cáo trước đó.
- Không tính Subtask và Bug trong audit này.
- Số liệu Document Plan ở mục 9 là ước tính do chưa tách riêng epic D-series trong lần chạy này — cần script riêng ở lần audit tiếp theo để chính xác 100%.
- So sánh với audit 2026-07-11 và 2026-08-03 lưu tại cùng thư mục `docs/plan/audit/`.
