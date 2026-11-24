# DA-E07-06 — OpenAPI 3.1 Specification for `brandhub-ai-service`

> Navigation: [← Knowledge Base Hub](../index.md) · [← API Contracts Index](./README.md) · [Business–AI REST Contract](../architecture/business-ai-rest-contract.md) · [AI Service Architecture](../architecture/ai-service-architecture.md) · [API Response Format](./api-response-format.md)

Complete, code-verified internal OpenAPI 3.1 contract for **`brandhub-ai-service` (`:8082`)**, extracted directly from `app/main.py`, `app/api/v1/router.py`, `app/api/v1/endpoints/*.py`, and `app/api/v2/endpoints/commercial_image.py`.

---

## 1. Runtime Exposure & Security Model

- **Internal Network Boundary**: `brandhub-ai-service` listens on `http://ai-service:8082` locally and `http://172.31.20.60:8082` (`brandhub-ai` EC2) in production. It is **never** routed publicly through `brandhub-api-gateway`.
- **Interactive Docs Availability (`app/main.py`)**:
  - **Development (`ENV=dev`)**: Swagger UI at `http://localhost:8082/docs`, ReDoc at `/redoc`, and raw JSON schema at `/openapi.json`.
  - **Production (`ENV=prod`)**: `docs_url`, `redoc_url`, and `openapi_url` are automatically set to `None`.
- **Service-to-Service Authentication (`verify_internal_key`)**:
  ```yaml
  components:
    securitySchemes:
      InternalApiKey:
        type: apiKey
        in: header
        name: X-Internal-Key
  ```
  Every `/api/v1/ai/**`, `/api/v2/ai/**`, and `/internal/ai/**` endpoint validates `X-Internal-Key` against `INTERNAL_SERVICE_KEY` using constant-time comparison and propagates `X-Request-Id` for distributed tracing.

---

## 2. Complete Router & Endpoint Inventory (18 Routers / 68 Endpoints)

### 2.1 Content, Captions, Hashtags & Moderation (`endpoints/content.py` — `/api/v1/ai/content`)

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `POST` | `/api/v1/ai/content/generate` *(+ `/captions/generate`)* | `generate_content` | Quick single-post caption or 3-variant Brand Hybrid GraphRAG generation (`HOOK_DRIVEN`, `STORYTELLING`, `DIRECT_CTA`, `FR 3.7.6`) |
| `POST` | `/api/v1/ai/content/captions/refine` | `refine_caption_endpoint` | Iterative caption rewrite incorporating user feedback + `Humanizer` (`FR 3.7.6`) |
| `POST` | `/api/v1/ai/content/captions/adapt` | `adapt_caption_endpoint` | Cross-platform tone/length adaptation across Facebook, Instagram, TikTok, and Threads |
| `POST` | `/api/v1/ai/content/hashtags` | `generate_hashtags` | Contextual + trend-aware hashtag suggestions (`FR 3.7.14`) |
| `POST` | `/api/v1/ai/content/moderate` | `moderate_caption_endpoint` | Community safety & profanity compliance check (`PASSED` \| `WARNING` \| `BLOCKED`, `FR 3.6.33`) |
| `POST` | `/api/v1/ai/content/brand-profile/extract` | `extract_brand_profile_endpoint` | Extracts structured brand voice/persona attributes from Brand Guideline text |

### 2.2 Brand Knowledge RAG (`endpoints/rag.py` — `/api/v1/ai/rag`)

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `POST` | `/api/v1/ai/rag/documents` | `upload_document` | Multipart upload (`pdf`/`docx`/`txt`/`url`), S3 archival (`rag/{clientId}/{docId}/...`), `500`/`50` chunking, and `384d` ChromaDB indexing (`FR 3.7.3`–`3.7.4`) |
| `DELETE` | `/api/v1/ai/rag/documents/{document_id}` | `delete_document` | Removes S3 source object and purges all `{documentId}:*` vectors from ChromaDB (`FR 3.7.5`) |

### 2.3 Virtual Brand Ambassador & Commercial Image (`ambassador.py` & `v2/commercial_image.py`)

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `GET` | `/api/v1/ai/ambassadors/presets` | `list_ambassador_presets` | Lists built-in studio model presets (`MODEL_PRESETS`) |
| `POST` | `/api/v1/ai/ambassadors/generate` | `generate_ambassador` | Synthesizes Virtual Brand Ambassador portrait via Vast.ai **Qwen Image 2.1** (`FR 3.7.7`) |
| `POST` | `/api/v1/ai/ambassadors/character-sheet` | `generate_character_sheet` | Generates 3-panel (`1024×1024`) front/profile/three-quarter character turnaround sheet (`FR 3.7.7`) |
| `POST` | `/api/v2/ai/image/commercial/generate` | `generate_commercial_image` | 3-reference Qwen Image 2.1 ad composition (Ambassador + Product + Style/Pose; `4:5`, `9:16`, `16:9`, `auto`; `<= 20 MB` RGB validation + `validate_prompt_safety`, `FR 3.7.8`–`3.7.9`) |
| `GET` | `/api/v2/ai/image/commercial/generations/{generation_id}` | `get_commercial_generation` | Retrieves cached commercial generation result and latency telemetry |
| `GET` | `/api/v2/ai/image/commercial/health` | `commercial_health` | Probes remote Qwen GPU worker readiness |

