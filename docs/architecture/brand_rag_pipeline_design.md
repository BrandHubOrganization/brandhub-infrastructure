# 🏗️ Brand Knowledge Base RAG Pipeline Architecture & Design Specifications

## 📋 Document Information
- **Title**: Brand Knowledge Base RAG Pipeline Architecture & Specifications
- **System**: BrandHub AI Infrastructure & Services (`brandhub-ai-service`)
- **File Location**: `brandhub-infrastructure/docs/architecture/brand_rag_pipeline_design.md`
- **Target Audience**: AI/ML Engineers, Backend Developers, DevOps, System Architects
- **Status**: Approved Architecture & Implementation Standard
- **Associated Ticket**: `DA-AI03-08` (Blocked by `DA-AI03-04`)

---

## 1. 🌐 System Architecture & Dual Hybrid RAG Pipeline

The Brand Knowledge Base RAG Pipeline employs a **Dual Hybrid RAG Architecture** combining dense vector retrieval (**ChromaDB**) with structured knowledge graph traversal (**Neo4j**). This ensures both semantic search recall and high-precision brand entity relationship queries.

### 1.1 High-Level Architecture Flowchart

```mermaid
flowchart TD
    %% STEP 1: DATA INGESTION
    subgraph STEP1 ["Step 1: Data Ingestion & Crawling (API Ingress)"]
        API_INGRESS["Client REST API Ingress<br/>• POST /api/v1/ai/rag/upload<br/>• POST /api/v1/ai/trends/crawl"]
        INPUT["Tài liệu & Bài viết Trend<br/>(PDF, DOCX, TXT, Web URL)"]
        S3_STORE[("AWS S3 Storage<br/>rag/{clientId}/{documentId}/{filename}")]
        EXTRACT["Extractor Engines<br/>(pdfplumber, python-docx, bs4)"]
        
        API_INGRESS --> INPUT
        INPUT --> S3_STORE
        INPUT --> EXTRACT
    end

    %% STEP 2: CHUNKING
    subgraph STEP2 ["Step 2: Document Chunking"]
        SPLIT["LangChain RecursiveCharacterTextSplitter<br/>(chunk_size = 500, overlap = 50)"]
        CHUNKS["Chunks Dữ Liệu"]
        SPLIT --> CHUNKS
    end
    EXTRACT --> SPLIT

    %% STEP 3: DUAL AI PIPELINE
    subgraph STEP3 ["Step 3: Dual AI Pipeline (Vector + Knowledge Graph)"]
        direction TB

        %% VECTOR BRANCH
        subgraph VECTOR ["⚡ Vector Pipeline (Primary & Backup Embedding)"]
            V_EMBED["Embedding Engine<br/>• Primary: all-MiniLM-L6-v2 (384d)<br/>• Backup: text-embedding-3-small (1536d)"]
            V_DB[("ChromaDB Vector Store<br/>Collection: client_{clientId}<br/>(Cosine HNSW Index)")]
            V_EMBED --> V_DB
        end

        %% GRAPH BRANCH
        subgraph GRAPH ["🧠 Knowledge Graph Pipeline"]
            G_NER["LLM NER Engine<br/>(Groq Llama 3 70B)"]
            G_DB[("Neo4j Knowledge Graph<br/>(Aura Cloud DB)")]
            G_RES["Entity Resolution Job<br/>(DSU + APOC Merge)"]
            
            G_NER --> G_DB
            G_DB --> G_RES
        end

        V_DB -. "Cross-Reference Query" .-> G_DB
    end

    CHUNKS --> V_EMBED
    CHUNKS --> G_NER

    %% STEP 4: SERVING LAYER
    subgraph STEP4 ["Step 4: Serving & Query Layer (API Endpoints)"]
        QUERY_API["Client Query REST APIs<br/>• POST /api/v1/ai/content/generate<br/>• POST /api/v1/ai/rag/query"]
        QUERY_ENGINE["AI Search & Content Generation Engine<br/>(BM25 Pruning + GraphRAG Context Builder)"]
        
        QUERY_API --> QUERY_ENGINE
        V_DB --> QUERY_ENGINE
        G_DB --> QUERY_ENGINE
    end

    %% STYLING
    style STEP1 fill:#EFF6FF,stroke:#2563EB,stroke-width:2px;
    style STEP2 fill:#FEFDE8,stroke:#CA8A04,stroke-width:2px;
    style STEP3 fill:#F8FAFC,stroke:#0F172A,stroke-width:2px;
    style STEP4 fill:#F0FDF4,stroke:#16A34A,stroke-width:2px;
    style VECTOR fill:#EFF6FF,stroke:#2563EB,stroke-width:1px;
    style GRAPH fill:#FDF4FF,stroke:#C026D3,stroke-width:1px;
```

---

