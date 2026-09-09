# AI Iteration 5 — GraphRAG Trend Detection

**Timeline:** Parallel with Sprints 13–14 (Weeks 25–28) — after Iteration 4
**Duration:** 2 weeks
**Goal:** Upgrade the trend crawler (AI-05) from keyword-only into a full GraphRAG pipeline — multi-modal ingest (audio/video via STT), BM25 + semantic scoring, and a Graph DB layer that captures entity relationships, so trend suggestions carry real context (who, what brand, what event) instead of a bare keyword list.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| AI-12 | Multi-Modal Ingest & STT Pipeline | Tuấn |
| AI-13 | Scoring & Vector Layer (BM25 + ChromaDB) | Ân |
| AI-14 | Graph Layer & GraphRAG Context Builder | Lộc |

**Prerequisites from Iteration 2:**
- `AI-05` trend crawler already running (Google Trends + TikTok keyword, Redis cache) — this iteration extends it, does not replace it
- ChromaDB collection design already documented (DA-AI02-07)
- `services/trends/normalizer.py` schema `TrendItem` already exists — this iteration's ingest output must stay compatible

**Deliverables by end of Iteration 5:**
- Whisper STT pipeline transcribing crawled video/audio locally (GPU)
- BM25 keyword scoring layer, integrated alongside existing trend score
- Trend items embedded and stored in ChromaDB (`trends` collection extended with vector)
- Neo4j deployed, entity graph populated (KOL, brand, topic, hashtag nodes)
- Entity Resolution job merging duplicate nodes
- GraphRAG Context Builder: vector search entry point → graph traversal → pruned context
- `/ai/trends/context` endpoint returning graph-enriched context (not just a keyword list)

**Layer split rationale (why this avoids conflicts):**
Each epic owns a distinct vertical slice of the pipeline with its own files/modules and one clear interface handed to the next stage. Nobody edits another owner's files under normal flow — only the three interface contracts below are shared and must be locked before parallel work starts:
1. `IngestedItem` shape (AI-12 → AI-13 input)
2. `ScoredItem` shape with `bm25_score` + `embedding` (AI-13 → AI-14 input)
3. `GraphContext` shape (AI-14 → AI-04 prompt builder input)

---

## EPIC AI-12 — Multi-Modal Ingest & STT Pipeline

### DA-AI12-01 — Extend crawler to fetch video/audio files from posts already discovered by AI-05
**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** AI-05's existing crawler only extracts keyword/hashtag text. This task adds a download step that fetches the actual video/audio file behind each discovered post, so later steps have real spoken content to transcribe instead of just a caption string.

**Acceptance Criteria:**
- [ ] `services/ingest/downloader.py` function `download_media(post_url: str, platform: str) -> str` returns local file path to the downloaded video/audio
- [ ] Supports at least TikTok and Facebook video URLs; unsupported platforms return `None` and log a warning rather than raising
- [ ] Downloaded files are saved to a temp working directory (`/tmp/ingest/{platform}_{post_id}.mp4`) and cleaned up after transcription completes
- [ ] Handles download failure (404, geo-block, private post) gracefully — skips the item, logs reason, continues batch

**Technical Notes:**
- Reuse AI-05's existing discovery output (which posts/hashtags are trending) — this task only adds the media fetch step on top, does not duplicate crawl logic
- For TikTok, consider `yt-dlp` (actively maintained, handles TikTok URL extraction) instead of writing a custom downloader
- Rate-limit downloads (e.g. max 5 concurrent) to avoid IP bans from the source platform

**Dependencies:** Blocks: DA-AI12-02. Blocked by: DA-AI05-02 (existing TikTok discovery).

---

### DA-AI12-02 — Set up faster-whisper with local GPU (RTX 4050)
**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Stand up the local speech-to-text engine that the rest of the ingest pipeline depends on. Running this locally on GPU instead of calling a paid STT API (Google Speech-to-Text, AssemblyAI) is the core cost-saving decision behind this epic.

