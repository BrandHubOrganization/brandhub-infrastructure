# TÀI LIỆU CHUẨN BỊ HỌP TEAM AI: TỔNG HỢP TIẾN ĐỘ & THỐNG NHẤT FLOW CÔNG NGHỆ

Tài liệu này tổng hợp toàn bộ nội dung quan trọng để chuẩn bị cho cuộc họp sắp tới với team AI, bao gồm: review kết quả Iteration 1, lộ trình phát triển sắp tới (khi đã xong Epic 1 & 2), và luồng xử lý kỹ thuật (Data Pipeline) chi tiết của tính năng Crawl Trend & AI Generate (GraphRAG).

---

## I. Báo Cáo & Đánh Giá AI Iteration 1 (Research & Evaluation)
*Thời gian chạy: Song song với Sprint 5–6 (Weeks 9–12)*

### 1. Mục tiêu ban đầu
Đánh giá công nghệ cho 3 nhánh cốt lõi (Virtual Ambassador, AI Video, Image Composition) và thiết lập nền tảng hạ tầng kỹ thuật ban đầu cho dịch vụ `brandhub-ai-service` (FastAPI).

### 2. Các kết quả đã đạt được (Epic 1 & 2 đã hoàn thành)
Team AI đã hoàn thành việc nghiên cứu mô hình và dựng khung hạ tầng cơ bản:
* **EPIC AI-01 — AI Model Research & Evaluation:**
  * **Virtual Ambassador:** Đã tiến hành nghiên cứu, so sánh giữa **InstantID vs IP-Adapter vs ControlNet** để tạo ra đại sứ thương hiệu ảo nhất quán về khuôn mặt. Đã chạy thử nghiệm trên 5 ảnh mẫu và lập bảng so sánh chất lượng, thời gian chạy và chi phí.
  * **AI Video:** Đã nghiên cứu Google Veo API (tính năng, giá cả, giới hạn request, tham số chuyển động) và kiểm thử hơn 20 prompt sinh video khác nhau.
  * **Image Composition (Ghép ảnh):** Nghiên cứu các kỹ thuật ghép ảnh sản phẩm vào mẫu (ControlNet Inpainting, DALL-E Edit, tách nền qua `rembg` và ghép layer qua Pillow) và thử nghiệm trên 10 cặp ảnh.
  * **LLM Engine:** So sánh chất lượng tiếng Việt, tốc độ phản hồi và chi phí giữa Llama 3 (chạy qua Groq API) và Claude API.
* **EPIC AI-02 — AI Service Infrastructure Setup:**
  * Khởi tạo thành công dự án `brandhub-ai-service` sử dụng **FastAPI + Python 3.11** với cấu trúc thư mục chuẩn (`app/api`, `app/services`, `app/models`, `app/utils`).
  * Đóng gói dịch vụ AI bằng **Dockerfile** và cấu hình chạy chung trong hệ thống qua `docker-compose.yml`.
  * Cấu hình các Client API từ biến môi trường (`.env`): ChromaDB, Groq API, Anthropic Claude, Stability AI.
  * Tích hợp thành công client AWS S3 sử dụng thư viện `boto3` và viết các hàm helper để upload/delete file và sinh presigned URL.
  * Xây dựng Middleware xác thực API Key nội bộ (`X-Internal-Key`) và định nghĩa cấu trúc Schema Pydantic.

---

## II. Lộ Trình Tiến Độ & Kế Hoạch Chi Tiết Theo Từng Epic (Iteration 2 ➔ 4)

### 1. Thông tin tổng hợp & Thời gian dự kiến các Iteration
Dưới đây là bảng tổng hợp timeline, thời lượng phát triển và trạng thái của từng Iteration trong dự án AI Track để team dễ dàng nắm bắt bức tranh toàn cảnh:

| Iteration | Nội dung trọng tâm | Thời gian dự kiến | Sprint song song | Trạng thái |
| :--- | :--- | :--- | :--- | :--- |
| **AI Iteration 1** | **Research & Evaluation** (Nghiên cứu công nghệ & dựng nền móng AI Service) | Tuần 9 – 12 (4 tuần) | Sprints 5 – 6 | **Hoàn thành** |
| **AI Iteration 2** | **GraphRAG, LLM & Trends** (Dựng Whisper STT, cào trend, GraphRAG, sinh content) | Tuần 13 – 18 (6 tuần)* | Sprints 7 – 9 | **Chuẩn bị chạy** (Đang đề xuất tăng 2 tuần do tăng quy mô) |
| **AI Iteration 3** | **Image, Ambassador & Composition** (Stability AI SDXL, InstantID, tách & ghép nền) | Tuần 17 – 20 (4 tuần) | Sprints 9 – 10 | **Sắp tới** (Chạy gối đầu song song gối đầu) |
| **AI Iteration 4** | **Video, Integration & Docs** (Google Veo, đóng gói API, test tích hợp, làm báo cáo) | Tuần 21 – 24 (4 tuần) | Sprints 11 – 12 | **Sắp tới** |

