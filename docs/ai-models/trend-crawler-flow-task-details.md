# Chi Tiết Nhiệm Vụ Epic AI-4.99 (Trend Crawler Flow Task Details)
**Epic:** `AI-4.99 — Analyze deeply crawl trend flow`  
**Dự án:** BrandHub AI Trend System  

Tài liệu này định nghĩa chi tiết 7 nhiệm vụ phân tích kỹ thuật phục vụ cho việc nghiên cứu, làm chủ thuật toán, thiết kế cơ sở dữ liệu và hạ tầng cho toàn bộ luồng cào dữ liệu xu hướng và nạp tri thức của BrandHub.

---

### DA-AI04-99-01 — Phân tích và thiết kế Tầng thu thập dữ liệu (Google Trends & TikTok Crawlers, Social Firehose)
**Assignee:** Tuấn (Crawl) | **Priority:** 🔴 High

**Goal:** Nghiên cứu và tài liệu hóa cơ chế hoạt động, giao thức cào, giải pháp chống chặn (anti-blocking) và cơ chế lập lịch cào dữ liệu từ Google Trends (`pytrends`), TikTok Creative Center và các nguồn social.

**Input:**(Điều chỉnh input nếu cần)
- Cấu hình Google Trends: Khu vực (`geo='VN'`), từ khóa hoặc category, khoảng thời gian (`timeframe='now 7-d'`).
- Danh sách cào có mục tiêu (Targeted List): 50-100 usernames/IDs của các KOLs và đường dẫn của các group cộng đồng Facebook công khai cần giám sát.

**Output:**
- Danh sách bài đăng thô dạng văn bản kèm metadata tương tác.
- Định dạng JSON Output mẫu:
  ```json
  {
    "source": "tiktok/facebook/google",
    "crawl_time": "2026-07-18T20:00:00Z",
    "posts": [
      {
        "post_id": "tt_738291038102",
        "author": "ninheating",
        "content": "Hé lô mọi người, hôm nay đi uống thử trà sữa đất nung Hàng Bồ ngon lắm nha! #trasuadatnung",
        "interactions": { "likes": 45000, "shares": 1200, "comments_count": 850 },
        "comments": [
          { "user": "reviewer_A", "text": "Quán này ở số 10 Hàng Bồ đúng không anh?" }
        ]
      }
    ]
  }
  ```

**Detailed Solution (Giải pháp chi tiết):**(Đây chỉ là giải pháp đề suất bởi AI, nghiên cứu kỹ hơn để đưa ra giải pháp phù hợp)
1. **Google Trends (`pytrends`):** Sử dụng class `TrendReq` gọi API của Google. Định kỳ chạy hàm `realtime_trending_searches(pn='VN')` mỗi 6 giờ để lấy các từ khóa đang tìm kiếm thịnh hành nhất Việt Nam.
2. **TikTok Creative Center & KOL Crawler:** Sử dụng headless browser `Playwright` truy cập vào TikTok Creative Center lấy danh sách hashtag hot. Đối với các KOLs trong danh sách mục tiêu, gọi API không chính thức (qua dịch vụ RapidAPI TikTok Scraper) để lấy feed bài đăng mới nhất dựa trên `uniqueId` hoặc `secUid`.
3. **Facebook Public Groups Scraper:** Sử dụng `Scrapy` kết hợp với dịch vụ Proxy xoay vòng (Proxy Rotation như Bright Data hoặc Webshare) để liên tục cào bài viết mới nhất từ các nhóm công khai mà không cần đăng nhập tài khoản nhằm tránh bị khóa tài khoản/checkpoint.
4. **Cơ chế lập lịch:** Sử dụng `APScheduler` tích hợp sẵn trong FastAPI chạy ngầm định kỳ mỗi 6 giờ dưới nền. Kết quả thô được ghi đệm tạm thời thành file JSON hoặc đẩy vào hàng đợi trong Redis.

