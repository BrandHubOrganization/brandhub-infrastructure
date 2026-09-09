# DA-AI04-99-07 — Crawl Trend Analysis Blueprint (End-to-End)

**Epic:** AI-4.99 — Analyze deeply crawl trend flow
**Task ID:** DA-AI04-99-07
**Status:** Approved
**Date:** 2026-08-03

---

## Mục lục

1. [Overview & Philosophy](#1-overview--philosophy)
2. [Data Collection Layer (99-01)](#2-data-collection-layer-99-01)
3. [Text Normalizer & Chunking Layer (99-04)](#3-text-normalizer--chunking-layer-99-04)
4. [BM25 Scoring & Anomaly Engine (99-02)](#4-bm25-scoring--anomaly-engine-99-02)
5. [Trend Prediction Engine (99-03)](#5-trend-prediction-engine-99-03)
6. [Hybrid Storage — ChromaDB + Neo4j + Redis (99-05 + 99-06)](#6-hybrid-storage--chromadb--neo4j--redis-99-05--99-06)
7. [GraphRAG Context Builder](#7-graphrag-context-builder)
8. [API Layer & Contracts](#8-api-layer--contracts)
9. [Deployment & Configuration](#9-deployment--configuration)
10. [Acceptance Criteria & Phase 2 Roadmap](#10-acceptance-criteria--phase-2-roadmap)

---

## 1. Overview & Philosophy

### 1.1 Epic Scope

AI-4.99 là epic phân tích sâu toàn bộ pipeline crawl trend: từ thu thập dữ liệu đa nguồn đến lưu trữ, scoring, và sinh context cho LLM. Blueprint này là single source of truth — developer đọc 1 file hiểu toàn bộ pipeline end-to-end.

**Sub-tasks:**

| ID | Task | Status |
|---|---|---|
| 99-01 | Data Collection Layer | Complete |
| 99-02 | BM25 Scoring & Anomaly Engine | Designed here |
| 99-03 | Trend Prediction Engine | Designed here |
| 99-04 | Text Normalizer & Chunking Layer | Designed here |
| 99-05 | Hybrid DB Schema (ChromaDB + Neo4j) | Complete |
| 99-06 | Redis + Neo4j Upsert Flow | Complete |
| 99-07 | Final Blueprint (this document) | In progress |

### 1.2 Design Philosophy

**API-first MVP.** Dùng third-party API (Apify, ScrapeCreators, SerpApi) cho data collection thay vì tự code crawler. Lý do: time-to-market 1-2 tuần thay vì 2-4 tuần, không cần maintain proxy/anti-detection, chi phí $0-55/tháng.

**GraphRAG over keyword-only.** Không trả về bare keyword list. Mỗi trend có entity graph (KOL, Dish, Location) + semantic chunks, cho phép LLM sinh context-aware content.

**Local GPU for STT.** Whisper chạy trên RTX 4050 — không phụ thuộc API trả phí cho transcription.

**Dual-path storage.** Vector (ChromaDB) cho semantic search + Graph (Neo4j) cho entity relationships. Hai đường bổ sung, không thay thế nhau.

**Cost-conscious.** Định vị "Brandwatch/Meltwater thu nhỏ" cho SME Việt Nam. Tận dụng open-source stack, local GPU, free tier API.

### 1.3 End-to-End Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DATA COLLECTION (99-01)                           │
│  SerpApi (Google Trends)  Apify (TikTok KOL)  ScrapeCreators (TikTok)   │
│                          Apify (Facebook Search)                         │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │ Raw JSON items
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     TEXT NORMALIZER (99-04)                              │
│  STT (Whisper GPU) → Text Clean → Lang Detect → Chunk → IngestedItem    │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │ IngestedItem (clean text + metadata)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     BM25 SCORING ENGINE (99-02)                          │
│  Tokenize (Vietnamese) → BM25 Score → Anomaly Detection → ScoredItem    │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │ ScoredItem (bm25_score + anomaly_flag)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   TREND PREDICTION ENGINE (99-03)                        │
│  Anomaly Score → Graph Virality → Final Ranking → Top 10-20 Trends      │
└──────────┬─────────────────────────────────┬────────────────────────────┘
           │                                 │
           ▼                                 ▼
┌──────────────────────┐    ┌──────────────────────────────────────────────┐
│   REDIS CACHE (99-06) │    │           NEO4j + CHROMADB (99-05 + 99-06)   │
│   ZSET TTL 6h         │    │  ChromaDB: chunks + vectors (384d)           │
│   /ai/trends <20ms    │    │  Neo4j: Trend/KOL/Dish/Location graph        │
└──────────────────────┘    └──────────────────┬───────────────────────────┘
                                               │
                                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     GRAPHRAG CONTEXT BUILDER                             │
│  Vector Search → Graph Traversal → Entity Resolution → Prune → Context  │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │ GraphContext (structured prompt)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          LLM PROMPT LAYER                                │
│  /ai/trends/context → LLM → Content script (hook + SEO + narrative)     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Collection Layer (99-01)

> **Source:** DA-AI04-99-01 (complete). This section summarizes key configs — refer to 99-01 for full implementation detail.

### 2.1 Data Sources & Tools

| Source | Data Type | Frequency | Tool | Fallback |
|---|---|---|---|---|
| Google Trends | Trending keywords VN | Every 6h | SerpApi Google Trends API | DataForSEO |
| TikTok Hashtag Trending | Hot hashtags, top search | Every 6h | ScrapeCreators TikTok API | Apify TikTok Scraper |
| TikTok KOL Feed | Posts + comments | Every 6h | Apify `clockworks/tiktok-scraper` | ScrapeCreators profile API |
| Facebook Public Groups | Posts + comments | Every 6h | Apify `danek/facebook-search-ppr` | ScrapeCreators Facebook API |

### 2.2 SerpApi Google Trends Config

```python
TRENDS_CONFIG = {
    "geo": "VN",
    "timeframe": "now 7-d",
    "category": "all",          # all, food, beauty, fashion, tech
    "property": "",             # web search (default), youtube, news
}
```

**Schedule:** Cron `0 */6 * * *` via APScheduler `BackgroundScheduler`.

### 2.3 Apify Actors

| Actor | ID | Pricing |
|---|---|---|
| TikTok Scraper | `clockworks/tiktok-scraper` | ~$1.70/1K results |
| Facebook Search | `danek/facebook-search-ppr` | ~$3/1K results |

**Integration pattern:**

```python
from apify_client import ApifyClient

async def run_apify_actor(actor_id: str, input_data: dict) -> list[dict]:
    client = ApifyClient(token=settings.APIFY_TOKEN)
    run = client.actor(actor_id).call(run_input=input_data)
    return list(client.dataset(run["defaultDatasetId"]).iterate_items())
```

### 2.4 ScrapeCreators TikTok API

22 endpoints available. Key endpoints for MVP:

```python
SCRAPECREATORS_CONFIG = {
    "base_url": "https://api.scrapecreators.com/v1/tiktok",
    "endpoints": {
        "trending_feed": "/get-trending-feed",
        "hashtag_search": "/search/hashtag",
        "hashtag_posts":  "/hashtag/posts",
    },
    "rate_limit": "5 req/s (Freelance plan)",
}
```

### 2.5 APScheduler Setup

```python
from apscheduler.schedulers.background import BackgroundScheduler

scheduler = BackgroundScheduler()
scheduler.add_job(crawl_google_trends,  "cron", hour="*/6", id="google_trends")
scheduler.add_job(crawl_tiktok_trends, "cron", hour="*/6", id="tiktok_trends")
scheduler.add_job(crawl_facebook,      "cron", hour="*/6", id="facebook_groups")
scheduler.start()
```

### 2.6 Raw Output Contract

All collectors produce a unified `RawCrawlItem`:

```python
class RawCrawlItem:
    source: str            # "google_trends" | "tiktok" | "facebook"
    platform: str          # "google" | "tiktok" | "facebook"
    keyword: str           # trending keyword or hashtag
    text_content: str      # raw caption, post text, or empty
    media_url: str | None  # video/audio URL if available
    author: str | None     # username / creator
    metrics: dict          # {likes, shares, comments, views}
    region: str            # "VN"
    crawled_at: datetime   # ISO 8601
```

---

## 3. Text Normalizer & Chunking Layer (99-04)

> **Status:** New design. This layer fills the gap between Data Collection (99-01) and BM25 Scoring (99-02).

### 3.1 Purpose

Biến đổi `RawCrawlItem` (JSON thô đa ngôn ngữ, có audio/video) thành `IngestedItem` (text sạch chuẩn hóa, đã chunk). Đây là bước tiền xử lý bắt buộc trước khi BM25 scoring và embedding.

### 3.2 Pipeline Flow

```
RawCrawlItem
    │
    ├─ Has media_url? ──Yes──► STT (Whisper GPU) → transcribed_text
    │                              │
    └─ Has text_content? ─────────┼──────────────► raw_text
                                   │
                                   ▼
                            Text Normalizer
                            (lowercase, remove emoji,
                             normalize whitespace,
                             remove URLs, unify Unicode)
                                   │
                                   ▼
                            Language Detection
                            (keep only vi + en, mark others)
                                   │
                                   ▼
                            Text Chunker
                            (split by sentence boundary,
                             overlap 20%, max 512 chars/chunk)
                                   │
                                   ▼
                            IngestedItem[]
```

### 3.3 Module Structure

```
app/services/normalizer/
├── __init__.py
├── stt.py              # Whisper transcription
├── text_cleaner.py     # Normalization rules
├── chunker.py          # Sentence-boundary chunking
├── lang_detect.py      # Language detection + filter
└── models.py           # IngestedItem schema
```

### 3.4 Whisper STT (`stt.py`)

**Model:** `faster-whisper` base model, CUDA on RTX 4050.

```python
from faster_whisper import WhisperModel

class STTEngine:
    def __init__(self, model_size: str = "base", device: str = "cuda"):
        self.model = WhisperModel(model_size, device=device, compute_type="float16")

    def transcribe(self, audio_path: str, language: str = "vi") -> str:
        segments, _ = self.model.transcribe(audio_path, language=language)
        return " ".join(seg.text for seg in segments)
```

**Model size rationale:**

| Size | VRAM | Speed (1min audio) | Vietnamese WER |
|---|---|---|---|
| tiny | ~1 GB | ~3s | ~18% |
| base | ~1.5 GB | ~5s | ~12% |
| small | ~2.5 GB | ~10s | ~8% |

Chọn `base` làm default: balance speed/accuracy cho MVP. Nâng lên `small` khi có budget GPU.

**GPU check:** Khi không có CUDA, fallback `device="cpu" compute_type="int8"` — chậm hơn nhưng vẫn functional.

### 3.5 Text Normalizer (`text_cleaner.py`)

```python
import re
import unicodedata

class TextCleaner:
    @staticmethod
    def normalize(text: str) -> str:
        # 1. Unicode NFC normalization
        text = unicodedata.normalize("NFC", text)

        # 2. Lowercase (preserve proper nouns — defer to NER later)
        text = text.lower()

        # 3. Remove URLs
        text = re.sub(r"https?://\S+", "", text)

        # 4. Remove emoji (keep Vietnamese tone marks)
        text = re.sub(r"[^\w\sàáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđÀÁẢÃẠÂẦẤẨẪẬĂẰẮẲẴẶÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴĐ]", "", text, flags=re.UNICODE)

        # 5. Collapse whitespace
        text = re.sub(r"\s+", " ", text).strip()

        # 6. Remove standalone numbers / special chars
        text = re.sub(r"(?<=\s)[\d\W_]+(?=\s)", " ", text)

        return text
```

### 3.6 Language Detection (`lang_detect.py`)

```python
from lingua import LanguageDetectorBuilder, Language

class LangDetector:
    def __init__(self):
        self.detector = LanguageDetectorBuilder.from_languages(
            Language.VIETNAMESE, Language.ENGLISH
        ).build()

    def detect(self, text: str) -> str:
        lang = self.detector.detect_language_of(text)
        return lang.iso_code_639_1.name.lower() if lang else "unknown"

    def should_keep(self, text: str) -> bool:
        return self.detect(text) in ("vi", "en")
```

### 3.7 Text Chunker (`chunker.py`)

**Strategy:** Sentence-boundary chunking với 20% overlap. Max 512 characters/chunk (tương đương ~85-128 tokens, safe cho hầu hết embedding model).

```python
import re

class TextChunker:
    def __init__(self, max_chars: int = 512, overlap_ratio: float = 0.2):
        self.max_chars = max_chars
        self.overlap = int(max_chars * overlap_ratio)

    def chunk(self, text: str) -> list[str]:
        sentences = re.split(r"(?<=[.!?;:\n])\s+", text)
        chunks = []
        current = ""

        for sent in sentences:
            if len(current) + len(sent) <= self.max_chars:
                current += " " + sent if current else sent
            else:
                if current:
                    chunks.append(current.strip())
                # Start new chunk with overlap from previous
                overlap_text = current[-self.overlap:] if current and self.overlap > 0 else ""
                current = (overlap_text + " " + sent).strip()

        if current:
            chunks.append(current.strip())

        return chunks
```

### 3.8 IngestedItem Schema

```python
from dataclasses import dataclass
from datetime import datetime

@dataclass
class IngestedItem:
    chunk_id: str          # deterministic: sha256(source + chunk_index)
    trend_name: str        # from RawCrawlItem.keyword
    text: str              # normalized, chunked text
    source_platform: str   # "google" | "tiktok" | "facebook"
    source_url: str | None
    author: str | None
    language: str          # "vi" | "en"
    chunk_index: int       # position in original document
    total_chunks: int      # total chunks for this document
    has_audio: bool        # True if STT was applied
    raw_metrics: dict      # {likes, shares, comments, views}
    ingested_at: datetime
```

---

## 4. BM25 Scoring & Anomaly Engine (99-02)

> **Status:** New design. This layer scores individual text chunks and detects anomalous keyword surges.

### 4.1 Purpose

BM25 keyword scoring layer thực hiện 2 nhiệm vụ:
1. **Ranking:** Gán điểm keyword relevance cho mỗi chunk — thay thế normalized score đơn giản bằng BM25 chính xác hơn.
2. **Anomaly detection:** Phát hiện keyword có tần suất tăng đột biến so với historical baseline — đây chính là tín hiệu "trend đang nổi".

### 4.2 BM25 Algorithm

```
score(D, Q) = Σ IDF(qi) · [f(qi,D) · (k1+1)] / [f(qi,D) + k1 · (1 - b + b · |D|/avgdl)]

where:
  IDF(qi) = log[(N - n(qi) + 0.5) / (n(qi) + 0.5) + 1]
  f(qi, D) = term frequency of qi in document D
  |D| = document length
  avgdl = average document length in corpus
  k1 = 1.5 (term saturation)
  b = 0.75 (length normalization)
```

**Why BM25 over TF-IDF:**
- Term frequency saturation — 10 mentions không gấp 10 lần quan trọng hơn 1 mention.
- Length normalization — văn bản dài không được ưu tiên vô lý.
- Industry standard cho keyword retrieval (Elasticsearch, Lucene).

### 4.3 Vietnamese Tokenizer

BM25 yêu cầu tokenization. Tiếng Việt cần tokenizer riêng vì từ ghép (vd: "trà sữa" là 1 token, không phải "trà" + "sữa").

**Tool:** `pyvi` (Python Vietnamese NLP) hoặc `underthesea` — cả hai có word_tokenize.

```python
from pyvi import ViTokenizer

class VietnameseBM25:
    def __init__(self, k1: float = 1.5, b: float = 0.75):
        self.k1 = k1
        self.b = b
        self.tokenizer = ViTokenizer

    def tokenize(self, text: str) -> list[str]:
        return self.tokenizer.tokenize(text).split()
```

### 4.4 Module Structure

```
app/services/scoring/
├── __init__.py
├── bm25.py              # BM25 implementation
├── tokenizer.py         # Vietnamese + English tokenizer
├── anomaly.py           # Anomaly detection engine
└── models.py            # ScoredItem schema
```

### 4.5 BM25 Implementation (`bm25.py`)

```python
import numpy as np
from collections import Counter

class BM25Scorer:
    def __init__(self, k1: float = 1.5, b: float = 0.75):
        self.k1 = k1
        self.b = b
        self.corpus: list[list[str]] = []
        self.doc_freq: dict[str, int] = Counter()
        self.avgdl: float = 0.0
        self.N: int = 0

    def index(self, tokenized_docs: list[list[str]]):
        self.corpus = tokenized_docs
        self.N = len(tokenized_docs)
        self.avgdl = np.mean([len(d) for d in tokenized_docs]) if tokenized_docs else 0
        for doc in tokenized_docs:
            for token in set(doc):
                self.doc_freq[token] += 1

    def idf(self, token: str) -> float:
        n = self.doc_freq.get(token, 0)
        return np.log((self.N - n + 0.5) / (n + 0.5) + 1)

    def score(self, query_tokens: list[str], doc_tokens: list[str]) -> float:
        doc_len = len(doc_tokens)
        doc_counter = Counter(doc_tokens)
        score = 0.0
        for qi in query_tokens:
            if qi not in doc_counter:
                continue
            f = doc_counter[qi]
            idf_val = self.idf(qi)
            numerator = f * (self.k1 + 1)
            denominator = f + self.k1 * (1 - self.b + self.b * doc_len / self.avgdl)
            score += idf_val * numerator / denominator
        return score

    def score_batch(self, query_tokens: list[str]) -> list[float]:
        return [self.score(query_tokens, doc) for doc in self.corpus]
```

### 4.6 Anomaly Detection Engine (`anomaly.py`)

**Goal:** Phát hiện keyword có tần suất vượt xa historical baseline — đây là định nghĩa của "trend".

**Approach:** Moving Z-score với sliding window.

```
For each keyword k at time t:
  baseline_window = [t-7d, t-1d]     (7-day historical baseline)
  current_value  = freq(k, t)         (today's frequency)

  z_score(k, t) = (current_value - mean(baseline_window)) / max(stdev(baseline_window), ε)

  anomaly_threshold = 2.0             (2σ — top ~2.3% = genuine anomalies)
  is_trend = z_score > threshold
```

**Edge cases handled:**
- Keywords with zero historical data (new keyword): default z_score = 3.0 (treat as potential trend).
- Low baseline stddev (ε = 0.1): avoid division by zero khi keyword có frequency ổn định.
- Weekend/weekday cycle: rolling 7-day baseline automatically captures weekly pattern.

```python
from dataclasses import dataclass
from datetime import datetime, timedelta
import numpy as np

@dataclass
class KeywordFrequency:
    keyword: str
    date: str           # YYYY-MM-DD
    doc_count: int      # number of docs mentioning keyword
    total_docs: int     # total docs crawled that day

class AnomalyDetector:
    def __init__(self, z_threshold: float = 2.0, baseline_days: int = 7):
        self.z_threshold = z_threshold
        self.baseline_days = baseline_days
        self.history: dict[str, list[tuple[str, float]]] = {}  # keyword -> [(date, freq), ...]

    def freq(self, doc_count: int, total_docs: int) -> float:
        return doc_count / max(total_docs, 1)

    def add_observation(self, kw: str, date: str, doc_count: int, total_docs: int):
        freq = self.freq(doc_count, total_docs)
        self.history.setdefault(kw, []).append((date, freq))

    def z_score(self, kw: str, current_freq: float) -> float:
        records = self.history.get(kw, [])
        if not records:
            return 3.0  # new keyword = potential trend

        # Build baseline: last 7 days, excluding today
        baseline = [f for d, f in records[-self.baseline_days:]]
        if len(baseline) < 3:
            # Not enough data: use all available
            baseline = [f for _, f in records]

        mean = np.mean(baseline)
        std = np.std(baseline)
        epsilon = max(std, 0.1)  # avoid division by zero
        return (current_freq - mean) / epsilon

    def is_anomaly(self, kw: str, current_freq: float) -> tuple[bool, float]:
        z = self.z_score(kw, current_freq)
        return z > self.z_threshold, z
```

### 4.7 ScoredItem Schema

```python
@dataclass
class ScoredItem:
    chunk_id: str
    trend_name: str
    text: str
    source_platform: str
    author: str | None
    bm25_score: float          # BM25 relevance score
    anomaly_z_score: float     # Z-score vs historical baseline
    is_anomaly: bool           # True if z_score > threshold
    tokenized_keywords: list[str]  # top N keywords extracted
    language: str
    raw_metrics: dict
    scored_at: datetime
```

---

## 5. Trend Prediction Engine (99-03)

> **Status:** New design. This layer aggregates ScoredItems into a final ranked trend list.

### 5.1 Purpose

Biến tập hợp các `ScoredItem` riêng lẻ thành bảng xếp hạng trend cuối cùng (Top 10-20). Đây là composite score kết hợp:
- **Anomaly strength:** Tần suất keyword tăng mạnh thế nào so với baseline.
- **Graph virality:** Bao nhiêu KOL/entity liên kết với trend này.
- **Engagement volume:** Tổng volume tương tác (likes, shares, comments).
- **Source diversity:** Trend xuất hiện trên nhiều nền tảng sẽ được boost.

### 5.2 Composite Trend Score Formula

```
finalScore(T) = w1 · anomalyScore(T) + w2 · viralityScore(T) + w3 · engagementScore(T) + w4 · diversityScore(T)

Default weights (tunable):
  w1 = 0.35   anomaly — core signal: keyword is surging
  w2 = 0.30   virality — graph signal: KOL/entity network density
  w3 = 0.25   engagement — social signal: raw interaction volume
  w4 = 0.10   diversity — cross-platform signal

Each sub-score normalized to [0, 10] before weighted sum.
```

### 5.3 Sub-Score Definitions

#### 5.3.1 Anomaly Score

```
anomalyScore(T) = 10 · sigmoid(z_score / z_scale)
  where z_scale = 3.0, sigmoid(x) = 1/(1+e^(-x))

Maps z_score [0, 6+] → anomalyScore [5, 10]
  z=0   → 5.0  (no anomaly)
  z=2   → 6.6  (threshold)
  z=3   → 7.3
  z=5   → 8.4
  z=6+  → 9.5+ (very strong anomaly)
```

#### 5.3.2 Graph Virality Score

```
viralityScore(T) = 10 · min(graphDensity(T) / densityMax, 1.0)

graphDensity(T) = (incoming_edges + outgoing_edges) / unique_entities
  where edges: PROMOTED + ASSOCIATED_WITH + LOCATED_IN pointing to Trend node

densityMax = 5.0 (cap — beyond 5 edges/entity is noise)
```

#### 5.3.3 Engagement Score

```
engagementScore(T) = 10 · log(1 + totalEngagements) / log(1 + engCap)

totalEngagements = Σ chunks_for_trend(raw_metrics.likes + shares + comments)
engCap = 1_000_000  (1M interactions = score 10)
```

#### 5.3.4 Source Diversity Score

```
diversityScore(T) = 10 · (unique_sources / total_source_types)

unique_sources = count of distinct source_platform values for this trend
total_source_types = 3 (google, tiktok, facebook)

Trend on 1 platform = 3.3
Trend on 2 platforms = 6.7
Trend on all 3      = 10.0
```

### 5.4 Module Structure

```
app/services/prediction/
├── __init__.py
├── anomaly_scorer.py    # Anomaly sub-score
├── virality_scorer.py   # Graph virality sub-score (reads from Neo4j)
├── engagement_scorer.py # Engagement sub-score
├── composite_ranker.py  # Combine all scores → top N
└── models.py            # TrendResult schema
```

### 5.5 Composite Ranker Implementation

```python
import numpy as np
from dataclasses import dataclass

@dataclass
class TrendResult:
    keyword: str
    category: str
    anomaly_score: float       # [0, 10]
    virality_score: float      # [0, 10]
    engagement_score: float    # [0, 10]
    diversity_score: float     # [0, 10]
    final_score: float         # [0, 10]
    rank: int
    z_score: float
    entity_count: int          # total entities linked in Neo4j
    source_platforms: list[str]
    scored_at: datetime

class CompositeRanker:
    def __init__(self, weights: dict[str, float] | None = None):
        self.weights = weights or {
            "anomaly": 0.35,
            "virality": 0.30,
            "engagement": 0.25,
            "diversity": 0.10,
        }

    def sigmoid(self, x: float, scale: float = 3.0) -> float:
        return 1.0 / (1.0 + np.exp(-x / scale))

    def anomaly_score(self, z: float) -> float:
        return 10.0 * self.sigmoid(z)

    def virality_score(self, trend_name: str, neo4j_session) -> float:
        # Count entities connected to this trend
        result = neo4j_session.run("""
            MATCH (entity)-[r]->(t:Trend {name: $name})
            RETURN count(DISTINCT entity) AS entity_count,
                   count(DISTINCT r) AS edge_count
        """, name=trend_name).single()
        if not result or result["entity_count"] == 0:
            return 0.0
        density = result["edge_count"] / result["entity_count"]
        cap = 5.0
        return 10.0 * min(density / cap, 1.0)

    def engagement_score(self, total_engagements: int) -> float:
        cap = 1_000_000
        return 10.0 * np.log(1 + total_engagements) / np.log(1 + cap)

    def diversity_score(self, platforms: set[str]) -> float:
        return 10.0 * len(platforms) / 3

    def rank(self, trends_data: list[dict], neo4j_session=None) -> list[TrendResult]:
        results = []
        for t in trends_data:
            anom = self.anomaly_score(t["z_score"])
            vira = self.virality_score(t["keyword"], neo4j_session) if neo4j_session else 0.0
            enga = self.engagement_score(t.get("total_engagements", 0))
            divs = self.diversity_score(set(t.get("platforms", [])))

            final = (
                self.weights["anomaly"]    * anom +
                self.weights["virality"]   * vira +
                self.weights["engagement"] * enga +
                self.weights["diversity"]  * divs
            )

            results.append(TrendResult(
                keyword=t["keyword"],
                category=t.get("category", "all"),
                anomaly_score=round(anom, 2),
                virality_score=round(vira, 2),
                engagement_score=round(enga, 2),
                diversity_score=round(divs, 2),
                final_score=round(final, 2),
                rank=0,
                z_score=t["z_score"],
                entity_count=t.get("entity_count", 0),
                source_platforms=t.get("platforms", []),
                scored_at=datetime.utcnow(),
            ))

        # Sort and assign rank
        results.sort(key=lambda r: r.final_score, reverse=True)
        for i, r in enumerate(results):
            r.rank = i + 1

        return results[:20]
```

### 5.6 Threshold Tuning

| Parameter | Default | Tuning Strategy |
|---|---|---|
| `w1` (anomaly) | 0.35 | Increase if trends are too noisy / false positives |
| `w2` (virality) | 0.30 | Increase when Neo4j graph matures (>100 entities) |
| `w3` (engagement) | 0.25 | Increase if social volume is reliable signal |
| `w4` (diversity) | 0.10 | Boost if single-platform noise is a problem |
| `z_threshold` | 2.0 | Lower = more trends detected (higher recall), Higher = stricter (higher precision) |
| `densityMax` | 5.0 | Cap for graph density normalization |

---

## 6. Hybrid Storage — ChromaDB + Neo4j + Redis (99-05 + 99-06)

> **Sources:** DA-AI04-99-05 (complete), DA-AI04-99-06 (complete). This section summarizes key schemas and flows.

### 6.1 ChromaDB — Vector Storage

**Collection:** `trend_knowledge_chunks`
**Embedding Model:** `all-MiniLM-L6-v2` (384 dimensions, cosine similarity)
**ID Format:** `chunk_{trendName_normalized}_{sha256(text_content)}` (deterministic — safe for re-crawl)

**Metadata fields:**

| Field | Type | Indexed | Purpose |
|---|---|---|---|
| `trendName` | String | Yes | Fast pre-filtering before ANN search |
| `chunkIndex` | Integer | No | Sentence order within document |
| `sourcePlatform` | String | No | Filter by platform |
| `author` | String | No | KOL attribution |
| `interactionScore` | Float | No | `log(1 + likes + shares + comments)` |
| `docId` | String | No | Link to raw doc in MongoDB |

**HNSW Index Config:**

```python
collection = client.create_collection(
    name="trend_knowledge_chunks",
    metadata={
        "hnsw:space": "cosine",
        "hnsw:M": 16,
        "hnsw:construction_ef": 128,
        "hnsw:search_ef": 64,
    }
)
```

### 6.2 Neo4j — Graph Storage

**Nodes:**

| Label | Unique Key | Key Properties |
|---|---|---|
| `:Trend` | `name` | `category`, `finalScore`, `rank`, `createdAt`, `updatedAt` |
| `:KOL` | `username` | `platform`, `followers`, `engagementRate` |
| `:Dish` | `name` | `description`, `cuisineType` |
| `:Location` | `name` | `lat`, `lon`, `city`, `country` |

**Relationships** (all directed toward `:Trend`):

```
(:KOL)      -[:PROMOTED {views, likes, postedAt, platform}]->   (:Trend)
(:Dish)     -[:ASSOCIATED_WITH {confidenceScore, mentionCount}]-> (:Trend)
(:Location) -[:LOCATED_IN {mentionCount, isOrigin}]->            (:Trend)
```

**Cypher Constraints:**

```cypher
CREATE CONSTRAINT trend_name_unique    FOR (t:Trend)    REQUIRE t.name IS UNIQUE;
CREATE CONSTRAINT kol_username_unique  FOR (k:KOL)      REQUIRE k.username IS UNIQUE;
CREATE CONSTRAINT dish_name_unique     FOR (d:Dish)     REQUIRE d.name IS UNIQUE;
CREATE CONSTRAINT location_name_unique FOR (l:Location) REQUIRE l.name IS UNIQUE;

CREATE INDEX trend_category_idx FOR (t:Trend) ON (t.category);
CREATE INDEX location_city_idx  FOR (l:Location) ON (l.city);
```

### 6.3 Entity Resolution (Background Job)

**Schedule:** Daily at 02:00 AM (Cron: `0 2 * * *`)

**Algorithm (4-step):**

1. **Blocking:** Only compare same-label nodes (`KOL` vs `KOL`, etc.). For `Location`, further block by `city`.
2. **Hybrid Similarity:** `Score(u, v) = 0.4 × JaroWinkler(u.name, v.name) + 0.6 × Cosine(embed(u.name), embed(v.name))`. Threshold θ = 0.88.
3. **WCC Clustering:** Create temporary `:SIMILAR_TO` edges for pairs above threshold. Run WCC (Weakly Connected Components) from Neo4j GDS library.
4. **APOC Merge:** `apoc.refactor.mergeNodes()` consolidates clusters into master node (highest degree), redirects all relationships.

### 6.4 Redis — Cache Layer

**Key Template:** `trends:vn:{YYYY-MM-DD}:{category}` (e.g., `trends:vn:2026-08-03:food`)
**Data Structure:** Sorted Set (ZSET), score = `finalScore`, member = JSON metadata
**TTL:** 21600 seconds (6 hours) — matches crawl cycle

**Write (ZADD batch):**

```bash
ZADD trends:vn:2026-08-03:food 7.82 '{"keyword":"trà sữa đất nung","platform":"tiktok","rank":1}'
EXPIRE trends:vn:2026-08-03:food 21600
```

**Read (top 10):**

```bash
ZREVRANGE trends:vn:2026-08-03:food 0 9 WITHSCORES
```

### 6.5 Concurrent Upsert Flow

```python
async def sync_trends_pipeline(redis_client, neo4j_driver, category, trends_data):
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    redis_key = f"trends:vn:{today_str}:{category}"

    # Concurrent writes — non-blocking
    await asyncio.gather(
        write_to_redis(redis_client, redis_key, trends_data),
        write_to_neo4j(neo4j_driver, trends_data),
    )
```

**Error handling:**
- Redis fail + Neo4j OK: warm cache from Neo4j.
- Neo4j fail + Redis OK: evict Redis key, retry Neo4j 3x.

**Neo4j Upsert Pattern:**

```cypher
UNWIND $batch AS item
MERGE (t:Trend {name: item.keyword})
ON CREATE SET t.category = item.category, t.createdAt = datetime(),
              t.finalScore = item.score, t.rank = item.rank, t.updatedAt = datetime()
ON MATCH SET  t.finalScore = item.score, t.rank = item.rank, t.updatedAt = datetime()
```

### 6.6 Dashboard Read Flow (Cache-Aside)

```
Client → /ai/trends
    ├─ Redis Cache Hit?  → Return ZREVRANGE (<20ms)
    └─ Redis Cache Miss? → Query Neo4j (trends updated today)
                          → Warm Redis cache → Return (<200ms)
```

---

## 7. GraphRAG Context Builder

> **Source:** AI_Iteration_5 (DA-AI14), DA-AI04-99-05 §5.2. Synthesized into unified flow.

### 7.1 Purpose

Transform a user query (e.g., "phân tích trend trà sữa đất nung") into a rich, structured context that the LLM uses to write content. Not a bare keyword list — the context includes who is promoting it, where it is happening, what related entities exist.

### 7.2 Retrieval Flow

```
User Query: "phân tích trend trà sữa đất nung"
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: VECTOR SEARCH (ChromaDB)                            │
│   query = embed("trà sữa đất nung")                         │
│   where = {"trendName": "trà sữa đất nung"}                 │
│   results = collection.query(query, n=5, where=where)       │
│   → Top 5 semantic chunks about this trend                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: GRAPH TRAVERSAL (Neo4j)                             │
│   MATCH (entity)-[r]->(t:Trend {name: "trà sữa đất nung"}) │
│   RETURN entity, r                                          │
│   → KOLs promoting + Dishes associated + Locations          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: CONTEXT SYNTHESIS                                   │
│   Merge vector results + graph results into single prompt:  │
│                                                             │
│   "Dữ liệu ngữ cảnh cho trend 'trà sữa đất nung':           │
│                                                             │
│    [THEO DỮ LIỆU CÀO]                                      │
│     - Chunk 1: quán trà sữa nồi đất Hàng Bồ rất đông...     │
│     - Chunk 2: cách làm trà sữa đất nung tại nhà...         │
│                                                             │
│    [THEO MẠNG LƯỚI THỰC THỂ]                               │
│     - KOL ninheating (1.2M followers) quảng bá trên TikTok  │
│     - Địa điểm Hàng Bồ, Hà Nội là nơi khởi nguồn           │
│     - Món Trà sữa đất nung Hàng Bồ liên kết chặt chẽ       │
│                                                             │
│    Hãy viết kịch bản quảng cáo bắt trend..."               │
└─────────────────────────────────────────────────────────────┘
```

### 7.3 Module Structure

```
app/services/graphrag/
├── __init__.py
├── context_builder.py    # Orchestrates retrieval + synthesis
├── vector_search.py      # ChromaDB query wrapper
├── graph_traversal.py    # Neo4j Cypher query wrapper
├── pruner.py             # BM25-based pruning, depth limit
└── models.py             # GraphContext schema
```

### 7.4 Context Builder Implementation

```python
class GraphRAGContextBuilder:
    def __init__(self, chroma_collection, neo4j_driver):
        self.chroma = chroma_collection
        self.neo4j = neo4j_driver

    async def build(self, trend_name: str, query_text: str,
                    top_k_vector: int = 5, graph_depth: int = 1,
                    max_context_chars: int = 4000) -> GraphContext:

        # Step 1: Vector search
        vector_results = self.chroma.query(
            query_texts=[query_text],
            n_results=top_k_vector,
            where={"trendName": trend_name},
        )

        # Step 2: Graph traversal
        async with self.neo4j.session() as session:
            graph_results = await session.run("""
                MATCH (entity)-[r]->(t:Trend {name: $name})
                RETURN labels(entity)[0] AS entity_type,
                       entity.name AS entity_name,
                       properties(entity) AS entity_props,
                       type(r) AS rel_type,
                       properties(r) AS rel_props
                LIMIT 20
            """, name=trend_name)
            graph_data = await graph_results.data()

        # Step 3: Synthesize context
        context = self._synthesize(
            trend_name=trend_name,
            vector_chunks=vector_results.get("documents", [[]])[0],
            graph_entities=graph_data,
            max_chars=max_context_chars,
        )

        return GraphContext(
            trend_name=trend_name,
            context_text=context,
            source_chunks=len(vector_results.get("documents", [[]])[0]),
            entity_count=len(graph_data),
            entity_types=list(set(e["entity_type"] for e in graph_data)),
        )

    def _synthesize(self, trend_name, vector_chunks, graph_entities, max_chars):
        parts = [f"Dữ liệu ngữ cảnh cho trend '{trend_name}':\n"]

        # Vector chunks
        parts.append("\n[THEO DỮ LIỆU CÀO THÔ]")
        for i, chunk in enumerate(vector_chunks):
            parts.append(f"  - Chunk {i+1}: {chunk}")

        # Graph entities
        parts.append("\n[THEO MẠNG LƯỚI THỰC THỂ]")
        for entity in graph_entities:
            parts.append(
                f"  - {entity['entity_type']} '{entity['entity_name']}' "
                f"({entity['rel_type']})"
            )

        context = "\n".join(parts)
        if len(context) > max_chars:
            context = context[:max_chars] + "\n... (truncated)"
        return context
```

### 7.5 Pruning Strategy

Trước khi build context, prune để tránh vượt token limit:

1. **BM25 threshold:** Chỉ giữ chunks có `bm25_score > median`.
2. **Graph depth limit:** Default `depth=1` (chỉ entity trực tiếp kết nối với Trend). Có thể tăng lên `depth=2` cho phân tích sâu hơn.
3. **Entity cap:** Max 10 entities per entity type (KOL, Dish, Location).
4. **Context character cap:** 4000 chars (~1000 tokens) — đủ rich cho LLM, không vượt context window.

### 7.6 GraphContext Schema

```python
@dataclass
class GraphContext:
    trend_name: str
    context_text: str          # synthesized context ready for LLM
    source_chunks: int         # number of vector chunks included
    entity_count: int          # number of graph entities included
    entity_types: list[str]    # ["KOL", "Location", "Dish"]
    top_keywords: list[str]    # from BM25 scoring
    anomaly_z: float           # current anomaly signal
    generated_at: datetime
```

---

## 8. API Layer & Contracts

### 8.1 Endpoints

| Method | Path | Description | Latency Target |
|---|---|---|---|
| GET | `/ai/trends` | Top trends by category + date | <20ms (Redis cache hit) |
| GET | `/ai/trends/context` | GraphRAG context for one trend | <500ms (vector + graph) |
| GET | `/ai/trends/search` | Semantic search across trends | <200ms |
| POST | `/ai/trends/crawl/trigger` | Manual crawl trigger (internal) | N/A (async) |
| GET | `/ai/trends/health` | Pipeline health status | <10ms |

### 8.2 Request/Response Contracts

**GET `/ai/trends?category=food&date=2026-08-03&limit=10`**

```json
{
  "category": "food",
  "date": "2026-08-03",
  "trends": [
    {
      "keyword": "trà sữa đất nung",
      "rank": 1,
      "finalScore": 7.82,
      "anomalyScore": 7.3,
      "viralityScore": 6.5,
      "platforms": ["tiktok", "google"],
      "entityCount": 5,
      "fetchedAt": "2026-08-03T09:00:00Z"
    }
  ],
  "cached": true
}
```

**GET `/ai/trends/context?trend=trà sữa đất nung`**

```json
{
  "trendName": "trà sữa đất nung",
  "contextText": "Dữ liệu ngữ cảnh cho trend 'trà sữa đất nung':\n\n[THEO DỮ LIỆU CÀO THÔ]\n  - Chunk 1: ...",
  "sourceChunks": 5,
  "entityCount": 8,
  "entityTypes": ["KOL", "Location", "Dish"],
  "topKeywords": ["trà sữa", "đất nung", "Hàng Bồ", "ninheating"],
  "anomalyZ": 3.4,
  "generatedAt": "2026-08-03T09:00:05Z"
}
```

### 8.3 Internal Service Contract (Business Service → AI Service)

**Header:** `X-Internal-Service-Key: ${INTERNAL_SERVICE_KEY}` (shared secret)

**POST `/ai/trends/crawl/trigger`** (internal only)

```json
{
  "sources": ["google_trends", "tiktok", "facebook"],
  "region": "VN",
  "categories": ["food", "fashion", "tech", "beauty"]
}
```

Response: `{"jobId": "crawl_20260803_0900", "status": "started"}`

---

## 9. Deployment & Configuration

### 9.1 New Docker Services

Add to `docker-compose.apps.yml`:

```yaml
ai-service:
  environment:
    # Existing
    CHROMADB_HOST: chromadb
    CHROMADB_PORT: 8000
    # New — Neo4j
    NEO4J_URI: bolt://neo4j:7687
    NEO4J_USER: neo4j
    NEO4J_PASSWORD: ${NEO4J_PASSWORD:-password}
    # New — Redis (for trend cache)
    REDIS_URL: redis://redis:6379
    REDIS_PASSWORD: ${REDIS_PASSWORD:-password}
    # New — Whisper
    WHISPER_MODEL: base
    WHISPER_DEVICE: cuda
    # New — API keys
    APIFY_TOKEN: ${APIFY_TOKEN:-}
    SCRAPECREATORS_API_KEY: ${SCRAPECREATORS_API_KEY:-}
    SERPAPI_KEY: ${SERPAPI_KEY:-}
```

**New Docker services needed:**

```yaml
neo4j:
  image: neo4j:5-community
  container_name: brandhub-neo4j
  ports:
    - "7474:7474"   # HTTP
    - "7687:7687"   # Bolt
  environment:
    NEO4J_AUTH: neo4j/${NEO4J_PASSWORD:-password}
    NEO4J_PLUGINS: '["apoc", "graph-data-science"]'
  volumes:
    - neo4j_data:/data
  networks:
    - brandhub-network
  restart: unless-stopped
```

### 9.2 New Python Dependencies

Add to `brandhub-ai-service/requirements.txt`:

```
# Crawl & Data Collection
serpapi==0.1.5
apify-client==1.3.0

# STT
faster-whisper==1.0.3

# BM25 & NLP
rank-bm25==0.2.2
pyvi==0.0.4
lingua-language-detector==2.0.2

# Neo4j
neo4j==5.26.0

# Redis
redis==5.2.0

# Scheduling
apscheduler==3.10.4
```

### 9.3 Config Fields

Add to `app/core/config.py`:

```python
# Neo4j
neo4j_uri: str = Field(default="bolt://localhost:7687", validation_alias="NEO4J_URI")
neo4j_user: str = Field(default="neo4j", validation_alias="NEO4J_USER")
neo4j_password: str = Field(default="", validation_alias="NEO4J_PASSWORD")

# Redis
redis_url: str = Field(default="redis://localhost:6379", validation_alias="REDIS_URL")
redis_password: str = Field(default="", validation_alias="REDIS_PASSWORD")

# Whisper
whisper_model: str = Field(default="base", validation_alias="WHISPER_MODEL")
whisper_device: str = Field(default="cuda", validation_alias="WHISPER_DEVICE")

# Third-party APIs
apify_token: str = Field(default="", validation_alias="APIFY_TOKEN")
scrapecreators_api_key: str = Field(default="", validation_alias="SCRAPECREATORS_API_KEY")
serpapi_key: str = Field(default="", validation_alias="SERPAPI_KEY")

# MongoDB (for raw doc storage)
mongodb_uri: str = Field(default="mongodb://localhost:27017", validation_alias="MONGODB_URI")
mongodb_db: str = Field(default="brandhub_ai", validation_alias="MONGODB_DATABASE")

# Trend Prediction
trend_z_threshold: float = Field(default=2.0, validation_alias="TREND_Z_THRESHOLD")
trend_weights: str = Field(default="0.35,0.30,0.25,0.10", validation_alias="TREND_WEIGHTS")
```

### 9.4 Cost Estimate

| Component | Monthly Cost | Notes |
|---|---|---|
| SerpApi | $0 (free tier: 100 searches) | Sufficient for 4 calls/day × 30 = 120 |
| Apify TikTok | ~$5 | 4 calls/day × $0.04/call |
| ScrapeCreators | $0-$47 | Free tier or Freelance plan |
| Apify Facebook | ~$3 | 4 calls/day × $0.03/call |
| Neo4j (self-hosted) | $0 | Docker on existing infra |
| Redis (existing) | $0 | Already in docker-compose |
| ChromaDB (existing) | $0 | Already in docker-compose |
| GPU (RTX 4050) | $0 | Local hardware |
| **Total** | **$0-$55/month** | |

---

## 10. Acceptance Criteria & Phase 2 Roadmap

### 10.1 Pipeline Acceptance (E2E Checklist)

- [ ] **99-01:** Crawl job chạy mỗi 6h, trả về `RawCrawlItem[]` từ 3 nguồn (Google, TikTok, Facebook)
- [ ] **99-04:** STT transcribe được video TikTok tiếng Việt (Whisper base, WER ≤15%)
- [ ] **99-04:** Text normalizer loại bỏ emoji, URL, unify Unicode NFC
- [ ] **99-04:** Chunker tạo chunk 512 chars, overlap 20%
- [ ] **99-02:** BM25 score từng chunk với Vietnamese tokenizer
- [ ] **99-02:** Anomaly detector phát hiện keyword có z-score > 2.0
- [ ] **99-03:** Composite ranker cho ra Top 10-20 trend với đủ 4 sub-scores
- [ ] **99-05:** ChromaDB collection `trend_knowledge_chunks` có metadata index trên `trendName`
- [ ] **99-05:** Neo4j constraints + indexes deployed; entity resolution job chạy daily
- [ ] **99-06:** Redis ZSET cache + Neo4j upsert chạy đồng thời qua `asyncio.gather`
- [ ] **99-07:** `/ai/trends` trả về top trends <20ms (Redis hit)
- [ ] **99-07:** `/ai/trends/context` trả về GraphRAG context <500ms

### 10.2 Quality Gates

| Gate | Metric | Threshold |
|---|---|---|
| G1: STT Accuracy | Vietnamese WER | ≤15% (base model) |
| G2: Anomaly Precision | Trends flagged that are genuine | ≥60% |
| G3: Anomaly Recall | Known trends that are flagged | ≥80% |
| G4: Cache Hit Rate | `/ai/trends` served from Redis | ≥90% |
| G5: Context Latency | `/ai/trends/context` p95 | <500ms |
| G6: Entity Resolution | Duplicate nodes merged daily | 0 duplicates >24h old |
| G7: Pipeline Reliability | Crawl jobs completing without manual restart | ≥95% (target: 1 failure/week max) |

### 10.3 Known Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| TikTok blocks Apify actor | Medium | High | Fallback to ScrapeCreators; Phase 2 custom crawler |
| SerpApi free tier exhausted | Low | Medium | Upgrade to Starter ($50) or DataForSEO fallback |
| Whisper OOM on RTX 4050 | Low | Medium | Fallback to CPU int8; pin model size |
| Neo4j Community license limits | Low | Low | Single-node deployment is free; scale horizontally only if needed |
| BM25 underperforms for Vietnamese | Medium | Medium | Add PhoBERT embedding as semantic complement |
| API rate limit from ScrapeCreators | Medium | Medium | Implement exponential backoff retry |

### 10.4 Phase 2 Roadmap (Post-MVP)

| Phase | Scope | Trigger |
|---|---|---|
| **Phase 2a** | Custom TikTok/Playwright crawler (replace Apify) | When API cost > $50/month |
| **Phase 2b** | PhoBERT embedding for Vietnamese semantic search (replace all-MiniLM-L6-v2) | When Vietnamese content > 80% of corpus |
| **Phase 2c** | Visual/OCR pipeline for image-based trend detection | When TikTok trends shift heavily to visual |
| **Phase 2d** | Kafka streaming to replace batch APScheduler | When <1h trend detection latency is required |
| **Phase 2e** | Graph Neural Network scoring (PinSage-inspired) | When Neo4j graph > 10K nodes |
| **Phase 2f** | Retention/hook measurement from video metrics | When content generation needs hook optimization |

### 10.5 Document Cross-References

| Document | Covers |
|---|---|
| [DA-AI04-99-01](DA-AI04-99-01_Data_Collection_Layer_Design.md) | Full data collection implementation |
| [DA-AI04-99-05](../database/DA-AI04-99-05_Hybrid_DB_Schema.md) | Full ChromaDB + Neo4j schema |
| [DA-AI04-99-06](../database/DA-AI04-99-06_Redis_Neo4j_Upsert_Flow.md) | Full Redis + Neo4j upsert implementation |
| [AI_Iteration_5](../plan/iterations/AI_Iteration_5_GraphRAG_Trend_Detection.md) | Phase 2 GraphRAG full epic breakdown |
| [ARCHITECTURE](../idea/idea_crawData_algorithm/ARCHITECTURE.md) | Original system architecture concept |
| [crawData_analysis](../idea/idea_crawData_algorithm/crawData_analysis.md) | Original GraphRAG + streaming concept |
| [market_comparison](../idea/idea_crawData_algorithm/market_comparison.md) | Market positioning analysis |

---

*Generated: 2026-08-03 | Epic AI-4.99 | DA-AI04-99-07*