> [!IMPORTANT]
> \* **Thời gian dự kiến của Iteration 2** đã được đề xuất kéo dài từ **4 tuần lên 6 tuần** (tuần 13 đến tuần 18) để có đủ thời gian tích hợp cấu hình GPU local RTX 4050 cho Whisper và hạ tầng đồ thị Neo4j. Để bù đắp thời gian này, Iteration 3 sẽ chạy gối đầu bắt đầu từ tuần 17 (khi một số thành viên làm xong sớm chuyển sang làm trước tính năng tách/ghép nền).

---

### 2. Chi tiết các nhiệm vụ cụ thể theo từng Epic

#### 🔴 EPIC AI-03 — GraphRAG & Speech-to-Text Pipeline (Mở rộng & Tái cấu trúc)
* **`DA-AI03-01` [MODIFY]:** Nâng cấp API Ingest `/ai/rag/upload` để chấp nhận cả video/audio (`.mp4`, `.mp3`, `.m4a`) bên cạnh các file text tĩnh. *(Assignee: Lộc)*
* **`DA-AI03-01.1` [NEW-Bỏ]:** Cấu hình thư viện `faster-whisper` và CUDA trên GPU local RTX 4050 phục vụ chuyển âm thanh thành văn bản. *(Assignee: Tuấn)*
* **`DA-AI03-02` [KEEP]:** Dựng bộ chia nhỏ văn bản (Chunking) bằng LangChain RecursiveCharacterTextSplitter (chunk_size=500, overlap=50). *(Assignee: Ân)*
* **`DA-AI03-03` [KEEP]:** Viết module sinh vector embedding từ text chunk và nạp vào ChromaDB kèm metadata (documentId, clientId, chunkIndex). *(Assignee: Tuấn)*
* **`DA-AI03-03.1` [NEW]:** Cấu hình cơ sở dữ liệu Neo4j chạy trên container Docker, viết class quản lý connection pool (`app/core/neo4j.py`). *(Assignee: Tuấn)*
* **`DA-AI03-03.2` [NEW]:** Xây dựng module trích xuất thực thể (NER) và nạp mạng lưới quan hệ (`KOL`, `Món ăn`, `Địa danh`) vào Neo4j bằng Cypher query. *(Assignee: Ân)*
* **`DA-AI03-04` [MODIFY]:** Tìm kiếm ngữ nghĩa ChromaDB để tìm các thực thể gần nhất làm điểm truy cập (Entry Points) cho đồ thị. *(Assignee: Tuấn)*
* **`DA-AI03-04.1` [NEW]:** Viết Graph Traversal Service để duyệt đồ thị trong Neo4j (độ sâu 1–2 bước nhảy) dựa trên Entry Points để thu thập mối liên hệ. *(Assignee: Tuấn)*
* **`DA-AI03-04.2` [NEW]:** Phát triển thuật toán chấm điểm và cắt tỉa (BM25 Pruning) loại bỏ node có độ tương quan thấp đối với query gốc. *(Assignee: Ân)*
* **`DA-AI03-05` [MODIFY]:** Xây dựng GraphRAG Context Builder định dạng dữ liệu ChromaDB + cấu trúc liên kết Neo4j thành chuỗi context gửi LLM. *(Assignee: Ân)*
* **`DA-AI03-06` [KEEP]:** API xóa dữ liệu tri thức (dọn sạch ChromaDB chunks + node tương ứng trong Neo4j + file S3). *(Assignee: Lộc)*
* **`DA-AI03-07` [KEEP]:** Viết test case đánh giá độ chính xác của GraphRAG, tránh hiện tượng LLM bị ảo giác (hallucination). *(Assignee: Ân)*
* **`DA-AI03-08` [KEEP]:** Viết tài liệu kỹ thuật về RAG pipeline, cấu hình tham số và cách đánh giá chất lượng context. *(Assignee: Ân)*
* **`DA-AI03-09` [NEW]:** Tạo Background Cronjob chạy định kỳ (12 tiếng) thực hiện Entity Resolution (gộp các thực thể trùng lặp ngữ nghĩa). *(Assignee: Ân)*

