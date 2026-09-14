# Chi Tiết Nhiệm Vụ RAG & Content Generation Flow (RAG Content Generation Pipeline)
**Epic:** `AI-03 — RAG Knowledge Base Pipeline` & `AI-04 — LLM Content Generation`  
**Dự án:** BrandHub AI Trend System  

Tài liệu này định nghĩa chi tiết toàn bộ các nhiệm vụ (tasks) kỹ thuật phục vụ cho việc xây dựng **Luồng nạp dữ liệu tri thức (Offline/Periodic Ingestion)** và **Luồng xử lý truy vấn & Sinh bài viết quảng cáo (Online/Runtime Generation)**. Các nhiệm vụ này được phân rã chi tiết nhất có thể để phục vụ phân chia công việc cho các thành viên trong đội phát triển AI.

---

## I. Tổng Quan Luồng Hoạt Động (Pipeline Architecture)

Hệ thống RAG và sinh nội dung hoạt động dựa trên sự phối hợp của 2 luồng chính:

### 1. Luồng Nạp Tri Thức Thương Hiệu & Xu Hướng (Ingestion Pipeline - Offline/Periodic)
```
[TÀI LIỆU THƯƠNG HIỆU / BÀI VIẾT TREND] 
       │
       ▼
[Task DA-AI03-01: Document Upload API] ➔ Lưu S3
       │
       ▼ (Asynchronous Background Task)
[Task DA-AI03-02: Document Chunking] ➔ LangChain RecursiveSplitter
       │
       ├──────────────────────────────────────────────┐
       ▼ (Nhánh Vector)                               ▼ (Nhánh Graph)
[Task DA-AI03-03: Embeddings Pipeline]        [Task DA-AI03-03.2: NER Entity Extraction]
       │                                              │ (Dùng Connection Pool DA-AI03-03.1)
       ▼                                              ▼
[Lưu ChromaDB (HNSW Index)]                   [Lưu Neo4j Graph DB]
                                                      │ (Merge node trùng lặp qua)
                                                      ▼
                                              [Task DA-AI03-09: Entity Resolution Cron]
```

### 2. Luồng Truy Vấn Người Dùng & Sinh Bài Viết (Retrieval & Generation - Online/Runtime)
```
[YÊU CẦU SINH BÀI VIẾT (TOPIC / QUERY)]
       │
       ▼
[Task DA-AI03-03.3: Query Normalization] ➔ Làm sạch, sửa từ lóng viết tắt
       │
       ▼
[Task DA-AI03-04: ChromaDB Semantic Search] ➔ Tìm các thực thể gốc (Entry Points)
       │
       ▼
[Task DA-AI03-04.1: Neo4j Graph Traversal] ➔ Duyệt đồ thị 1-2 hops tìm thực thể liên quan
       │
       ▼
[Task DA-AI03-04.2: BM25 Scoring & Pruning] ➔ Chấm điểm tương quan, cắt tỉa node rác
       │
       ▼
[Task DA-AI03-05: GraphRAG Context Builder] ➔ Định dạng context phân cấp gửi LLM
       │
       ▼
[Task DA-AI04-01: Prompt Builder & Hook 3s] ➔ Sinh prompt hoàn chỉnh động
       │
       ▼
[Task DA-AI04-02: Llama 3 Groq API] ──(Lỗi/Quá tải)──► [Task DA-AI04-03: Claude Fallback]
       │                                                         │
       └────────────────────────┬────────────────────────────────┘
                                ▼
                 [Bài viết thô (Hook + Body + CTA)]
                                │
                                ├───────────────────────────────┐
                                ▼ (Tối ưu độ dài)               ▼ (Tạo thẻ)
                 [Task DA-AI04-04: Length Optimizer]    [Task DA-AI04-05: Hashtags API]
                                │                               │
                                └──────────────┬────────────────┘
                                               ▼
                                  [BÀI VIẾT HOÀN THIỆN ĐẦU RA]
                                               │
                                               ▼ (Vòng lặp chỉnh sửa nếu có)
                                [Task DA-AI04-06: Feedback Loop]
```

---

## II. Phân Rã Chi Tiết Nhiệm Vụ Epic AI-03 (RAG Knowledge Base Pipeline)

### DA-AI03-01 — Xây dựng Endpoint nạp tài liệu tri thức (Document Upload Endpoint)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Xây dựng cổng nạp tài liệu tri thức thương hiệu, hỗ trợ tải lên file vật lý hoặc truyền đường link URL, lưu trữ file thô vào S3 và kích hoạt bất đồng bộ luồng xử lý tiếp theo.

*   **Input:**
    *   Multipart Form chứa file (`.pdf`, `.docx`, `.txt`) hoặc chuỗi URL.
    *   `clientId` (String) định danh khách hàng.
*   **Output:**
    *   JSON response chứa thông tin tài liệu được tạo:
        ```json
        {
          "documentId": "doc_123456789_abcdef",
          "clientId": "client_abc",
          "filename": "menu_tea_house.pdf",
          "s3Key": "rag/client_abc/doc_123456789_abcdef/menu_tea_house.pdf",
          "status": "processing",
          "createdAt": "2026-08-03T16:00:00Z"
        }
        ```
*   **Detailed Solution:**
    1.  Tạo endpoint FastAPI `POST /ai/rag/documents`.
    2.  Kiểm tra định dạng file (chỉ cho phép `.pdf`, `.docx`, `.txt`) và giới hạn dung lượng tối đa 10MB. Nếu sai định dạng hoặc quá dung lượng, trả về `400 Bad Request`.
    3.  Lưu file vào AWS S3 với đường dẫn cấu trúc: `rag/{clientId}/{documentId}/{filename}` sử dụng thư viện `boto3`.
    4.  Nếu đầu vào là URL: Sử dụng thư viện `requests` và `BeautifulSoup` để tải nội dung HTML, bóc tách text sạch (loại bỏ script, style), ghi đệm thành file `.txt` và đẩy lên S3 tương tự file vật lý.
    5.  Sử dụng `FastAPI.BackgroundTasks` kích hoạt bất đồng bộ hàm xử lý chunking (`DA-AI03-02`) nhằm phản hồi ngay lập tức cho client.
*   **Acceptance Criteria:**
    *   [ ] Endpoint nhận tải lên file vật lý (PDF, DOCX, TXT) và URL hoạt động đúng.
    *   [ ] Tải file thô lên S3 thành công theo đúng cấu trúc thư mục quy định.
    *   [ ] Kiểm soát lỗi dung lượng file (>10MB) và loại file không được hỗ trợ.
    *   [ ] Trả dữ liệu phản hồi ngay lập tức trong khi tiến trình chunking chạy ngầm.
*   **Technical Notes:**
    *   Phải cấu hình timeout và spoofing user-agent cho requests tải URL để tránh bị các website chặn.
*   **Dependencies:** Blocks: `DA-AI03-02`. Blocked by: `DA-AI02-03`, `DA-AI02-04`.

---

### DA-AI03-02 — Xây dựng dịch vụ cắt nhỏ văn bản (Document Chunking Service)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Trích xuất văn bản thô từ tài liệu trên S3 và thực hiện cắt nhỏ thành các đoạn có kích thước tối ưu phục vụ cho việc trích xuất thực thể và tạo embeddings.

