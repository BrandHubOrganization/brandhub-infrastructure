# BÁO CÁO TOÀN DIỆN: ĐÁNH GIÁ & ĐIỀU CHỈNH KẾ HOẠCH PHÁT TRIỂN AI (BRANDHUB)

Báo cáo này tổng hợp ý tưởng kỹ thuật đột phá mới về **Trend Detection & Content Generation** từ thư mục [idea_crawData_algorithm](file:///d:/FPT/FA26/brandhub-infrastructure/docs/idea/idea_crawData_algorithm), đối chiếu với kế hoạch dự án hiện có để chỉ ra các khoảng cách công nghệ và đề xuất các điều chỉnh task chi tiết kèm theo lộ trình thời gian hoàn thành cụ thể.

---

## I. Tổng Hợp Thông Tin Về Ý Tưởng Crawl Dữ Liệu & Phát Hiện Xu Hướng

Ý tưởng cốt lõi là xây dựng một hệ thống phát hiện xu hướng (trend) thông minh, đa nguồn và tối ưu hóa chi phí bằng cách kết hợp chuyển đổi giọng nói local (Speech-to-Text) và lưu trữ tri thức lai **GraphRAG**.

### 1. Luồng dữ liệu kỹ thuật chi tiết (Data Pipeline)
* **Bước 1: Crawl đa nguồn (Multi-source Crawler)**
  * Hệ thống tự động thu thập video/audio/text từ các nền tảng video ngắn (TikTok, Reels, Shorts) dựa trên hashtag đang thịnh hành hoặc danh sách KOLs định hướng thị trường.
* **Bước 2: Chuyển giọng nói thành văn bản local (Speech-to-Text - STT)**
  * Tách luồng âm thanh từ video và đẩy qua mô hình **Whisper local** chạy bằng CUDA trên GPU **RTX 4050** để lấy transcript văn bản kèm mốc thời gian (timestamp).
* **Bước 3: Chuẩn hóa văn bản (Normalization)**
  * Loại bỏ emoji rác, sửa lỗi viết tắt/từ lóng tiếng Việt, tách câu để chuẩn bị cho giai đoạn nhúng vector.
* **Bước 4: Nhúng vector & Trích xuất thực thể (Embedding & Entity Resolution)**
  * Tạo vector embedding cho các đoạn text để nạp vào **Vector DB (ChromaDB)**.
  * Đồng thời dùng LLM/Rule-based NER trích xuất các thực thể (`KOL`, `Món ăn`, `Địa điểm`, `Nền tảng`) để dựng đồ thị tri thức trong **Graph DB (Neo4j)**.
* **Bước 5: Chấm điểm & Cắt tỉa (BM25 Scoring & Pruning)**
  * Sử dụng thuật toán **BM25** để tính toán mức độ nổi bật của từ khóa, cắt bỏ những nút đồ thị có độ tương quan thấp trước khi đưa vào LLM để tối ưu độ trễ và giới hạn token (token limit).
* **Bước 6: Tạo Prompt tối ưu kịch bản giữ chân người dùng (Hook 3s)**
  * Kết hợp ngữ cảnh từ ChromaDB và cấu trúc đồ thị liên đới từ Neo4j để dựng prompt. Prompt được cấu trúc đặc biệt để LLM sinh câu mở đầu giật gân (Retention Hook) nhằm bắt kịp thuật toán phân phối nội dung của các mạng xã hội.

---

## II. Đánh Giá Khoảng Cách: Kế Hoạch Dự Án Hiện Tại vs Ý Tưởng Đột Phá Mới

Qua đối chiếu giữa kế hoạch dự án hiện tại (tệp [AI_Iteration_2_RAG_LLM_Trends.md](file:///d:/FPT/FA26/brandhub-infrastructure/docs/plan/iterations/AI_Iteration_2_RAG_LLM_Trends.md)) và ý tưởng đột phá mới, chúng ta có các khoảng cách công nghệ quan trọng sau:

1. **Về xử lý Ingestion (Dữ liệu đầu vào):**
   * *Kế hoạch cũ:* Chỉ thiết kế upload các định dạng văn bản tĩnh như PDF, DOCX, TXT, URL (`DA-AI03-01`).
   * *Ý tưởng mới:* Yêu cầu bắt buộc phải ingest video/audio và chạy qua Whisper local. Kế hoạch hiện tại hoàn toàn thiếu tác vụ cài đặt thư viện Whisper, CUDA Toolkit cho GPU RTX 4050.
2. **Về kiến trúc lưu trữ và truy vấn tri thức (Database & Retrieval):**
   * *Kế hoạch cũ:* Chỉ sử dụng ChromaDB làm cơ sở dữ liệu Vector đơn thuần (`DA-AI03-03`).
   * *Ý tưởng mới:* Sử dụng cơ chế lưu trữ lai (Hybrid Storage) kết hợp ChromaDB và **Neo4j** (Graph DB). Kế hoạch hiện tại thiếu hoàn toàn hạ tầng đồ thị Neo4j, logic liên kết thực thể (Entity resolution) và thuật toán duyệt đồ thị (Graph traversal).
3. **Về tối ưu hóa Token và Chi phí LLM:**
   * *Kế hoạch cũ:* Đẩy trực tiếp Top-K chunks lấy từ ChromaDB vào prompt.
   * *Ý tưởng mới:* Sử dụng thuật toán **BM25** để chấm điểm mức độ viral/trend và tỉa bớt dữ liệu nhiễu (pruning), tránh lãng phí token LLM và giảm độ trễ phản hồi. Kế hoạch cũ chưa hề định nghĩa thuật toán này.
4. **Về chất lượng nội dung sinh ra (Content Quality):**
   * *Kế hoạch cũ:* Sinh caption và hashtag dựa trên thông tin thô và tone giọng chung (`DA-AI04-01`).
   * *Ý tưởng mới:* Tích hợp layer chấm điểm "Hook strength" cho cấu trúc 3 giây đầu để giữ chân người xem video ngắn.

---

## III. Gợi Ý Thay Đổi Về Các Task Trong Plan (Chi Tiết Các Epic)

Dưới sự ảnh hưởng của các công nghệ mới (Whisper local, Neo4j, BM25, Entity Resolution), 3 Epic cốt lõi của AI Iteration 2 cần được thiết kế lại chi tiết như sau:

### 1. EPIC AI-03: Triển Khai GraphRAG & Speech-to-Text Pipeline (Mở rộng & Tái cấu trúc)
Epic này chuyển từ RAG truyền thống sang xây dựng Pipeline dữ liệu lai có khả năng xử lý âm thanh/hình ảnh và đồ thị liên kết.

* **`DA-AI03-01` [MODIFY] - API Ingestion đa phương tiện:**
  * *Mô tả:* Sửa đổi để endpoint `/ai/rag/upload` không chỉ nhận tài liệu text (PDF/TXT) mà còn chấp nhận file video/audio (`.mp4`, `.mp3`, `.m4a`).
  * *Người thực hiện:* Lộc (Frontend/API) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-01.1` [NEW] - Triển khai Whisper local trên GPU:**
  * *Mô tả:* Tích hợp thư viện `faster-whisper` và cấu hình PyTorch hỗ trợ CUDA. Chạy thử nghiệm trên card đồ họa local RTX 4050 để đảm bảo tốc độ transcribe $\ge 4x$ real-time. Viết service nội bộ `app/services/stt/whisper.py`.
  * *Người thực hiện:* Tuấn (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-03.1` [NEW] - Triển khai Neo4j Infra:**
  * *Mô tả:* Thêm dịch vụ Neo4j vào `docker-compose.yml` ở môi trường dev/staging. Viết module kết nối database và các class quản lý session/driver tại `app/core/neo4j.py`.
  * *Người thực hiện:* Tuấn (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-03.2` [NEW] - Xây dựng NER & Graph Ingestion Pipeline:**
  * *Mô tả:* Sử dụng mô hình ngôn ngữ nhỏ (hoặc regex/rule-based kết hợp LLM) để trích xuất các thực thể (`KOL`, `Món ăn`, `Thương hiệu`, `Địa điểm`) từ văn bản đã transcribe. Định nghĩa câu lệnh Cypher để lưu các thực thể này cùng quan hệ (`CHECK_IN`, `PROMOTED_BY`, `VIRAL_ON`) vào Neo4j.
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-04` [MODIFY] - Tìm kiếm ngữ nghĩa ChromaDB:**
  * *Mô tả:* Nhận query từ user -> Embed thành vector -> Truy vấn ra top thực thể tương đồng nhất làm "cổng vào" (Entry point) cho Graph DB.
  * *Người thực hiện:* Tuấn (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-04.1` [NEW] - Graph Traversal Service:**
  * *Mô tả:* Nhận các entry-point từ ChromaDB, chạy Cypher query để duyệt đồ thị trong Neo4j (độ sâu 1 đến 2 bước nhảy) nhằm thu thập tất cả các nút thực thể liên quan.
  * *Người thực hiện:* Tuấn (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-04.2` [NEW] - Thuật toán BM25 Pruning:**
  * *Mô tả:* Viết service `app/services/scoring/bm25.py` tự chấm điểm tương quan của các thực thể đồ thị vừa lấy ra đối với query gốc của người dùng. Cắt tỉa các thực thể có điểm số dưới ngưỡng threshold nhằm tối ưu dung lượng context.
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-05` [MODIFY] - GraphRAG Context Builder:**
  * *Mô tả:* Định dạng dữ liệu thô (từ ChromaDB chunks) kết hợp với cấu trúc mối quan hệ (từ Neo4j đã prune bằng BM25) thành một chuỗi context có cấu trúc phân cấp chặt chẽ để nạp vào prompt.
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🔴 Critical.
* **`DA-AI03-09` [NEW] - Cronjob Entity Resolution:**
  * *Mô tả:* Thiết lập APScheduler chạy định kỳ mỗi 12 tiếng. Sử dụng embedding similarity để tự động tìm kiếm và gộp các nút thực thể bị trùng lặp ngữ nghĩa (ví dụ: gộp node `"Trấn Thành"` và `"MC Trấn Thành"`).
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🟡 High.

### 2. EPIC AI-04: LLM Content Generation & Hook Optimization (Mở rộng prompt)
* **`DA-AI04-01` [MODIFY] - Cấu trúc Prompt Builder chuyên sâu:**
  * *Mô tả:* Thêm layer chấm điểm "Hook strength". Thiết lập các template prompt yêu cầu LLM viết tiêu đề và kịch bản mở đầu giật gân trong 3 giây đầu tiên (Hook 3s) tối ưu cho định dạng video ngắn trên TikTok/Facebook Reels.
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🔴 Critical.

### 3. EPIC AI-05: Trend Crawler & Scoring Service (Giữ nguyên khung, làm rõ đầu ra)
* **`DA-AI05-03` [MODIFY] - Đơn giản hóa dữ liệu đầu ra để lưu trữ đồ thị:**
  * *Mô tả:* Định dạng dữ liệu trend crawl được từ pytrends/TikTok thành danh sách Node/Edge để nạp trực tiếp vào Neo4j (đối chiếu với `DA-AI03-03.2`).
  * *Người thực hiện:* Ân (AI) | *Độ ưu tiên:* 🟡 High.

---

## IV. Đánh Giá Tác Động Về Thời Gian & Lộ Trình Triển Khai Điều Chỉnh

Triển khai một chuỗi công nghệ phức tạp (Whisper + Neo4j + GraphRAG + BM25) sẽ làm **tăng khối lượng công việc ước tính khoảng 3,5 tuần** so với kế hoạch RAG truyền thống ban đầu. 

Dưới đây là hai phương án điều chỉnh thời gian và cách phân bổ tài nguyên để đảm bảo dự án không bị vỡ tiến độ:

### 1. Phân Tích Khối Lượng Thời Gian Tăng Thêm
* **Cài đặt & Cấu hình GPU local cho Whisper STT:** 1 tuần (setup driver CUDA, PyTorch, kiểm thử rò rỉ bộ nhớ VRAM trên card RTX 4050).
* **Thiết lập Neo4j & Thiết kế Đồ thị Tri thức:** 1,5 tuần (triển khai Docker, viết class connect, định nghĩa schema cho node/edge, viết Cypher query).
* **Code thuật toán BM25 Pruning & Service duyệt đồ thị:** 0,5 tuần.
* **Xây dựng Background Job Entity Resolution:** 0.5 tuần.
* **Tổng thời gian bổ sung:** ~3,5 tuần phát triển.

---

### 2. Đề Xuất Điều Chỉnh Lộ Trình (Timeline) & Cách Phân Bổ Tài Nguyên

#### PHƯƠNG ÁN A: Gối đầu song song (Gợi ý - Giữ nguyên deadline Tuần 24)
Thay vì kéo dài toàn bộ dự án, chúng ta tận dụng mô hình phát triển gối đầu (overlapping) giữa các thành viên nhờ việc chia nhóm làm việc hiệu quả:

* **AI Iteration 2 (Kéo dài thành 6 tuần - Sprints 7-9 | Weeks 13-18):**
  * *Nội dung:* Tập trung toàn lực hoàn thành luồng GraphRAG phức tạp + STT local + Crawler.
* **AI Iteration 3 (Giữ nguyên 4 tuần nhưng bắt đầu gối đầu - Sprints 9-10 | Weeks 17-20):**
  * *Cách thực hiện:* Trong 2 tuần cuối của Iteration 2 (Sprint 9 - Weeks 17-18), khi Tuấn và Ân đang hoàn thiện phần tích hợp GraphRAG & tối ưu hóa BM25, **Lộc (Frontend/API) sẽ tách ra bắt đầu trước các task của Iteration 3** (Cấu hình Stability AI SDXL và viết service tách nền `rembg` local).
* **AI Iteration 4 (Giữ nguyên 4 tuần - Sprints 11-12 | Weeks 21-24):**
  * *Nội dung:* Tích hợp Google Veo, đóng gói API Swagger và hoàn thiện báo cáo Capstone.

```
Tuần:  | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 |
-----------------------------------------------------------------------------------------
Iter 1:|====== Research ======| (4 tuần)
Iter 2:|                              |======== GraphRAG & STT ========| (6 tuần)
Iter 3:|                                             |=== Image & Ambassador ===| (4 tuần)
Iter 4:|                                                                |=== Video ===| (4 tuần)
```

* **Ưu điểm:** Giữ nguyên được cột mốc hoàn thành cuối cùng ở Tuần 24 để kịp tiến độ bảo vệ capstone. Tối ưu hóa được năng lực của Lộc (người có thế mạnh về API/Frontend) khi gối đầu sang Iteration 3 trước.
* **Nhược điểm:** Đòi hỏi sự phối hợp và giao tiếp chặt chẽ giữa các thành viên trong Sprint 9 để tránh xung đột mã nguồn.

#### PHƯƠNG ÁN B: Dịch chuyển tịnh tiến (Kéo dài toàn bộ dự án thêm 2 tuần)
Nếu thời gian bảo vệ không quá khắt khe, chúng ta có thể tịnh tiến toàn bộ roadmap:

* **AI Iteration 2:** Weeks 13–18 (Sprints 7–9) — 6 tuần.
* **AI Iteration 3:** Weeks 19–22 (Sprints 10–11) — 4 tuần.
* **AI Iteration 4:** Weeks 23–26 (Sprints 12–13) — 4 tuần.
* **Tổng thời gian hoàn thành:** Tuần 26 thay vì Tuần 24.
* **Ưu điểm:** Giảm áp lực phát triển song song cho đội ngũ, code được kiểm thử kỹ lưỡng hơn trước khi chuyển tiếp.
* **Nhược điểm:** Trễ tiến độ tổng thể của Capstone thêm 2 tuần.