#### 🔴 EPIC AI-04 — LLM Content Generation & Hook Optimization
* **`DA-AI04-01` [MODIFY]:** Xây dựng Prompt Template System tích hợp thêm layer chấm điểm "Hook strength" cho cấu trúc giữ chân người dùng 3s đầu. *(Assignee: Ân)*
* **`DA-AI04-02` [KEEP]:** Tích hợp Llama 3 qua Groq API, thiết lập hệ thống system prompt để LLM chỉ sử dụng context thực tế được cung cấp. *(Assignee: Tuấn)*
* **`DA-AI04-03` [KEEP]:** Tích hợp Claude API (Anthropic) làm fallback khi Groq bị quá tải request (rate limit) hoặc chất lượng bị sụt giảm. *(Assignee: Tuấn)*
* **`DA-AI04-04` [KEEP]:** Tự động tối ưu hóa độ dài bài viết theo từng nền tảng (Facebook tối đa 63k, Threads 500, TikTok 4k ký tự). *(Assignee: Lộc)*
* **`DA-AI04-05` [KEEP]:** Viết endpoint sinh tự động danh sách hashtag liên quan đến nội dung bài viết. *(Assignee: Lộc)*
* **`DA-AI04-06` [KEEP]:** Phát triển tính năng cải thiện nội dung dựa trên feedback (User gửi lại caption cũ + feedback của client để tạo phiên bản mới). *(Assignee: Ân)*
* **`DA-AI04-07` [KEEP]:** Viết kịch bản kiểm thử chống ảo giác cho 20 bài viết mẫu khác nhau. *(Assignee: All)*
* **`DA-AI04-08` [KEEP]:** Tài liệu hướng dẫn Prompt Engineering (cấu trúc template, giọng điệu tone guide, prompt hệ thống). *(Assignee: Ân)*

#### 🟡 EPIC AI-05 — Trend Crawler & Scoring Service
* **`DA-AI05-01` [KEEP]:** Viết module sử dụng `pytrends` để cào tự động các từ khóa tìm kiếm hot nhất tại Việt Nam từ Google Trends. *(Assignee: Ân)*
* **`DA-AI05-02` [KEEP]:** Viết bot cào hashtag xu hướng của TikTok bằng cách cào web hoặc sử dụng API không chính thức. *(Assignee: Ân)*
* **`DA-AI05-03` [MODIFY]:** Chuẩn hóa dữ liệu trend cào về thành định dạng chuẩn Node/Edge để lưu trực tiếp vào cơ sở dữ liệu Neo4j. *(Assignee: Ân)*
* **`DA-AI05-04` [KEEP]:** Dựng cache Redis cho dữ liệu trend (TTL 6 tiếng, cấu trúc key: `trends:vn:{date}:{category}`). *(Assignee: Ân)*
* **`DA-AI05-05` [KEEP]:** API lấy danh sách gợi ý trend phục vụ hiển thị trên giao diện (GET `/ai/trends?category=...&limit=20`). *(Assignee: Ân)*
* **`DA-AI05-06` [KEEP]:** Thiết lập thư viện APScheduler để kích hoạt hệ thống cào trend tự động mỗi 6 tiếng. *(Assignee: Ân)*

---

### AI Iteration 3 — Image, Ambassador & Composition (Parallel với Sprints 9–10 | Weeks 17–20)

#### 🔴 EPIC AI-06 — Image Generation Pipeline
* **`DA-AI06-01`:** Tích hợp Stability AI API (SDXL) để sinh ảnh từ text kèm các tham số: style, tỷ lệ khung hình, negative prompt. *(Assignee: Lộc)*
* **`DA-AI06-02`:** Endpoint sinh ảnh từ text và lưu trữ ảnh kết quả lên S3 (POST `/ai/image/generate`). *(Assignee: Lộc)*
* **`DA-AI06-03`:** Phát triển tính năng sinh hàng loạt (batch 3 biến thể ảnh cùng lúc) để người dùng tự chọn ảnh đẹp nhất. *(Assignee: Lộc)*
* **`DA-AI06-04`:** Thiết lập bộ lọc an toàn thương hiệu (mặc định các negative prompt để chặn ảnh nhạy cảm, bạo lực). *(Assignee: Lộc)*
* **`DA-AI06-05`:** Đánh giá chất lượng và thời gian phản hồi của mô hình trên 20 prompt sản phẩm thực tế. *(Assignee: Lộc)*