### 1.2 Entity Resolution & Graph Node Fusion Workflow

To prevent duplicate entities in the Neo4j Knowledge Graph across uploaded brand documents, a background Entity Resolution job runs periodically.

```mermaid
flowchart TD
    %% TỰ ĐỘNG CHẠY & LẤY NODE
    subgraph S1 ["1️⃣ Khởi Tạo & Lấy Dữ Liệu (API & Cron Trigger)"]
        API_RUN["POST /api/v1/ai/entity-resolution/run<br/>(Trigger thủ công / theo brand_id)"]
        CRON["APScheduler (0 2 * * * - 2:00 AM)<br/>(Chạy tự động ngầm)"]
        LOCK{"Redis Lock<br/>(lock:entity_resolution)"}
        FETCH["Lấy Entities từ Neo4j Aura<br/>(MATCH (e) WHERE e.name IS NOT NULL)"]

        API_RUN --> LOCK
        CRON --> LOCK
        LOCK -- "Lock Acquired" --> FETCH
    end

    %% PHÂN VÙNG & SO KHỚP AI
    subgraph S2 ["2️⃣ Phân Vùng & So Khớp AI"]
        PARTITION["Phân nhóm theo Label Key<br/>(:Location | :KOL | :Brand | :Product)"]
        SIM["Tính Vector Similarity<br/>(all-MiniLM-L6-v2 + Cosine Similarity >= 85%)"]
        PARTITION --> SIM
    end
    FETCH --> PARTITION

    %% GOM CỤM & HỢP NHẤT NODE
    subgraph S3 ["3️⃣ Gom Cụm & Fusion Node"]
        CLUSTER["Gom Cụm Duplicate<br/>(Disjoint Set Union - DSU)"]
        MERGE["Neo4j APOC Node Fusion<br/>(CALL apoc.refactor.mergeNodes)"]
        CLUSTER --> MERGE
    end
    SIM --> CLUSTER

    %% LƯU TRẠNG THÁI & MONITORING API
    subgraph S4 ["4️⃣ Lưu Báo Cáo & Monitoring API"]
        REDIS_CACHE[("Redis Cache<br/>(entity_resolution:last_run_status)")]
        API_STATUS["GET /api/v1/ai/entity-resolution/status<br/>(Đọc kết quả & thống kê)"]
        
        REDIS_CACHE --> API_STATUS
    end
    MERGE --> REDIS_CACHE

    %% STYLING
    style S1 fill:#EFF6FF,stroke:#2563EB,stroke-width:2px;
    style S2 fill:#F3E8FF,stroke:#9333EA,stroke-width:2px;
    style S3 fill:#FDF4FF,stroke:#C026D3,stroke-width:2px;
    style S4 fill:#F0FDF4,stroke:#16A34A,stroke-width:2px;
```

---

## 2. ✂️ Chunking Parameters & Text Extraction Specs

### 2.1 Chunking Configuration Matrix
The chunking process converts extracted document text into contiguous text segments formatted for dense embedding.

| Parameter | Value | Technical Justification |
| :--- | :--- | :--- |
| **Engine** | LangChain `RecursiveCharacterTextSplitter` | Hierarchical recursive splitting preserving paragraph and sentence integrity. |
| **Chunk Size** | `500` characters | Aligns with the optimal context window for `all-MiniLM-L6-v2` (max sequence 256 tokens \(\approx 500\) chars). |
| **Chunk Overlap** | `50` characters | Provides a 10% context bridge across adjacent chunks to prevent entity truncation. |
| **Separators** | `["\n\n", "\n", ".", ",", " ", ""]` | Priority order avoids splitting inside Vietnamese/English sentences or words. |
| **Max Upload Limit** | `10 MB` (API spec up to `20 MB`) | Protects memory during PDF/DOCX stream extraction. |

### 2.2 File Extractors & Preprocessing Pipeline
- **PDF Documents**: Parsed using `pdfplumber` (primary for rich layout/text) with `pypdf` fallback.
- **DOCX Documents**: Processed via `python-docx` extracting headers, paragraphs, and list items.
- **TXT / Markdown Files**: Read directly via UTF-8 text decoder.
- **Web URLs**: Downloaded via `requests` and sanitized using `BeautifulSoup4` (stripping `<script>`, `<style>`, and navigation noise).

---

## 3. 🗄️ AWS S3 Path Structure & Document Storage

### 3.1 Standardized S3 URI Pattern
All ingested documents are uploaded to AWS S3 prior to chunking and vector store indexing:

```text
s3://<bucket-name>/rag/{clientId}/{documentId}/{filename}
```