**Acceptance Criteria:**
- [ ] Tài liệu hóa cách cấu hình và giới hạn tần suất (rate limits) của Google Trends qua thư viện `pytrends`.
- [ ] Nghiên cứu và tài liệu hóa cơ chế cào dữ liệu từ TikTok Creative Center và API lấy bài đăng KOLs.
- [ ] Thiết kế luồng cào các Group Facebook công khai kết hợp dịch vụ proxy xoay vòng để chống chặn.
- [ ] Cấu hình scheduler chạy ngầm thông qua thư viện `APScheduler` chạy định kỳ mỗi 6 giờ.

**Technical Notes:**
- Việc sử dụng các giải pháp chống chặn IP (Proxy Rotation, Spoofing Headers, Random User-Agents) là bắt buộc đối với TikTok và Facebook Scraper để đảm bảo hệ thống hoạt động liên tục.
- Thiết kế phương án lưu trữ văn bản thô tạm thời trước khi đẩy vào động cơ dự đoán xu hướng.

**Dependencies:** Blocks: DA-AI04-99-02.

---

### DA-AI04-99-02 — Nghiên cứu thuật toán Động cơ dự đoán xu hướng (Tách từ & BM25 Anomaly Detection)
**Assignee:** Ân (Algorithm) | **Priority:** 🔴 High

**Goal:** Thiết kế công thức toán học và logic lập trình cho việc tách từ tiếng Việt và tính toán điểm đột biến BM25 để lọc ra 100 ứng cử viên xu hướng.

**Input:**
- Danh sách bài đăng thô dạng văn bản kèm metadata tương tác [Output từ `DA-AI04-99-01`].

**Output:**
- Danh sách Top 100 từ khóa/cụm từ ứng cử viên có điểm bất thường cao nhất.
- Định dạng JSON mẫu:
  ```json
  [
    { "keyword": "trà sữa đất nung", "anomaly_score": 8.45 },
    { "keyword": "capybara", "anomaly_score": 7.12 }
  ]
  ```

**Detailed Solution (Giải pháp chi tiết):**
1. **Làm sạch thô:** Sử dụng Regex loại bỏ các ký tự đặc biệt, link URL và emoji.
2. **Tách từ tiếng Việt:** Sử dụng thư viện `Underthesea` (hàm `word_tokenize`) để phân tách văn bản thô thành các cụm từ ghép có nghĩa. Nạp bộ từ điển custom để nhận diện các từ lóng mới.
3. **Tính toán chỉ số BM25:** So sánh tần suất xuất hiện của từ khóa hôm nay (TF) so với mức độ hiếm của nó trong lịch sử 30 ngày trước (IDF).
   - Công thức: \(\text{Anomaly\_Score}(D, q_i) = \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}\)
4. **Trích xuất Candidates:** Sắp xếp giảm dần theo điểm số Anomaly Score và cắt lấy 100 từ khóa đứng đầu.

**Acceptance Criteria:**
- [ ] Xác định thư viện tách từ tiếng Việt (`Underthesea` hoặc `PyVi`) và thiết lập bộ từ điển tùy chỉnh (custom dictionary) để nhận diện các từ ghép/từ mới.
- [ ] Định nghĩa công thức toán học BM25 áp dụng cho phát hiện bất thường: tính toán tần suất $TF$ của chu kỳ 6h hiện tại so với chỉ số nghịch đảo $IDF$ của lịch sử 30 ngày trước.
- [ ] Xác định các ngưỡng lọc (thresholds) và cơ chế chuẩn hóa điểm số BM25 để chọn ra Top 100 Candidates.

**Technical Notes:**
- Thuật toán BM25 cần xử lý được các từ tiếng Việt có dấu/không dấu và loại bỏ chính xác danh sách Stop words (từ đệm, từ vô nghĩa) để tránh nhiễu dữ liệu.

**Dependencies:** Blocked by: DA-AI04-99-01. Blocks: DA-AI04-99-03.

---

### DA-AI04-99-03 — Phân tích đồ thị tương tác & Thuật toán Centrality tính Điểm lan truyền
**Assignee:** Ân (Algorithm) | **Priority:** 🔴 High

**Goal:** Thiết kế cấu trúc đồ thị tương tác Neo4j cho các ứng cử viên xu hướng và áp dụng các thuật toán đồ thị của Neo4j GDS để tính toán điểm lan truyền (Virality Score).