#### 🔴 EPIC AI-07 — Virtual Brand Ambassador (InstantID)
* **`DA-AI07-01`:** Thiết lập InstantID pipeline chạy local/cloud (nạp model, trích xuất InsightFace, ControlNet depth). *(Assignee: Tuấn)*
* **`DA-AI07-02`:** Phát triển module xử lý ảnh mẫu (phát hiện khuôn mặt và trích xuất vector khuôn mặt làm tham chiếu). *(Assignee: Tuấn)*
* **`DA-AI07-03`:** Viết endpoint sinh ảnh đại sứ (POST `/ai/ambassador/generate` nhận 1 ảnh mẫu + prompt tả trang phục/bối cảnh). *(Assignee: Tuấn)*
* **`DA-AI07-04`:** Chạy thử nghiệm 15 ảnh mẫu đại sứ với các tư thế/bối cảnh khác nhau, đánh giá độ giống mặt qua similarity score. *(Assignee: Tuấn)*
* **`DA-AI07-05`:** Xây dựng tính năng quản lý thư viện đại sứ thương hiệu (lưu ảnh tham chiếu và ảnh đã sinh lên S3 theo clientId). *(Assignee: Tuấn)*
* **`DA-AI07-06`:** API áp dụng ảnh đại sứ ảo lên các bối cảnh khác nhau (POST `/ai/ambassador/apply`). *(Assignee: Tuấn)*
* **`DA-AI07-07`:** Lập bảng so sánh, benchmark chất lượng giữa InstantID và IP-Adapter để đưa ra quyết định tối ưu. *(Assignee: Tuấn)*
* **`DA-AI07-08`:** Viết tài liệu hướng dẫn sử dụng tham số để sinh ảnh đại sứ đạt chất lượng cao nhất. *(Assignee: Tuấn)*

#### 🔴 EPIC AI-08 — Image Composition Pipeline
* **`DA-AI08-01`:** Triển khai thư viện `rembg` (mô hình U2Net) để tách nền tự động cho ảnh sản phẩm thô thành dạng PNG trong suốt. *(Assignee: Lộc)*
* **`DA-AI08-02`:** Triển khai tách nền cho ảnh người mẫu/đại sứ ảo để chuẩn bị ghép layer. *(Assignee: Lộc)*
* **`DA-AI08-03`:** Viết service ghép ảnh nhiều lớp sử dụng thư viện Pillow (Layer sản phẩm + Layer mẫu + Layer background). *(Assignee: Lộc)*
* **`DA-AI08-04`:** Phát triển thuật toán tự động cân bằng ánh sáng và vẽ bóng đổ nhân tạo tại chân mẫu/sản phẩm để ảnh trông thật hơn. *(Assignee: Lộc)*
* **`DA-AI08-05`:** API ghép ảnh tổng hợp (POST `/ai/compose` nhận S3 keys của sản phẩm, mẫu, background để ghép). *(Assignee: Lộc)*
* **`DA-AI08-06`:** Thử nghiệm ghép trên 20 cặp sản phẩm + người mẫu thực tế, ghi lại các case bị lỗi/mất nét. *(Assignee: Lộc)*
* **`DA-AI08-07`:** Viết tài liệu hướng dẫn kích thước tối ưu và các thông số căn lề chuẩn khi ghép ảnh. *(Assignee: Lộc)*

---

### AI Iteration 4 — Video, Integration & Documentation (Parallel với Sprints 11–12 | Weeks 21–24)

#### 🔴 EPIC AI-09 — AI Video Generation
* **`DA-AI09-01`:** Tích hợp Google Veo API (cơ chế xác thực, gọi API, polling trạng thái xử lý video bất đồng bộ). *(Assignee: Ân)*
* **`DA-AI09-02`:** Xây dựng hệ thống prompt template sinh video (nhận chủ đề + chuyển động + thời lượng để dịch ra prompt Veo). *(Assignee: Ân)*
* **`DA-AI09-03`:** Ánh xạ các lệnh chuyển động camera của người dùng (camera_pan, zoom_in, zoom_out, walk) thành tham số Veo. *(Assignee: Ân)*
* **`DA-AI09-04`:** Xây dựng thư viện chứa 30 kịch bản/template prompt video marketing mẫu chia theo nhiều lĩnh vực. *(Assignee: Ân)*
* **`DA-AI09-05`:** API sinh video bất đồng bộ (POST `/ai/video/generate` trả về `jobId`, GET `/ai/video/{jobId}/status` để lấy kết quả). *(Assignee: Ân)*
* **`DA-AI09-06`:** Upload video thành phẩm lên S3, tự động cắt 1 khung hình làm ảnh đại diện (thumbnail) và trả về thông tin đầy đủ. *(Assignee: Ân)*
* **`DA-AI09-07`:** Thực hiện chạy benchmark trên 30 prompt mẫu để thống kê thời gian và chi phí sinh một video. *(Assignee: Ân)*
* **`DA-AI09-08`:** Viết báo cáo nghiên cứu sinh video AI (bí kíp viết prompt và bảng cheat sheet tham số chuyển động). *(Assignee: Ân)*