### 3.2 Path Component Definitions
- `<bucket-name>`: Configured environment variable `S3_BUCKET_NAME` (e.g., `brandhub-media-bucket`).
- `clientId`: Unique client UUID (e.g., `client_9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11`).
- `documentId`: MongoDB `knowledge_documents` primary object ID (e.g., `doc_550e8400-e29b-41d4-a716-446655440000`).
- `filename`: Sanitized original uploaded filename (e.g., `brand_identity_guide_2026.pdf`).

### 3.3 Example S3 Key
```text
rag/client_9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11/doc_550e8400-e29b-41d4-a716-446655440000/brand_identity_guide_2026.pdf
```

### 3.4 S3 Utility Functions (`app/utils/s3.py`)
```python
def upload_file(file_obj, s3_key: str, content_type: str = None) -> str:
    """Uploads document stream to S3 under specified multi-tenant key."""
    s3_client = get_s3_client()
    extra_args = {"ContentType": content_type} if content_type else {}
    s3_client.upload_fileobj(file_obj, settings.S3_BUCKET_NAME, s3_key, ExtraArgs=extra_args)
    return f"s3://{settings.S3_BUCKET_NAME}/{s3_key}"

def get_presigned_url(s3_key: str, expires_in: int = 3600) -> str:
    """Generates temporary access URL for document preview."""
    s3_client = get_s3_client()
    return s3_client.generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.S3_BUCKET_NAME, "Key": s3_key},
        ExpiresIn=expires_in,
    )
```

---

## 4. 🔒 Multi-Tenant Security Tags & ChromaDB Filter Patterns

### 4.1 Security Isolation Architecture
Multi-tenancy isolation in BrandHub is enforced at two distinct security layers:
1. **Physical/Logical Collection Isolation**: Each client has an isolated ChromaDB collection named `client_{clientId}`.
2. **Metadata Filter Enforcer**: Every ChromaDB query strictly injects metadata filtering `where={"clientId": {"$eq": client_id}}`.

> [!IMPORTANT]
> Under no circumstances can a query search across multiple client collections or execute without an explicit `clientId` filter parameter.

### 4.2 Standardized Metadata Schema
Every document chunk stored in ChromaDB must include the following metadata dictionary:

```json
{
  "documentId": "doc_550e8400-e29b-41d4-a716-446655440000",
  "clientId": "client_9f3a6f7b-2d4a-49a8-93cc-2b8e7a8c0d11",
  "chunkIndex": 0,
  "source": "brand_identity_guide_2026.pdf",
  "uploadedAt": "2026-08-17T17:44:00Z"
}
```

- **Deterministic Chunk Vector ID**: `{documentId}:{chunkIndex}` (e.g., `doc_550e8400-e29b-41d4-a716-446655440000:0`).

---

### 4.3 ChromaDB Python Query & Deletion Patterns

#### Pattern A: Multi-tenant Semantic Retrieval (Client-Scoped)
```python
def query_client_knowledge_base(
    client_id: str,
    query_text: str,
    top_k: int = 5
) -> dict:
    collection_name = f"client_{client_id}"
    collection = chromadb_client.get_or_create_collection(
        name=collection_name,
        metadata={"hnsw:space": "cosine"}
    )
    
    # Strictly enforced tenant filter
    results = collection.query(
        query_texts=[query_text],
        n_results=top_k,
        where={"clientId": {"$eq": client_id}}
    )
    return results
```

#### Pattern B: Document-Scoped Semantic Retrieval
```python
def query_specific_document(
    client_id: str,
    document_id: str,
    query_text: str,
    top_k: int = 5
) -> dict:
    collection = chromadb_client.get_collection(name=f"client_{client_id}")
    
    results = collection.query(
        query_texts=[query_text],
        n_results=top_k,
        where={
            "$and": [
                {"clientId": {"$eq": client_id}},
                {"documentId": {"$eq": document_id}}
            ]
        }
    )
    return results
```

#### Pattern C: Cascade Document Deletion
```python
def delete_document_chunks(client_id: str, document_id: str) -> int:
    """Cascade deletes all vector chunks belonging to a deleted document."""
    collection = chromadb_client.get_collection(name=f"client_{client_id}")
    
    # Retrieve all chunk IDs matching documentId
    matching = collection.get(where={"documentId": {"$eq": document_id}})
    if matching and matching["ids"]:
        collection.delete(ids=matching["ids"])
        return len(matching["ids"])
    return 0
```

---

## 5. ⚡ Embedding Engine & Model Failover Strategy

### 5.1 Embedding Model Alignment
- **PRIMARY MODEL**: `all-MiniLM-L6-v2`
  - **Dimensions**: 384-dimensional dense vectors
  - **Execution**: Local CPU/GPU execution via HuggingFace `SentenceTransformers` (`sentence-transformers/all-MiniLM-L6-v2`)
  - **Distance Metric**: Cosine Distance (\(1 - \text{CosineSimilarity}\))
  - **Latency**: \(\le 15\text{ms}\) per chunk