*   **Input:**
    *   `s3Key` của tài liệu thô trên S3.
*   **Output:**
    *   Mảng JSON chứa các chunk text sạch:
        ```json
        [
          { "chunkIndex": 0, "text": "Trà sữa nướng TeaHouse làm từ trà ô long đặc sản..." },
          { "chunkIndex": 1, "text": "...được nướng cùng đường nâu hữu cơ tạo vị caramel đặc trưng." }
        ]
        ```
*   **Detailed Solution:**
    1.  Tạo module `app/services/chunking.py`.
    2.  Đọc file thô từ S3:
        *   Đối với PDF: Sử dụng thư viện `pdfplumber` bóc tách văn bản theo trang.
        *   Đối với DOCX: Sử dụng thư viện `python-docx` bóc tách văn bản theo paragraph.
        *   Đối với TXT: Đọc text UTF-8 trực tiếp.
    3.  Sử dụng thư viện LangChain `RecursiveCharacterTextSplitter` cấu hình:
        *   `chunk_size = 500` ký tự.
        *   `chunk_overlap = 50` ký tự.
        *   `separators = ["\n\n", "\n", ".", ",", " ", ""]` để tránh cắt cụt câu tiếng Việt.
    4.  Lọc bỏ các chunk trống hoặc chỉ chứa ký tự trắng rác.
*   **Acceptance Criteria:**
    *   [ ] Trích xuất text thành công từ cả 3 định dạng PDF, DOCX, TXT.
    *   [ ] Thực hiện cắt nhỏ văn bản đúng cấu hình 500 ký tự và 50 ký tự gối đầu (overlap).
    *   [ ] Bộ lọc loại bỏ các chunk rác hoạt động tốt.
*   **Technical Notes:**
    *   Khi đọc PDF, nếu toàn bộ trang bị rỗng (ví dụ: PDF scan dạng ảnh), cần ghi log cảnh báo chi tiết để phục vụ nâng cấp OCR sau này.
*   **Dependencies:** Blocked by: `DA-AI03-01`. Blocks: `DA-AI03-03`, `DA-AI03-03.2`.

---

### DA-AI03-03 — Xây dựng đường ống Vector hóa và Lưu trữ ChromaDB (Embedding Pipeline)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Chuyển đổi các chunk text sạch thành vector embeddings và lưu trữ vào cơ sở dữ liệu Vector (ChromaDB) kèm metadata chi tiết để phục vụ tìm kiếm ngữ nghĩa.

*   **Input:**
    *   Mảng các chunk text sạch từ `DA-AI03-02`.
    *   `clientId`, `documentId`.
*   **Output:**
    *   Bản ghi trong collection của ChromaDB.
*   **Detailed Solution:**
    1.  Tạo module `app/services/embedding.py`.
    2.  Khởi tạo mô hình embedding `sentence-transformers/all-MiniLM-L6-v2` (tạo vector 384 chiều) chạy cục bộ trên môi trường CPU hoặc sử dụng HuggingFace local pipeline để tối ưu tốc độ và chi phí.
    3.  Lấy hoặc tạo mới Collection trong ChromaDB theo tên định dạng: `client_{clientId}`.
    4.  Đóng gói metadata cho từng chunk: `{documentId, clientId, chunkIndex, source_filename}`.
    5.  Thực hiện insert hàng loạt (Batch Insert) tối đa 50 chunks/lần bằng hàm `collection.add()` để tránh quá tải bộ nhớ ChromaDB.
*   **Acceptance Criteria:**
    *   [ ] Sinh vector embeddings 384 chiều chính xác cho văn bản tiếng Việt.
    *   [ ] Khởi tạo collection trong ChromaDB tự động nếu chưa tồn tại.
    *   [ ] Lưu trữ thành công vector và metadata tương ứng.
*   **Technical Notes:**
    *   ChromaDB cần được chạy dưới dạng container độc lập (Docker) và kết nối qua connection pool của Python client.
*   **Dependencies:** Blocked by: `DA-AI03-02`. Blocks: `DA-AI03-04`.

---

### DA-AI03-03.1 — Cấu hình kết nối cơ sở dữ liệu Neo4j (Neo4j Connection Pool)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Thiết lập container Docker Neo4j ở môi trường phát triển và viết class quản lý kết nối cơ sở dữ liệu đồ thị (Connection Pool) tối ưu trong AI Service.

*   **Input:**
    *   Thông tin cấu hình Neo4j trong file `.env` (`NEO4J_URI`, `NEO4J_USER`, `NEO4J_PASSWORD`).
*   **Output:**
    *   Đối tượng kết nối Neo4j Driver sẵn sàng thực thi truy vấn Cypher.
*   **Detailed Solution:**
    1.  Cài đặt thư viện `neo4j` (Python official driver).
    2.  Tạo class `Neo4jDatabase` tại `app/core/neo4j.py` theo mẫu thiết kế Singleton.
    3.  Sử dụng `GraphDatabase.driver()` để khởi tạo driver kết nối với pool mặc định.
    4.  Viết các hàm helper quản lý Session (`execute_read`, `execute_write`) để đảm bảo giải phóng kết nối sau khi thực thi truy vấn.
    5.  Bổ sung cấu hình Neo4j Community Edition vào file `docker-compose.yml` của hạ tầng.
*   **Acceptance Criteria:**
    *   [ ] Khởi chạy thành công container Neo4j local.
    *   [ ] Class `Neo4jDatabase` kết nối thành công đến DB thông qua biến môi trường.
    *   [ ] Đảm bảo cơ chế đóng/mở connection pool hoạt động chính xác, không rò rỉ kết nối (connection leak).
*   **Technical Notes:**
    *   Thiết lập tham số `max_connection_lifetime` và `keep_alive` cho driver để tránh lỗi đứt kết nối ngầm khi chạy trên Docker.
*   **Dependencies:** Blocks: `DA-AI03-03.2`, `DA-AI03-04.1`.

---

### DA-AI03-03.2 — Trích xuất thực thể NER & Nạp liên kết đồ thị tri thức Neo4j
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Sử dụng LLM phân tích các chunk văn bản để trích xuất các thực thể chính (KOL, Dish, Location, Trend) và quan hệ giữa chúng, sau đó nạp vào cơ sở dữ liệu Neo4j.

*   **Input:**
    *   Các chunk văn bản từ `DA-AI03-02`.
*   **Output:**
    *   Các Node và Edge quan hệ được lưu trữ thành công trên Neo4j.
*   **Detailed Solution:**
    1.  Tạo module `app/services/ner_extractor.py`.
    2.  Xây dựng prompt NER chuyên biệt gửi lên LLM (Llama 3 hoặc Claude) để trích xuất thực thể theo định dạng JSON bắt buộc:
        ```json
        {
          "entities": [
            {"type": "KOL", "name": "ninheating"},
            {"type": "Location", "name": "Hàng Bồ"}
          ],
          "relations": [
            {"source": "ninheating", "type": "CHECK_IN_AT", "target": "Hàng Bồ"}
          ]
        }
        ```
    3.  Viết các truy vấn Cypher sử dụng mệnh đề `MERGE` để ghi dữ liệu vào Neo4j:
        *   Tạo node: `MERGE (n:Entity {name: $name, type: $type})`
        *   Tạo quan hệ: `MATCH (s), (t) MERGE (s)-[:RELATION_TYPE]->(t)`