### 2.4 Short Video, Durable Product Video & Server Video Edit (`video.py`, `product_video.py`, `server_video_edit.py`)

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `GET` | `/api/v1/ai/video/styles` | `list_video_styles` | Lists curated camera-movement & genre video templates (`FR 3.7.10`) |
| `POST` | `/api/v1/ai/video/generate` | `generate_video_endpoint` | Launches Claude JSON director (`ltx_director.py`) + Vast.ai **Wan 2.2 Fun VACE 14B** (`:10200`) 15–20s render + `ffmpeg` CC0 music mix (`FR 3.7.11`) |
| `GET` | `/api/v1/ai/video/{job_id}/status` | `get_video_status_endpoint` | Polls async video job state (`PENDING` \| `RUNNING` \| `COMPLETED` \| `FAILED`) and S3 MP4 URL |
| `POST` | `/api/v1/ai/video/edit-plan` · `/reel-auto-edit` | `edit_video_plan` / `reel_auto_edit_endpoint` | Generates structured timeline edit plan or automated short-form reel assembly |
| `POST` · `GET` | `/api/v1/ai/product-video/plan` · `/render` · `/render/{render_id}` | `create_plan` / `create_render` / `render_status` | Multi-scene Product Video Production storyboard planning & durable scene rendering |
| `POST` · `GET` · `PUT` | `/api/v1/ai/video-edit/plan` · `/plans/{job_id}` · `/jobs` · `/jobs/{job_id}` · `/memory/{workspace_id}/{owner_id}` · `/capabilities` | `server_video_edit` handlers | Agentic server-side Video Space auto-editor (`brandhub-edit-video` `:8095`) + per-owner style memory |

### 2.5 Trends, Workspace Exploration, Replays & Crawler Proxy (`trends.py`, `workspace_trends.py`, `trend_replays.py`, `trend_pipeline.py`)

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` | `/api/v1/ai/trends` · `/neo4j` · `/for-brand` · `/boards/{source}` · `/summary` · `/normalize` | `trends.py` handlers | Ranked Vietnam trends (Redis `ZSET` / Neo4j), brand-fit scoring, source boards, and text normalization (`FR 3.7.1`, `3.7.14`) |
| `GET` | `/api/v1/ai/trends/explore` · `/explore/matrix` · `/explore/history` | `list_trends` / `matrix` / `history` | Workspace trend discovery matrix and historical trajectory (`Neo4jTrendService`) |
| `GET` · `POST` · `PUT` | `/api/v1/ai/trends/{crawl,crawl-config,crawl-cookie,crawl-runs,pipeline-config}` | `trends.py` admin handlers | Crawler schedule config (`FR 3.7.13`), session cookie upload, run history, and `T0`–`T7` pipeline tuning |
| `GET` · `POST` | `/api/v1/ai/trends/pipeline` · `/pipeline/{path:path}` | `forward` | Bounded (`<= 1.1 MB`) internal streaming proxy to `brandhub-crawl` (`CRAWLER_API_URL`, via `crawl-gate` `:8084`) |
| `GET` · `POST` | `/api/v1/ai/trends/replays{,/preview,/{identity},/{identity}/start,/{identity}/cancel,/{identity}/days/{day}}` | `trend_replays.py` handlers | Multi-day historical dataset replay runner for benchmarking `T0`–`T7` trend precision |

### 2.6 Trend Knowledge Graph, NER, Collaborators, References & Internal Probes

| Method | Path | Handler | Purpose & SRS Mapping |
| :---: | :--- | :--- | :--- |
| `GET` · `POST` | `/api/v1/ai/graph/explorer/{catalog,trends,neighborhood,nodes,expand,overview,overview/edges,overview/root,overview/neighbors}` | `trend_graph.py` handlers | Interactive Neo4j Trend Knowledge Graph explorer (`FR 3.7.2`) |
| `POST` · `GET` | `/api/v1/ai/graph/ingest` · `/api/v1/ai/graph/trends/{trend_id}` | `knowledge_graph.py` handlers | Batch graph ingestion and per-trend entity subgraph traversal |
| `POST` | `/api/v1/ai/ner/extract` | `extract_entities_and_relations` | LLM Named Entity & Relation extraction (`:KOL`, `:Brand`, `:Product`, `:Location`, `:Dish`) |
| `POST` | `/api/v1/ai/collaborators/recommend` | `recommend_collaborators` | Ranks third-party KOL/KOC, Press, Banner, and TV partners for a campaign brief (`FR 3.7.19`) |
| `POST` | `/api/v1/ai/references/recommend` · `/unfurl` | `recommend` / `unfurl` | Recommends visual/copy references and unfurls OpenGraph metadata for Workspace Moodboards |
| `GET` · `POST` | `/health` · `/internal/ai/trends/{fetch,dependencies}` · `/internal/ai/backups/{health,status,run,restore}` | Health & internal handlers | Container liveness (`/health`) and internal dependency/backup diagnostics (`FR 3.10.3`) |

---

## 3. Exporting & Validating the Runtime OpenAPI Schema

When running `brandhub-ai-service` locally (`ENV=dev` on `:8082`):

```bash
curl -fsS http://localhost:8082/openapi.json -o docs/openapi.json
python -c "import json, yaml; open('docs/openapi.yaml','w',encoding='utf-8').write(yaml.safe_dump(json.load(open('docs/openapi.json',encoding='utf-8')), sort_keys=False, allow_unicode=True))"
```