**Acceptance Criteria:**
- [ ] `faster-whisper` installed with CUDA-enabled `torch` build; `nvidia-smi` confirms GPU is detected inside the environment used for inference
- [ ] Model loads successfully with `WhisperModel("base", device="cuda", compute_type="float16")`
- [ ] A smoke test transcribes one sample Vietnamese audio file and produces non-empty text
- [ ] Model size choice (tiny/base/small) is documented with the reasoning (speed vs accuracy tradeoff for Vietnamese)

**Technical Notes:**
- Add `whisper_model` and `whisper_device` config fields to `app/core/config.py` (`whisper_model: str = "base"`, `whisper_device: str = "cuda"`)
- If a teammate's machine has no CUDA GPU, document the CPU fallback (`compute_type="int8"`) — slower but functional, do not block the epic on GPU availability for every contributor
- Pin `faster-whisper` version in `requirements.txt` — Whisper model behavior can shift across versions

**Dependencies:** Blocks: DA-AI12-03. Blocked by: DA-AI12-01.

---

### DA-AI12-03 — Build transcribe.py: transcribe(video_path) -> str
**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** Wrap the Whisper model into a single reusable function that the ingest pipeline calls per downloaded file, with explicit handling for the reality that not every crawled video will be in Vietnamese or even contain speech.

**Acceptance Criteria:**
- [ ] `services/ingest/transcribe.py` function `transcribe(video_path: str, language: str = "vi") -> str` returns the joined transcript text
- [ ] If detected language confidence is low or audio contains no speech (music-only, silent video), function returns empty string rather than garbage text, and logs the reason
- [ ] Function returns within a reasonable timeout per file (document the observed p50/p95 duration from testing) to avoid one slow file blocking the whole batch
- [ ] Errors (corrupted file, unsupported codec) are caught and logged; do not crash the batch job

**Technical Notes:**
- Use `model.transcribe(video_path, language="vi")` from faster-whisper, iterate `segments` and join `segment.text`
- Consider capping max audio duration processed (e.g. 3 minutes) since most trend videos are short-form — protects against an outlier long video stalling the pipeline

**Dependencies:** Blocks: DA-AI12-04. Blocked by: DA-AI12-02.

---

### DA-AI12-04 — Build normalize.py: clean transcribed text
**Assignee:** Tuấn (AI) | **Priority:** 🟡 High

**Goal:** Whisper output is often messy — repeated filler sounds, missing punctuation, run-on sentences. This task produces clean, sentence-structured text so BM25 scoring (AI-13) and entity extraction (AI-14) operate on usable input instead of raw transcript noise.