*   **Acceptance Criteria:**
    *   [ ] Trích xuất thực thể chuẩn xác từ văn bản tiếng Việt F&B/Trends.
    *   [ ] Ghi thực thể và quan hệ vào Neo4j không bị trùng lặp node nhờ mệnh đề `MERGE`.
*   **Technical Notes:**
    *   Sử dụng cơ chế Batching Cypher queries (truyền tham số dạng list các node/relations) để tối ưu hóa hiệu năng, giảm thời gian trao đổi với database.
*   **Dependencies:** Blocked by: `DA-AI03-02`, `DA-AI03-03.1`. Blocks: `DA-AI03-04.1`.

---

### DA-AI03-03.3 — Chuẩn hóa câu truy vấn của người dùng (Query Normalization)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Tiền xử lý câu query/topic của người dùng trước khi đưa vào luồng tìm kiếm ngữ nghĩa nhằm tăng độ chính xác của kết quả.

*   **Input:** Query thô từ người dùng (Ví dụ: *"Review trà sữa đất nung Hàng Bồ ngon hết nấc ❤️🥤"*).
*   **Output:** Chuỗi query sạch, đã chuẩn hóa ngôn ngữ viết tắt/từ lóng (Ví dụ: *"trà sữa đất nung Hàng Bồ rất ngon"*).
*   **Detailed Solution:**
    1.  Tạo hàm `normalize_query(query: str) -> str` tại `app/services/normalization.py`.
    2.  Sử dụng Regex để lọc bỏ emoji rác, ký tự đặc biệt, link liên kết ngoài.
    3.  Tạo từ điển ánh xạ từ viết tắt/từ lóng tiếng Việt phổ biến (synonym dictionary):
        *   `khum`, `k` -> `không`
        *   `ly` -> `cốc`
        *   `hết nấc`, `hết nước chấm` -> `rất ngon`
    4.  Sử dụng hàm của `Underthesea` hoặc regex để thay thế các từ lóng này về dạng tiếng Việt chuẩn mực.
*   **Acceptance Criteria:**
    *   [ ] Lọc sạch 100% emojis và liên kết rác khỏi câu query.
    *   [ ] Thay thế chính xác từ viết tắt/từ lóng thông dụng theo từ điển cấu hình.
*   **Technical Notes:**
    *   Từ điển từ lóng cần được viết dưới dạng file cấu hình JSON độc lập bên ngoài để dễ dàng cập nhật mà không cần sửa code.
*   **Dependencies:** Blocks: `DA-AI03-04`.

---

### DA-AI03-04 — Truy vấn tìm kiếm ngữ nghĩa ChromaDB (ChromaDB Semantic Search)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Chuyển đổi query đã chuẩn hóa thành vector embedding, thực hiện tìm kiếm ngữ nghĩa trên ChromaDB để thu về các chunk văn bản tương tự nhất làm Entry Points cho đồ thị.

*   **Input:** Query đã chuẩn hóa [Đầu ra từ `DA-AI03-03.3`].
*   **Output:** Danh sách các thực thể chính (Entry Points) và các đoạn văn bản tương quan ngữ nghĩa cao nhất.
*   **Detailed Solution:**
    1.  Chuyển đổi query thành vector thông qua mô hình embedding `all-MiniLM-L6-v2`.
    2.  Truy vấn ChromaDB sử dụng hàm `collection.query()` với tham số `query_embeddings`.
    3.  Áp dụng bộ lọc metadata `clientId` để đảm bảo không bị lẫn dữ liệu giữa các tenant khác nhau.
    4.  Lấy Top K kết quả tương đồng nhất (mặc định $K = 5$), bóc tách thuộc tính `trendName` trong metadata để làm node Entry Point gửi sang Neo4j.
*   **Acceptance Criteria:**
    *   [ ] Trả về danh sách chunks tương đồng ngữ nghĩa nhanh chóng (latency < 100ms).
    *   [ ] Lọc chính xác theo `clientId` của khách hàng.
    *   [ ] Trích xuất đúng tên các thực thể gốc (Entry Points) phục vụ cho bước duyệt đồ thị.
*   **Technical Notes:**
    *   Cấu hình ngưỡng khoảng cách khoảng cách Cosine tối thiểu để lọc bỏ các kết quả có độ tương quan quá thấp (Ví dụ: `distance < 0.5`).
*   **Dependencies:** Blocked by: `DA-AI03-03.3`, `DA-AI03-03`. Blocks: `DA-AI03-04.1`.

---

### DA-AI03-04.1 — Phát triển thuật toán Duyệt đồ thị tri thức Neo4j (Graph Traversal Service)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Từ danh sách thực thể gốc (Entry Points) lấy ra từ ChromaDB, duyệt đồ thị Neo4j trong phạm vi 1-2 bước nhảy (hops) để thu thập toàn bộ mạng lưới quan hệ thực tế xung quanh xu hướng đó.

*   **Input:** Tên thực thể gốc (Entry Points) từ `DA-AI03-04`.
*   **Output:** Mảng JSON chứa danh sách các Node thực thể và Quan hệ liền kề:
    ```json
    {
      "nodes": [
        {"id": "ninheating", "label": "KOL"},
        {"id": "Hàng Bồ", "label": "Location"}
      ],
      "edges": [
        {"source": "ninheating", "target": "trà sữa đất nung", "relation": "PROMOTED"}
      ]
    }
    ```
*   **Detailed Solution:**
    1.  Tạo module `app/services/graph_traversal.py`.
    2.  Viết câu lệnh truy vấn Cypher duyệt đồ thị cục bộ:
        ```cypher
        MATCH (start {name: $entryPoint})
        MATCH path = (start)-[r*1..2]-(connected)
        RETURN path LIMIT 50
        ```
    3.  Bóc tách dữ liệu từ đối tượng Record của Neo4j, chuẩn hóa thành danh sách Node và Edge sạch.
*   **Acceptance Criteria:**
    *   [ ] Duyệt đồ thị Neo4j chính xác từ node gốc trong phạm vi 1-2 bước nhảy.
    *   [ ] Định dạng output chuẩn cấu trúc JSON Node/Edge phục vụ khâu chấm điểm.
*   **Technical Notes:**
    *   Phải giới hạn `LIMIT` kết quả trong câu Cypher để tránh việc đồ thị quá dày làm bùng nổ số lượng node duyệt gây lag RAM và nghẽn mạng.
*   **Dependencies:** Blocked by: `DA-AI03-04`, `DA-AI03-03.1`, `DA-AI03-03.2`. Blocks: `DA-AI03-04.2`.

---

### DA-AI03-04.2 — Chấm điểm tương quan & Cắt tỉa đồ thị ngữ cảnh (BM25 Scoring & Pruning)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Sử dụng thuật toán BM25 chấm điểm mức độ liên quan của từng node thực thể tìm thấy trong đồ thị đối với câu query của người dùng, lọc bỏ các node rác dưới ngưỡng (Threshold) để tối ưu hóa chiều dài Token gửi LLM.

