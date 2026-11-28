# `business-service` ↔ `ai-service` — Internal REST Contract

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [Service Boundaries](./service-boundaries.md) · [AI OpenAPI Spec](../api/openapi-spec-ai-service.md) · [RabbitMQ Publisher Contract](/view?file=architecture/rabbitmq-publisher-contract.html)

Defines the service-to-service HTTP/REST contract, authentication headers, timeout/retry rules, durable job state machines, and atomic AI credit accounting between `brandhub-business-service` (`:8081`) and `brandhub-ai-service` (`:8082`).

---

## 1. Transport, Network Isolation & Authentication

- **Internal Base URL**:
  - Local Docker (`brandhub-network`): `http://ai-service:8082`
  - AWS Production (`ap-southeast-1`): `http://172.31.20.60:8082` (`brandhub-ai` EC2, restricted by `brandhub-ai-sg` to `core`, `gateway`, and `crawl` security groups — **zero** public routes on `brandhub-api-gateway`).
- **Authentication (`verify_internal_key`)**: Every internal call carries `X-Internal-Key: <INTERNAL_SERVICE_KEY>` verified via constant-time comparison in `app/core/security.py`, plus `X-Request-Id: <uuid>` propagated from `RequestIdWebFilter` for cross-service log correlation.
- **Timeout & Retry Budget in `business-service`**:
  - **Caption / Hashtag / Moderation / Collaborator / RAG Query**: `30s` read timeout; at most `1` retry (`2s` backoff) on TCP connect failure; **never** retry `4xx` or post-inference `5xx` without idempotency keys.
  - **Synchronous Ambassador / Commercial Image (`Qwen Image 2.1`)**: `120s`–`180s` read timeout (Vast.ai GPU execution).
  - **Product Video (`Wan 2.2 Fun VACE 14B`) & Server Auto-Edit**: Asynchronous submit + polling lifecycle (`202 Accepted` / `jobId` polling) coordinated via PostgreSQL `product_video_*` and MongoDB `video_auto_edits` leases.

---

## 2. Complete Service-to-Service Endpoint Mapping