**Acceptance Criteria:**
- [ ] `services/ingest/normalize.py` function `normalize_text(raw: str) -> str` collapses whitespace, removes emoji/filler sounds (\"ơ ơ\", \"ừm\"), fixes repeated characters (\"ngonnn\" → \"ngon\")
- [ ] Output is split into sentences with basic capitalization applied
- [ ] Function is idempotent — running it twice on already-normalized text produces the same result
- [ ] Unit tested against at least 5 real messy transcript samples from DA-AI12-03 output

**Technical Notes:**
- Keep this rule-based (regex) rather than another LLM call — it needs to be fast and cheap since it runs on every ingested item
- Do not over-clean — preserve brand names, hashtags, and proper nouns exactly as spoken (needed intact for AI-14 entity extraction later)

**Dependencies:** Blocks: DA-AI12-05. Blocked by: DA-AI12-03.

---

### DA-AI12-05 — Define and freeze IngestedItem schema
**Assignee:** Tuấn (AI) | **Priority:** 🔴 Critical

**Goal:** This is the handoff contract between AI-12 (ingest) and AI-13 (scoring). Freezing it early lets Ân start building the scoring layer against a stable shape instead of waiting for the full ingest pipeline to be code-complete.

**Acceptance Criteria:**
- [ ] `models/ingest_models.py` defines `IngestedItem` as a Pydantic model: `{id: str, platform: str, author: str, raw_text: str, source_url: str, crawled_at: datetime}`
- [ ] Schema is shared with Ân (AI-13) and Lộc (AI-14) in a shared doc or Slack thread before either starts consuming it
- [ ] A sample batch of 10 real `IngestedItem` records (from DA-AI12-01 through 04) is committed as a fixture file for AI-13/AI-14 to test against without needing the full pipeline running

**Technical Notes:**
- Treat this as a **blocking interface gate** — once Ân or Lộc starts writing code against this shape, changing field names/types requires notifying both immediately
- Keep the schema minimal on purpose — resist adding fields "just in case"; extend only when AI-13/AI-14 actually need something new

**Dependencies:** Blocks: DA-AI13-01, DA-AI13-03 (AI-13 cannot start until this is frozen). Blocked by: DA-AI12-04.

---

### DA-AI12-06 — Benchmark Whisper throughput on RTX 4050
**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Provide a real throughput number so the team can plan how many videos/day the pipeline can realistically process, and decide whether "base" model is fast enough or a smaller/larger model is needed.

**Acceptance Criteria:**
- [ ] Benchmark run on at least 20 real crawled videos, measuring total wall-clock time vs total audio duration (realtime factor)
- [ ] Result documented as items/hour at model size "base", and compared against "tiny" and "small" for the same sample set
- [ ] Recommendation given: which model size to use in production based on the speed/accuracy tradeoff observed

**Technical Notes:**
- Run this after DA-AI12-03 is stable — benchmarking against unfinished code gives misleading numbers
- Document GPU memory usage too (`nvidia-smi` during run) — relevant if multiple services later share the same GPU

**Dependencies:** Blocks: None. Blocked by: DA-AI12-03.

---

### DA-AI12-07 — Write Ingest & STT Pipeline documentation
**Assignee:** Tuấn (AI) | **Priority:** 🟢 Medium

**Goal:** Record the GPU setup and pipeline design decisions so a teammate without local GPU access, or a future contributor, can reproduce or reason about this epic without re-deriving it from code.

**Acceptance Criteria:**
- [ ] Document covers: GPU/CUDA setup steps, model size choice rationale, `IngestedItem` schema with example, known failure modes (geo-blocked downloads, silent videos, low-confidence language detection)
- [ ] Includes the benchmark numbers from DA-AI12-06
- [ ] CPU fallback path documented for contributors without CUDA GPU

**Dependencies:** Blocks: None. Blocked by: DA-AI12-06.

---

## EPIC AI-13 — Scoring & Vector Layer (BM25 + ChromaDB)

### DA-AI13-01 — Implement BM25 scoring using rank_bm25
**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Replace the simple "normalized 0–1 score" currently used in AI-05 with a real keyword-ranking algorithm. BM25 solves term-frequency saturation and penalizes overly long documents, giving more accurate trending-keyword extraction than the current placeholder scoring.

**Acceptance Criteria:**
- [ ] `services/scoring/bm25.py` builds a `BM25Okapi` index over the corpus of `IngestedItem.raw_text` for a given crawl batch
- [ ] Function `score_keywords(corpus: List[str], query_terms: List[str]) -> Dict[str, float]` returns a score per query term
- [ ] Default BM25 parameters (`k1=1.5`, `b=0.75`) documented; deviations from defaults justified if changed
- [ ] Handles empty corpus or empty query gracefully (returns `{}` rather than raising)

**Technical Notes:**
- Use `rank_bm25` package (`BM25Okapi`); tokenize with a simple whitespace + lowercase split for Vietnamese (do not assume English-style tokenization)
- Score formula for reference: `score(D,Q) = Σ IDF(qi)·f(qi,D)(k1+1) / [f(qi,D)+k1(1-b+b·|D|/avgdl)]`

**Dependencies:** Blocks: DA-AI13-02. Blocked by: DA-AI12-05.

---

### DA-AI13-02 — Build bm25.py score_keywords function, exposed for AI-14 pruning reuse
**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Make the BM25 scoring function a clean, reusable module — not just an inline script — because AI-14's GraphRAG pruning step (DA-AI14-06) needs to call the same scoring logic to decide which graph nodes to keep or drop.

**Acceptance Criteria:**
- [ ] `score_keywords` from DA-AI13-01 is importable as `from services.scoring.bm25 import score_keywords` with no side effects on import
- [ ] Function signature and return shape documented in a docstring clear enough for Lộc (AI-14) to call without reading the implementation
- [ ] Unit tests cover: normal corpus, single-document corpus, corpus with duplicate documents

**Technical Notes:**
- Keep this stateless — no global mutable index — so AI-14 can call it per-batch without worrying about stale state from a previous scoring run

**Dependencies:** Blocks: DA-AI14-06 (AI-14 pruning calls this function). Blocked by: DA-AI13-01.

---

### DA-AI13-03 — Wire sentence-transformers embedding into the ingest flow
**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Produce the semantic vector representation of each ingested item, run in parallel with BM25 scoring, so trend items can later be found via semantic search (matching user intent, not just exact keyword match) rather than only keyword scoring.

**Acceptance Criteria:**
- [ ] `services/scoring/embed.py` function `embed_text(text: str) -> List[float]` returns a 384-dim vector using `sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2` (Vietnamese-capable)
- [ ] Batched embedding supported (`embed_batch(texts: List[str]) -> List[List[float]]`) for efficiency over a crawl batch, not one-by-one calls
- [ ] Model load time measured and documented — loaded once at service startup, not per-request

**Technical Notes:**
- `sentence-transformers` is already in `requirements.txt` — no new dependency needed, just wiring
- Prefer the multilingual model over `all-MiniLM-L6-v2` (English-only) since crawled content is primarily Vietnamese

**Dependencies:** Blocks: DA-AI13-04. Blocked by: DA-AI12-05.

---

### DA-AI13-04 — Extend ChromaDB trends collection to store embeddings + metadata
**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** Persist the embeddings and BM25 scores so they can be queried later — without this, every semantic search or graph lookup would require re-embedding and re-scoring from scratch each time.

**Acceptance Criteria:**
- [ ] `trends` ChromaDB collection (already configured via `chromadb_host`/`chromadb_port` in `app/core/config.py`) accepts `collection.add(ids, embeddings, metadatas)` with metadata `{doc_id, platform, bm25_score, crawled_at}`
- [ ] Existing keyword-only trend data (from AI-05) is not broken by this schema extension — old records without embeddings are handled gracefully by read paths
- [ ] A test insert of 10 sample `IngestedItem` fixtures (from DA-AI12-05) is verified queryable back out with correct metadata

**Technical Notes:**
- ChromaDB client setup already exists (`chromadb.HttpClient(host=settings.chromadb_host, port=settings.chromadb_port)`) — reuse it, do not create a second client instance
- Decide and document a stable `doc_id` scheme (e.g. `{platform}_{post_id}`) so re-crawling the same post updates rather than duplicates

**Dependencies:** Blocks: DA-AI13-05. Blocked by: DA-AI13-03.

---

### DA-AI13-05 — Define and freeze ScoredItem schema
**Assignee:** Ân (AI) | **Priority:** 🔴 Critical

**Goal:** This is the handoff contract between AI-13 (scoring/vector) and AI-14 (graph). Freezing it lets Lộc start building the GraphRAG context builder against a stable shape instead of waiting for the vector layer to be fully wired end-to-end.

**Acceptance Criteria:**
- [ ] `models/scoring_models.py` defines `ScoredItem`: `{id: str, bm25_score: float, embedding: List[float], metadata: dict}`
- [ ] Schema shared with Lộc (AI-14) before he starts DA-AI14-06 (graph traversal + pruning)
- [ ] A sample batch of 10 real `ScoredItem` records is committed as a fixture file for AI-14 to test the context builder against, independent of whether the full scoring pipeline is running live

**Technical Notes:**
- Treat this as a **blocking interface gate**, same as DA-AI12-05 — do not change shape after Lộc starts consuming it without notifying him first

**Dependencies:** Blocks: DA-AI14-06 (AI-14 cannot start graph traversal until this is frozen). Blocked by: DA-AI13-04.

---

### DA-AI13-06 — Extend /ai/trends search to query ChromaDB by embedding
**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Upgrade the existing keyword-based `/ai/trends` endpoint so a query like "gợi ý trend đồ ăn" can match relevant trends by meaning ("trà sữa", "review đồ ăn") even when none of those exact words appear in the query — the core value semantic search adds over the current string-match approach.

**Acceptance Criteria:**
- [ ] `GET /ai/trends/search?query=` embeds the query string and returns top-K trend items from ChromaDB ranked by cosine similarity
- [ ] Response includes both `bm25_score` and `similarity_score` per result so callers can see both signals
- [ ] Existing `GET /ai/trends?category=` keyword endpoint from AI-05 continues to work unchanged — this is an additive endpoint, not a replacement
- [ ] Manual test: query "gợi ý trend đồ ăn" returns "trà sữa" in top 3 results despite no exact keyword overlap

**Technical Notes:**
- Default `top_k=5`; make configurable via query param
- This endpoint is a stepping stone toward DA-AI14-08's richer `/ai/trends/context` — keep both endpoints, they serve different callers (this one for quick keyword-level lookups, AI-14's for full graph context)