*   **Input:**
    *   Mảng các node thực thể từ `DA-AI03-04.1`.
    *   Query đã chuẩn hóa của người dùng.
*   **Output:**
    *   Danh sách các node thực thể chất lượng cao nhất đã được tinh giản.
*   **Detailed Solution:**
    1.  Tạo hàm `score_and_prune_context(nodes, query) -> list` tại `app/services/pruning.py`.
    2.  Sử dụng thư viện `rank_bm25` để khởi tạo bộ chấm điểm BM25 dựa trên tập văn bản mô tả của các node.
    3.  Tính điểm tương đồng BM25 của từng node đối với token của câu query.
    4.  Cấu hình ngưỡng cắt tỉa (Ví dụ: `threshold = 1.0`). Lọc bỏ toàn bộ các node có điểm BM25 thấp hơn ngưỡng này.
*   **Acceptance Criteria:**
    *   [ ] Chấm điểm BM25 chuẩn xác cho các node thực thể tiếng Việt.
    *   [ ] Cắt tỉa thành công các thực thể rác (ít tương quan ngữ cảnh).
    *   [ ] Giảm được tối thiểu 30% lượng token rác gửi lên prompt.
*   **Dependencies:** Blocked by: `DA-AI03-04.1`. Blocks: `DA-AI03-05`.

---

### DA-AI03-05 — Xây dựng Bộ sinh Ngữ cảnh GraphRAG (GraphRAG Context Builder)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Đóng gói dữ liệu văn bản tìm kiếm từ ChromaDB và cấu trúc mạng lưới quan hệ từ Neo4j sau khi cắt tỉa thành một chuỗi văn bản (context string) phân cấp sạch sẽ để nạp vào prompt của LLM.

*   **Input:**
    *   Text chunks từ ChromaDB [Đầu ra từ `DA-AI03-04`].
    *   Các node quan hệ sạch từ Neo4j [Đầu ra từ `DA-AI03-04.2`].
*   **Output:**
    *   Chuỗi văn bản (String) context hoàn chỉnh.
    *   *Ví dụ:*
        ```
        [THÔNG TIN THỰC TẾ TRÍCH XUẤT]:
        - Xu hướng: trà sữa đất nung (Rank 1, Score 7.82).
        - KOL quảng bá: ninheating (Nền tảng TikTok, 1.2M views).
        - Địa điểm liên quan: Hàng Bồ (Quận Hoàn Kiếm, Hà Nội).
        [BÀI ĐĂNG THAM KHẢO]:
        "Quán trà sữa đất nung Hàng Bồ nằm tại số 10 Hàng Bồ rất ngon..."
        ```
*   **Detailed Solution:**
    1.  Tạo class `GraphContextBuilder` tại `app/services/context_builder.py`.
    2.  Thiết kế hàm format: Gom các node thực thể cùng loại (KOL, Location, Topic) và viết thành các dòng gạch đầu dòng rõ ràng.
    3.  Ghi rõ quan hệ của chúng dưới dạng mệnh đề ngắn gọn để LLM dễ đọc hiểu.
    4.  Chèn các đoạn văn bản thô tham khảo từ ChromaDB vào cuối chuỗi context.
*   **Acceptance Criteria:**
    *   [ ] Tạo chuỗi context phân cấp, cấu trúc mạch lạc, không bị lỗi định dạng.
    *   [ ] Đảm bảo dữ liệu trích xuất từ ChromaDB và Neo4j ăn khớp logic.
*   **Dependencies:** Blocked by: `DA-AI03-05`. Blocks: `DA-AI04-01`.

---

### DA-AI03-06 — Endpoint xóa dữ liệu tri thức thương hiệu (Document Deletion Endpoint)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟡 High  
**Goal:** Xóa toàn bộ dữ liệu liên quan đến một tài liệu trên cả 3 tầng lưu trữ: file thô trên S3, vector chunks trên ChromaDB và các node/edge tri thức tương ứng trong Neo4j.

*   **Input:**
    *   `documentId` và `clientId`.
*   **Output:**
    *   Trạng thái xóa thành công (`200 OK`).
*   **Detailed Solution:**
    1.  Tạo API `DELETE /ai/rag/documents/{documentId}`.
    2.  Lấy thông tin tài liệu từ DB để xác định `s3Key`. Gọi AWS S3 API xóa file thô.
    3.  Gọi ChromaDB API thực hiện xóa vector chunks:
        `collection.delete(where={"documentId": documentId})`
    4.  Gọi Cypher query trên Neo4j để xóa các quan hệ và node liên quan đến tài liệu (chú ý chỉ xóa các node độc lập, tránh xóa các node dùng chung của client khác):
        ```cypher
        MATCH (n {documentId: $documentId})
        DETACH DELETE n
        ```
*   **Acceptance Criteria:**
    *   [ ] Xóa thành công file thô trên S3.
    *   [ ] Xóa sạch vector chunks tương ứng trong ChromaDB.
    *   [ ] Dọn dẹp sạch các node độc lập liên đới trên Neo4j Graph DB.
*   **Dependencies:** Blocked by: `DA-AI03-03`, `DA-AI03-03.2`.

---

### DA-AI03-07 — Thiết lập bộ kiểm thử đánh giá chất lượng RAG (RAG Accuracy Test)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Viết script kiểm thử độ chính xác của luồng RAG, sử dụng 3 bộ tài liệu thương hiệu thực tế khác nhau để xác minh dữ liệu context trích xuất hoàn toàn khớp thông tin, không bị lẫn lộn hoặc ảo giác.

*   **Input:** 3 tài liệu tri thức mẫu của brand.
*   **Output:** Báo cáo kiểm thử độ chính xác (RAG QA Report) đạt kết quả 100%.
*   **Detailed Solution:**
    1.  Soạn 3 tài liệu mẫu: Một menu quán cafe, một cẩm nang thương hiệu thời trang, một thông báo sự kiện khuyến mại.
    2.  Chạy luồng nạp dữ liệu tri thức (`Ingestion Pipeline`).
    3.  Thực hiện 15 câu query test khác nhau truy vấn vào hệ thống.
    4.  Viết code tự động so sánh kết quả trả về từ `GraphRAG Context Builder` với file text gốc để kiểm chứng sự trùng khớp thông tin bằng phép so sánh ký tự hoặc so sánh độ tương quan ngữ nghĩa (Semantic Similarity > 0.85).
*   **Acceptance Criteria:**
    *   [ ] 100% các câu hỏi kiểm tra đều lấy ra đúng context tương ứng trong tài liệu gốc.
    *   [ ] Không xảy ra lỗi trích xuất nhầm lẫn dữ liệu giữa các client.
    *   [ ] Lưu trữ báo cáo kiểm thử thành công vào thư mục `tests/reports`.
*   **Dependencies:** Blocked by: `DA-AI03-05`. Blocks: `DA-AI04-01` (Đây là chốt chặn chất lượng quan trọng trước khi tích hợp LLM).

---