| Business Caller / Domain | `ai-service` Method & Path | SRS FR / Feature | Purpose |
| :--- | :--- | :---: | :--- |
| **Caption & Copywriting** (`AiCaptionService`, `AiGenerationController`) | `POST /api/v1/ai/content/generate`<br>`POST /api/v1/ai/content/captions/generate` *(alias)*<br>`POST /api/v1/ai/content/captions/refine`<br>`POST /api/v1/ai/content/captions/adapt`<br>`POST /api/v1/ai/content/hashtags`<br>`POST /api/v1/ai/content/moderate`<br>`POST /api/v1/ai/content/brand-profile/extract` | `FR 3.7.6`, `3.7.14`, `3.6.33` | Quick single-post generation, 3-variant Hybrid GraphRAG captions (`HOOK_DRIVEN`, `STORYTELLING`, `DIRECT_CTA`), platform adaptation, contextual hashtags, and safety moderation |
| **Brand Knowledge RAG** | `POST /api/v1/ai/rag/documents`<br>`DELETE /api/v1/ai/rag/documents/{document_id}` | `FR 3.7.3`–`3.7.5` | Uploads PDF/DOCX/TXT/URL to S3, chunks (`500`/`50`), embeds (`384d`), and purges vectors from ChromaDB |
| **Virtual Brand Ambassador** (`AiGenerationController`) | `GET /api/v1/ai/ambassadors/presets`<br>`POST /api/v1/ai/ambassadors/generate`<br>`POST /api/v1/ai/ambassadors/character-sheet` | `FR 3.7.7` | Lists built-in model presets; generates custom portrait & 3-angle character turnaround sheet via Vast.ai Qwen 2.1 |
| **Commercial Ad Image** (`AiGenerationController`) | `POST /api/v2/ai/image/commercial/generate`<br>`GET /api/v2/ai/image/commercial/generations/{id}`<br>`GET /api/v2/ai/image/commercial/health` | `FR 3.7.8`–`3.7.9` | 3-reference Qwen Image 2.1 composition (Ambassador + Product + Style/Pose) across `4:5`, `9:16`, `16:9`, or `auto` |
| **Short & Product Video** (`AiVideoController`, `ProductVideoController`) | `GET /api/v1/ai/video/styles`<br>`POST /api/v1/ai/video/generate`<br>`GET /api/v1/ai/video/{job_id}/status`<br>`POST /api/v1/ai/product-video/plan`<br>`POST /api/v1/ai/product-video/render`<br>`GET /api/v1/ai/product-video/render/{render_id}` | `FR 3.7.10`–`3.7.11` | Claude director + Vast.ai **Wan 2.2 Fun VACE 14B** 15–20s video generation and multi-scene durable product video rendering |
| **Server Video Auto-Edit** (`VideoAutoEditController`) | `POST /api/v1/ai/video-edit/plan`<br>`GET /api/v1/ai/video-edit/plans/{job_id}`<br>`POST /api/v1/ai/video-edit/jobs`<br>`GET /api/v1/ai/video-edit/jobs/{job_id}`<br>`GET\|PUT /api/v1/ai/video-edit/memory/{ws}/{owner}`<br>`GET /api/v1/ai/video-edit/capabilities` | Video Space | Agentic timeline planning, automated video assembly, and per-user editing preference memory |
| **Trends, Graph & Crawler Admin** (`WorkspaceTrendController`, `AdminTrend*Controller`) | `GET /api/v1/ai/trends` · `POST /api/v1/ai/trends/for-brand`<br>`GET /api/v1/ai/trends/boards/{source}` · `/summary`<br>`GET /api/v1/ai/trends/explore/{,matrix,history}`<br>`GET\|POST /api/v1/ai/trends/{crawl-config,crawl-runs,crawl-cookie,pipeline-config}`<br>`ANY /api/v1/ai/trends/pipeline/**`<br>`GET\|POST /api/v1/ai/trends/replays/**`<br>`GET\|POST /api/v1/ai/graph/explorer/**` · `/ai/graph/**` | `FR 3.7.1`–`3.7.2`, `3.7.13` | Workspace trend discovery, brand-fit ranking, Neo4j Knowledge Graph explorer, replay evaluation, and `Admin` crawler control |
| **Collaborators & Moodboard References** | `POST /api/v1/ai/collaborators/recommend`<br>`POST /api/v1/ai/references/{recommend,unfurl}` | `FR 3.7.19` | Ranks third-party KOL/Press/Banner/TV collaborators (`third_party_collaborators`) and recommends moodboard references |
| **System Health & Backups** | `GET /health`<br>`GET /internal/ai/trends/{fetch,dependencies}`<br>`GET\|POST /internal/ai/backups/{health,status,run,restore}` | `FR 3.10.3` | Liveness and internal dependency probes |

---

## 3. Atomic Double-Entry AI Credit Settlement Protocol

`brandhub-business-service` (`AiCreditGenerationService` + `ProductVideoStore`) guarantees zero unbilled GPU/LLM execution and zero lost credits on upstream failure:

```text
1. Price & Quota Check (PostgreSQL ACID):
   - Resolve unit cost from ai_credit_operation_prices (managed by Admin via FR 3.10.10–3.10.12).
   - Verify workspace monthly cap in workspace_credit_limits (set by Owner via FR 3.9.6).
   - Lock available grant balances in agency_credit_wallets / credit_grants (FIFO by expires_at).
   - Insert ai_credit_reservations + credit_reservation_allocations (bound to idempotency_key).

2. Dispatch to ai-service (:8082, X-Internal-Key):
   - Synchronous (Caption / Ambassador / Commercial Image) OR Asynchronous (Video / Product Video).

3a. On COMPLETED:
    - Record CAPTURE in credit_operations & credit_entries; persist output metadata in ai_caption_generations /
      ai_video_jobs / product_video_productions. Replaying the same idempotency_key returns the cached output.

3b. On FAILED / Timeout / Invalid Director Script:
    - Record RELEASE in credit_operations & credit_entries, restoring 100% of reserved credits back to
      credit_grants.available and decrementing workspace_credit_usage (BR-48, BR-60).
```
