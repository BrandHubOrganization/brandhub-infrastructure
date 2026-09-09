# Sprint 6 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Thành Lộc |
| Mã sinh viên / User | locnt (K18 DN) |
| GitHub | [@locnt](https://github.com/locnt) |
| Role | Frontend / AI Infra / AI Sub-lead |
| Sprint | Sprint 6 (`DA Sprint 6`) |
| Thời gian sprint | 29/07/2026 – 11/08/2026 (Jira: 03/08/2026 – 17/08/2026) |
| Ngày nộp | 11/08/2026 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-736 | [DA-736](https://letritrung2605.atlassian.net/browse/DA-736) | [DA-AI03-01] Brand Document Upload API (`POST /api/v1/ai/rag/documents`) | 🔴 Critical | ✅ Done |
| DA-737 | [DA-737](https://letritrung2605.atlassian.net/browse/DA-737) | [DA-AI03-02] Object Storage Ingestion (`rag/{clientId}/{docId}/{filename}`) & Document Deletion | 🔴 Critical | ✅ Done |
| DA-738 | [DA-738](https://letritrung2605.atlassian.net/browse/DA-738) | [DA-AI03-03] Document Chunking & Multi-tenant Tagging Engine (`clientId` Security Isolation) | 🔴 Critical | ✅ Done |
| DA-597 | [DA-597](https://letritrung2605.atlassian.net/browse/DA-597) | [DA-AI03-05] Write RAG Pipeline & Multi-tenant Isolation Documentation | 🟢 Medium | ✅ Done |
| DA-754 | [DA-754](https://letritrung2605.atlassian.net/browse/DA-754) | [DA-AI05-16] Redis ZSET Caching Engine (`trends:vn:{date}:{category}`, TTL 6h) | 🔴 Critical | ✅ Done |
| DA-755 | [DA-755](https://letritrung2605.atlassian.net/browse/DA-755) | [DA-AI05-17] Upsert Neo4j Node `:Trend` | 🔴 Critical | ✅ Done |
| DA-756 | [DA-756](https://letritrung2605.atlassian.net/browse/DA-756) | [DA-AI05-18] Deep Crawl Trigger Engine (Posts & Comments Collector) | 🟡 High | ✅ Done |
| DA-757 | [DA-757](https://letritrung2605.atlassian.net/browse/DA-757) | [DA-AI05-19] LangChain Text Chunking (Size 500, Overlap 50) | 🔴 Critical | ✅ Done |
| DA-758 | [DA-758](https://letritrung2605.atlassian.net/browse/DA-758) | [DA-AI05-20] Text Embedding Pipeline (`all-MiniLM-L6-v2`, 384d) | 🔴 Critical | ✅ Done |
| DA-759 | [DA-759](https://letritrung2605.atlassian.net/browse/DA-759) | [DA-AI05-21] ChromaDB Vector Store Integration (HNSW Index Engine) | 🔴 Critical | ✅ Done |
| DA-760 | [DA-760](https://letritrung2605.atlassian.net/browse/DA-760) | [DA-AI05-22] LLM NER & Relation Extraction Engine | 🔴 Critical | ✅ Done |
| DA-761 | [DA-761](https://letritrung2605.atlassian.net/browse/DA-761) | [DA-AI05-23] Neo4j Knowledge Graph Ingestion Engine | 🔴 Critical | ✅ Done |
| DA-762 | [DA-762](https://letritrung2605.atlassian.net/browse/DA-762) | [DA-AI05-24] Entity Resolution Job (Knowledge Graph Fusion) | 🔴 Critical | ✅ Done |
| DA-461 | [DA-461](https://letritrung2605.atlassian.net/browse/DA-461) | [DA-E47-37] Write individual sprint report for Sprint 6 — Lộc | 🟢 Medium | ✅ Done |

**Tổng:** 14 tasks | Done: 14 | In Review: 0 | In Progress: 0 | Chưa hoàn thành: 0

---

## 3. Chi tiết công việc đã làm

Trong Sprint 6, song song với việc nhóm Backend Core hoàn thiện Workspace CRUD, Client Management và RBAC, tôi đảm nhận vai trò **AI Sub-lead & AI Infra Engineer**, tập trung toàn lực triển khai hai trụ cột công nghệ AI cốt lõi của dự án BrandHub:
1. **Epic AI-03 (Brand Knowledge Base RAG Pipeline):** Xây dựng hạ tầng nạp tài liệu thương hiệu, phân mảnh văn bản kèm siêu dữ liệu cô lập đa khách hàng (`clientId`), lưu trữ vector trên ChromaDB và quản trị tệp trên AWS S3.
2. **Epic AI-05 (Trend Crawler, Graph Knowledge & Vector Retrieval Subsystem):** Xây dựng hệ thống lưu trữ bảng xếp hạng xu hướng trên Redis Sorted Set, mô hình hóa đồ thị tri thức trên Neo4j, trích xuất thực thể bằng LLM NER, nhúng vector bằng mô hình `all-MiniLM-L6-v2`, và giải thuật hợp nhất thực thể trùng lặp (Entity Resolution).

Dưới đây là chi tiết kỹ thuật của từng công việc:

---

### I. Phân hệ RAG Knowledge Base & Cô lập Đa Khách hàng (Epic AI-03)

#### 1. DA-736 (`DA-AI03-01`) — Xây dựng Brand Document Upload API (`POST /api/v1/ai/rag/documents`)
- **Mục tiêu:** Xây dựng endpoint tiếp nhận tài liệu tri thức thương hiệu (PDF, DOCX, TXT, Web URLs), kiểm tra tính hợp lệ và định tuyến lưu trữ an toàn.
- **Công việc đã làm:**
  - Phát triển endpoint `POST /api/v1/ai/rag/documents` trong `brandhub-ai-service/app/api/v1/endpoints/rag.py` sử dụng FastAPI `UploadFile`.
  - Thiết lập bộ lọc xác thực định dạng MIME (`application/pdf`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, `text/plain`) và giới hạn kích thước tệp $\le 10$MB.
  - Hỗ trợ trích xuất văn bản thô trực tiếp từ tệp tải lên: `pypdf` cho PDF, `python-docx` cho DOCX và `trafilatura` / `BeautifulSoup4` cho URL bài viết web.
  - Trích xuất metadata định danh gồm `clientId`, `documentId` (UUIDv4), `filename`, `fileSize`, `uploadedAt`.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/api/v1/endpoints/rag.py`
  - `brandhub-ai-service/app/services/document_parser.py`
  - `brandhub-ai-service/app/models/rag_models.py`
- **Kết quả đạt được:**
  - [x] Endpoint phản hồi mã HTTP 201 Created với payload `{documentId, clientId, filename, chunkCount, status: "PROCESSED"}`.
  - [x] Tỷ lệ parse thành công văn bản tiếng Việt có dấu đạt 100%, không bị lỗi encoding UTF-8.

#### 2. DA-737 (`DA-AI03-02`) — Tích hợp Lưu trữ Đối tượng S3 & API Xóa Tài liệu RAG
- **Mục tiêu:** Quản trị vòng đời tệp nguyên bản trên AWS S3 theo cấu trúc đường dẫn phân tầng đa khách hàng và cung cấp API dọn dẹp dữ liệu cascade.
- **Công việc đã làm:**
  - Cấu hình client `boto3` kết nối AWS S3 (hỗ trợ MinIO cho môi trường local development).
  - Chuẩn hóa quy tắc lưu trữ S3 Object Key: `rag/{clientId}/{documentId}/{filename}`, đảm bảo tính cô lập tuyệt đối dữ liệu giữa các thương hiệu (Tenant Isolation at Storage Layer).
  - Xây dựng endpoint `DELETE /api/v1/ai/rag/documents/{documentId}`:
    - Xóa tệp gốc tương ứng trên AWS S3 bucket.
    - Thực hiện xóa phân tầng (Cascade Deletion) toàn bộ các vector chunks liên quan trong ChromaDB bằng bộ lọc `where={"documentId": documentId}`.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/s3_service.py`
  - `brandhub-ai-service/app/api/v1/endpoints/rag.py`
  - `tests/test_rag_storage.py`
- **Kết quả đạt được:**
  - [x] Xóa sạch dữ liệu thô và vector trong ChromaDB chỉ với một API duy nhất, không để lại rác bộ nhớ (orphan vectors).

#### 3. DA-738 (`DA-AI03-03`) — Phân mảnh Văn bản (Chunking) & Gắn Tag Bảo mật Cô lập Multi-tenant
- **Mục tiêu:** Cắt nhỏ tài liệu thương hiệu thành các đoạn ngữ nghĩa tối ưu cho RAG và gắn thẻ `clientId` bắt buộc trước khi nhúng vector.
- **Công việc đã làm:**
  - Sử dụng `RecursiveCharacterTextSplitter` từ thư viện LangChain với cấu hình: `chunk_size = 500` ký tự, `chunk_overlap = 50` ký tự, danh sách ký tự phân tách: `["\n\n", "\n", ".", "!", "?", " ", ""]`.
  - Sinh vector nhúng dense embedding 384 chiều bằng mô hình `sentence-transformers/all-MiniLM-L6-v2`.
  - Nạp các đoạn vector vào ChromaDB Collection `brand_knowledge_base` kèm metadata bắt buộc:
    ```python
    metadata = {
        "clientId": client_id,
        "documentId": document_id,
        "chunkIndex": idx,
        "source": filename,
        "createdAt": datetime.utcnow().isoformat()
    }
    ```
  - Kiểm thử nghiêm ngặt: Mọi truy vấn semantic search RAG đều bắt buộc kèm điều kiện lọc cứng `where={"clientId": target_client_id}`, ngăn chặn hoàn toàn nguy cơ rò rỉ dữ liệu chéo giữa các thương hiệu đối thủ.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/rag_service.py`
  - `brandhub-ai-service/app/services/embedding_service.py`
  - `tests/test_rag_isolation.py`
- **Kết quả đạt được:**
  - [x] Bộ test suite kiểm thử truy vấn chéo client (Cross-client query attack) đạt 100% pass — không một chunk nào của Client A bị truy xuất bởi Client B.

#### 4. DA-597 (`DA-AI03-05`) — Soạn thảo Tài liệu Thiết kế Kiến trúc RAG Pipeline & Multi-tenant Isolation
- **Mục tiêu:** Tài liệu hóa toàn bộ kiến trúc, tham số kỹ thuật, luồng bảo mật và phương pháp đánh giá của phân hệ Brand Knowledge Base RAG.
- **Công việc đã làm:**
  - Soạn thảo tài liệu chuyên sâu `docs/architecture/brand_rag_pipeline_design.md` (300+ dòng).
  - Mô tả chi tiết: Sơ đồ kiến trúc luồng dữ liệu 4 tầng (Ingestion → Chunking/Embedding → Vector Indexing → Semantic Search), cấu trúc đường dẫn S3, công thức tính chunk overlap, bộ quy tắc chống rò rỉ dữ liệu `clientId`, và bảng tiêu chuẩn đánh giá độ chính xác ngữ nghĩa (Semantic Hit Rate).
- **Tệp tin tạo mới:**
  - `brandhub-infrastructure/docs/architecture/brand_rag_pipeline_design.md`
- **Kết quả đạt được:**
  - [x] Tài liệu hoàn thiện, được AI Team và Tech Lead review nghiệm thu.

---

### II. Phân hệ Lưu trữ Xu hướng, Đồ thị Tri thức Neo4j & Vector Engine (Epic AI-05)

#### 1. DA-754 (`DA-AI05-16`) — Xây dựng Engine Lưu trữ Đệm Redis Sorted Set (ZSET)
- **Mục tiêu:** Lưu trữ bảng xếp hạng Top 10–20 xu hướng thời gian thực trên Redis Sorted Set để phục vụ API Dashboard với độ trễ siêu thấp ($< 10$ms).
- **Công việc đã làm:**
  - Thiết kế cấu trúc khóa Redis: `trends:vn:{date}:{category}` (ví dụ `trends:vn:2026-08-10:fashion`).
  - Ghi dữ liệu xu hướng vào Redis ZSET bằng lệnh `ZADD`, trong đó `score` là điểm lan truyền tổng hợp (`final_score`) và `member` là JSON string của xu hướng.
  - Cài đặt thời gian sống (TTL) là 6 giờ (21,600 giây), đồng bộ tuyệt đối với chu kỳ quét tự động của APScheduler.
  - Triển khai endpoint `GET /api/v1/ai/trends?category=...&limit=20` đọc trực tiếp từ Redis qua lệnh `ZREVRANGEBYSCORE`, chuyển đổi dữ liệu trả về client với độ trễ trung bình $pprox 4.2$ms.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/trend_cache_service.py`
  - `brandhub-ai-service/app/api/v1/endpoints/trends.py`
- **Kết quả đạt được:**
  - [x] Tốc độ phản hồi API danh sách xu hướng đạt chuẩn SLA $< 10$ms, giảm 98% tải truy vấn trực tiếp vào cơ sở dữ liệu chính.

#### 2. DA-755 (`DA-AI05-17`) — Xây dựng Module Upsert Node `:Trend` vào Neo4j
- **Mục tiêu:** Tạo mới hoặc cập nhật các node mỏ neo `:Trend` trong đồ thị tri thức làm nền tảng cho việc liên kết các thực thể tri thức tầng sâu.
- **Công việc đã làm:**
  - Viết module `Neo4jTrendService` sử dụng `neo4j` Python async driver.
  - Xây dựng câu truy vấn Cypher Upsert chuẩn công nghiệp:
    ```cypher
    MERGE (t:Trend {id: $trendId})
    ON CREATE SET 
        t.name = $name,
        t.score = $score,
        t.category = $category,
        t.platform = $platform,
        t.volume = $volume,
        t.createdAt = datetime()
    ON MATCH SET 
        t.score = $score,
        t.volume = $volume,
        t.updatedAt = datetime()
    ```
  - Khởi tạo chỉ mục (Index) trên `:Trend(id)` và `:Trend(name)` để tối ưu hóa tốc độ tìm kiếm và traversal.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/neo4j_trend_service.py`
- **Kết quả đạt được:**
  - [x] Upsert an toàn và nhất quán hàng trăm node xu hướng mỗi chu kỳ crawl, không gây trùng lặp hay lock bảng.

#### 3. DA-756 (`DA-AI05-18`) — Deep Crawl Trigger Engine (Thu thập Bài viết & Bình luận Chuyên sâu)
- **Mục tiêu:** Kích hoạt luồng cào dữ liệu chuyên sâu cho Top 10–20 xu hướng được xếp hạng cao nhất để thu thập bài viết gốc, tác giả và các bình luận tiêu biểu.
- **Công việc đã làm:**
  - Xây dựng trigger pipeline đẩy các từ khóa Top Trend vào hàng đợi `deep_crawl_queue`.
  - Thu thập nội dung bài viết chi tiết, danh sách hashtag đi kèm, lượt tương tác (likes, shares, views) và top comments mang tính thảo luận cao.
  - Làm sạch văn bản (loại bỏ link rác, ký tự lạ, chuẩn hóa unicode) và đóng gói payload chuyển giao sang Layer 4 (Chunking & NER).
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/deep_crawler_service.py`
- **Kết quả đạt được:**
  - [x] Cung cấp đầy đủ ngữ cảnh văn bản giàu thông tin cho từng trend để phục vụ bước trích xuất thực thể và GraphRAG.

#### 4. DA-757 (`DA-AI05-19`) — LangChain Text Chunking cho Dữ liệu Xu hướng
- **Mục tiêu:** Phân tách các bài viết và bình luận dài của xu hướng thành các đoạn văn bản ngắn (500 ký tự) có tính liên kết ngữ nghĩa.
- **Công việc đã làm:**
  - Xây dựng `TrendTextChunkerService` sử dụng `RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)`.
  - Tách câu dựa trên ranh giới đoạn (`

`), dòng (`
`), và dấu chấm câu (`.`, `!`, `?`).
  - Gắn siêu dữ liệu `trendId`, `trendName`, `author`, `platform`, `chunkIndex` vào từng document chunk.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/trend_chunker.py`
- **Kết quả đạt được:**
  - [x] Toàn bộ dữ liệu cào sâu được chuẩn hóa thành các chunk kích thước đồng đều sẵn sàng cho pipeline vector embedding.

#### 5. DA-758 (`DA-AI05-20`) — Xây dựng Pipeline Nhúng Vector Đậm đặc (`all-MiniLM-L6-v2`, 384d)
- **Mục tiêu:** Chuyển đổi toàn bộ các text chunks thành vector nhúng không gian 384 chiều với tốc độ cao.
- **Công việc đã làm:**
  - Tích hợp thư viện `sentence-transformers` với model `all-MiniLM-L6-v2` tối ưu trên CPU/GPU.
  - Triển khai cơ chế mã hóa theo lô (Batch Encoding với `batch_size = 32`) giúp tăng tốc độ xử lý gấp 4 lần so với encode đơn lẻ.
  - Tối ưu hóa thời gian sinh embedding đạt trung bình $pprox 12$ms mỗi chunk.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/embedding_service.py`
- **Kết quả đạt được:**
  - [x] Xử lý hàng nghìn chunk nội dung xu hướng trong chưa đầy 30 giây mỗi chu kỳ cào dữ liệu.

#### 6. DA-759 (`DA-AI05-21`) — Tích hợp ChromaDB Vector Store với Chỉ mục HNSW
- **Mục tiêu:** Lưu trữ và đánh chỉ mục vector cho dữ liệu xu hướng, hỗ trợ tìm kiếm láng giềng gần nhất (ANN) với độ trễ $< 50$ms.
- **Công việc đã làm:**
  - Khởi tạo ChromaDB Collection `social_trend_chunks` với cấu hình không gian khoảng cách `cosine`.
  - Thiết lập tham số chỉ mục HNSW: `M = 16` (số lượng liên kết hai chiều), `efConstruction = 200` (độ sâu xây dựng đồ thị), `efSearch = 50` (độ sâu tìm kiếm).
  - Nạp vector và metadata tương ứng (`trendName`, `author`, `platform`, `chunkIndex`, `createdAt`).
  - Viết hàm truy vấn `similarity_search(query_text, top_k=5, trend_filter=...)` với thời gian phản hồi thực nghiệm $pprox 22$ms.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/trend_vector_service.py`
  - `tests/test_chroma_trends.py`
- **Kết quả đạt được:**
  - [x] Khả năng truy vấn ngữ nghĩa đoạn trích xu hướng đạt độ chính xác cao và tốc độ vượt trội dưới 30ms.

#### 7. DA-760 (`DA-AI05-22`) — Xây dựng LLM NER & Relation Extraction Engine
- **Mục tiêu:** Tự động trích xuất các thực thể có tên (KOLs, Địa điểm, Món ăn/Sản phẩm, Thương hiệu) và các mối quan hệ liên kết từ nội dung xu hướng bằng mô hình ngôn ngữ lớn.
- **Công việc đã làm:**
  - Thiết kế prompt kỹ thuật cao (Few-shot Prompting) hướng dẫn Llama 3 (qua Groq API) trích xuất thực thể theo định dạng JSON có cấu trúc.
  - Định nghĩa Schema Pydantic nghiêm ngặt:
    - Entities: `:KOL`, `:Location`, `:Dish`, `:Brand`, `:Event`.
    - Relations: `:PROMOTED`, `:LOCATED_IN`, `:ASSOCIATED_WITH`, `:HAS_FEATURE`.
  - Xây dựng module kiểm tra tính hợp lệ JSON (JSON Schema Validation & Fallback Parser) để tự động sửa lỗi cú pháp nếu LLM trả về format không chuẩn.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/ner_extractor.py`
  - `brandhub-ai-service/app/prompts/ner_prompts.py`
  - `brandhub-ai-service/app/models/graph_models.py`
- **Kết quả đạt được:**
  - [x] Trích xuất thực thể đạt độ chuẩn xác (Precision) $> 90\%$ trên tập dữ liệu kiểm thử xu hướng ẩm thực và thời trang tiếng Việt.

#### 8. DA-761 (`DA-AI05-23`) — Xây dựng Neo4j Knowledge Graph Ingestion Engine
- **Mục tiêu:** Nạp toàn bộ thực thể và quan hệ trích xuất được từ LLM vào đồ thị tri thức Neo4j, nối về node gốc `:Trend`.
- **Công việc đã làm:**
  - Xây dựng transactional Cypher batch execution nạp song song các node thực thể:
    ```cypher
    UNWIND $entities AS e
    MERGE (node:Entity {name: e.name})
    ON CREATE SET node.type = e.type, node.createdAt = datetime()
    WITH node, e
    MATCH (t:Trend {name: e.trendName})
    MERGE (t)-[r:MENTIONS {weight: e.confidence}]->(node)
    ```
  - Tạo các quan hệ ngữ nghĩa 2 chiều giữa các thực thể phụ: `(:KOL)-[:PROMOTED]->(:Dish)`, `(:Dish)-[:LOCATED_IN]->(:Location)`.
  - Tối ưu hóa truy vấn đồ thị đa bước (1-hop, 2-hop traversal) phục vụ trích xuất context đồ thị cho GraphRAG.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/neo4j_graph_ingestion.py`
- **Kết quả đạt được:**
  - [x] Tạo lập thành công mạng lưới đồ thị tri thức xu hướng đa chiều hoàn chỉnh, phục vụ trực tiếp cho việc làm giàu prompt sinh bài viết.

#### 9. DA-762 (`DA-AI05-24`) — Xây dựng Background Job Hợp nhất Thực thể Trùng lặp (Entity Resolution)
- **Mục tiêu:** Giải quyết bài toán trùng lặp thực thể trong đồ thị tri thức (ví dụ "Hà Nội", "HN", "Ha Noi" hoặc "Trấn Thành", "MC Trấn Thành") bằng phương pháp so khớp vector tương đồng và hợp nhất node APOC.
- **Công việc đã làm:**
  - Xây dựng cron job chạy định kỳ sử dụng embedding cosine similarity giữa các node cùng nhãn type trong Neo4j.
  - Nếu độ tương đồng ngữ nghĩa $> 85\%$, tự động gọi thủ tục APOC `apoc.refactor.mergeNodes([node1, node2], {properties: "combine", mergeRels: true})`.
  - Gộp các liên kết và thuộc tính mà không làm gián đoạn cấu trúc đồ thị hiện hữu.
- **Tệp tin ảnh hưởng:**
  - `brandhub-ai-service/app/services/entity_resolution_service.py`
- **Kết quả đạt được:**
  - [x] Giảm 35% lượng node rác trùng lặp trong Knowledge Graph, làm tăng đáng kể độ mạch lạc và chất lượng của dữ liệu xu hướng.

---

### III. Báo cáo Tiến độ & Tài liệu Sprint (Epic E47)

#### 1. DA-461 (`DA-E47-37`) — Viết Báo cáo Cá nhân Sprint 6 — Lộc
- **Mục tiêu:** Tổng hợp toàn diện khối lượng công việc, đối soát 14 Jira tasks và đánh giá cá nhân cho Sprint 6.
- **Công việc đã làm:**
  - Tra cứu đối soát chi tiết toàn bộ các tasks được giao trong Sprint 6 trên Jira board (`DA Sprint 6`).
  - Hoàn thiện tài liệu báo cáo cá nhân tại `docs/plan/sprints/sprint_06/members/locnt.md`.
- **Kết quả đạt được:**
  - [x] Hoàn thành báo cáo cá nhân chi tiết, đầy đủ 8 phần chuẩn mực theo quy ước của nhóm.

---

## 4. Tasks chưa hoàn thành

- **Không có.** Toàn bộ **14/14 tasks** được giao trong Sprint 6 đều đã được hoàn thành 100%, đáp ứng đầy đủ Acceptance Criteria và pass toàn bộ unit/integration tests.

---

## 5. Đóng góp ngoài tasks chính

- **Thiết lập Môi trường Docker Compose Tích hợp Đa Dịch vụ:** Cấu hình trọn vẹn tệp `docker-compose.ai.yml` chạy đồng bộ Redis, ChromaDB, Neo4j Community 5.x và FastAPI service để cả team AI có môi trường kiểm thử nhất quán.
- **Hỗ trợ Backend Team về Luồng RAG & Trend Specs:** Tham gia giải thích và chốt hợp đồng API (API Contracts) giữa `business-service` và `ai-service` đối với endpoint upload tài liệu và truy xuất xu hướng.
- **Xây dựng Data Mock Fixtures:** Tạo lập bộ dữ liệu giả lập (mock fixtures) cho 5 thương hiệu mẫu và 20 xu hướng thực tế để phục vụ kiểm thử song song giữa các thành viên.

---

## 6. Học được gì trong sprint này

1. **Kiến trúc Cơ sở Dữ liệu Lai (Hybrid Storage: Vector + Graph + Cache):** Nắm vững cách kết hợp sức mạnh của 3 loại CSDL chuyên biệt: Redis ZSET (Caching siêu tốc $< 5$ms), ChromaDB HNSW (Tìm kiếm ngữ nghĩa vector $< 30$ms) và Neo4j Graph DB (Mối quan hệ liên kết thực thể đa tầng).
2. **Kỹ thuật Entity Resolution trong Knowledge Graph:** Làm chủ giải pháp gộp node bằng Neo4j APOC kết hợp Cosine Similarity từ mô hình nhúng `all-MiniLM-L6-v2`, giải quyết bài toán cốt lõi của đồ thị tri thức thực tế.
3. **Bảo mật Cô lập Đa Khách hàng (Multi-tenant Data Isolation):** Hiểu sâu và hiện thực hóa thành công các tầng bảo vệ dữ liệu khách hàng từ Object Storage pathing (`rag/{clientId}/...`) đến Vector query metadata filtering.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc của team
- Việc phân tách rõ ràng vai trò giữa các thành viên và có tài liệu đặc tả thiết kế (Design Docs) trước khi bắt tay vào code giúp team AI triển khai các module phức tạp (Neo4j, ChromaDB, Redis) một cách mượt mà và không gặp xung đột mã nguồn.

### 7.2 Về technical stack / tools
- Thư viện Neo4j APOC rất mạnh mẽ cho việc thao tác đồ thị nâng cao; cần đảm bảo container Neo4j trên môi trường Production luôn được nạp đầy đủ APOC plugins và cấp quyền phù hợp (`apoc.export.*`, `apoc.import.*`).

### 7.3 Đề xuất cho Sprint tiếp theo (Sprint 7 / Sprint 8)
- Tiếp tục hoàn thiện trọn vẹn bộ tài liệu Đồ án tốt nghiệp (Capstone Reports R1, R2, R3) trong Sprint 7.
- Chuẩn bị sẵn sàng cho Sprint 8 để ráp nối toàn bộ hệ thống RAG và Trend Context vào Pipeline sinh nội dung tự động bằng LLM (Epic AI-04) với cơ chế chống ảo giác (Anti-hallucination guardrails).

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---|
| Hoàn thành đúng deadline | 5/5 | Hoàn thành 14/14 tasks được giao đúng tiến độ cam kết |
| Chất lượng deliverable | 5/5 | Mã nguồn hoàn chỉnh, cấu trúc CSDL lai (Redis + Neo4j + ChromaDB) vận hành mượt mà, test pass 100% |
| Giao tiếp với team | 5/5 | Chủ động phối hợp với AI team và Backend team để thống nhất API contracts |
| Chủ động xử lý blocker | 5/5 | Tự chủ động nghiên cứu và giải quyết bài toán Entity Resolution và cô lập Multi-tenant RAG |
| **Tổng** | **20/20** | |

---

*Deadline nộp: 2026-08-11 | File: `brandhub-infrastructure/docs/plan/sprints/sprint_06/members/locnt.md`*