### DA-AI03-08 — Biên soạn Tài liệu Kỹ thuật RAG Pipeline (RAG Architecture Documentation)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟢 Medium  
**Goal:** Viết tài liệu mô tả chi tiết kiến trúc hệ thống RAG, hướng dẫn cấu hình tham số (chunk size, overlap, thresholds) và phương pháp đánh giá chất lượng hệ thống cho các kỹ sư bảo trì sau này.

*   **Acceptance Criteria:**
    *   [ ] Tạo file tài liệu `docs/ai/rag_pipeline_architecture.md`.
    *   [ ] Vẽ sơ đồ chi tiết luồng Ingestion và Retrieval (bằng Mermaid).
    *   [ ] Giải thích chi tiết các chỉ số cấu hình và thuật toán (Chroma HNSW, Neo4j GDS, BM25 Pruning).

---

### DA-AI03-09 — Xây dựng tiến trình chạy ngầm dọn dẹp và gộp thực thể trùng lặp (Entity Resolution Cronjob)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟡 High  
**Goal:** Tạo một background worker/cronjob chạy định kỳ (mỗi 12 tiếng) thực hiện quét đồ thị Neo4j, phát hiện và gộp (merge) các node thực thể có cùng ý nghĩa ngữ nghĩa nhưng viết khác nhau để tránh làm loãng đồ thị tri thức.

*   **Input:** Đồ thị tri thức hiện tại trong Neo4j.
*   **Output:** Đồ thị đã được dọn sạch, các node trùng lặp được gộp thành một.
*   **Detailed Solution:**
    1.  Sử dụng thư viện `APScheduler` để đăng ký cronjob chạy mỗi 12 tiếng.
    2.  Quá trình xử lý gộp thực thể (Entity Resolution):
        *   Quét danh sách các node cùng loại (Ví dụ: node `:Location`).
        *   Sử dụng mô hình embedding tính khoảng cách cosine giữa tên các node.
        *   Nếu khoảng cách nhỏ hơn ngưỡng (Ví dụ: `distance < 0.15` như `"HN"` và `"Hà Nội"`, `"Trấn Thành"` và `"MC Trấn Thành"`), kích hoạt lệnh Cypher gộp node:
            ```cypher
            MATCH (n1:Entity {name: $name1}), (n2:Entity {name: $name2})
            CALL apoc.refactor.mergeNodes([n1, n2]) YIELD node
            RETURN node
            ```
*   **Acceptance Criteria:**
    *   [ ] Cấu hình cronjob chạy ngầm bằng `APScheduler` hoạt động ổn định không gây blocking event loop.
    *   [ ] Gộp thành công các node trùng lặp ngữ nghĩa trên đồ thị Neo4j mà không làm mất các cạnh quan hệ chéo.
*   **Technical Notes:**
    *   Cần sử dụng thư viện APOC của Neo4j để chạy lệnh `mergeNodes` tối ưu và an toàn.
*   **Dependencies:** Blocked by: `DA-AI03-03.1`, `DA-AI03-03.2`.

---

## III. Phân Rã Chi Tiết Nhiệm Vụ Epic AI-04 (LLM Content Generation)

*(Phần này kế thừa và làm chi tiết hóa sâu hơn tài liệu AI-04 trước đó để đảm bảo tính đồng bộ hoàn toàn với Epic AI-03)*

### DA-AI04-01 — Thiết kế Prompt Template System & Thang chấm điểm "Hook strength" 3s đầu tiên
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Thiết kế hệ thống sinh prompt động kết hợp các mảnh dữ liệu đầu vào (topic, context từ GraphRAG, dữ liệu xu hướng hot, tone giọng điệu yêu cầu) thành một prompt tối ưu duy nhất gửi đến LLM, đồng thời tích hợp các chỉ dẫn bắt buộc để LLM tối ưu cấu trúc giữ chân người dùng trong 3 giây đầu tiên (Hook 3s).

*   **Input:**
    *   Query/Topic thô từ người dùng (Ví dụ: `"Viết bài giới thiệu món trà sữa nướng đất nung Hàng Bồ"`).
    *   Context sạch đã được định dạng phân cấp từ GraphRAG Context Builder [Đầu ra của `DA-AI03-05`].
    *   Thông tin trend đính kèm (Nền tảng, Virality Score, từ khóa liên quan).
    *   Brand Tone Guide (Ví dụ: `Hài hước`, `Giật gân/Tò mò`, `Sang trọng/Premium`).
*   **Output:**
    *   Bản prompt hoàn chỉnh dạng text chứa đầy đủ cấu trúc chỉ dẫn và dữ liệu nạp.
*   **Detailed Solution:**
    1.  Tạo class `PromptBuilder` tại thư mục `app/services/prompt_builder.py`.
    2.  Sử dụng công cụ template Jinja2 để quản lý các mẫu prompt hệ thống nhằm dễ dàng bảo trì và cập nhật.
    3.  Xây dựng danh mục các công thức Hook 3s đầu tiên tích hợp sẵn trong prompt:
        *   *Công thức Tò mò (Curiosity Hook):* Tạo câu hỏi bỏ ngỏ hoặc một bí mật chưa bật mí (Ví dụ: *"Đừng mua trà sữa đất nung Hàng Bồ nếu bạn chưa biết điều này..."*).
        *   *Công thức Trực diện (Direct Benefit Hook):* Đưa ngay kết quả hoặc lợi ích nổi bật lên dòng đầu tiên.
        *   *Công thức FOMO (Nỗi sợ bỏ lỡ):* Nhấn mạnh tính giới hạn hoặc trào lưu đang diễn ra.
    4.  Anti-Hallucination Layer: Cài đặt các quy tắc logic cứng trong system prompt yêu cầu mô hình từ chối hoặc chỉ sử dụng thông tin trong Block `[CONTEXT]`.
*   **Acceptance Criteria:**
    *   [ ] Xây dựng class `PromptBuilder` hỗ trợ nạp động RAG context, trend data, tone, topic của người dùng.
    *   [ ] Thiết kế system prompt nghiêm ngặt, hướng dẫn LLM phân tách bài viết thành 3 phần rõ rệt: `[HOOK_3S]`, `[BODY]`, `[CALL_TO_ACTION]`.
    *   [ ] Tạo ít nhất 3 bộ template prompt khác nhau tương ứng với 3 công thức viết Hook 3s đầu tiên.
    *   [ ] Kiểm thử việc render prompt động thông qua unit test độc lập mà không cần kết nối API.
*   **Technical Notes:**
    *   Đảm bảo prompt được thiết kế tối ưu về số lượng token. Phải đếm thử chiều dài ký tự để tránh việc prompt bị cắt cụt do vượt quá giới hạn ngữ cảnh của LLM.
*   **Dependencies:** Blocked by: `DA-AI03-05`. Blocks: `DA-AI04-02`, `DA-AI04-03`.

---

### DA-AI04-02 — Tích hợp Llama 3 qua Groq API & Ràng buộc System Prompt chống ảo giác
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Phát triển module kết nối tới dịch vụ Groq Cloud API, gửi prompt đã sinh từ `DA-AI04-01` lên mô hình Llama 3 (mục tiêu: `llama-3.1-70b-versatile`), cấu hình tham số nhiệt độ thấp nhằm giảm thiểu tối đa hiện tượng ảo giác thông tin, nhận kết quả và thực hiện parse output.

