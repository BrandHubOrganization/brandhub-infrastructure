import{_ as s,o as a,c as t,a5 as i}from"./chunks/framework.CsGesDJn.js";const d=JSON.parse('{"title":"Báo Cáo Tổng Quan Hệ Thống & Sơ Đồ Kiến Trúc (AI Iteration 2 - RAG & Content Generation) - v1.1","description":"","frontmatter":{},"headers":[],"relativePath":"ai-models/iteration-2/ai-iteration-2-system-architecture-report.md","filePath":"ai-models/iteration-2/ai-iteration-2-system-architecture-report.md"}'),e={name:"ai-models/iteration-2/ai-iteration-2-system-architecture-report.md"};function l(p,n,h,r,o,c){return a(),t("div",null,[...n[0]||(n[0]=[i(`<h1 id="bao-cao-tong-quan-he-thong-so-đo-kien-truc-ai-iteration-2-rag-content-generation-v1-1" tabindex="-1">Báo Cáo Tổng Quan Hệ Thống &amp; Sơ Đồ Kiến Trúc (AI Iteration 2 - RAG &amp; Content Generation) - v1.1 <a class="header-anchor" href="#bao-cao-tong-quan-he-thong-so-đo-kien-truc-ai-iteration-2-rag-content-generation-v1-1" aria-label="Permalink to &quot;Báo Cáo Tổng Quan Hệ Thống &amp; Sơ Đồ Kiến Trúc (AI Iteration 2 - RAG &amp; Content Generation) - v1.1&quot;">​</a></h1><p><strong>Mã tài liệu:</strong> AI-IT2-ARCH-REPORT-V1.1<br><strong>Dự án:</strong> BrandHub AI Trend System</p><p>Báo cáo này cung cấp cái nhìn toàn diện về kiến trúc hệ thống, cấu trúc file, thiết kế API và luồng tương tác của hệ thống AI sau khi hoàn thành các nhiệm vụ của <strong>Iteration 2 (RAG Knowledge Base &amp; LLM Content Generation)</strong>. Bản nâng cấp v1.1 bổ sung chi tiết Luồng cào/nạp xu hướng (Offline Ingestion), hệ thống Scheduler chạy ngầm và cấu trúc thư mục file hoàn thiện.</p><hr><h2 id="_1-so-đo-tong-quan-he-thong-overall-system-architecture" tabindex="-1">1. Sơ Đồ Tổng Quan Hệ Thống (Overall System Architecture) <a class="header-anchor" href="#_1-so-đo-tong-quan-he-thong-overall-system-architecture" aria-label="Permalink to &quot;1. Sơ Đồ Tổng Quan Hệ Thống (Overall System Architecture)&quot;">​</a></h2><p>Hệ thống được thiết kế theo kiến trúc chia tách trách nhiệm rõ ràng giữa <strong>Luồng nạp dữ liệu tri thức &amp; xu hướng (Offline Ingestion)</strong> và <strong>Luồng sinh nội dung theo thời gian thực (Online Retrieval &amp; Generation)</strong>.</p><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">graph TD</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Styles</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    classDef clientClass fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    classDef gateClass fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    classDef svcClass fill:#fff9c4,stroke:#fbc02d,stroke-width:2px;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    classDef dbClass fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    classDef extClass fill:#ffe0b2,stroke:#e65100,stroke-width:2px;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Components</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    User[&quot;Dashboard Client (Web App)&quot;]:::clientClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Gateway[&quot;BrandHub API Gateway&quot;]:::gateClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    subgraph AIService [&quot;BrandHub AI Service (FastAPI)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        APILayer[&quot;API Endpoints Layer&quot;]:::svcClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        subgraph SchedulerLayer [&quot;Background Jobs &amp; Scheduler (APScheduler)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            Scheduler[&quot;APScheduler Daemon&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            EntityResJob[&quot;Entity Resolution Cronjob (DA-AI03-09)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        subgraph OfflinePipeline [&quot;Ingestion Pipeline (Offline &amp; Periodic)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            DocUpload[&quot;Doc Upload S3 Handler&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            subgraph TrendEngine [&quot;Trend Prediction Engine&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">                WordSeg[&quot;Word Segmentation (Underthesea)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">                BM25Anomaly[&quot;BM25 Anomaly Detector&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">                GraphScoring[&quot;Neo4j Centrality &amp; Virality Scoring&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            Chunking[&quot;Document Chunking Service&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            Embedding[&quot;Embedding Generator (MiniLM)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            NER[&quot;NER Relation Extractor&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        subgraph OnlinePipeline [&quot;Retrieval &amp; Gen Pipeline (Online)&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            Normalizer[&quot;Query Normalization&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            ChromaSearch[&quot;ChromaDB Vector Search&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            GraphTraversal[&quot;Neo4j Graph Traversal&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BM25Pruning[&quot;BM25 Scoring &amp; Pruning&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            ContextBuilder[&quot;GraphRAG Context Builder&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            PromptBuilder[&quot;Prompt Engine &amp; Hook 3s&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            LLMCoord[&quot;LLM Coordinator&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            LengthOpt[&quot;Platform Length Optimizer&quot;]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Databases &amp; Storage</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    S3[&quot;AWS S3 Bucket (Raw Docs)&quot;]:::dbClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Chroma[&quot;ChromaDB (Vector DB)&quot;]:::dbClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Neo4j[&quot;Neo4j Graph DB (Knowledge Graph)&quot;]:::dbClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Redis[&quot;Redis Cache (Top Trends)&quot;]:::dbClass</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% External Services</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Groq[&quot;Groq API (Llama 3 - Primary)&quot;]:::extClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Claude[&quot;Anthropic API (Claude - Fallback)&quot;]:::extClass</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ExtCrawlers[&quot;External Crawlers (pytrends &amp; TikTok API)&quot;]:::extClass</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Connections - Ingestion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Scheduler --&gt;|Kích hoạt cào định kỳ| ExtCrawlers</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ExtCrawlers --&gt;|Raw social/trends text| WordSeg</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WordSeg --&gt;|Clean Vietnamese tokens| BM25Anomaly</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BM25Anomaly --&gt;|Top 100 Candidates| GraphScoring</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GraphScoring --&gt;|Virality Score| Redis</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GraphScoring --&gt;|Create trend nodes| Neo4j</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Nạp tri thức xu hướng chi tiết</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ExtCrawlers --&gt;|Raw post &amp; comment text| Chunking</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Nạp tri thức thương hiệu</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    DocUpload --&gt;|Upload file thô| S3</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    DocUpload --&gt;|Trigger async| Chunking</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Chunking --&gt;|Text chunks| Embedding</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Chunking --&gt;|Text chunks| NER</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Embedding --&gt;|Save vectors &amp; metadata| Chroma</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    NER --&gt;|Save nodes &amp; relationships| Neo4j</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Entity Resolution</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Scheduler --&gt;|Trigger background job| EntityResJob</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    EntityResJob --&gt;|APOC merge duplicate nodes| Neo4j</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Connections - Retrieval &amp; Generation</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    User --&gt;|Yêu cầu sinh bài viết| Gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Gateway --&gt; APILayer</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    APILayer --&gt;|Topic / Query| Normalizer</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Normalizer --&gt;|Query đã chuẩn hóa| ChromaSearch</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ChromaSearch --&gt;|Entry Points - Top K| GraphTraversal</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GraphTraversal --&gt;|Traversed sub-graph| BM25Pruning</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BM25Pruning --&gt;|Clean graph context| ContextBuilder</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ChromaSearch --&gt;|Vector context| ContextBuilder</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    ContextBuilder --&gt;|Hierarchical Context| PromptBuilder</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PromptBuilder --&gt;|Assembled Prompt| LLMCoord</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    LLMCoord --&gt;|1. Try Groq API| Groq</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    LLMCoord --&gt;|2. Fallback switch| Claude</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    LLMCoord --&gt;|Raw caption| LengthOpt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    LengthOpt --&gt;|Optimized post| APILayer</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    APILayer --&gt;|Response JSON| Gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Gateway --&gt;|Display post| User</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    %% Cache Check</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    APILayer -.-&gt;|Read Top Trends| Redis</span></span></code></pre></div><hr><h2 id="_2-so-đo-cau-truc-file-thu-muc-directory-file-structure" tabindex="-1">2. Sơ Đồ Cấu Trúc File &amp; Thư Mục (Directory &amp; File Structure) <a class="header-anchor" href="#_2-so-đo-cau-truc-file-thu-muc-directory-file-structure" aria-label="Permalink to &quot;2. Sơ Đồ Cấu Trúc File &amp; Thư Mục (Directory &amp; File Structure)&quot;">​</a></h2><p>Cấu trúc thư mục của dự án <code>brandhub-ai-service</code> được tổ chức theo mô hình Modular Service nhằm đảm bảo tính cô đọng, dễ bảo trì và mở rộng khi thêm các module AI mới (như Image/Video Generation).</p><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>brandhub-ai-service/</span></span>
<span class="line"><span>│</span></span>
<span class="line"><span>├── docker/</span></span>
<span class="line"><span>│   └── Dockerfile                  # Cấu hình container chạy FastAPI</span></span>
<span class="line"><span>├── tests/                          # Thư mục kiểm thử</span></span>
<span class="line"><span>│   ├── test_rag_accuracy.py        # Kịch bản kiểm thử accuracy của RAG (3 tài liệu)</span></span>
<span class="line"><span>│   └── test_anti_hallucination.py  # Kịch bản kiểm thử chống ảo giác (20 kịch bản)</span></span>
<span class="line"><span>│</span></span>
<span class="line"><span>├── app/</span></span>
<span class="line"><span>│   ├── __init__.py</span></span>
<span class="line"><span>│   ├── main.py                     # Entry point khởi chạy FastAPI, cấu hình middlewares &amp; scheduler</span></span>
<span class="line"><span>│   │</span></span>
<span class="line"><span>│   ├── api/                        # Tầng Router nhận và xử lý request HTTP</span></span>
<span class="line"><span>│   │   ├── __init__.py</span></span>
<span class="line"><span>│   │   ├── v1/</span></span>
<span class="line"><span>│   │   │   ├── documents.py        # API upload/delete tài liệu tri thức RAG</span></span>
<span class="line"><span>│   │   │   ├── generate.py         # API sinh content, hashtag, refining</span></span>
<span class="line"><span>│   │   │   ├── trends.py           # API lấy trends hot từ Redis</span></span>
<span class="line"><span>│   │   │   └── health.py           # API kiểm tra trạng thái hoạt động (Healthcheck)</span></span>
<span class="line"><span>│   │</span></span>
<span class="line"><span>│   ├── core/                       # Cấu hình hệ thống và khởi tạo kết nối DB/Services</span></span>
<span class="line"><span>│   │   ├── __init__.py</span></span>
<span class="line"><span>│   │   ├── config.py               # Quản lý biến môi trường Pydantic Settings</span></span>
<span class="line"><span>│   │   ├── security.py             # Middleware kiểm tra API Key nội bộ (X-Internal-Key)</span></span>
<span class="line"><span>│   │   ├── neoj4.py                # Quản lý Connection Pool kết nối Neo4j</span></span>
<span class="line"><span>│   │   ├── redis.py                # Quản lý kết nối Redis client</span></span>
<span class="line"><span>│   │   ├── s3.py                   # Boto3 client cấu hình AWS S3</span></span>
<span class="line"><span>│   │   └── scheduler.py            # Khởi tạo và cấu hình APScheduler (cào xu hướng, gộp node)</span></span>
<span class="line"><span>│   │</span></span>
<span class="line"><span>│   ├── models/                     # Thư mục định nghĩa Pydantic Schemas</span></span>
<span class="line"><span>│   │   ├── __init__.py</span></span>
<span class="line"><span>│   │   ├── request.py              # Schema request sinh bài viết, hashtags, refine</span></span>
<span class="line"><span>│   │   └── response.py             # Schema response trả về bài viết đã sinh</span></span>
<span class="line"><span>│   │</span></span>
<span class="line"><span>│   └── services/                   # Tầng xử lý logic nghiệp vụ và thuật toán AI</span></span>
<span class="line"><span>│       ├── __init__.py</span></span>
<span class="line"><span>│       ├── chunking.py             # LangChain RecursiveCharacterTextSplitter</span></span>
<span class="line"><span>│       ├── embedding.py            # SentenceTransformers (MiniLM-L6-v2)</span></span>
<span class="line"><span>│       ├── normalization.py        # Làm sạch query, sửa từ viết tắt, từ lóng</span></span>
<span class="line"><span>│       ├── graph_traversal.py      # Cypher Query duyệt đồ thị Neo4j 1-2 hops</span></span>
<span class="line"><span>│       ├── pruning.py              # Thuật toán rank_bm25 cắt tỉa node rác</span></span>
<span class="line"><span>│       ├── context_builder.py      # GraphRAG context formatter</span></span>
<span class="line"><span>│       ├── prompt_builder.py       # Render prompt động bằng Jinja2 &amp; công thức Hook 3s</span></span>
<span class="line"><span>│       ├── llm_coordinator.py      # Điều phối Groq API và switch sang Claude fallback</span></span>
<span class="line"><span>│       ├── length_optimizer.py     # Tối ưu độ dài bài viết theo platform, auto-summarize</span></span>
<span class="line"><span>│       ├── hashtag_extractor.py    # Phân tích text sinh mảng hashtag</span></span>
<span class="line"><span>│       ├── entity_resolution.py    # Tiến trình chạy ngầm gộp thực thể trùng lặp (apoc merge)</span></span>
<span class="line"><span>│       ├── trend_predictor.py      # Thuật toán chấm điểm xu hướng (BM25 Anomaly x Centrality)</span></span>
<span class="line"><span>│       ├── word_segmentation.py    # Tách từ tiếng Việt bằng Underthesea</span></span>
<span class="line"><span>│       └── crawlers/               # Module cào dữ liệu định kỳ từ mạng xã hội</span></span>
<span class="line"><span>│           ├── __init__.py</span></span>
<span class="line"><span>│           ├── google_trends.py    # Crawler lấy hot keywords từ pytrends</span></span>
<span class="line"><span>│           └── tiktok_scraper.py   # Crawler bóc tách TikTok Creative Center (Playwright)</span></span></code></pre></div><hr><h2 id="_3-so-đo-cau-truc-api-api-endpoint-structure" tabindex="-1">3. Sơ Đồ Cấu Trúc API (API Endpoint Structure) <a class="header-anchor" href="#_3-so-đo-cau-truc-api-api-endpoint-structure" aria-label="Permalink to &quot;3. Sơ Đồ Cấu Trúc API (API Endpoint Structure)&quot;">​</a></h2><p>Hệ thống cung cấp tập API bảo mật (yêu cầu header <code>X-Internal-Key</code>) phục vụ cho Web Dashboard thông qua Gateway:</p><table tabindex="0"><thead><tr><th style="text-align:left;">Endpoint</th><th style="text-align:center;">Method</th><th style="text-align:left;">Chức năng</th><th style="text-align:left;">Request Body / Query Params</th><th style="text-align:left;">Response JSON Shape</th></tr></thead><tbody><tr><td style="text-align:left;"><code>/ai/rag/documents</code></td><td style="text-align:center;"><code>POST</code></td><td style="text-align:left;">Tải lên tài liệu hoặc URL</td><td style="text-align:left;">Multipart Form: <code>file</code> (opt), <code>url</code> (opt), <code>clientId</code> (req)</td><td style="text-align:left;"><code>{ &quot;documentId&quot;: &quot;str&quot;, &quot;s3Key&quot;: &quot;str&quot;, &quot;status&quot;: &quot;processing&quot; }</code></td></tr><tr><td style="text-align:left;"><code>/ai/rag/documents/{id}</code></td><td style="text-align:center;"><code>DELETE</code></td><td style="text-align:left;">Xóa tài liệu</td><td style="text-align:left;">Path Param: <code>id</code> (documentId), Query: <code>clientId</code></td><td style="text-align:left;"><code>{ &quot;status&quot;: &quot;success&quot;, &quot;message&quot;: &quot;Document deleted&quot; }</code></td></tr><tr><td style="text-align:left;"><code>/ai/content/generate</code></td><td style="text-align:center;"><code>POST</code></td><td style="text-align:left;">Sinh bài viết theo RAG &amp; Trend</td><td style="text-align:left;"><code>{ &quot;topic&quot;: &quot;str&quot;, &quot;clientId&quot;: &quot;str&quot;, &quot;tone&quot;: &quot;str&quot;, &quot;platform&quot;: &quot;str&quot; }</code></td><td style="text-align:left;"><code>{ &quot;hook_3s&quot;: &quot;str&quot;, &quot;body&quot;: &quot;str&quot;, &quot;cta&quot;: &quot;str&quot;, &quot;metadata&quot;: { &quot;platform&quot;: &quot;str&quot; } }</code></td></tr><tr><td style="text-align:left;"><code>/ai/generate/hashtags</code></td><td style="text-align:center;"><code>POST</code></td><td style="text-align:left;">Tự động trích lọc Hashtag</td><td style="text-align:left;"><code>{ &quot;content&quot;: &quot;str&quot;, &quot;brandName&quot;: &quot;str&quot;, &quot;trendName&quot;: &quot;str&quot; }</code></td><td style="text-align:left;"><code>[&quot;#hashtag1&quot;, &quot;#hashtag2&quot;, &quot;#hashtag3&quot;]</code></td></tr><tr><td style="text-align:left;"><code>/ai/generate/refine</code></td><td style="text-align:center;"><code>POST</code></td><td style="text-align:left;">Sửa bài viết theo feedback</td><td style="text-align:left;"><code>{ &quot;originalPost&quot;: &quot;str&quot;, &quot;feedback&quot;: &quot;str&quot;, &quot;clientId&quot;: &quot;str&quot; }</code></td><td style="text-align:left;"><code>{ &quot;hook_3s&quot;: &quot;str&quot;, &quot;body&quot;: &quot;str&quot;, &quot;cta&quot;: &quot;str&quot; }</code></td></tr><tr><td style="text-align:left;"><code>/ai/trends</code></td><td style="text-align:center;"><code>GET</code></td><td style="text-align:left;">Lấy danh sách xu hướng hot</td><td style="text-align:left;">Query Params: <code>category</code> (opt), <code>limit</code> (opt)</td><td style="text-align:left;"><code>[ { &quot;rank&quot;: 1, &quot;trend&quot;: &quot;str&quot;, &quot;finalScore&quot;: 0.0 } ]</code></td></tr></tbody></table><hr><h2 id="_4-so-đo-lien-ket-giua-cac-api-db-api-integration-call-flow" tabindex="-1">4. Sơ Đồ Liên Kết Giữa Các API &amp; DB (API Integration &amp; Call Flow) <a class="header-anchor" href="#_4-so-đo-lien-ket-giua-cac-api-db-api-integration-call-flow" aria-label="Permalink to &quot;4. Sơ Đồ Liên Kết Giữa Các API &amp; DB (API Integration &amp; Call Flow)&quot;">​</a></h2><p>Sơ đồ tuần tự (Sequence Diagram) dưới đây mô tả chi tiết luồng gọi và xử lý dữ liệu khi người dùng kích hoạt yêu cầu sinh bài viết quảng cáo bắt trend (Online Generation Flow):</p><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    autonumber</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor User as Dashboard Client</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant GW as API Gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant API as AI Service API</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant RAG as GraphRAG Engine</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant DB as Databases (Chroma &amp; Neo4j)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant LLM as LLM Coordinator (Groq/Claude)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    User-&gt;&gt;GW: Click &quot;Generate Content&quot; (Topic, Tone, Platform)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;API: POST /ai/content/generate (X-Internal-Key)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    API-&gt;&gt;RAG: Call Ingestion-Retrieval pipeline</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Note over RAG: Bước 1: Query Normalization&lt;br/&gt;(Sửa từ lóng/viết tắt/emoji)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    RAG-&gt;&gt;DB: Bước 2: ChromaDB Query (Vector Search)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    DB--&gt;&gt;RAG: Trả về Top K Chunks &amp; thực thể gốc (Entry Points)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    RAG-&gt;&gt;DB: Bước 3: Neo4j Cypher Query (Graph Traversal 1-2 Hops)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    DB--&gt;&gt;RAG: Trả về mạng lưới node &amp; quan hệ cục bộ</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Note over RAG: Bước 4: BM25 Scoring &amp; Pruning&lt;br/&gt;(Lọc bỏ node rác tương quan thấp)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Note over RAG: Bước 5: GraphRAG Context Builder&lt;br/&gt;(Đóng gói context phân cấp dạng chuỗi)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    RAG--&gt;&gt;API: Trả về Context sạch hoàn chỉnh</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    API-&gt;&gt;LLM: Gửi Prompt chứa Context &amp; Hook 3s Rules</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt Groq API hoạt động bình thường</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        LLM-&gt;&gt;LLM: Gửi request tới Groq (Llama 3)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        LLM--&gt;&gt;API: Trả về bài viết thô (JSON format)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    else Groq trả lỗi (Rate limit 429 hoặc Timeout)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        Note over LLM: Kích hoạt Fallback logic</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        LLM-&gt;&gt;LLM: Switch sang Anthropic API (Claude 3.5)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        LLM--&gt;&gt;API: Trả về bài viết thô (JSON format)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Note over API: Bước 6: Platform Length Optimizer&lt;br/&gt;(Cắt tỉa thông minh/Auto-summarize)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    API--&gt;&gt;GW: Trả về bài viết hoàn thiện (JSON Hook, Body, CTA)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW--&gt;&gt;User: Hiển thị bài viết quảng cáo bắt trend lên màn hình</span></span></code></pre></div><hr><h2 id="_5-phan-tich-ky-thuat-cac-điem-nhan-kien-truc-architectural-highlights" tabindex="-1">5. Phân Tích Kỹ Thuật Các Điểm Nhấn Kiến Trúc (Architectural Highlights) <a class="header-anchor" href="#_5-phan-tich-ky-thuat-cac-điem-nhan-kien-truc-architectural-highlights" aria-label="Permalink to &quot;5. Phân Tích Kỹ Thuật Các Điểm Nhấn Kiến Trúc (Architectural Highlights)&quot;">​</a></h2><p>Sau khi hoàn thành Iteration 2, kiến trúc hệ thống AI được tối ưu hóa sâu ở các khâu trọng yếu sau:</p><h3 id="a-hieu-nang-tim-kiem-chromadb-hnsw-indexing" tabindex="-1">A. Hiệu năng tìm kiếm ChromaDB (HNSW Indexing) <a class="header-anchor" href="#a-hieu-nang-tim-kiem-chromadb-hnsw-indexing" aria-label="Permalink to &quot;A. Hiệu năng tìm kiếm ChromaDB (HNSW Indexing)&quot;">​</a></h3><p>ChromaDB lưu trữ vector biểu diễn ngữ nghĩa của các chunk tài liệu tri thức. Hệ thống sử dụng thuật toán <strong>HNSW (Hierarchical Navigable Small World)</strong> xây dựng đồ thị nhiều tầng. Việc tìm kiếm lân cận gần nhất (Nearest Neighbor) được giới hạn độ phức tạp ở mức <strong>$\\mathcal{O}(\\log N)$</strong> thay vì quét tuyến tính toàn bộ DB ($\\mathcal{O}(N)$). Phép tìm kiếm vector lấy Top-K Chunks hoàn tất dưới <strong>50ms</strong>, đảm bảo tổng thời gian xử lý cực kỳ nhanh.</p><h3 id="b-truy-van-tri-thuc-đo-thi-neo4j-cypher-traversal" tabindex="-1">B. Truy vấn tri thức đồ thị (Neo4j Cypher Traversal) <a class="header-anchor" href="#b-truy-van-tri-thuc-đo-thi-neo4j-cypher-traversal" aria-label="Permalink to &quot;B. Truy vấn tri thức đồ thị (Neo4j Cypher Traversal)&quot;">​</a></h3><p>Không giống các hệ thống RAG thông thường chỉ tìm text giống nhau, hệ thống lai sử dụng Neo4j để lưu mạng lưới thực thể. Câu Cypher động duyệt 1-2 hops giúp kết nối tất cả các thực thể liên quan (ví dụ: biết được KOL nào quảng bá món trà sữa, địa điểm bán ở đâu). Việc duyệt đồ thị chỉ thực hiện cục bộ từ các Entry Points lấy ra từ ChromaDB nên lượng RAM tiêu thụ và độ trễ truy vấn đồ thị luôn ở mức tối thiểu.</p><h3 id="c-bm25-scoring-pruning-cat-tia-ngu-canh" tabindex="-1">C. BM25 Scoring &amp; Pruning (Cắt tỉa ngữ cảnh) <a class="header-anchor" href="#c-bm25-scoring-pruning-cat-tia-ngu-canh" aria-label="Permalink to &quot;C. BM25 Scoring &amp; Pruning (Cắt tỉa ngữ cảnh)&quot;">​</a></h3><p>Để giải quyết bài toán token limits của Groq (Llama 3) và Claude, thuật toán BM25 được tích hợp làm bộ lọc thông minh. Node nào có tần suất xuất hiện quá phổ biến trong baseline lịch sử hoặc không liên quan trực tiếp đến query của người dùng sẽ bị loại bỏ ngay lập tức trước khi đưa vào RAG Context Builder. Việc này giúp giảm trung bình 30%-40% chiều dài context gửi sang prompt, tăng tốc độ xử lý của LLM và tiết kiệm chi phí gọi API.</p><h3 id="d-llm-fallback-retry-strategy" tabindex="-1">D. LLM Fallback &amp; Retry Strategy <a class="header-anchor" href="#d-llm-fallback-retry-strategy" aria-label="Permalink to &quot;D. LLM Fallback &amp; Retry Strategy&quot;">​</a></h3><p>Bộ điều phối <code>LLMService</code> đóng vai trò là một Router tự động bắt lỗi thông minh. Khi nhận được exception rate-limit (HTTP status 429) hoặc timeout từ Groq Cloud API, hệ thống sẽ thực hiện thử lại (Retry) với exponential backoff. Nếu sau 3 lần vẫn thất bại, hệ thống tự động định tuyến (fallback) sang Claude API (Anthropic Cloud) và biên dịch kết quả trả về dưới định dạng thống nhất để đảm bảo trải nghiệm của người dùng hoàn toàn liền mạch.</p><h3 id="e-vai-tro-cua-aws-s3-trong-luu-tru-va-tai-xu-ly-tri-thuc-aws-s3-storage-reprocessing-role" tabindex="-1">E. Vai trò của AWS S3 trong lưu trữ và tái xử lý tri thức (AWS S3 Storage &amp; Reprocessing Role) <a class="header-anchor" href="#e-vai-tro-cua-aws-s3-trong-luu-tru-va-tai-xu-ly-tri-thuc-aws-s3-storage-reprocessing-role" aria-label="Permalink to &quot;E. Vai trò của AWS S3 trong lưu trữ và tái xử lý tri thức (AWS S3 Storage &amp; Reprocessing Role)&quot;">​</a></h3><p>AWS S3 đóng vai trò là kho lưu trữ tài liệu thô ban đầu, hỗ trợ cho việc vận hành bền vững của hệ thống RAG thông qua 3 khía cạnh:</p><ul><li><strong>Lưu trữ tài liệu gốc:</strong> Lưu trữ file nguyên bản (<code>.pdf</code>, <code>.docx</code>, <code>.txt</code>) theo cấu trúc phân cấp <code>rag/{clientId}/{documentId}/{filename}</code> để phục vụ tải xuống và đối chiếu nguồn gốc thông tin (Fact-Checking).</li><li><strong>Tái xử lý dữ liệu (Re-indexing):</strong> Khi hệ thống AI cập nhật thuật toán (như đổi kích thước <code>chunk_size</code> hoặc nâng cấp mô hình embedding), hệ thống có thể đọc trực tiếp tài liệu gốc trên S3 để sinh lại vector mà không yêu cầu khách hàng tải lại tài liệu.</li><li><strong>Xử lý bất đồng bộ (Asynchronous Background Tasks):</strong> API Upload trả về ngay kết quả phản hồi <code>200 OK</code> cho client sau khi đẩy file lên S3, sau đó luồng ngầm (Background Task) sẽ tải file từ S3 về để thực hiện bóc tách, sinh vector và NER, giúp giảm tối đa độ trễ của endpoint.</li></ul>`,33)])])}const E=s(e,[["render",l]]);export{d as __pageData,E as default};