**Dependencies:** Blocks: None (parallel convenience feature). Blocked by: DA-AI13-04.

---

### DA-AI13-07 — Test scoring accuracy
**Assignee:** Ân (AI) | **Priority:** 🟡 High

**Goal:** Verify BM25 scoring actually ranks known trending keywords above noise before AI-14 builds pruning logic on top of it — catching a broken scorer here is much cheaper than debugging it after it's embedded inside graph traversal.

**Acceptance Criteria:**
- [ ] 20 sample items (mix of clearly-trending and clearly-noise text) scored; top 5 by BM25 score match manual human judgment of "actually trending" at least 80% of the time
- [ ] Edge cases tested: very short text (single word), very long text (full transcript), text with no meaningful keywords
- [ ] Results and methodology documented for reproducibility

**Technical Notes:**
- This is a **quality gate** — do not let Lộc start relying on `bm25_score` for pruning (DA-AI14-06) until this passes

**Dependencies:** Blocks: DA-AI14-06 (soft gate — quality, not schema). Blocked by: DA-AI13-02.

---

### DA-AI13-08 — Write Scoring & Vector Layer documentation
**Assignee:** Ân (AI) | **Priority:** 🟢 Medium

**Goal:** Record the scoring and embedding design decisions so BM25 parameter tuning or embedding model swaps can be made deliberately later, rather than by trial and error.