#### 🔴 EPIC AI-10 — AI Service Integration & API Finalize
* **`DA-AI10-01`:** Đồng bộ và hoàn thiện toàn bộ các router/endpoint của `ai-service` đảm bảo chuẩn REST API. *(Assignee: Lộc)*
* **`DA-AI10-02`:** Thiết lập cơ chế bắt lỗi và thử lại (Exponential Backoff + Fallback Provider) khi gọi các API AI bên ngoài. *(Assignee: All)*
* **`DA-AI10-03`:** Viết bộ kịch bản test tích hợp với `business-service` trong môi trường Docker-compose để verify luồng gọi chéo. *(Assignee: All)*
* **`DA-AI10-04`:** Xuất collection Postman mẫu chứa đầy đủ body request/response của tất cả API AI để bàn giao. *(Assignee: Lộc)*
* **`DA-AI10-05`:** Cập nhật Swagger/OpenAPI spec của `ai-service` lên phiên bản chuẩn cuối cùng. *(Assignee: Lộc)*

#### 🔴 EPIC AI-11 — AI Research Documentation & Demo
* **`DA-AI11-01`:** Biên soạn tài liệu kỹ thuật cho Virtual Ambassador (so sánh mô hình, kết quả khảo sát similarity). *(Assignee: Tuấn)*
* **`DA-AI11-02`:** Biên soạn tài liệu kỹ thuật sinh video marketing (thư viện prompt, hướng dẫn điều khiển camera). *(Assignee: Ân)*
* **`DA-AI11-03`:** Biên soạn tài liệu kỹ thuật Image Composition (phương pháp tách nền, giải thuật đổ bóng chân thực). *(Assignee: Lộc)*
* **`DA-AI11-04`:** Thực hiện báo cáo phân tích chi phí AI dự kiến (trên quy mô 1,000 người dùng hoạt động/tháng). *(Assignee: All)*
* **`DA-AI11-05`:** Quay video demo thực tế chạy thử cả 7 tính năng AI đã phát triển trong dự án. *(Assignee: All)*
* **`DA-AI11-06`:** Trình bày kết quả nghiên cứu và chạy thử trực tiếp (Demo) với Mentor/Hội đồng chấm. *(Assignee: All)*

---

## III. Luồng Kỹ Thuật (Data Pipeline): Crawl Trend & AI Generate (GraphRAG)

Đây là flow chốt kết hợp giữa việc quét dữ liệu xu hướng và quy trình sinh kịch bản/nội dung quảng cáo tối ưu hóa khả năng giữ chân người dùng (Retention Hook).

### 1. Luồng xử lý chi tiết (Step-by-step Flow)

