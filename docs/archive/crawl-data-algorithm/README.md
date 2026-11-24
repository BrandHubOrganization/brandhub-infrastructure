# Early R&D Brainstorm — Social Crawl & GraphRAG Algorithm (`2026-07`)

> Navigation: [← Knowledge Base Hub](../../index.md) · [← Historical Archive Hub](../README.md) · [Current Production AI Models →](../../ai-models/README.md)

This folder preserves the initial `2026-07` R&D brainstorming notes, audio session transcript, market comparison, and interactive HTML concept visualization that originated BrandHub's **Vietnam Social Trend Detection & Hybrid GraphRAG** architecture.

> [!NOTE]
> These documents capture **early conceptual ideation** prior to production implementation. For the live production pipeline (`T0`–`T8` with PhoBERT `NLPStep`, 4-signal `BurstStep`, Neo4j Centrality, and `384`-d ChromaDB + Neo4j GraphRAG), refer to [crawl-trend-blueprint.md](../../ai-models/crawl-trend-blueprint.md), [text-normalization-pipeline-design.md](../../ai-models/text-normalization-pipeline-design.md), and [trend-prediction-bm25-design.md](../../ai-models/trend-prediction-bm25-design.md).

---

## Preserved Ideation Artifacts

| Artifact | Format | Historical Scope |
| :--- | :---: | :--- |
| [architecture.md](./architecture.md) | Markdown | Conceptual multi-platform crawler + BM25 burst + Vector/Graph hybrid storage sketch |
| [crawl-data-analysis.md](./crawl-data-analysis.md) | Markdown | Structured engineering synthesis of the `crawl-data.m4a` brainstorming session covering entity resolution and token pruning |
| [market-comparison.md](./market-comparison.md) | Markdown | Comparative analysis of commercial social listening platforms (Meltwater, Glia, TikTok Creative Center, Google Trends) and graph recommender papers (`PinSage`) |
| [Interactive Concept Prototype (`crawl-data-interactive.html`)](/view?file=archive/crawl-data-algorithm/crawl-data-interactive.html) | Interactive HTML | Browser-renderable interactive diagram illustrating the conceptual crawl-to-GraphRAG data lineage |
| `docs/archive/crawl-data-algorithm/crawl-data.m4a` | Audio (`m4a`) | Original recorded team R&D discussion |
