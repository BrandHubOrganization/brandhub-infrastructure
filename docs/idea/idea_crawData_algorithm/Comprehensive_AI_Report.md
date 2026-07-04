# BÁO CÁO TOÀN DIỆN: ĐÁNH GIÁ & ĐIỀU CHỈNH KẾ HOẠCH PHÁT TRIỂN AI (BRANDHUB)

Báo cáo này tổng hợp ý tưởng kỹ thuật đột phá mới về **Trend Detection & Content Generation** từ thư mục [idea_crawData_algorithm](file:///d:/FPT/FA26/brandhub-infrastructure/docs/idea/idea_crawData_algorithm), đối chiếu với kế hoạch dự án hiện có để chỉ ra các khoảng cách công nghệ và đề xuất các điều chỉnh task chi tiết kèm theo lộ trình thời gian hoàn thành cụ thể.

---

## I. Tổng Hợp Thông Tin Về Ý Tưởng Crawl Dữ Liệu & Phát Hiện Xu Hướng

Ý tưởng cốt lõi là xây dựng một hệ thống phát hiện xu hướng (trend) thông minh, đa nguồn và tối ưu hóa chi phí bằng cách kết hợp chuyển đổi giọng nói local (Speech-to-Text) và lưu trữ tri thức lai **GraphRAG**.

### 1. Luồng dữ liệu kỹ thuật chi tiết (Data Pipeline)
* **Bước 1: Crawl đa nguồn (Multi-source Crawler)**
  * Hệ thống tự động thu thập video/audio/text từ các nền tảng video ngắn (TikTok, Reels, Shorts) dựa trên hashtag đang thịnh hành hoặc danh sách KOLs định hướng thị trường.
* **Bước 2: Chuyển giọng nói thành văn bản local (Speech-to-Text - STT)**
  * Tách luồng âm thanh từ video và đẩy qua mô hình **Whisper local** chạy bằng CUDA trên GPU để lấy transcript văn bản kèm mốc thời gian (timestamp).
* **Bước 3: Chuẩn hóa văn bản (Normalization)**
  * Loại bỏ emoji rác, sửa lỗi viết tắt/từ lóng tiếng Việt, tách câu để chuẩn bị cho giai đoạn nhúng vector.
* **Bước 4: Nhúng vector & Trích xuất thực thể (Embedding & Entity Resolution)**
  * Tạo vector embedding cho các đoạn text để nạp vào **Vector DB (ChromaDB)**.
  * Đồng thời dùng LLM/Rule-based NER trích xuất các thực thể (`KOL`, `Món ăn`, `Địa điểm`, `Nền tảng`) để dựng đồ thị tri thức trong **Graph DB (Neo4j)**.
* **Bước 5: Chấm điểm & Cắt tỉa (BM25 Scoring & Pruning)**
  * Sử dụng thuật toán **BM25** để tính toán mức độ nổi bật của từ khóa, cắt bỏ những nút đồ thị có độ tương quan thấp trước khi đưa vào LLM để tối ưu độ trễ và giới hạn token (token limit).
* **Bước 6: Tạo Prompt tối ưu kịch bản giữ chân người dùng (Hook 3s)**
  * Kết hợp ngữ cảnh từ ChromaDB và cấu trúc đồ thị liên đới từ Neo4j để dựng prompt. Prompt được cấu trúc đặc biệt(CẤU TRÚC GÌ?) để LLM sinh câu mở đầu giật gân (Retention Hook) nhằm bắt kịp thuật toán phân phối nội dung của các mạng xã hội.

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

## III. Gợi Ý Thay Đổi Và Bổ Sung Các Task Trong Plan (Chi Tiết)

Để hiện thực hóa ý tưởng mới, chúng ta cần cập nhật và bổ sung các task cụ thể cho **AI Iteration 2** như sau:

### 1. Bổ sung các Task mới (EPIC AI-03)
* **`DA-AI03-01.1` [NEW] - Triển khai Speech-to-Text local:** Cài đặt thư viện `faster-whisper` + PyTorch CUDA, cấu hình chạy trên RTX 4050 và viết API `/ai/stt/transcribe` nhận video/audio.
* **`DA-AI03-01` [MODIFY] - Cải tiến API Ingest:** Cho phép tải lên video/audio, tự động gọi API STT để chuyển thành văn bản trước khi đưa vào bộ cắt câu.
* **`DA-AI03-03.1` [NEW] - Triển khai cơ sở dữ liệu Neo4j:** Cấu hình container Neo4j trong `docker-compose.yml`, viết module kết nối và định nghĩa schema đồ thị tri thức trend.
* **`DA-AI03-03.2` [NEW] - Viết module NER & Cấu trúc đồ thị:** Nhận text đã transcribe, sử dụng LLM/Rule-based để trích xuất thực thể (`KOL`, `Món ăn`, `Địa điểm`, `Nền tảng`), tạo liên kết và nạp vào Neo4j.
* **`DA-AI03-04.1` [NEW] - Graph Traversal & BM25 Pruning Service:** Viết thuật toán duyệt đồ thị trên Neo4j (1-hop, 2-hop) từ các thực thể tìm được bằng ChromaDB; hiện thực hóa thuật toán BM25 tại `app/services/scoring/bm25.py` để cắt tỉa các node liên kết yếu.
* **`DA-AI03-05` [MODIFY] - Xây dựng GraphRAG Context Builder:** Sửa logic gom ngữ cảnh để kết hợp dữ liệu vector ngữ nghĩa (ChromaDB) và quan hệ cấu trúc (Neo4j đã được prune).
* **`DA-AI03-09` [NEW] - Bổ sung Job chuẩn hóa thực thể (Entity Resolution):** Xây dựng task chạy nền định kỳ tự động gộp các nút đồ thị đồng nghĩa (ví dụ: "Trấn Thành" và "MC Trấn Thành").

### 2. Cập nhật các Task hiện có (EPIC AI-04)
* **`DA-AI04-01` [MODIFY] - Prompt Builder tối ưu Hook:** Thiết kế kịch bản prompt chi tiết hướng dẫn LLM tạo câu tiêu đề giật gân (Hook 3s) chuyên biệt cho từng nền tảng (TikTok vs Facebook Reels).

---

## IV. Dự Kiến Thời Gian Hoàn Thành Các Iteration Của AI (Timeline)

Timeline được tính toán tối ưu dựa trên việc triển khai song song giữa các thành viên AI (Tuấn, Ân, Lộc) song hành cùng các Sprint phát triển tổng thể dự án:

```
[AI Iter 1] Weeks 9-12 (Sprints 5-6)  : Nghiên cứu & Dựng khung hạ tầng cơ bản
[AI Iter 2] Weeks 13-16 (Sprints 7-8) : Xây dựng RAG + GraphRAG + Whisper local + Trend Crawler
[AI Iter 3] Weeks 17-20 (Sprints 9-10): Sinh ảnh + Virtual Ambassador (InstantID) + Tách nền
[AI Iter 4] Weeks 21-24 (Sprints 11-12): Sinh video (Google Veo) + Tích hợp & Đóng gói capstone
```

### 1. AI Iteration 1: Research & Evaluation (Weeks 9–12 / Sprints 5–6)
* **Thời gian:** 4 tuần.
* **Mục tiêu:** Nghiên cứu so sánh công nghệ (InstantID, Llama 3 vs Claude, Google Veo) và dựng khung dự án `brandhub-ai-service`.
* **Kết quả:** Hoàn thành khung FastAPI, thiết lập API client (Groq, Anthropic, Stability), xác định mô hình InstantID.

### 2. AI Iteration 2: RAG, LLM & Trends (Weeks 13–16 / Sprints 7–8) — *Trọng tâm cập nhật*
* **Thời gian:** 4 tuần.
* **Mục tiêu:** Xây dựng toàn bộ pipeline GraphRAG (ChromaDB + Neo4j), tích hợp Whisper local xử lý audio/video crawl, thiết lập công cụ crawl trends và chấm điểm BM25.
* **Kết quả:** API `/ai/stt`, API `/ai/rag` nâng cao (lai đồ thị), crawler Google Trends/TikTok cached qua Redis, RAG accuracy test đạt 100% không hallucination.

### 3. AI Iteration 3: Image, Ambassador & Composition (Weeks 17–20 / Sprints 9–10)
* **Thời gian:** 4 tuần.
* **Mục tiêu:** Hiện thực hóa pipeline sinh ảnh quảng cáo, nhân vật ảo nhất quán khuôn mặt (InstantID) và ghép ảnh sản phẩm/người mẫu vào phông nền (Pillow + rembg local).
* **Kết quả:** API `/ai/image/generate`, API `/ai/ambassador/generate` (cosine similarity $\ge 0.85$), API `/ai/compose` tách nền hoàn chỉnh.

### 4. AI Iteration 4: Video, Integration & Documentation (Weeks 21–24 / Sprints 11–12)
* **Thời gian:** 4 tuần.
* **Mục tiêu:** Tích hợp Google Veo API để sinh video marketing ngắn, chạy thử nghiệm tích hợp toàn diện với `business-service` và viết toàn bộ báo cáo nghiên cứu phục vụ Capstone.
* **Kết quả:** API `/ai/video/generate` (async polling), Swagger hoàn chỉnh cho 7 nhóm API, ghi hình demo sản phẩm dưới 10 phút, báo cáo chi phí vận hành.
