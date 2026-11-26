# AI Parallel Track — Iteration Roadmaps & Deliverables (`Iterations 1–5`)

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Project Plans](../README.md) · [Master Plan](../brandhub-master-plan.md) · [AI Models & Research](../../ai-models/README.md)

This directory contains the 5 engineering iteration plans and R&D completion reports for BrandHub's **AI Parallel Track** (`brandhub-ai-service` + `gpu-workers/wan-vace/`).

---

## 1. Five-Iteration Roadmap

| Plan Document | Iteration | Epics | Primary Engineering Deliverables |
| :--- | :--- | :---: | :--- |
| [ai-iteration-1-research-evaluation.md](./ai-iteration-1-research-evaluation.md) | **Iteration 1** — Research & Evaluation | `AI-01`, `AI-02` | Model evaluation (Video, Virtual Ambassador, Image Compositing, Groq vs. Claude) & `brandhub-ai-service` FastAPI + Docker + S3 scaffold |
| [ai-iteration-2-rag-llm-trends.md](./ai-iteration-2-rag-llm-trends.md) | **Iteration 2** — Hybrid GraphRAG, LLM & Trends | `AI-03`, `AI-04`, `AI-05` | Brand Knowledge ingestion (`384`-d ChromaDB), Neo4j 1–2 hop GraphRAG + BM25 pruning, 3-second Hook LLM generation *(implementation blueprint: [ai-iteration-2-implementation-blueprint.md](../../ai-models/ai-iteration-2-implementation-blueprint.md))* |
| [ai-iteration-3-image-ambassador-composition.md](./ai-iteration-3-image-ambassador-composition.md) | **Iteration 3** — Image, Ambassador & Composition | `AI-06`, `AI-07`, `AI-08` | Commercial advertising image generation (Qwen Image 2.1 + ComfyUI), Virtual Brand Ambassador consistency, multi-layer compositing |
| [ai-iteration-4-video-integration-documentation.md](./ai-iteration-4-video-integration-documentation.md) | **Iteration 4** — Video, Integration & Docs | `AI-09`, `AI-10`, `AI-11` | Phase 1 Veo benchmark → Phase 2 **Wan 2.2 Fun VACE 14B + S2V** (`ltx_director.py`), `business-service` credit integration, and OpenAPI finalization |
| [ai-iteration-5-graphrag-trend-detection.md](./ai-iteration-5-graphrag-trend-detection.md) | **Iteration 5** — GraphRAG & Trend Pipeline V2 | `AI-04`, `AI-05` (V2) | `T0`–`T8` Trend Detection Pipeline: `KB1`–`KB6` bot filter, PhoBERT topic/7-emotion/NER (`T2`), 4-signal `BurstStep` (`T4`), and Neo4j Centrality (`T6`) |

---

## 2. Completed Iteration 1 Reports (`iteration-1/`)

- **Consolidated Team Report**: [iteration-1/iteration-report.md](./iteration-1/iteration-report.md) (`15/15` tasks `100% Done`, deliverables matrix, quality review, and retrospective)
- **Individual Engineer R&D Reports**:
  - **Hà Thị Ân**: [iteration-1/members/anha.md](./iteration-1/members/anha.md) — Video generation evaluation, 30 marketing prompt benchmarks, and FFmpeg video chaining
  - **Nguyễn Thành Lộc**: [iteration-1/members/locnt.md](./iteration-1/members/locnt.md) — `brandhub-ai-service` FastAPI architecture, multi-stage Dockerfile, AWS S3 `boto3` helpers, and image compositing
  - **Nguyễn Minh Tuấn**: [iteration-1/members/tuannm.md](./iteration-1/members/tuannm.md) — Virtual Brand Ambassador evaluation (`InstantID`, `ControlNet`, `Z-Image` — [ai-fashion-model-generation-platforms.md](../../ai-models/ai-fashion-model-generation-platforms.md)) and ChromaDB collection schema

---

## 3. Production AI Architecture & SRS Traceability

- **Canonical SRS AI Domain (`3.7.1`–`3.7.19`)**: [feature/srs/06-ai-features/README.md](../../feature/srs/06-ai-features/README.md)
- **Consolidated AI Platform Modules**: [05-ai-rag-and-crawler](../../feature/modules/05-ai-rag-and-crawler/README.md) · [06-ai-media-and-video-studio](../../feature/modules/06-ai-media-and-video-studio/README.md)
- **FastAPI & GPU Worker Architecture**: [architecture/ai-service-architecture.md](../../architecture/ai-service-architecture.md) · [openapi-spec-ai-service.md](../../api/openapi-spec-ai-service.md)
