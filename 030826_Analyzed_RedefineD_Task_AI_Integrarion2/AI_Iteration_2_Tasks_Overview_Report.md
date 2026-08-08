# Báo Cáo Tổng Quan So Sánh & Hợp Nhất Nhiệm Vụ (AI Iteration 2 - Tasks & Integration Report)
**Mã tài liệu:** AI-IT2-TASKS-OVERVIEW  
**Dự án:** BrandHub AI Trend System  

Báo cáo này cung cấp cái nhìn tổng quan và hệ thống hóa toàn bộ các nhiệm vụ (tasks) trong **Iteration 2** sau khi đối chiếu giữa kế hoạch gốc tại [`BrandHub_Master_Plan.md`](file:///d:/FPT/FA26/brandhub-infrastructure/docs/plan/BrandHub_Master_Plan.md) và các cải tiến GraphRAG, Scheduler chạy ngầm được đề xuất trong tài liệu [`AI_Iteration_2_System_Architecture_Report.md`](file:///d:/FPT/FA26/brandhub-infrastructure/AI_Iteration_2_System_Architecture_Report.md).

---

## 1. Phân Tích Khoảng Trống (Gap Analysis: Kế Hoạch Gốc vs Đề Xuất Mới)

Sự cải tiến kiến trúc từ RAG truyền thống (chỉ dùng ChromaDB) sang **GraphRAG lai (ChromaDB + Neo4j)** dẫn đến việc bổ sung các task cốt lõi để đảm bảo hệ thống vận hành chính xác:

| Cấu phần | Kế hoạch gốc (Master Plan cũ) | Đề xuất mới nâng cấp (v1.1) | Lý do nâng cấp kỹ thuật |
| :--- | :--- | :--- | :--- |
| **Tìm kiếm Tri thức** | Chỉ tìm kiếm ngữ nghĩa mờ bằng Vector (ChromaDB). | Kết hợp tìm kiếm Vector (ChromaDB) + Duyệt đồ thị quan hệ (Neo4j). | Giải quyết việc thông tin bị rời rạc; kết nối logic giữa các thực thể (KOL, món ăn, địa điểm) để sinh bài viết sâu sắc hơn. |
| **Tiền xử lý Query** | Chuyển trực tiếp query của user thành vector để tìm kiếm. | Chuẩn hóa câu query (Query Normalization) trước khi tìm. | Loại bỏ emoji rác, sửa từ viết tắt/từ lóng tiếng Việt để ChromaDB matching vector chính xác hơn. |
| **Tối ưu ngữ cảnh** | Gửi toàn bộ chunks tìm được sang prompt của LLM. | Chấm điểm tương quan BM25 và Cắt tỉa (Pruning) node ít liên quan. | Tiết kiệm tối thiểu 30% Token budget, giảm chi phí API và giảm thời gian phản hồi (latency) của LLM. |
| **Lưu trữ đồ thị** | Chưa có cơ chế quản lý và ghi dữ liệu đồ thị. | Xây dựng Connection Pool cho Neo4j và NER nạp liên kết đồ thị. | Quản lý connection luồng ghi/đọc đồ thị hiệu quả, tránh rò rỉ kết nối trên môi trường Docker. |
| **Dọn dẹp Database** | Chưa có cơ chế xử lý trùng lặp dữ liệu đồ thị. | Chạy background job Entity Resolution gộp node định kỳ. | Tránh hiện tượng phình to và loãng đồ thị (ví dụ: gộp các node đồng nghĩa "HN", "Hà Nội" thành một). |
| **Bộ lập lịch ngầm** | Chưa làm rõ cơ chế trigger cào xu hướng. | Cấu hình APScheduler daemon chạy ngầm trong FastAPI. | Đảm bảo việc cào xu hướng và dọn dẹp DB diễn ra hoàn toàn tự động dưới nền. |

---

## 2. Bảng Hợp Nhất & Phân Nhóm Tất Cả Các Task Iteration 2

Dưới đây là bảng tổng hợp đầy đủ các nhiệm vụ của Iteration 2 (Epic AI-03 và AI-04) sau khi hợp nhất. Các nhiệm vụ mới đề xuất được đánh dấu **[ĐỀ XUẤT MỚI]**:

### Nhóm 1: Luồng Nạp Tri Thức & Quản lý Cơ sở Dữ liệu (RAG Ingestion & DB)

| Mã Task | Tên Nhiệm Vụ | Trạng thái | Mục tiêu kỹ thuật |
| :--- | :--- | :---: | :--- |
| `DA-AI03-01` | Implement document upload endpoint | Gốc | Tiếp nhận file (PDF/DOCX/TXT/URL) đẩy lên S3. |
| `DA-AI03-02` | Build document chunking service | Gốc | Cắt văn bản thô thành các đoạn nhỏ 500 ký tự. |
| `DA-AI03-03` | Build embedding pipeline | Gốc | Sinh vector embeddings và lưu vào ChromaDB. |
| `DA-AI03-03.1`| Build Neo4j connection pool management | **Mới** | Quản lý kết nối driver Singleton kết nối Neo4j. |
| `DA-AI03-03.2`| NER extraction and relations ingestion | **Mới** | LLM trích thực thể nạp liên kết đồ thị vào Neo4j. |
| `DA-AI03-06` | Implement document deletion endpoint | Gốc | Xóa dữ liệu đồng thời trên S3, ChromaDB và Neo4j. |
| `DA-AI03-09` | Create Entity Resolution background job | **Mới** | APScheduler chạy ngầm gộp các node trùng lặp trong Neo4j. |

### Nhóm 2: Luồng Truy Vấn & Tối ưu hóa Ngữ cảnh (RAG Retrieval & Pruning)

| Mã Task | Tên Nhiệm Vụ | Trạng thái | Mục tiêu kỹ thuật |
| :--- | :--- | :---: | :--- |
| `DA-AI03-03.3`| Implement query normalization | **Mới** | Tiền xử lý query (lọc emoji, map từ lóng/viết tắt). |
| `DA-AI03-04` | Implement semantic search | Gốc | Quét ChromaDB tìm các entry point ngữ nghĩa. |
| `DA-AI03-04.1`| Build graph traversal service | **Mới** | Cypher query duyệt đồ thị Neo4j 1-2 hops từ entry point. |
| `DA-AI03-04.2`| Implement BM25 scoring & graph pruning | **Mới** | Chấm điểm BM25 của node và lọc bỏ các node rác. |
| `DA-AI03-05` | Build RAG context builder | Gốc | Đóng gói text ChromaDB + quan hệ Neo4j thành context. |

### Nhóm 3: Luồng Sinh Nội Dung & Hậu Xử Lý (Content Generation & Post-Processing)

| Mã Task | Tên Nhiệm Vụ | Trạng thái | Mục tiêu kỹ thuật |
| :--- | :--- | :---: | :--- |
| `DA-AI04-01` | Build prompt template system | Gốc | Prompt động Jinja2 kết hợp RAG context + Hook 3s. |
| `DA-AI04-02` | Integrate Llama 3 via Groq API | Gốc | Gọi Llama 3 Groq (temperature thấp, JSON response). |
| `DA-AI04-03` | Integrate Claude API as fallback | Gốc | Failover tự động switch sang Claude khi Groq lỗi/429. |
| `DA-AI04-04` | Platform-specific caption optimization | Gốc | Tối ưu ký tự theo nền tảng, auto-summarize cho Threads. |
| `DA-AI04-05` | Implement hashtag generation endpoint | Gốc | Phân tích bài viết trích lọc 5-10 hashtags sạch. |
| `DA-AI04-06` | Implement regenerate with feedback | Gốc | Tái tạo phiên bản bài viết mới dựa trên feedback của user. |

### Nhóm 4: Đánh Giá Chất Lượng & Tài Liệu Hóa (QA & Documentation)

| Mã Task | Tên Nhiệm Vụ | Trạng thái | Mục tiêu kỹ thuật |
| :--- | :--- | :---: | :--- |
| `DA-AI03-07` | Test RAG accuracy (3 documents) | Gốc | Chốt chặn chất lượng: Đảm bảo độ chính xác của RAG. |
| `DA-AI03-08` | Write RAG pipeline documentation | Gốc | Viết hướng dẫn cấu hình tham số và thiết kế RAG. |
| `DA-AI04-07` | Anti-hallucination test (20 captions) | Gốc | Chốt chặn chất lượng: Đảm bảo LLM không tự bịa thông tin. |
| `DA-AI04-08` | Write Prompt Engineering Documentation | Gốc | Tài liệu hóa cấu trúc prompt, tone guide và system prompts. |

---

## 3. Bản Đồ Phụ Thuộc Tích Hợp (Integrated Dependency Map)

Để luồng runtime sinh bài viết hoạt động trơn tru, các task phải được xây dựng theo đúng trình tự phụ thuộc kỹ thuật dưới đây:

```
[NHÓM 1: NẠP TRI THỨC]
DA-AI03-01 (API Upload) ➔ DA-AI03-02 (Chunking) ➔ DA-AI03-03 (Chroma Store)
                                 │
                                 ▼ (Graph Ingestion)
                           DA-AI03-03.1 (Neo4j Pool) ➔ DA-AI03-03.2 (NER Ingest) ➔ DA-AI03-09 (Resolution Cron)

[NHÓM 2: TRUY VẤN LAI]
DA-AI03-03.3 (Query Normalization) ➔ DA-AI03-04 (Chroma Search)
                                               │ (Trích Entry Points)
                                               ▼
                                         DA-AI03-04.1 (Neo4j Traversal)
                                               │
                                               ▼
                                         DA-AI03-04.2 (BM25 Pruning)
                                               │
                                               ▼
                                         DA-AI03-05 (Context Builder) ➔ DA-AI03-07 (RAG QA Gate)

[NHÓM 3: LLM GENERATION & POST-PROCESS]
                                                                        │
                                                                        ▼
                                                                 DA-AI04-01 (Prompt Builder)
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
                                                                 DA-AI04-07 (Anti-Hallucination QA)
                                                                        │
                                                                        ▼
                                                                 DA-AI04-08 (Documentation)
```

---

## 4. Định Hướng Phân Chia Công Việc Trong Team AI

Dựa trên tính chất công nghệ, trưởng nhóm có thể phân bổ 22 nhiệm vụ trên cho 3 vai trò lập trình viên trong team như sau:

### Vai trò A: AI Algorithm & Database Engineer (Tập trung vào Thuật toán & DB)
*   **Chuyên môn:** NLP, Cơ sở dữ liệu Vector & Đồ thị (Neo4j, ChromaDB, Cypher, GDS).
*   **Các task phân bổ:**
    *   `DA-AI03-02` (Chunking), `DA-AI03-03` (Embedding Chroma), `DA-AI03-03.1` (Neo4j Pool), `DA-AI03-03.2` (NER Neo4j), `DA-AI03-09` (Resolution Cron).
    *   `DA-AI03-03.3` (Query Normalization), `DA-AI03-04.1` (Neo4j Traversal), `DA-AI03-04.2` (BM25 Pruning).

### Vai trò B: API Integration & Backend Engineer (Tập trung vào API & LLM)
*   **Chuyên môn:** Python FastAPI, AWS S3, Integration API (Groq, Claude), APScheduler, Caching.
*   **Các task phân bổ:**
    *   `DA-AI03-01` (Upload Endpoint), `DA-AI03-06` (Delete Endpoint).
    *   `DA-AI03-04` (Chroma Search), `DA-AI03-05` (Context Builder).
    *   `DA-AI04-02` (Groq API), `DA-AI04-03` (Claude Fallback), `DA-AI04-04` (Length Optimizer), `DA-AI04-05` (Hashtag API).

### Vai trò C: Prompt Engineer & QA (Tập trung vào Prompt & Kiểm thử chất lượng)
*   **Chuyên môn:** Prompt Engineering, LLM-as-a-judge, QA Testing, soạn thảo tài liệu.
*   **Các task phân bổ:**
    *   `DA-AI04-01` (Prompt Builder & Hook 3s), `DA-AI04-06` (Feedback Loop).
    *   `DA-AI03-07` (RAG QA Gate), `DA-AI04-07` (Anti-hallucination QA).
    *   `DA-AI03-08` (RAG Documentation), `DA-AI04-08` (Prompt Documentation).
