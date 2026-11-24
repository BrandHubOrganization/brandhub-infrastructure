# 05-ai-rag-and-crawler — AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG (3 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 3.7 AI Features](../../srs/06-ai-features/README.md) · [AI Models Research](../../../ai-models/README.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Intelligence ingestion and text generation pipelines spanning the `T0 -> T7` multi-platform social trend crawler, Neo4j Trend Knowledge Graph with BM25 + Burst scoring, ChromaDB brand-grounded RAG captions, Content Humanizer, and community safety moderation.

---

## 1. Production Codebase & Persistence Mapping

- **Primary Services:** `brandhub-ai-service` (`crawl/`, `t2_nlp_step.py`, `t4_burst_step.py`, `trend_graph.py`, `rag.py`, `humanizer.py`, `moderation.py`), `prod/hosts/crawl/crawl-gate` (`:8084` internal dispatch gate), and `brandhub-business-service` (`AiGenerationController`, `AdminTrendGraphController`, `TrendController`).
- **Storage & Runtime State:**
  - **Neo4j 5.26:** `Trend`, `Topic`, `Keyword`, `Hashtag`, and `Platform` graph nodes + burst/velocity edges.
  - **ChromaDB 1.5.9:** Workspace-isolated collections `brand_docs_{workspace_id}` storing chunked brand guidelines (`gemini-embedding-001`).
  - **AWS S3 Cold Archive:** Daily compressed raw crawl snapshots for deterministic `T0 -> T7` replay without re-scraping upstream platforms.
- **Related Docs:** [06-ai-features (`3.7.1`–`3.7.7`, `3.7.14`)](../../srs/06-ai-features/README.md) · [AI Service Architecture](../../../architecture/ai-service-architecture.md) · [Trend Crawler Flow](../../../ai-models/trend-crawler-flow-task-details.md).

---

## 2. Consolidated Modules (`3`)

| Module Slug | Scope & Engineering Title | Core Codebase Touchpoints | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `multiplatform-trend-crawler-pipeline` | **Multi-Platform Trend Crawler Pipeline, Proxy Rotation, S3 Cold Storage & Daily Replay** | `crawl-gate` (`:8084`), proxy health rotation, PhoBERT + Underthesea `NLPStep` (`t2_nlp_step.py`), S3 raw replay archive | [Spec](./multiplatform-trend-crawler-pipeline/spec.md) · [Plan](./multiplatform-trend-crawler-pipeline/plan.md) · [Task](./multiplatform-trend-crawler-pipeline/task.md) · [Test](./multiplatform-trend-crawler-pipeline/test.md) |
| `neo4j-trend-knowledge-graph` | **Neo4j Trend Knowledge Graph Core, Workspace Trend Explorer & Brand-Fit Matching** | `BurstStep` (`t4_burst_step.py`), BM25 GraphRAG context pruning, `AdminTrendGraphController`, Workspace Brand-Fit trend scoring | [Spec](./neo4j-trend-knowledge-graph/spec.md) · [Plan](./neo4j-trend-knowledge-graph/plan.md) · [Task](./neo4j-trend-knowledge-graph/task.md) · [Test](./neo4j-trend-knowledge-graph/test.md) |
| `rag-caption-moderation-and-humanizer` | **Brand-Grounded RAG Captions, Editor AI Popover, Content Humanizer & Text Safety Moderation** | `rag.py` (`brand_docs_{workspace_id}`), inline TipTap AI popover, `humanizer.py` anti-slop rewrite, `POST /ai/captions/moderate` (`3.6.33`) | [Spec](./rag-caption-moderation-and-humanizer/spec.md) · [Plan](./rag-caption-moderation-and-humanizer/plan.md) · [Task](./rag-caption-moderation-and-humanizer/task.md) · [Test](./rag-caption-moderation-and-humanizer/test.md) |

---

## 3. Architectural Invariants

1. Every paid AI text/RAG call executes inside `brandhub-business-service`'s 3-phase credit reservation protocol (`RESERVE -> SETTLE / RELEASE`) before invoking `brandhub-ai-service`.
2. ChromaDB vector retrieval is strictly partitioned by `workspace_id` (`brand_docs_{workspace_id}`) so brand voice embeddings never cross tenant boundaries.