- **BACKUP MODEL**: `text-embedding-3-small`
  - **Dimensions**: 1536-dimensional dense vectors
  - **Execution**: External API call to OpenAI Embeddings API
  - **Usage**: Used as fallback in case of local GPU OOM or model initialization failures.

### 5.2 Cosine Similarity Mathematical Formula
Cosine similarity between query vector \(\mathbf{q}\) and chunk vector \(\mathbf{d}\):

\[
\text{CosineSimilarity}(\mathbf{q}, \mathbf{d}) = \frac{\mathbf{q} \cdot \mathbf{d}}{\|\mathbf{q}\| \|\mathbf{d}\|} = \frac{\sum_{i=1}^{n} q_i d_i}{\sqrt{\sum_{i=1}^{n} q_i^2} \sqrt{\sum_{i=1}^{n} d_i^2}}
\]

### 5.3 Model Failover Circuit Breaker Logic
```python
def generate_embeddings(texts: list[str]) -> list[list[float]]:
    try:
        # Primary: Local all-MiniLM-L6-v2 execution
        return primary_sentence_transformer.encode(texts).tolist()
    except Exception as e:
        logger.warning(f"Primary embedding failed ({e}). Triggering backup text-embedding-3-small.")
        # Backup: OpenAI Embeddings API fallback
        return openai_client.embeddings.create(
            input=texts,
            model="text-embedding-3-small"
        ).data[0].embedding
```

---

## 6. 📊 Evaluation Methodology & Quality Gates

### 6.1 Anti-Hallucination Evaluator (`app/services/hallucination_evaluator.py`)
To guarantee brand compliance and accuracy, generated context and response text are benchmarked using a dual-mode evaluator:

1. **`llm-judge` Mode (Claude 3.5 Sonnet / Llama 3 70B, `temperature=0.0`)**:
   - Deconstructs output text into atomic statements.
   - Cross-references each statement against `[BRAND CONTEXT]`.
   - Returns verified claims, unsupported claims, and exact reasoning.
2. **`regex` Rule-Based Pre-filter**:
   - Extracts numbers, years, pricing amounts (\$, VND), and capitalized brand entities.
   - Verifies whether exact entities exist in reference context.

### 6.2 Hallucination Metric Formula
\[
\text{Hallucination Rate} = \frac{\text{Unsupported Claims}}{\text{Total Claims Extracted}} \times 100\%
\]

### 6.3 RAG Accuracy Quality Gate (Target: Ticket `DA-AI03-07`)
- **Benchmark Suite**: 3 real brand documents (PDF menu, Brand Guidelines, PR Brief), 15 test queries.
- **Pass Criteria**:
  - **Semantic Retrieval Precision**: \(\ge 0.85\) Cosine Similarity.
  - **Hallucination Rate**: \(0.0\%\) (Passed 100%).

---

## 7. 🔗 Task Traceability & Dependency Matrix

| Ticket ID | Description | Status & Relationship to this Document |
| :--- | :--- | :--- |
| `DA-AI03-01` | Document Upload REST Endpoint (`/api/v1/ai/rag/upload`) | Ingestion Entry Point (S3 Storage) |
| `DA-AI03-02` | Document Chunking Service | Documented (Section 2: Chunk Specs) |
| `DA-AI03-03` | Embedding Pipeline & ChromaDB Storage | Documented (Section 5: Primary `all-MiniLM-L6-v2`) |
| `DA-AI03-03.1`| Neo4j Connection Pool Singleton | Documented (Section 1: Graph DB Pool) |
| `DA-AI03-03.2`| LLM NER Extraction & Cypher Ingestion | Documented (Section 1: Knowledge Graph Pipeline) |
| `DA-AI03-03.3`| Query Normalization | Pre-processing step for retrieval queries |
| `DA-AI03-04` | ChromaDB Semantic Search | **Blocking Dependency** (Documented Section 4 Filter Patterns) |
| `DA-AI03-04.1`| Neo4j Graph Traversal Service | Graph search extension layer |
| `DA-AI03-04.2`| BM25 Scoring & Context Pruning | Context Optimization layer |
| `DA-AI03-05` | GraphRAG Context Builder | Context Assembly layer |
| `DA-AI03-06` | Document Deletion Endpoint | Documented (Section 4: Pattern C Deletion) |
| `DA-AI03-07` | RAG Accuracy Quality Gate | Documented (Section 6: Quality Gates) |
| `DA-AI03-08` | Brand Knowledge Base RAG Pipeline Design Doc | **THIS DOCUMENT** |
| `DA-AI03-09` | Entity Resolution Cronjob | Documented (Section 1.2: DSU + APOC Flow) |

---
*Document maintained by BrandHub AI Engineering Team.*