```
[MẠNG XÃ HỘI (TikTok/Reels/Shorts)]
            │
            ▼ (Crawl định kỳ dựa trên Trending Hashtag/KOL list)
┌───────────────────────────────────────┐
│ 1. AUDIO & VIDEO EXTRACTION           │ ──► Tải video (.mp4) / Tách âm thanh (.mp3)
└───────────────────┬───────────────────┘
                    │
                    ▼ (CUDA GPU RTX 4050 Local)
┌───────────────────────────────────────┐
│ 2. SPEECH-TO-TEXT (Whisper Local)     │ ──► Transcribe văn bản thô kèm Timestamps(Bỏ đoạn này)
└───────────────────┬───────────────────┘
                    │
                    ▼
┌───────────────────────────────────────┐
│ 3. NORMALIZATION & CLEANING           │ ──► Loại bỏ emoji rác, sửa từ lóng/viết tắt tiếng Việt
└───────────────────┬───────────────────┘
                    │
                    ├───► LƯU TRỮ VÀO VECTOR DB (ChromaDB) ➔ Lưu các chunk text & vector nhúng
                    │
                    └───► TRÍCH XUẤT THỰC THỂ (LLM/Rule NER) ➔ Trích các node (KOL, Món ăn, Địa điểm, Trend)
                                                            ➔ Lưu liên kết vào GRAPH DB (Neo4j)
┌───────────────────────────────────────┐
│ 4. HYBRID RETRIEVAL (Truy vấn lai)     │ ──► Người dùng nhập Topic/Query
└───────────────────┬───────────────────┘     ➔ ChromaDB tìm kiếm ngữ nghĩa lấy các Entity gốc
                    │                         ➔ Neo4j duyệt đồ thị (1-2 hops) lấy toàn bộ mối liên quan
                    ▼
┌───────────────────────────────────────┐
│ 5. BM25 SCORING & PRUNING             │ ──► Chấm điểm độ tương quan từ khóa bằng BM25
└───────────────────┬───────────────────┘     ➔ Cắt tỉa (Prune) node rác để tối ưu token & giảm latency
                    │
                    ▼ (Kết hợp context ChromaDB + cấu trúc mối quan hệ Neo4j)
┌───────────────────────────────────────┐
│ 6. GRAPHRAG CONTEXT BUILDER           │ ──► Tạo chuỗi context phân cấp sạch gửi tới LLM
└───────────────────┬───────────────────┘
                    │
                    ▼ (Llama 3 Groq / Claude Fallback)
┌───────────────────────────────────────┐
│ 7. CONTENT GENERATION (Hook 3s)       │ ──► Sinh bài viết/kịch bản có câu mở đầu giật gân
└───────────────────────────────────────┘     ➔ Đáp ứng thuật toán phân phối dựa trên tương tác TikTok
```

### 2. Ví dụ thực tế chi tiết về vận hành của Luồng xử lý (Data Pipeline Example)

Để dễ hình dung cách hệ thống vận hành, dưới đây là kịch bản chạy thử nghiệm thực tế đối với một xu hướng ẩm thực đường phố:

#### ⚡ Bước 1: Crawl & Tách Audio
* **Bối cảnh:** Bot phát hiện từ khóa `#trasuadatnung` đang có lượt xem tăng đột biến trong danh mục ẩm thực tại Việt Nam.
* **Hành động:** Hệ thống tự động cào một video TikTok đạt 1.2 triệu view của KOL ẩm thực `@ninheating` review về món trà sữa này tại phố cổ.
* **Kết quả:** Hệ thống tải về tệp tin video `ninheating_review_09.mp4` và thực hiện trích xuất tách riêng kênh tiếng thành file âm thanh `audio_source.mp3`.

#### ⚡ Bước 2: Chuyển giọng nói thành văn bản (Speech-to-Text)
* **Hành động:** Đẩy file `audio_source.mp3` qua mô hình Whisper local chạy bằng CUDA trên card RTX 4050.
* **Kết quả đầu ra của Whisper (Transcript kèm Timestamps):**
  * `[00:01.50 -> 00:05.10]`: "Hé lô mọi người, hôm nay cùng mình đi uống thử cái món trà sữa đất nung đang hot rần rần này nha."
  * `[00:05.80 -> 00:11.20]`: "Quán này là Trà Sữa Đất Nung Hàng Bồ, nằm ngay tại số 10 Hàng Bồ, Hoàn Kiếm, Hà Nội nè."
  * `[00:11.90 -> 00:18.40]`: "Trà ở đây được nướng trực tiếp trên ấm đất nung bốc khói nghi ngút, vị trà ngọt thanh thanh, béo ngậy vị sữa thơm lừng luôn."
  * `[00:19.00 -> 00:23.00]`: "Thời tiết mùa đông lạnh lạnh mà làm một ly nóng hổi như này thì đúng là hết nước chấm."

#### ⚡ Bước 3: Chuẩn hóa ngôn ngữ (Normalization)
* **Hành động:** Loại bỏ các từ đệm vô nghĩa ("Hé lô mọi người", "nè", "nha"), sửa từ viết tắt hoặc từ lóng ("ly" -> "cốc", "hết nước chấm" -> "cực kỳ ngon/hoàn hảo").
* **Kết quả:** *"Hôm nay đi uống thử món trà sữa đất nung đang hot. Quán Trà Sữa Đất Nung Hàng Bồ nằm tại số 10 Hàng Bồ, Hoàn Kiếm, Hà Nội. Trà được nướng trực tiếp trên ấm đất nung bốc khói nghi ngút, vị trà ngọt thanh, béo ngậy vị sữa thơm lừng. Thời tiết mùa đông lạnh mà làm một cốc nóng hổi thì cực kỳ ngon."*