**Input:**
- Danh sách Top 100 ứng cử viên xu hướng [Output từ `DA-AI04-99-02`].
- Danh sách thông tin tài khoản người dùng/KOL và tương tác chéo từ Tầng cào thô [lấy từ `DA-AI04-99-01`].

**Output:**
- Bảng xếp hạng Top 10 - 20 xu hướng chính thức cuối cùng kèm điểm số tích hợp.
- Định dạng JSON mẫu:
  ```json
  [
    { "rank": 1, "trend": "trà sữa đất nung", "final_score": 7.52, "anomaly_score": 8.45, "virality_score": 0.89 }
  ]
  ```

**Detailed Solution (Giải pháp chi tiết):**
1. **Dựng đồ thị tương tác (Graph Construction):** Đẩy thông tin tương tác của 100 ứng cử viên vào Neo4j dưới dạng Node (`:User`, `:Trend`, `:Community`) và Edge (`:POSTED`, `:INTERACTED`).
2. **Chiếu đồ thị (Graph Projection):** Sử dụng Neo4j GDS để tạo một đồ thị ảo trong RAM (`gds.graph.project`).
3. **Chạy thuật toán Centrality:**
   - Chạy **Degree Centrality** để đo mức độ tiếp cận (Reach/Coverage).
   - Chạy **Betweenness Centrality** để đo khả năng lan truyền xuyên cộng đồng (Cross-community Virality).
   - Tổng hợp thành `Graph_Virality_Score` trong khoảng `[0, 1]`.
4. **Tính điểm cuối cùng:** Nhân điểm số bất thường với điểm lan truyền đồ thị:
   \[Final\_Trend\_Score = Anomaly\_Score \times Graph\_Virality\_Score\]
   Lọc lấy Top 10 - 20 xu hướng có điểm số cao nhất.

**Acceptance Criteria:**
- [ ] Định nghĩa cấu trúc Schema đồ thị tương tác thô (Nodes: `User`, `Trend`, `Community`; Edges: `POSTED`, `INTERACTED`).
- [ ] Viết sẵn các câu lệnh Cypher để chạy thuật toán Degree Centrality và Betweenness Centrality thông qua thư viện Neo4j GDS.
- [ ] Thiết lập công thức tính điểm tổng hợp cuối cùng: $Final\_Trend\_Score = Anomaly\_Score \times Graph\_Virality\_Score$.
- [ ] Thiết lập cơ chế lọc botnet bằng thuật toán Clustering Coefficient trên đồ thị.

**Technical Notes:**
- Đảm bảo cơ chế chiếu đồ thị ảo (Graph Projection) trong Neo4j GDS chạy tối ưu trên RAM để không gây trễ hệ thống khi chạy tính toán định kỳ.

**Dependencies:** Blocked by: DA-AI04-99-02. Blocks: DA-AI04-99-06, DA-AI04-99-07.

---

### DA-AI04-99-04 — Thiết kế quy trình Chuẩn hóa và Cắt nhỏ văn bản (Text Normalization & Chunking)
**Assignee:** Ân + Trung (Database) | **Priority:** 🟡 Medium

**Goal:** Định nghĩa bộ quy tắc làm sạch văn bản tiếng Việt và thiết lập thông số chia nhỏ văn bản tri thức phục vụ cho khâu nạp dữ liệu tri thức của trend.

**Input:**
- Tên các xu hướng chính thức trong Top 10 - 20 [từ `DA-AI04-99-06`].
- Văn bản thô của các bài đăng và comments chi tiết liên quan đến các xu hướng này [do bot tiếp tục cào sâu].

**Output:**
- Danh sách các text chunks sạch đã chuẩn hóa ngôn ngữ.
- Định dạng JSON mẫu:
  ```json
  {
    "trendName": "trà sữa đất nung",
    "chunks": [
      { "chunk_id": "chunk_0", "text": "Quán Trà Sữa Đất Nung Hàng Bồ nằm tại số 10 Hàng Bồ, Hoàn Kiếm, Hà Nội. Trà được nướng trực tiếp trên ấm đất..." }
    ]
  }
  ```