**Acceptance Criteria:**
- [ ] Document covers: BM25 parameter choices, embedding model choice and why multilingual was picked over English-only, ChromaDB schema extension details
- [ ] `ScoredItem` schema included with a worked example
- [ ] Known limitations noted (e.g. BM25 not accounting for synonyms, mitigated by pairing with semantic search)

**Dependencies:** Blocks: None. Blocked by: DA-AI13-07.

---

## EPIC AI-14 — Graph Layer & GraphRAG Context Builder

### DA-AI14-01 — Deploy Neo4j container
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** Stand up the graph database that this whole epic depends on. This is pure infrastructure with no data dependency on AI-12/AI-13, so it can start on day 1 in parallel with the other two epics.

**Acceptance Criteria:**
- [ ] Neo4j service added to `docker-compose.yml` (or the relevant compose file for ai-service infra), with a named volume for data persistence
- [ ] Credentials (`NEO4J_AUTH` or equivalent) set via environment variables, not hardcoded
- [ ] Neo4j Browser accessible locally (`http://localhost:7474`) and a manual test query (`MATCH (n) RETURN n LIMIT 5`) confirms the instance is reachable

**Technical Notes:**
- Pin the Neo4j Docker image version — do not use `:latest`, to keep the environment reproducible across teammates' machines
- Community Edition is sufficient for this iteration's scale — no need for Enterprise features

**Dependencies:** Blocks: DA-AI14-02. Blocked by: None.

---

### DA-AI14-02 — Add neo4j Python driver + shared client
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** Wire the application-side connection to Neo4j, following the existing pattern where all external service clients live in one shared module — keeps client setup consistent with how ChromaDB/Redis/S3 clients are already organized in this codebase.

**Acceptance Criteria:**
- [ ] `neo4j` package added to `requirements.txt`
- [ ] `utils/clients.py` gains a `neo4j_driver` alongside the existing 4 clients, constructed from `neo4j_uri`/`neo4j_user`/`neo4j_password` config fields
- [ ] `app/core/config.py` gains `neo4j_uri: str = "bolt://localhost:7687"`, `neo4j_user: str = "neo4j"`, `neo4j_password: str = ""`
- [ ] A smoke test opens a session and runs a trivial query, confirming the driver connects using config values (not hardcoded)