#### ⚡ Bước 4: Lưu trữ cơ sở dữ liệu lai (ChromaDB + Neo4j)
Hệ thống tiến hành xử lý song song trên hai cơ sở dữ liệu:
* **Nhánh ChromaDB (Vector):** Chuyển đoạn văn bản đã chuẩn hóa ở trên thành vector nhúng (vector embedding) và lưu vào ChromaDB phục vụ tìm kiếm ngữ nghĩa mờ.
* **Nhánh Neo4j (Graph):** Chạy mô hình trích xuất thực thể (NER). Hệ thống nhận diện các thực thể chính và tạo liên kết trên Neo4j:
  * **Nodes:**
    * Node `KOL` ➔ `ninheating` (nền tảng: TikTok)
    * Node `Dish` ➔ `Trà sữa đất nung` (đặc trưng: ngọt thanh, béo bùi, nướng than)
    * Node `Location` ➔ `Hàng Bồ` (thuộc quận: Hoàn Kiếm, thành phố: Hà Nội)
    * Node `Topic` ➔ `Đồ uống mùa đông`
  * **Edges (Các mối quan hệ):**
    * `ninheating` ── `[PROMOTED_BY]` ──► `Trà sữa đất nung`
    * `Trà sữa đất nung` ── `[CHECK_IN_AT]` ──► `Hàng Bồ`
    * `Hàng Bồ` ── `[LOCATED_IN]` ──► `Hà Nội`
    * `Trà sữa đất nung` ── `[BELONGS_TO]` ──► `Đồ uống mùa đông`

#### ⚡ Bước 5: Truy vấn lai & Cắt tỉa (Hybrid Retrieval & BM25 Pruning)
* **Yêu cầu của User (Brand bán đồ uống TeaHouse):** *"Lên ý tưởng viết bài quảng cáo sản phẩm mới lấy chủ đề đồ uống nóng ấm áp bắt trend để đăng lên Fanpage"*.
* **Hành động truy vấn:**
  1. **Tìm kiếm ngữ nghĩa (ChromaDB):** Query của user được nhúng thành vector. ChromaDB quét và xác định thực thể tương đồng ngữ nghĩa nhất là node `Trà sữa đất nung` (mặc dù user gõ "đồ uống nóng ấm áp"). Node này được chọn làm **Entry Point**.
  2. **Duyệt đồ thị (Neo4j):** Từ node gốc `Trà sữa đất nung`, Neo4j duyệt đồ thị trong phạm vi 2 bước nhảy, thu về các thực thể liên quan: `ninheating`, `Hàng Bồ`, `Hà Nội`, `Đồ uống mùa đông`.
  3. **Chấm điểm BM25:** Hệ thống chạy thuật toán BM25 trên tập dữ liệu cào về để chấm điểm xem thực thể nào thực sự đang tạo xu hướng mạnh. Thực thể `Hàng Bồ` và `ninheating` đạt điểm cao. Một số node rác ít liên quan khác trong đồ thị bị cắt tỉa (prune) khỏi ngữ cảnh để tiết kiệm token.

#### ⚡ Bước 6: Tạo Context phân cấp (GraphRAG Context Builder)
* **Kết quả xây dựng Context:**
  ```
  [XU HƯỚNG MỚI NỔI]: Món Trà sữa đất nung đang cực kỳ hot tại Hà Nội.
  [ĐỊA ĐIỂM HOT]: Khu vực Hàng Bồ, Hoàn Kiếm, Hà Nội (đang là tọa độ check-in chính).
  [ĐỒNG SÁNG TẠO / KOL]: Ninheating đã review món này đạt 1.2M lượt tương tác.
  [HƯƠNG VỊ ĐẶC TRƯNG]: Vị trà nướng trên bếp ấm áp, ngọt thanh, béo ngậy, phù hợp nhất với thời tiết mùa đông.
  ```