**Detailed Solution (Giải pháp chi tiết):**
1. **Chuẩn hóa từ lóng/viết tắt:** Thay thế các từ viết tắt và từ lóng phổ biến trên MXH bằng bộ từ điển ánh xạ (synonyms map). Loại bỏ hoàn toàn các emoji rác và URL quảng cáo.
2. **Chia nhỏ (Chunking):** Chạy thư viện LangChain `RecursiveCharacterTextSplitter` với các tham số: `chunk_size=500`, `chunk_overlap=50`. Cấu hình cắt theo độ ưu tiên: dấu xuống dòng `\n`, dấu chấm `.`, dấu phẩy `,`, và khoảng trắng để tránh đứt câu.

**Acceptance Criteria:**
- [ ] Xây dựng bộ quy tắc Regex và từ điển chuẩn hóa viết tắt/từ lóng tiếng Việt (ví dụ: "khum" -> "không", "k" -> "không", "ly" -> "cốc").
- [ ] Xác định cấu hình chia nhỏ văn bản bằng LangChain `RecursiveCharacterTextSplitter` (chunk_size=500, overlap=50).

**Technical Notes:**
- Phải đảm bảo các vết cắt chunk không làm đứt đoạn ngữ nghĩa của câu tiếng Việt (ưu tiên cắt theo dấu chấm, dấu phẩy, dấu xuống dòng).

**Dependencies:** Blocks: DA-AI04-99-05.

---

### DA-AI04-99-05 — Thiết kế cấu trúc cơ sở dữ liệu lai (ChromaDB + Neo4j NER Graph Schema)
**Assignee:** Lộc (APIs) | **Priority:** 🔴 High

**Goal:** Thiết kế sơ đồ dữ liệu (Schema) và cơ chế liên kết đồng bộ giữa Vector DB (ChromaDB) và Graph DB (Neo4j) đối với dữ liệu tri thức chi tiết của xu hướng.

**Input:**
- Danh sách các text chunks sạch kèm trendName liên kết [Output từ `DA-AI04-99-04`].

**Output:**
- Cơ sở dữ liệu ChromaDB được nạp vector embeddings.
- Neo4j được bổ sung các Node thực thể (`:KOL`, `:Dish`, `:Location`) và liên kết quan hệ (`:PROMOTED`, `:ASSOCIATED_WITH`, `:LOCATED_IN`) trỏ về Node `:Trend`.

**Detailed Solution (Giải pháp chi tiết):**
1. **Nạp ChromaDB (Vector DB):** Sử dụng mô hình `all-MiniLM-L6-v2` chuyển đổi từng text chunk thành vector 384 chiều. Lưu trữ vào ChromaDB kèm theo metadata lọc `trendName`.
2. **Trích thực thể & Nạp Neo4j (NER):** Gửi text chunk sang LLM (Llama 3 qua API) với prompt trích xuất thực thể có cấu trúc. Nhận về danh sách thực thể và chạy các câu lệnh Cypher `MERGE` để tạo mối quan hệ trên đồ thị Neo4j.
3. **Khớp nối dữ liệu (Linkage):** Đảm bảo cả bản ghi ChromaDB (qua metadata `trendName`) và các node thực thể trong Neo4j đều kết nối trực tiếp với node `:Trend` gốc để luồng GraphRAG sau này có thể truy vấn lai đồng bộ.

**Acceptance Criteria:**
- [ ] Định nghĩa Schema lưu trữ trong ChromaDB (Cấu trúc ID, nội dung document, cấu hình mô hình embedding và các trường metadata như `trendName` để filter).
- [ ] Định nghĩa Schema đồ thị tri thức trong Neo4j (Nodes: `KOL`, `Dish`, `Location`, `Trend`; Edges: `PROMOTED`, `ASSOCIATED_WITH`, `LOCATED_IN`).
- [ ] Thiết kế giải thuật chạy nền (Background Job) xử lý trùng lặp thực thể (Entity Resolution) để gộp các node tương tự ngữ nghĩa trong Neo4j.

