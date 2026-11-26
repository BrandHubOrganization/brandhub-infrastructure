# AI Service Internal Architecture — `brandhub-ai-service`

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [Business–AI REST Contract](./business-ai-rest-contract.md) · [Brand RAG Pipeline](./brand-rag-pipeline-design.md) · [Current AI Content Flow](./ai-content-flow.md) · [AI Models R&D](../ai-models/README.md)

Code-verified internal architecture of `brandhub-ai-service` (Python 3.11+, FastAPI, port `8082` on dedicated `brandhub-ai` EC2 `172.31.20.60`), powering all 19 AI functional requirements (`FR 3.7.1`–`3.7.19` / `UC-088`–`UC-106`) plus community compliance moderation (`FR 3.6.33`).

---

## 1. Layered FastAPI Codebase Structure

```text
brandhub-ai-service/
├── app/
│   ├── main.py                                # Lifespan manager (SERVICE_ROLE=all|api|worker), CORS, router mounts
│   ├── api/
│   │   ├── v1/router.py                       # Mounts 15 domain routers under /api/v1/ai/*
│   │   ├── v1/endpoints/
│   │   │   ├── content.py                     # /ai/content: captions, refine, adapt, hashtags, moderate, brand-profile
│   │   │   ├── rag.py                         # /ai/rag: Brand Guideline document upload/chunking & deletion
│   │   │   ├── ambassador.py                  # /ai/ambassadors: presets, Qwen 2.1 candidate & 3-angle character sheet
│   │   │   ├── video.py                       # /ai/video: styles, Wan VACE generate/status, edit-plan, reel-auto-edit
│   │   │   ├── product_video.py               # /ai/product-video: durable storyboard plan, scene render & status
│   │   │   ├── server_video_edit.py           # /ai/video-edit: agentic server video edit plan/jobs/memory/capabilities
│   │   │   ├── trends.py                      # /ai/trends: top trends, for-brand, boards, summary, crawl/pipeline config
│   │   │   ├── workspace_trends.py            # /ai/trends/explore: workspace trend list, matrix & history
│   │   │   ├── trend_replays.py               # /ai/trends/replays: historical dataset replay runner
│   │   │   ├── trend_pipeline.py              # /ai/trends/pipeline: 1.1 MB streaming proxy to brandhub-crawl (:8084)
│   │   │   ├── trend_graph.py                 # /ai/graph/explorer: interactive Neo4j catalog, neighborhood & expand
│   │   │   ├── knowledge_graph.py             # /ai/graph: graph ingestion & trend traversal
│   │   │   ├── ner.py                         # /ai/ner: LLM Named Entity & Relation extraction
│   │   │   ├── collaborators.py               # /ai/collaborators: KOL/Press/Banner/TV partner recommendation
│   │   │   ├── references.py                  # /ai/references: moodboard reference recommendation & URL unfurling
│   │   │   └── internal_{trends,backups}.py   # /internal/ai/*: internal dependency health & backup probes
│   │   └── v2/endpoints/commercial_image.py   # /api/v2/ai/image/commercial/*: Qwen 3-image commercial ad synthesis
│   ├── services/
│   │   ├── caption_service.py                 # 3-variant GraphRAG captions + PhoBERT emotion + hallucination signals
│   │   ├── llm_service.py                     # Multi-provider router (Groq -> Deploy -> Gemini -> Claude + CircuitBreaker)
│   │   ├── rag_ingestion_service.py           # PDF/DOCX/TXT/URL extraction, 500c/50o chunking, 384d ChromaDB indexing
│   │   ├── qwen_ambassador_client.py          # Remote Vast.ai Qwen Image 2.1 worker client (ambassador + 3-ref ad image)
│   │   ├── ltx_director.py & veo_client.py    # Claude JSON director -> Vast.ai Wan 2.2 Fun VACE 14B (:10200) + ffmpeg mix
│   │   ├── product_video/ & server_video_edit/# Multi-scene coordinator & agentic video editing services
│   │   ├── pipeline/steps/t0..t7_*.py         # Trend pipeline: Ingestion -> Bot Filter -> NLP -> BM25 Burst -> PhoBERT -> Fusion
│   │   └── trend_fit/                         # Neo4j 2s/3s bounded graph_context, lunar/VN moments & brand-fit scoring
│   └── workers/crawl_batch_consumer.py        # Async RabbitMQ consumer processing crawled social post batches
```

### Runtime Role Separation (`SERVICE_ROLE`)