*   **Input:**
    *   Chuỗi prompt hoàn chỉnh được sinh ra từ `DA-AI04-01`.
*   **Output:**
    *   JSON chứa nội dung bài viết được phân mảnh chi tiết:
        ```json
        {
          "hook_3s": "😱 Mùa đông Hà Nội lạnh căm căm thế này mà bạn vẫn chưa biết trend Trà sữa đất nung Hàng Bồ của @ninheating à?",
          "body": "Không cần phải chen chúc lên phố cổ chờ đợi, hôm nay TeaHouse chính thức ra mắt dòng Trà Sữa Đất Nung Nướng nóng hổi vị ngọt thanh thanh, béo ngậy vị sữa chuẩn vị phố cổ...",
          "cta": "Ghé ngay chi nhánh TeaHouse gần nhất để thưởng thức phiên bản trà sữa đất nung nướng nóng hổi đang làm xiêu lòng hàng triệu food reviewer!",
          "usage": { "prompt_tokens": 1250, "completion_tokens": 320, "total_tokens": 1570 }
        }
        ```
*   **Detailed Solution:**
    1.  Tạo class `GroqClient` trong file `app/core/llm/groq_client.py`.
    2.  Sử dụng model: `llama-3.1-70b-versatile` để đảm bảo khả năng lập luận tốt nhất.
    3.  Cài đặt `temperature = 0.2` hoặc `0.3` (mức nhiệt độ thấp giúp mô hình tuân thủ chặt chẽ ngữ cảnh và giảm độ sáng tạo tự do dẫn đến ảo giác).
    4.  Đặt `response_format = {"type": "json_object"}` để ép LLM trả về đúng định dạng JSON có cấu trúc nhằm phân tách rõ ràng Hook, Body, CTA.
    5.  Quản lý Rate limit: Triển khai cơ chế retry tự động sử dụng thư viện `tenacity` với chiến lược exponential backoff khi gặp mã lỗi HTTP 429 (Too Many Requests).
*   **Acceptance Criteria:**
    *   [ ] Kết nối thành công đến Groq API qua API Key lưu trong biến môi trường `.env`.
    *   [ ] Thực hiện cấu hình tham số chống ảo giác thành công (`temperature` thấp, system prompt nghiêm ngặt).
    *   [ ] Nhận response, xử lý đếm token và chuyển đổi dữ liệu thô từ LLM thành JSON có cấu trúc.
    *   [ ] Triển khai thành công cơ chế retry tự động tối đa 3 lần nếu gặp lỗi rate limit trước khi trả về lỗi cho tầng Router.
*   **Technical Notes:**
    *   Việc ép định dạng JSON từ Llama 3 Groq đòi hỏi schema yêu cầu phải được mô tả cực kỳ rõ ràng trong system prompt để tránh hiện tượng mô hình trả về chuỗi JSON lỗi cấu trúc.
*   **Dependencies:** Blocked by: `DA-AI04-01`. Blocks: `DA-AI04-03` (fallback logic), `DA-AI04-07`.

---

### DA-AI04-03 — Tích hợp Claude API (Anthropic) làm kênh dự phòng Fallback tự động
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Tích hợp SDK Anthropic Claude làm LLM Client dự phòng (mô hình đề xuất: `claude-3-5-sonnet` hoặc `claude-3-haiku`) và xây dựng bộ định tuyến (Router) tự động chuyển hướng yêu cầu sinh nội dung từ Groq sang Claude khi Groq gặp sự cố (Rate Limit, Network Error, Timeout).

*   **Input:**
    *   Chuỗi prompt hoàn chỉnh từ `DA-AI04-01`.
    *   Lỗi ngoại lệ (Exception) bắt được từ layer `DA-AI04-02`.
*   **Output:**
    *   JSON chứa nội dung bài viết tương tự chuẩn output của `DA-AI04-02`.
*   **Detailed Solution:**
    1.  Tạo class `ClaudeClient` tại `app/core/llm/claude_client.py`.
    2.  Xây dựng class điều phối `LLMService` đóng vai trò trung gian điều phối:
        ```python
        class LLMService:
            async def generate_content(self, prompt: str) -> dict:
                try:
                    # Thử gọi Llama 3 qua Groq trước
                    return await self.groq_client.generate(prompt)
                except (GroqRateLimitError, GroqConnectionError, TimeoutError) as e:
                    # Log lỗi cảnh báo Groq bị lỗi
                    logger.warning(f"Groq API failed: {str(e)}. Switching to Claude Fallback.")
                    # Kích hoạt fallback gọi sang Claude API
                    return await self.claude_client.generate(prompt)
        ```
    3.  Đồng nhất Output: Thiết lập system prompt bên phía Claude để đảm bảo phản hồi trả về có cấu trúc JSON giống hệt với output của Llama 3.
*   **Acceptance Criteria:**
    *   [ ] Kết nối thành công đến Anthropic API thông qua API Key lưu trong `.env`.
    *   [ ] Viết thành công class điều phối `LLMService` thực hiện cơ chế bắt lỗi và switch kênh thông minh.
    *   [ ] Đảm bảo định dạng JSON trả về từ Claude tương thích 100% với hệ thống xử lý sau (Post-processing) của Lộc.
    *   [ ] Viết script test mock giả lập lỗi của Groq (ví dụ: tắt mạng hoặc truyền key sai) để xác minh hệ thống tự động nhảy sang Claude mà người dùng không gặp gián đoạn.
*   **Technical Notes:**
    *   Timeout cho Groq Client nên được thiết lập ngắn (khoảng 5 đến 7 giây) để tránh việc người dùng phải đợi quá lâu trước khi hệ thống chuyển hướng sang kênh Claude dự phòng.
*   **Dependencies:** Blocked by: `DA-AI04-02`. Blocks: `DA-AI04-07`.

---

### DA-AI04-04 — Xây dựng bộ tối ưu hóa độ dài bài viết theo quy định của từng nền tảng (Platform Length Optimizer)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟡 High  
**Goal:** Phát triển tầng hậu xử lý (Post-processing) tự động kiểm tra, đo đếm ký tự và điều chỉnh độ dài bài viết sau khi sinh nhằm đảm bảo không vi phạm giới hạn ký tự của các mạng xã hội phổ biến (Facebook, Threads, TikTok, Instagram).

*   **Input:**
    *   Dữ liệu JSON chứa nội dung bài viết (Hook, Body, CTA) từ `DA-AI04-02` hoặc `DA-AI04-03`.
    *   Nền tảng mục tiêu người dùng lựa chọn: `facebook`, `threads`, `tiktok`, `instagram`.
*   **Output:**
    *   Nội dung văn bản đã được tối ưu hóa độ dài, cắt tỉa thông minh nếu cần thiết để đảm bảo vừa khít giới hạn của nền tảng mà không làm cụt câu.
