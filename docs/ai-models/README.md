# AI Models, Algorithms & Research Specifications

> [<< Knowledge Base Home](../index.md) · [AI Service Architecture](../architecture/ai-service-architecture.md) · [Brand RAG Design](../architecture/brand-rag-pipeline-design.md) · [Database & AI Vector Hub](../database/README.md) · [BA 06 - AI Features](../ba/06-ai-features.md)

This directory contains the authoritative algorithm specifications, hybrid GraphRAG blueprints, model evaluations, and GPU synthesis designs powering BrandHub's **19 AI Functional Requirements (`3.7.1`–`3.7.19`)** inside `brandhub-ai-service` and `gpu-workers/wan-vace/`.

---

## 1. Trend Crawler, PhoBERT NLP, Temporal Burst & Neo4j Virality (`3.7.15`–`3.7.19`)

| Document | Scope |
| :--- | :--- |
| [data-collection-layer-design.md](./data-collection-layer-design.md) | Multi-platform Vietnamese trend data collection architecture (TikTok Creative Center, Facebook Public Groups, Google Trends, anti-blocking & `APScheduler`) |
| [crawl-trend-blueprint.md](./crawl-trend-blueprint.md) | End-to-end Trend Crawler, GraphRAG context construction, and hybrid storage blueprint (`DA-AI04-99`) |
| [text-normalization-pipeline-design.md](./text-normalization-pipeline-design.md) | `T0`–`T2.5` pipeline (`NLPStep`): 2-layer dedup, `KB1`–`KB6` bot/seeding filter, PhoBERT topic/7-emotion/NER labeling, `underthesea` `Np` recovery, and Claude low-confidence disambiguation |
| [trend-prediction-bm25-design.md](./trend-prediction-bm25-design.md) | `T4_BurstStep` 4-signal burst formula (Density Z-score, Velocity slope, Author/Source Coverage, 7-reaction Engagement) + Okapi BM25 GraphRAG context pruning |
| [graph-virality-score-design.md](./graph-virality-score-design.md) | Neo4j Personalized PageRank, Degree & Betweenness Centrality virality scoring (`T6`) |
| [trend-crawler-flow-task-details.md](./trend-crawler-flow-task-details.md) | Engineering task breakdown (`DA-AI04-99-01`–`07`) and text-first crawl infrastructure decisions |
| [report-crawl-trend-analysis.md](./report-crawl-trend-analysis.md) | Consolidated mathematical & data-lineage report for the crawl and Redis/Neo4j upsert pipeline |

---

## 2. Brand Hybrid GraphRAG & LLM Content Generation (`3.7.1`–`3.7.6`, `3.7.12`–`3.7.14`)

| Document | Scope |
| :--- | :--- |
| [brand-knowledge-ingestion-report.md](./brand-knowledge-ingestion-report.md) | Brand Knowledge document upload, magic-byte validation, S3 storage, and 384-d ChromaDB indexing (`DA-AI03-01`) |
| [ai-iteration-2-implementation-blueprint.md](./ai-iteration-2-implementation-blueprint.md) | Consolidated AI Iteration 2 system architecture, gap analysis, sequence diagrams, and module-by-module FastAPI code blueprint (`Epic AI-03`, `AI-04`, `AI-05`) |
| [rag-generation-pipeline-task-details.md](./rag-generation-pipeline-task-details.md) | Task-level engineering specifications for Offline Brand/Trend Ingestion and Online Hybrid Retrieval (`ChromaDB` + `Neo4j` 1–2 hops + `BM25` pruning) |
| [ai-generation-pipeline-task-details.md](./ai-generation-pipeline-task-details.md) | Epic `AI-04` LLM generation task specs (`PromptBuilder` 3-second Hook, Groq Llama 3 + Claude fallback, platform length optimizer, hashtags, anti-hallucination QA gate, and end-to-end walkthrough) |

---

## 3. Image Composition, Virtual Ambassador & Wan 2.2 VACE Video Synthesis (`3.7.7`–`3.7.11`)

| Document | Scope |
| :--- | :--- |
| [ai-fashion-model-generation-platforms.md](./ai-fashion-model-generation-platforms.md) | Comparative evaluation of Virtual Brand Ambassador & AI fashion model generation platforms (`FR 3.7.8`) |
| [research-model-generate-advertise-image.md](./research-model-generate-advertise-image.md) | Evaluation of diffusion, VTON, and ControlNet composition pipelines leading to Qwen Image 2.1 + ComfyUI (`FR 3.7.7`) |
| [video-generation-research-report.md](./video-generation-research-report.md) | Phase 1 `veo-3.1-flash` 30-prompt benchmark + Phase 2 production **Wan 2.2 Fun VACE 14B + Qwen Image 2.1 + Wan 2.2 S2V 14B** (`ltx_director.py` & `gpu-workers/wan-vace/`) architecture |
| [camera-movement-ai-prompts.md](./camera-movement-ai-prompts.md) | Cinematographic camera movement taxonomy and shot prompt templates for AI video styles (`FR 3.7.10`) |