`app/main.py` supports `SERVICE_ROLE=all` (default on `brandhub-ai`), `api` (HTTP + `start_trend_scheduler`), or `worker` (`CrawlBatchConsumer` background task), disabling `/docs`, `/redoc`, and `/openapi.json` automatically when `ENV=prod`.

---

## 2. Model & Compute Routing Matrix

| Capability & SRS Mapping | Execution Engine & Model Stack | Latency & Guardrails |
| :--- | :--- | :--- |
| **3-Variant Caption & Hashtag Generation** (`FR 3.7.6`, `3.7.14`) | `Gemini` (`gemini-3.5-flash-lite`) / `Groq` (`openai/gpt-oss-120b`) + ChromaDB (`intfloat/multilingual-e5-small` `384d`) + Neo4j provenance + `Humanizer` + `PhoBERT` emotion | Synchronous (`< 15s`); verifies numeric claims against source context and runs `text_moderation_service` |
| **Compliance & Safety Check** (`FR 3.6.33`, `3.10.4`) | `text_moderation_service.py` + `image/safety_guardrails.py` (`PASSED` \| `WARNING` \| `BLOCKED`) | Blocks profanity, violence, hate speech, and platform-banned terms before publishing or GPU spend |
| **Virtual Brand Ambassador & Character Sheet** (`FR 3.7.7`) | `QwenAmbassadorClient` → **Qwen Image 2.1** on Vast.ai GPU worker (`1024×1024` portrait & 3-angle character sheet) | Enforces `<= 20 MB` RGB PNG normalization; stores outputs under `s3://brandhub-media-134875421878/qwen-ambassador/*` |
| **Commercial Advertising Image** (`FR 3.7.8`–`3.7.9`) | `v2/endpoints/commercial_image.py` → **Qwen Image 2.1 3-Reference Workflow** (Image 1: Ambassador/Preset, Image 2: Product, Image 3: Pose/Style; `4:5` `896×1120`, `9:16` `576×1024`, `16:9` `1024×576`) | Pre-validates prompt safety (`validate_prompt_safety`); returns `X-Inference-Time-Ms` telemetry headers |
| **15–20s Product Video Generation** (`FR 3.7.10`–`3.7.11`) | `ltx_director.py` (**Claude** JSON director + `Draft202012Validator`) → **Wan 2.2 Fun VACE 14B + Qwen 2.1 Turnaround/Storyboard** (`gpu-workers/wan-vace/` `:10200`) + `ffmpeg` CC0 audio fade mix | Validates `4n+1` frames (`85` @ `16 fps`), `8`-frame overlap, and `15–21s` bounds **before** GPU submission |
| **Server Auto-Edit (`Video Space`)** | `server_video_edit/` → `brandhub-edit-video` EC2 (`172.31.20.80:8095`) | Asynchronous job (`plan` → `jobs` → `jobs/{id}`) with per-owner style memory (`memory/{workspace_id}/{owner_id}`) |
| **Trend Detection (`T0`–`T7`) & Collaborator Match** (`FR 3.7.1`–`3.7.2`, `3.7.13`, `3.7.19`) | Bot filter (`T1`) → Vietnamese NLP normalization (`T2`) → **BM25 + Z-Score Burst** (`T4`) → **PhoBERT** sentiment (`T5`) → **Neo4j Graph Virality Fusion** (`T7`) | Publishes Top-K snapshots to Redis (`6h` TTL) & Neo4j Aura; crawler HTTP calls route via `CRAWLER_API_URL` (`crawl-gate` `:8084`) |

---

## 3. Multi-Tenant Vector & Graph Isolation

1. **ChromaDB Tenant Isolation (`vector_store_service.py`)**: Every chunk uses deterministic ID `{documentId}:{chunkIndex}` (`384d` Cosine HNSW) and **must** carry `metadata.clientId` filtered with `where={"clientId": {"$eq": client_id}}` ([ChromaDB Collection Design](../database/ai-vector/chromadb-collection-design.md)).
2. **Bounded Neo4j Provenance (`trend_fit/graph_context.py`)**: During caption generation with a `trendId`, `ai-service` queries `(:CrawledPost)-[:BELONGS_TO]->(:Trend)` and `(:CrawledPost)-[:MENTIONS]->(:Entity)` with a strict **`2s` query / `3s` total deadline** (max `3` source posts, `12` entity mentions, `3,000` chars), excluding foreign `brand_id` nodes and gracefully degrading on timeout.
3. **Zero Direct Credit Mutation**: `ai-service` logs model latency/tokens to MongoDB `ai_usage_logs` only; `brandhub-business-service` owns all credit pricing, reservations, captures, and refunds in PostgreSQL.
