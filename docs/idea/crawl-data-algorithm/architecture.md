# Trend Detection & Content Generation — System Architecture

Repo triển khai: `brandhub-ai-service` (FastAPI, port 8082).
Endpoint liên quan đã có skeleton: `trends.py`, `rag.py`, `rag_models.py`.

## 1. Tổng quan kiến trúc

```
                    ┌─────────────────────────────────────────────────┐
                    │              brandhub-ai-service (FastAPI)        │
                    │                                                   │
  Crawler jobs  →   │  Ingest → STT → Normalize → Score → Index → RAG  │  → LLM Prompt
  (external)        │                                                   │
                    └─────────────────────────────────────────────────┘
                              │            │             │
                        ┌─────▼───┐  ┌─────▼─────┐ ┌─────▼─────┐
                        │ ChromaDB │  │  Neo4j    │ │ MongoDB   │
                        │ (vector) │  │  (graph)  │ │ (metadata)│
                        └──────────┘  └───────────┘ └───────────┘
```

Backend orchestrate crawl job: **Spring Boot** (brandhub-business-service) hoặc job riêng — đẩy dữ liệu thô vào `brandhub-ai-service` xử lý AI pipeline.

## 2. Module theo layer

### 2.1 Ingest Layer (mới — cần build)
- Vị trí đề xuất: `app/services/ingest/`
- Nhận input: video/audio/text URL hoặc file upload
- Output: text thô + metadata nguồn (platform, timestamp, author)

### 2.2 Speech-to-Text (mới — cần build)
- Vị trí đề xuất: `app/services/stt/`
- Model: **Whisper** (faster-whisper hoặc openai-whisper), chạy local trên **RTX 4050**
- Lý do: giảm phụ thuộc API trả phí (Google STT, AssemblyAI…) khi crawl volume lớn hàng ngày
- Cần thêm vào `requirements.txt`: `faster-whisper` hoặc `openai-whisper`, `torch` (CUDA build)

### 2.3 Scoring Layer (mới — cần build)
- Vị trí đề xuất: `app/services/scoring/bm25.py`
- Thuật toán: BM25 (rank_bm25 hoặc tự implement) — chấm điểm trending keyword
- Dùng để: rank keyword + **prune** node trước khi build context cho Graph traversal

$$
\text{score}(D, Q) = \sum_{i=1}^{n} \text{IDF}(q_i) \cdot \frac{f(q_i, D) \cdot (k_1 + 1)}{f(q_i, D) + k_1 \cdot \left(1 - b + b \cdot \frac{|D|}{\text{avgdl}}\right)}
$$

### 2.4 Embedding Layer (đã có nền — mở rộng)
- Đã có: `sentence-transformers` trong requirements.txt
- Model hiện config: `text-embedding-3-small` (OpenAI) — có thể đổi sang sentence-transformers local để giảm chi phí
- Output: vector → ChromaDB

### 2.5 Storage — GraphRAG (Vector đã có, Graph cần thêm)

| Component | Trạng thái | Vai trò |
|---|---|---|
| **ChromaDB** | Đã có trong `requirements.txt`, config sẵn (`chromadb_host`, `chromadb_port`) | Semantic search — match ý định user |
| **Neo4j** | Chưa có — cần thêm driver `neo4j` + Docker container | Entity + quan hệ logic — mạng lưới trend |
| **MongoDB** | Đã reference trong `rag.py` comment (chưa implement) | Metadata document, danh sách trend, audit |

Quyết định kiến trúc: **kết hợp Vector DB + Graph DB** (GraphRAG) thay vì chọn một — chuẩn Agentic AI memory hiện tại.

### 2.6 GraphRAG Context Builder (mới — cần build)
- Vị trí đề xuất: `app/services/graphrag/context_builder.py`
- Flow: Vector search (Chroma) tìm entry point → Graph traversal (Neo4j) mở rộng ngữ cảnh → prune theo BM25 → build prompt

### 2.7 Existing skeleton cần fill

| File | Trạng thái | Việc cần làm |
|---|---|---|
| `app/api/v1/endpoints/trends.py` | `raise NotImplementedError` | Implement Google Trends + TikTok trend crawl |
| `app/api/v1/endpoints/rag.py` | 4 endpoint đều `raise NotImplementedError` | Chunking + ChromaDB indexing, URL scraping, document listing/deletion |
| `app/models/rag_models.py` | Đã có model | Có thể cần mở rộng thêm field cho graph entity |

## 3. Thách thức kỹ thuật

### 3.1 Entity Resolution
Graph phình to mỗi ngày → node trùng ngữ nghĩa (VD "Trấn Thành" vs "MC Trấn Thành").
**Giải pháp:** job định kỳ merge node bằng embedding similarity + alias dictionary, hoặc LLM-based resolution.

### 3.2 Token limit / độ trễ
Ghép nhiều node thành context dài → vượt context window LLM, chậm response.
**Giải pháp:** prune theo điểm BM25, giới hạn depth traversal trong Neo4j, cache context cho trend phổ biến.

### 3.3 Hook strength cho content
Nền tảng (TikTok/Facebook) đánh giá qua Retention Rate, không chỉ keyword.
**Giải pháp:** thêm scoring layer riêng "hook strength" khi build prompt — không chỉ trend keyword mà cả cấu trúc mở đầu 3 giây.

## 4. Việc cần làm (thứ tự đề xuất)

1. Thêm `faster-whisper` + CUDA torch vào `requirements.txt` → POC STT local trên RTX 4050
2. Deploy Neo4j (Docker container riêng) + thêm driver `neo4j` vào requirements
3. Implement `app/services/scoring/bm25.py`
4. Implement ingest layer — chunking, entity extraction (LLM-based NER)
5. Implement GraphRAG context builder — nối Vector search + Graph traversal
6. Fill `rag.py` endpoints thật (hiện đang `NotImplementedError`)
7. Fill `trends.py` — Google Trends + TikTok crawl
8. Entity resolution job (cron/scheduled)
9. Hook scoring layer cho prompt generation

## 5. Config cần thêm vào `app/core/config.py`

```python
# Neo4j
neo4j_uri: str = "bolt://localhost:7687"
neo4j_user: str = "neo4j"
neo4j_password: str = ""

# MongoDB
mongodb_uri: str = "mongodb://localhost:27017"
mongodb_db: str = "brandhub_ai"

# Whisper
whisper_model: str = "base"  # tiny/base/small/medium/large
whisper_device: str = "cuda"  # cuda | cpu
```