**Technical Notes:**
- ChromaDB cần được cấu hình index tối ưu cho việc lọc theo thuộc tính metadata `trendName` để phục vụ khâu truy vấn lai (Hybrid Retrieval) đạt latency dưới 100ms.

**Dependencies:** Blocked by: DA-AI04-99-04. Blocks: DA-AI04-99-07.

---

### DA-AI04-99-06 — Thiết kế luồng lưu trữ đệm Redis và Ghi đè kết quả Neo4j (Upsert Flow)
**Assignee:** Lộc (APIs) | **Priority:** 🟡 Medium

**Goal:** Thiết kế cấu trúc dữ liệu lưu đệm trong Redis và viết các truy vấn Cypher ghi đè/tạo mới (Upsert) điểm số xu hướng vào Neo4j.

**Input:**
- Bảng xếp hạng Top 10 - 20 xu hướng chính thức [Output từ `DA-AI04-99-03`].

**Output:**
- Dữ liệu được đồng bộ hóa thành công xuống Redis (Sorted Set) và Neo4j (Trend Nodes).
- API `/ai/trends` có thể đọc trực tiếp dữ liệu từ Redis để hiển thị lên Dashboard.

**Detailed Solution (Giải pháp chi tiết):**
1. **Redis Caching:** Ghi danh sách xu hướng vào Redis dưới dạng Sorted Set (ZSET) với key `trends:vn:{date}:{category}`. Điểm score của ZSET chính là `final_score` để dashboard truy vấn và sắp xếp tự động. Thiết lập TTL là 6 giờ.
2. **Neo4j Upsert:** Thực thi câu lệnh Cypher sử dụng mệnh đề `MERGE` kết hợp `ON CREATE SET` và `ON MATCH SET` để cập nhật/ghi đè chỉ số xếp hạng và điểm số lên Node `:Trend` trong database.

**Acceptance Criteria:**
- [ ] Thiết kế cấu trúc lưu trữ bảng xếp hạng trend trong Redis (cấu trúc key `trends:vn:{date}:{category}`, sử dụng kiểu dữ liệu Sorted Set hoặc JSON String) kèm TTL 6 giờ.
- [ ] Viết câu lệnh Cypher sử dụng `MERGE` kết hợp `ON CREATE SET` và `ON MATCH SET` để thực hiện upsert điểm số, thứ hạng của Top 10-20 Trend vào Neo4j mà không làm mất lịch sử ngày tạo.

**Technical Notes:**
- Đảm bảo việc ghi vào Redis và Neo4j diễn ra đồng thời để tránh bất đồng bộ dữ liệu hiển thị trên Dashboard.

**Dependencies:** Blocked by: DA-AI04-99-03. Blocks: DA-AI04-99-07.

---

### DA-AI04-99-07 — Tổng hợp tài liệu Blueprint thiết kế hệ thống cào dữ liệu xu hướng (Final Blueprint)
**Assignee:** Tuấn (APIs) | **Priority:** 🟡 Medium

**Goal:** Tổng hợp toàn bộ các phân tích, thuật toán, công thức toán học, sơ đồ database và thiết kế API từ các task trước thành một tài liệu Blueprint hoàn chỉnh bàn giao cho đội phát triển.

**Acceptance Criteria:**
- [ ] Hoàn thành tài liệu thiết kế hệ thống chi tiết `report_crawl_trend_analysis.md`.
- [ ] Tích hợp đầy đủ các sơ đồ luồng dữ liệu (Mermaid) và ví dụ JSON thô/vector/graph properties thực tế.
- [ ] Bàn giao thành công và họp thống nhất (Alignment) tài liệu thiết kế với toàn bộ thành viên trong đội phát triển AI.

**Technical Notes:**
- Tài liệu Blueprint cần lưu trực tiếp trong thư mục tài liệu thiết kế của dự án để làm tài liệu đối chiếu (Reference) trong suốt quá trình code.

**Dependencies:** Blocked by: DA-AI04-99-03, DA-AI04-99-05, DA-AI04-99-06.