*   **Detailed Solution:**
    1.  **Thiết lập giới hạn (Rules Engine):**
        - **Facebook:** Giới hạn kỹ thuật là 63,206 ký tự (nhưng thiết lập ngưỡng tối ưu hóa hiển thị trong khoảng 1000 - 1500 ký tự).
        - **TikTok:** Giới hạn 4,000 ký tự.
        - **Threads:** Giới hạn nghiêm ngặt 500 ký tự.
        - **Instagram:** Giới hạn 2,200 ký tự.
    2.  **Thuật toán cắt tỉa thông minh (Smart Truncation):**
        - Nếu tổng số ký tự (Hook + Body + CTA + Hashtags) vượt quá giới hạn:
          - Giữ nguyên vẹn 100% phần `hook_3s` và `cta`.
          - Tính toán số lượng ký tự thừa và thực hiện cắt tỉa phần `body`.
          - Tìm dấu chấm câu (`.`, `!`, `?`) gần nhất trước điểm giới hạn để cắt, tránh việc văn bản bị ngắt nửa chừng giữa từ hoặc giữa câu.
    3.  **Cơ chế nén bằng LLM (Auto-Summarize):**
        - Đối với các nền tảng có giới hạn siêu ngắn như **Threads (500 ký tự)**, nếu nội dung sinh ra quá dài, hệ thống sẽ thực hiện một cuộc gọi nhanh (sub-request) sang mô hình Claude-Haiku yêu cầu tóm tắt cô đọng phần body mà vẫn giữ được thông tin đắt giá nhất.
*   **Acceptance Criteria:**
    *   [ ] Viết hàm helper đo đếm độ dài ký tự tiếng Việt UTF-8 chính xác.
    *   [ ] Triển khai thuật toán cắt tỉa thông minh theo dấu chấm câu để bài viết không bị cụt lủn.
    *   [ ] Tích hợp luồng auto-summarize bằng LLM khi bài viết đăng lên Threads vượt quá 500 ký tự.
    *   [ ] Trả về cảnh báo (warning metadata) cho client nếu hệ thống buộc phải cắt bớt văn bản.
*   **Technical Notes:**
    *   Phải tính toán gộp cả độ dài của danh sách hashtag sẽ được chèn vào cuối bài viết để đảm bảo tổng số ký tự cuối cùng gửi lên mạng xã hội không bị lỗi.
*   **Dependencies:** Blocked by: `DA-AI04-02`, `DA-AI04-03`. Blocks: `DA-AI04-07`.

---

### DA-AI04-05 — Phát triển Endpoint tự động sinh Hashtags bắt trend và Hashtags thương hiệu
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟡 High  
**Goal:** Phát triển endpoint API `/ai/generate/hashtags` nhận văn bản bài viết, phân tích ngữ nghĩa và trích xuất danh sách 5-10 hashtags tối ưu nhất. Hashtags bao gồm: hashtags xu hướng đang thịnh hành trong database, hashtags nội dung bài viết và hashtags đặc trưng thương hiệu.

*   **Input:**
    *   Chuỗi văn bản bài viết đã được sinh.
    *   Brand Name (Ví dụ: `TeaHouse`).
    *   Trend Name liên kết (Ví dụ: `trà sữa đất nung` - lấy từ context).
*   **Output:**
    *   Mảng JSON chứa danh sách các hashtag đã được chuẩn hóa.
*   **Detailed Solution:**
    1.  Tạo endpoint `POST /ai/generate/hashtags` bằng FastAPI.
    2.  Hệ thống Prompt Hashtag: Viết một prompt hệ thống ngắn gửi sang LLM Llama-8b yêu cầu: *"Phân tích đoạn văn sau và trích xuất ra 5 từ khóa chính viết liền không dấu, không chứa ký tự đặc biệt để làm hashtag."*
    3.  Xử lý Regex & Ghép nối:
        - Viết hàm chuẩn hóa ký tự tiếng Việt sang không dấu, loại bỏ dấu cách, loại bỏ các ký tự đặc biệt (Ví dụ: *"trà sữa nướng"* -> `trasuanuong`).
        - Tự động ghép thêm dấu `#` vào đầu mỗi từ khóa.
        - Đính kèm thêm các hashtag thương hiệu cố định (nếu có trong cấu hình brand) và hashtag xu hướng lấy ra từ Redis/Neo4j.
*   **Acceptance Criteria:**
    *   [ ] Endpoint `/ai/generate/hashtags` hoạt động ổn định, phản hồi dưới 200ms.
    *   [ ] Chuẩn hóa thành công các cụm từ tiếng Việt có dấu thành chuỗi hashtag không dấu, viết liền.
    *   [ ] Kết quả trả ra chứa đủ 3 nhóm: Hashtag thương hiệu, hashtag nội dung bài viết, và hashtag xu hướng của hệ thống.
    *   [ ] Lọc bỏ hoàn toàn các hashtag trùng lặp trong mảng đầu ra.
*   **Technical Notes:**
    *   Để giảm độ trễ (latency), tác vụ sinh hashtag có thể sử dụng mô hình nhỏ Llama 3 8B trên Groq hoặc thậm chí sử dụng thuật toán NLP trích xuất từ khóa đơn giản (như TF-IDF hoặc RAKE) chạy trực tiếp trên server backend mà không cần gọi LLM ngoài.
*   **Dependencies:** Blocked by: `DA-AI04-02`, `DA-AI04-03`. Blocks: `DA-AI04-07`.

---

### DA-AI04-06 — Xây dựng Endpoint Chỉnh sửa và Cải thiện bài viết dựa trên Feedback (Feedback Iteration Loop)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟡 High  
**Goal:** Phát triển tính năng cho phép người dùng nhập ý kiến phản hồi (ví dụ: *"viết ngắn lại"*, *"thêm nhiều emoji hơn"*, *"nhấn mạnh vào yếu tố vệ sinh an toàn thực phẩm"*) đối với một bài viết cũ để hệ thống tinh chỉnh và sinh ra phiên bản mới tối ưu hơn.

*   **Input:**
    *   Bài viết gốc đã được sinh ra trước đó (Original Post).
    *   Phản hồi bằng tiếng Việt từ phía người dùng (User Feedback).
    *   Context RAG ban đầu (để đảm bảo không bị ảo giác khi viết lại).
*   **Output:**
    *   Bài viết phiên bản mới đã được cập nhật theo ý kiến phản hồi nhưng vẫn bảo tồn cấu trúc 3 phần.
*   **Detailed Solution:**
    1.  Xây dựng endpoint `POST /ai/generate/refine` trong FastAPI.
    2.  Xây dựng Refining Prompt Template:
        ```markdown
        Bạn là trợ lý AI biên tập nội dung. Dưới đây là bài viết gốc:
        ---
        {original_post}
        ---
        Khách hàng phản hồi như sau: "{user_feedback}".
        Hãy viết lại bài viết trên để đáp ứng phản hồi của khách hàng.
        
        Lưu ý nghiêm ngặt:
        1. Chỉ sử dụng thông tin thực tế trong ngữ cảnh ban đầu: {rag_context}. KHÔNG tự ý bịa đặt.
        2. Giữ nguyên định dạng đầu ra gồm các thẻ [HOOK_3S], [BODY], [CALL_TO_ACTION].
        ```
    3.  Cấu hình tham số: Cài đặt `temperature = 0.4` (cao hơn một chút so với sinh gốc để mô hình có đủ không gian điều chỉnh văn phong theo phản hồi).