**Dependencies:** Blocks: DA-AI14-03. Blocked by: DA-AI14-01.

---

### DA-AI14-03 — Build entity_extractor.py: LLM-based NER
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** Extract structured entities (which KOL, which brand, which topic, which hashtag) from raw transcribed text, since this is the input the graph needs — Neo4j has nothing to store until text is turned into named, typed entities.

**Acceptance Criteria:**
- [ ] `services/graph/entity_extractor.py` function `extract_entities(text: str) -> List[{name: str, type: str}]` where `type` is one of `KOL`, `BRAND`, `TOPIC`, `HASHTAG`
- [ ] Uses the existing LLM integration (Groq/Anthropic, already configured) with a prompt constrained to only the 4 entity types above — does not invent new categories
- [ ] Tested against 10 real `ScoredItem.metadata` text samples; extracted entities manually verified for correctness
- [ ] Handles text with zero extractable entities (returns empty list, does not error)

**Technical Notes:**
- Reuse the LLM client wiring already set up for AI-04's content generation — do not create a second separate LLM client just for this
- Keep the prompt strict about not fabricating entities not present in the text (same anti-hallucination principle already applied in AI-04)

**Dependencies:** Blocks: DA-AI14-04. Blocked by: DA-AI14-02.

---

### DA-AI14-04 — Build link_entity.py: MERGE entities and relationships into Neo4j
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** Turn extracted entities into actual graph structure — nodes and the relationships between them (which KOL mentions which trend, which brand sells which product) — so the graph becomes queryable for context, not just a flat entity list.

**Acceptance Criteria:**
- [ ] `services/graph/link_entity.py` function `link_entities(entities: List[dict], source_item_id: str)` writes `MERGE` Cypher statements so re-running on the same data does not create duplicate nodes
- [ ] Relationship types defined and used consistently: `MENTIONS` (KOL→Trend), `SOLD_BY` (Trend→Brand), `TAGGED` (Trend→Hashtag), `HAS_EVENT` (Brand→Event)
- [ ] A test run against DA-AI14-03's 10 sample outputs produces a visually inspectable graph in Neo4j Browser with the expected node/edge counts

**Technical Notes:**
- Use `MERGE` (not `CREATE`) for both nodes and relationships — this is what makes re-crawling idempotent instead of creating duplicate nodes on every run
- Keep relationship types to the 4 listed above for this iteration — resist adding more without a clear use case, to keep the graph query-able and easy to reason about

**Dependencies:** Blocks: DA-AI14-05. Blocked by: DA-AI14-03.

---

### DA-AI14-05 — Implement Entity Resolution job
**Assignee:** Lộc (Frontend) | **Priority:** 🟡 High

**Goal:** Solve the duplicate-node problem identified as the biggest long-term risk to graph quality — as the graph grows daily, the same real-world entity gets created as multiple nodes with slightly different names (e.g. "Trấn Thành" and "MC Trấn Thành"), which would silently degrade every downstream query if left unresolved.