#### ⚡ Bước 7: Sinh bài viết thương hiệu (LLM generation với Hook 3s)
* **Hành động:** Hệ thống gộp Context ở trên vào Template Prompt gửi sang Llama 3 (Groq). Prompt quy định cấu hình sinh tiêu đề và câu mở đầu giật gân (Hook 3s) thu hút tương tác.
* **Kết quả đầu ra cuối cùng gửi cho User:**
  > **[HOOK 3 CHI TIẾT ĐẦU - GIẬT TÍT]**
  > 😱 Mùa đông Hà Nội lạnh căm căm thế này mà bạn vẫn chưa biết trend Trà sữa đất nung Hàng Bồ đang làm mưa làm gió khắp TikTok của @ninheating à? Đừng để mình thành người "tối cổ" nhé!
  > 
  > **[NỘI DUNG SẢN PHẨM]**
  > Không cần phải chen chúc lên phố cổ chờ đợi xếp hàng dài cổ dưới gió lạnh, hôm nay **TeaHouse** chính thức cho ra mắt dòng **Trà Sữa Đất Nung Nướng Than Củi** chuẩn vị phố cổ ngay tại quán!
  > 
  > Vẫn là hương vị trà nướng đất nung ấm áp bốc khói, nhấp một ngụm cảm nhận ngay vị trà ngọt thanh dễ chịu kết hợp cùng lớp sữa béo ngậy thơm lừng ấm lòng. Mùa đông này chỉ cần thế là đủ trọn vẹn.
  > 
  > Ghé ngay chi nhánh TeaHouse gần nhất để thưởng thức phiên bản trà sữa đất nung nướng nóng hổi đang làm xiêu lòng hàng triệu food reviewer nhé!
  > 
  > **[HASHTAGS BẮT TREND]**
  > `#TeaHouse #trasuadatnung #trasuanuong #ninheating #hangbo #anuonghanoi #douongmuadong #xuhuong2026`

---

### 3. Tại sao Whisper STT chạy local là bắt buộc trong luồng này?
* **Metadata captions/hashtags trên social thường không có giá trị phân tích:** Người đăng video ngắn thường chỉ ghi caption ngắn mang tính giật gân hoặc tag xu hướng chung (`#xuhuong`, `#fyp`). Nếu chỉ đọc text metadata này, hệ thống sẽ bỏ sót toàn bộ nội dung thực.
* **Thông tin cốt lõi nằm ở tiếng nói:** Đánh giá sản phẩm, công thức, địa chỉ cửa hàng, tên thương hiệu, bối cảnh, cảm xúc... đều nằm trong giọng nói (voiceover) của video.
* **Giải pháp tối ưu chi phí:** Sử dụng thư viện `faster-whisper` chạy trên card đồ họa local **RTX 4050** giúp:
  * Đạt tốc độ xử lý gấp **4-5 lần** thời gian thực (transcribe video 30 giây trong 6 giây).
  * Chi phí bằng 0 (không mất phí API đám mây cho hàng ngàn video cào mỗi ngày).

### 4. Tại sao phải dùng kiến trúc lai GraphRAG (ChromaDB + Neo4j)?
* **Chỉ dùng Vector DB (ChromaDB):** Chỉ tìm kiếm được các đoạn văn giống nhau về mặt ngữ nghĩa thông qua vector tương đồng (Cosine Similarity). Tuy nhiên, các mẩu thông tin trả về bị rời rạc, không liên kết logic (ví dụ: không thể liên kết chính xác quán ăn C nằm ở quận 1 và do KOL A review nếu các thông tin này nằm ở các đoạn text khác nhau).
* **Chỉ dùng Graph DB (Neo4j):** Đòi hỏi dữ liệu đầu vào có cấu trúc cứng nhắc. Nếu người dùng gõ từ khóa đồng nghĩa nhưng khác chữ, Graph DB truyền thống sẽ không thể truy quét được.
* **Kết hợp GraphRAG (ChromaDB + Neo4j):**
  * Sử dụng ChromaDB để **hiểu ngữ nghĩa câu hỏi** và tìm ra các thực thể ban đầu (Entry Points).
  * Sử dụng Neo4j để từ các Entry Points này **duyệt tìm tất cả các mối quan hệ thực tế** xung quanh nó (KOL nào đang lăng xê, có trend nào liên quan, địa điểm ở đâu) trong phạm vi 1-2 bước nhảy.
  * Giúp LLM sinh ra kịch bản bắt trend vừa chính xác về thông tin, vừa hiểu rõ bối cảnh và các mối liên hệ xã hội.

### 5. Thuật toán chấm điểm BM25 & Cắt tỉa (Pruning)
Để tránh việc gom quá nhiều node liên quan vào prompt làm quá tải token limit của LLM và tăng độ trễ (latency), hệ thống tích hợp thuật toán chấm điểm **BM25**:
$$
\text{score}(D, Q) = \sum_{i=1}^{n} \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}
$$
* **Vai trò:** Đánh giá chính xác mức độ liên quan và sức ảnh hưởng thực tế của từng thực thể đối với query của người dùng (giải quyết được vấn đề bão hòa từ khóa của TF-IDF truyền thống). Các thực thể có điểm thấp dưới ngưỡng threshold sẽ bị lọc bỏ (prune), tạo ra một gói context cô đọng và chất lượng nhất để gửi tới LLM.

---