*   **Acceptance Criteria:**
    *   [ ] Thiết kế endpoint nhận request thành công và trả về bài viết đã được cập nhật.
    *   [ ] Viết prompt refining đảm bảo LLM chỉnh sửa đúng trọng tâm feedback mà không làm mất đi các dữ liệu thực tế trong RAG context.
    *   [ ] Triển khai cơ chế lưu vết lịch sử phiên bản (Version History) để người dùng có thể quay lại các bản nháp trước đó nếu muốn.
*   **Technical Notes:**
    *   Cần phòng chống tấn công injection qua trường feedback của người dùng. Tiến hành validate đầu vào, giới hạn độ dài của chuỗi feedback gửi lên tối đa 300 ký tự.
*   **Dependencies:** Blocked by: `DA-AI04-01`, `DA-AI04-02`. Blocks: `DA-AI04-07`.

---

### DA-AI04-07 — Thiết lập bộ kịch bản kiểm thử tự động & thủ công chống ảo giác (Anti-Hallucination QA Gate)
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🔴 Critical  
**Goal:** Thiết lập chốt chặn chất lượng (Quality Gate) bắt buộc trước khi deploy. Tạo ra bộ 20 kịch bản kiểm thử thực tế và kiểm tra xem các bài viết sinh ra có hoàn toàn trung thực với tài liệu tri thức (RAG Context) hay không, tuyệt đối không được có lỗi tự bịa thông tin (zero hallucination).

*   **Input:**
    *   20 kịch bản kiểm thử (Test Cases) được định nghĩa sẵn bao gồm:
      - Query của user.
      - Tài liệu RAG Context chuẩn (chứa các thông tin đúng sự thật).
      - Tệp output sinh ra từ pipeline của Llama 3 và Claude.
*   **Output:**
    *   Báo cáo chất lượng `hallucination_test_report.json` với điểm Factuality đạt 100% (20/20 kịch bản vượt qua kiểm thử).
*   **Detailed Solution:**
    1.  Biên soạn 20 kịch bản kiểm thử bao gồm các thông tin dễ gây ảo giác cho LLM như: địa chỉ quán ăn, tên KOL review, thông số giá cả, đặc sản vùng miền.
    2.  Kiểm thử tự động (LLM-as-a-judge):
        - Viết một script Python chạy tự động. Script này gửi bài viết đã sinh cùng với tài liệu RAG Context gốc lên mô hình `claude-3-5-sonnet`.
        - Sử dụng prompt đánh giá logic học: *"Hãy phân tích từng câu khẳng định trong bài viết. Đối chiếu với RAG Context và xác định xem khẳng định đó là Đúng (True) hay Sai/Không có căn cứ (False). Trả về định dạng JSON: { 'factuality_score': float, 'failed_statements': list }."*
    3.  Kiểm thử thủ công (Manual Review): Tổ chức một buổi họp rà soát chung cả nhóm để duyệt thủ công 20 bài viết mẫu, đánh giá độ tự nhiên của Hook 3s đầu và độ khớp thông tin.
*   **Acceptance Criteria:**
    *   [ ] Xây dựng hoàn chỉnh bộ dữ liệu 20 kịch bản test case mẫu.
    *   [ ] Phát triển thành công script Python chạy tự động chấm điểm độ trung thực của bài viết (LLM-as-a-judge).
    *   [ ] Đạt tỷ lệ chính xác 100% trên cả 20 test case (Không phát hiện bất kỳ thông tin nào ngoài RAG context).
    *   [ ] Báo cáo kiểm thử được ghi nhận và lưu trữ trong thư mục dự án.
*   **Technical Notes:**
    *   Đây là **cửa chặn chất lượng bắt buộc (Blocking Quality Gate)**. Nếu có bất kỳ test case nào thất bại, nhiệm vụ phát triển prompt (`DA-AI04-01`) buộc phải mở lại để tinh chỉnh và kiểm thử lại từ đầu.
*   **Dependencies:** Blocked by: `DA-AI04-01`, `DA-AI04-02`, `DA-AI04-03`, `DA-AI04-04`, `DA-AI04-05`, `DA-AI04-06`. Blocks: Deploy hệ thống.

---

### DA-AI04-08 — Biên soạn Tài liệu Kỹ thuật Prompt Engineering & Hướng dẫn Bảo trì Prompt
**Assignee:** *Sẽ phân bổ sau* | **Priority:** 🟢 Medium  
**Goal:** Viết tài liệu kỹ thuật hướng dẫn chi tiết về cấu trúc Prompt Engineering trong dự án, bao gồm cấu trúc template prompt hệ thống, danh sách các công thức Hook 3s đang chạy, cấu hình tone guide và các kịch bản đối phó với lỗi ảo giác nhằm phục vụ cho việc bảo trì hệ thống lâu dài.

*   **Acceptance Criteria:**
    *   [ ] Biên soạn thành công tài liệu `docs/ai/prompt_engineering_guide.md`.
    *   [ ] Giải thích rõ ràng cấu trúc prompt hệ thống của Groq và Claude API.
    *   [ ] Tài liệu hóa cách cấu hình và thêm mới các platform, giọng điệu tone guide hoặc công thức hook mới vào hệ sinh thái.
    *   [ ] Tài liệu được review và phê duyệt bởi các thành viên trong đội phát triển AI.
*   **Dependencies:** Blocked by: `DA-AI04-07`.

---

## IV. Bản Đồ Phụ Thuộc Đồng Bộ (Dependency Map) & Trình Tự Thực Thi

```
[INGESTION PIPELINE]
DA-AI03-01 (Upload Doc) ➔ DA-AI03-02 (Chunking) ➔ DA-AI03-03 (Chroma Embedding)
                                       │
                                       ▼ (Neo4j Graph setup)
                                 DA-AI03-03.1 (Neo4j Pool) ➔ DA-AI03-03.2 (NER Graph Ingestion)
                                                                            │
                                                                            ▼
                                                                     DA-AI03-09 (Resolution Cron)

[GENERATION PIPELINE]
DA-AI03-03.3 (Query Normalization) ➔ DA-AI03-04 (Chroma Search) ➔ DA-AI03-04.1 (Neo4j Traversal)
                                                                            │
                                                                            ▼
                                                                     DA-AI03-04.2 (Pruning)
                                                                            │
                                                                            ▼
                                                                     DA-AI03-05 (Context Builder)
                                                                            │
                                                                            ▼
                                                                     DA-AI03-07 (RAG QA Gate)
                                                                            │
                                                                            ▼
                                                                     DA-AI04-01 (Prompt System)
                                                                            │
                                                                 ┌──────────┴──────────┐
                                                                 ▼                     ▼
                                                             DA-AI04-02 (Groq)    DA-AI04-03 (Claude)
                                                                 │                     │
                                                                 └──────────┬──────────┘
                                                                            ▼
                                                                     DA-AI04-04 (Length Optimizer)
                                                                     DA-AI04-05 (Hashtags API)
                                                                     DA-AI04-06 (Feedback Loop)
                                                                            │
                                                                            ▼
                                                                     DA-AI04-07 (Hallucination Test)
                                                                            │
                                                                            ▼
                                                                     DA-AI04-08 (Documentation)
```