**Acceptance Criteria:**
- [ ] `services/graph/entity_resolution.py` scheduled job compares node name embeddings (reusing DA-AI13-03's embedding function) within the same entity type, flags pairs above a similarity threshold as merge candidates
- [ ] An alias dictionary (`config/entity_aliases.json` or similar) allows manually confirmed merges to be applied automatically without re-running similarity comparison every time
- [ ] Merging a duplicate node re-points all its relationships to the canonical node and removes the duplicate — verified no relationships are silently dropped during merge
- [ ] Job runs on a schedule (reuse the `APScheduler` pattern from DA-AI05-06) rather than only on-demand

**Technical Notes:**
- Start with a conservative similarity threshold (favor missing a merge over incorrectly merging two different real entities) — false merges are harder to detect and undo than false negatives
- Log every merge decision (which nodes, similarity score, timestamp) for auditability — this is the kind of silent data mutation that needs a paper trail

**Dependencies:** Blocks: DA-AI14-09. Blocked by: DA-AI14-04.

---

### DA-AI14-06 — Build context_builder.py: vector search entry point → graph traversal → pruning
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** This is the centerpiece of the whole epic — the actual GraphRAG logic that combines what Vector DB is good at (finding the right entry point by meaning) with what Graph DB is good at (expanding out to the full connected context), then trims the result down to something an LLM prompt can actually use.

**Acceptance Criteria:**
- [ ] `services/graphrag/context_builder.py` function `build_context(query: str) -> GraphContext` first calls ChromaDB (via AI-13's vector search) to find the top entry-point node(s) matching the query semantically
- [ ] From entry point(s), performs Neo4j graph traversal up to depth 2 (configurable), collecting connected entities and relationships
- [ ] Calls AI-13's `score_keywords` (DA-AI13-02) to get BM25 scores for traversed nodes, drops any node below a configurable threshold
- [ ] Final context text is assembled from the pruned node set, readable as natural-language-ish context (not raw Cypher/JSON dump)

**Technical Notes:**
- Depth 2 is the starting default — deeper traversal risks pulling in loosely related nodes and bloating context; document why depth 2 was chosen if changed
- This function directly depends on both AI-13 deliverables (`ScoredItem` schema, `score_keywords` function) — do not start real implementation before both are frozen/passing their quality gates

**Dependencies:** Blocks: DA-AI14-07. Blocked by: DA-AI13-05, DA-AI13-02, DA-AI13-07 (soft — quality gate).

---

### DA-AI14-07 — Define and freeze GraphContext schema
**Assignee:** Lộc (Frontend) | **Priority:** 🔴 Critical

**Goal:** This is the handoff contract between AI-14 (graph) and AI-04 (LLM prompt builder). Freezing it lets whoever owns AI-04's prompt template integrate graph-enriched context without needing to understand the graph traversal internals.

**Acceptance Criteria:**
- [ ] `models/graphrag_models.py` defines `GraphContext`: `{entry_keyword: str, related_entities: List[{name: str, type: str, relation: str}], context_text: str, token_count: int}`
- [ ] `token_count` is calculated using the same tokenizer AI-04's LLM integration uses, so the 800-token cap (see DA-AI14-06 notes) is enforced with an accurate count, not a rough character estimate
- [ ] Schema shared with whoever picks up AI-04's prompt builder update before that integration work starts
- [ ] A sample batch of 5 real `GraphContext` outputs committed as a fixture for prompt-builder testing

**Dependencies:** Blocks: DA-AI14-08, downstream AI-04 prompt integration. Blocked by: DA-AI14-06.

---

### DA-AI14-08 — Implement GET /ai/trends/context endpoint
**Assignee:** Lộc (Frontend) | **Priority:** 🟡 High

**Goal:** Expose the GraphRAG context builder as an API endpoint so it can be called independently (for testing, demos, or direct integration) rather than only being reachable as an internal function buried inside the prompt builder.

**Acceptance Criteria:**
- [ ] `GET /ai/trends/context?query=` returns a `GraphContext` JSON matching the frozen schema
- [ ] Response time documented under normal load (this involves a vector search + graph traversal + BM25 scoring chain, so latency should be measured, not assumed)
- [ ] Errors (Neo4j unreachable, ChromaDB unreachable) return a clear error response rather than a raw stack trace, and are logged
- [ ] Manual test: query "gợi ý trend đồ ăn" returns a `GraphContext` containing at least the entry trend plus 1+ related entity (KOL, brand, or event)

**Dependencies:** Blocks: None (feeds AI-04 integration, tracked separately). Blocked by: DA-AI14-07.

---

### DA-AI14-09 — Test Entity Resolution
**Assignee:** Lộc (Frontend) | **Priority:** 🟡 High

**Goal:** Prove the Entity Resolution job actually catches known duplicate cases before the endpoint goes live — an unverified merge job risks either leaving obvious duplicates in the graph (degrading query quality) or, worse, incorrectly merging two distinct real entities (corrupting the graph silently).

**Acceptance Criteria:**
- [ ] 5 known duplicate-entity cases seeded into the graph (e.g. "Trấn Thành" / "MC Trấn Thành", brand name with/without diacritics)
- [ ] Entity Resolution job run against the seeded graph; all 5 cases verified merged correctly with relationships preserved
- [ ] At least 2 "should NOT merge" negative cases included (genuinely different entities with superficially similar names) to confirm the threshold isn't too aggressive
- [ ] Results documented with before/after node counts

**Technical Notes:**
- This is a **blocking quality gate** — do not expose `/ai/trends/context` (DA-AI14-08) publicly, or hand it to AI-04 for integration, until this passes

**Dependencies:** Blocks: DA-AI14-08 (quality gate, soft block). Blocked by: DA-AI14-05.

---

### DA-AI14-10 — Write Graph Layer & GraphRAG documentation
**Assignee:** Lộc (Frontend) | **Priority:** 🟢 Medium

**Goal:** Record the graph schema and GraphRAG design decisions so future contributors (or future iterations extending the graph with new entity/relationship types) can build on this without re-deriving the reasoning from scratch.

**Acceptance Criteria:**
- [ ] Document covers: Neo4j schema (node types, relationship types with a small diagram), traversal depth rationale, pruning strategy (BM25 threshold, token cap), Entity Resolution approach and known limitations
- [ ] `GraphContext` schema included with a worked example end-to-end (query in → context out)
- [ ] Known risks documented: graph growth rate expectations, when Entity Resolution threshold might need retuning

**Dependencies:** Blocks: None. Blocked by: DA-AI14-09.

---

## Dependency Map

```
AI-12 (Tuấn, independent start):
  DA-AI12-01 → DA-AI12-02 → DA-AI12-03 → DA-AI12-04 → DA-AI12-05 → DA-AI12-06 → DA-AI12-07
                                                      ↓ (schema freeze — blocking gate)

AI-13 (Ân, starts once DA-AI12-05 frozen):
  DA-AI12-05 → DA-AI13-01 → DA-AI13-02 ──────────────────────────┐
             → DA-AI13-03 → DA-AI13-04 → DA-AI13-05 → DA-AI13-06 │
                                        ↓ (schema freeze)         │
                                        → DA-AI13-07 → DA-AI13-08 │
                                                                   ↓ (both feed AI-14)

AI-14 (Lộc, infra starts day 1, data flow waits on AI-13 gates):
  DA-AI14-01 → DA-AI14-02 → DA-AI14-03 → DA-AI14-04 → DA-AI14-05 → DA-AI14-09 → DA-AI14-10
  DA-AI13-05 + DA-AI13-02 + DA-AI13-07 → DA-AI14-06 → DA-AI14-07 → DA-AI14-08

Feeds forward:
  DA-AI14-08 (GraphContext via /ai/trends/context) → AI-04's DA-AI04-01 (prompt builder)
  — replaces plain trend keyword input with graph-enriched context in future prompt generation
```

**Cross-epic sync points (the only 3 moments the three owners must coordinate):**
1. **DA-AI12-05 frozen** — Tuấn notifies Ân before Ân starts DA-AI13-01/03.
2. **DA-AI13-05 + DA-AI13-02 frozen, DA-AI13-07 passing** — Ân notifies Lộc before Lộc starts real implementation of DA-AI14-06.
3. **DA-AI14-07 frozen, DA-AI14-09 passing** — Lộc notifies whoever owns AI-04's prompt builder update before wiring `GraphContext` into content generation.

---

## Iteration 5 Checklist

- [ ] Whisper STT transcribing crawled video/audio on local GPU (RTX 4050), throughput benchmarked
- [ ] `IngestedItem` schema frozen and shared before AI-13 starts consuming
- [ ] BM25 scoring integrated, passes 20-item accuracy test (≥80% match with human judgment)
- [ ] ChromaDB `trends` collection storing embeddings + BM25 metadata, backward-compatible with AI-05's existing records
- [ ] `ScoredItem` schema frozen and shared before AI-14 starts graph traversal
- [ ] Neo4j deployed, entity graph populated with KOL/brand/topic/hashtag nodes
- [ ] Entity Resolution passing on 5 seeded duplicate-entity test cases + 2 negative cases
- [ ] GraphRAG Context Builder returns pruned context under 800 tokens
- [ ] `/ai/trends/context` endpoint live, manually verified to return graph-enriched context (not just a keyword list)
- [ ] Ingest, Scoring, and Graph Layer documentation committed
