# Sprint 5 — Individual Report

---

## 1. Thông tin cá nhân

| Field | Value |
|---|---|
| Họ tên | Nguyễn Minh Tuấn |
| GitHub | [@tuannm] |
| Role | AI Engineer |
| Sprint | Sprint 5 |
| Ngày nộp | 2026-08-03 |

---

## 2. Tasks được giao trong sprint này

| Task ID | Jira Link | Mô tả | Priority | Status cuối sprint |
|---|---|---|---|---|
| DA-AI04-99-01 | [DA-AI04-99-01](https://letritrung2605.atlassian.net/browse/DA-AI04-99-01) | Design & research data collection layer (Google Trends, TikTok crawlers, Social firehose) | 🔴 High | 🔄 In Review |
| DA-AI04-99-07 | [DA-AI04-99-07](https://letritrung2605.atlassian.net/browse/DA-AI04-99-07) | Compile final crawl trend analysis blueprint document | 🔴 High | 🔄 In Review |

**Tổng:** 2 tasks | Done: 0 | In Review: 2 | In Progress: 0 | To Do: 0

---

## 3. Chi tiết công việc đã làm cho 2 task In Review

---

### [DA-AI04-99-01] — Design & research data collection layer (Google Trends, TikTok crawlers, Social firehose)

**Jira status:** In Review
**Phạm vi:** nghiên cứu và thiết kế tầng thu thập dữ liệu đa nguồn cho trend detection pipeline, chốt chiến lược API-first MVP.

**File liên quan:**
- `docs/AI_Models/DA-AI04-99-01_Data_Collection_Layer_Design.md` (1,186 dòng)

**Công việc đã thực hiện:**

**Nghiên cứu nền tảng & tool:**
- Đánh giá 3 hướng tiếp cận: Apify marketplace actors, ScrapeCreators TikTok API (22 endpoints), và tự code Playwright/Scrapy.
- Kết luận: pytrends đã chết (archived GitHub 4/2025, Google thay đổi session auth, mọi request trả 429).
- Chọn SerpApi Google Trends API làm replacement cho pytrends — ổn định nhất, trả JSON sạch.

**Chiến lược API-first MVP:**
- Quyết định kiến trúc: dùng third-party API cho toàn bộ data collection giai đoạn MVP.
- Lý do: time-to-market 1-2 tuần (so với 2-4 tuần tự code), không cần maintain proxy/anti-detection, chi phí $0-55/tháng.
- Lộ trình 2 giai đoạn: Giai đoạn 1 (MVP) dùng API, Giai đoạn 2 (Scale) tự code crawler chọn lọc cho source nào API quá đắt.

**Thiết kế 4 crawler:**

| Crawler | Tool | Dữ liệu |
|---|---|---|
| Google Trends | SerpApi | Trending keywords VN, 7-day window, theo category |
| TikTok Hashtag Trending | ScrapeCreators | Hashtag hot, top search feed |
| TikTok KOL Feed | Apify `clockworks/tiktok-scraper` | Bài đăng + comments từ KOL |
| Facebook Public Groups | Apify `danek/facebook-search-ppr` | Bài đăng + comments từ group công khai |

**Thiết kế kỹ thuật chi tiết:**
- Cấu hình geo, timeframe, category cho từng nguồn.
- Contract output thống nhất: `RawCrawlItem` với các trường source, platform, keyword, text_content, media_url, author, metrics, region, crawled_at.
- APScheduler `BackgroundScheduler` chạy cron `0 */6 * * *` cho cả 4 crawler.
- Chiến lược rate limiting và retry với exponential backoff.
- Tầng raw storage buffer: MongoDB collection `raw_crawl_items` lưu kết quả crawl thô trước khi qua normalizer.
- Tổng chi phí ước tính: $0-55/tháng (tùy free tier hay Freelance plan).

**Kết quả đạt được:**
- Tài liệu thiết kế hoàn chỉnh 1,186 dòng, đủ chi tiết để implement.
- Chốt được chiến lược API-first giúp tiết kiệm ít nhất 80% thời gian MVP so với tự code crawler.
- Contract `RawCrawlItem` đã defined — sẵn sàng bàn giao cho 99-04 (Text Normalizer).

**Ghi chú review:** Cần team review quyết định chọn free tier hay nâng lên ScrapeCreators Freelance plan ($47/tháng) để có 25K credits và rate limit 5 req/s.

---

### [DA-AI04-99-07] — Compile final crawl trend analysis blueprint document

**Jira status:** In Review
**Phạm vi:** tổng hợp toàn bộ tài liệu nghiên cứu và thiết kế của Epic AI-4.99 thành một blueprint end-to-end duy nhất, đồng thời thiết kế các sub-task còn thiếu.

**File liên quan:**
- `docs/AI_Models/DA-AI04-99-07_Crawl_Trend_Blueprint.md`

**Công việc đã thực hiện:**

**Tổng hợp từ tài liệu có sẵn (synthesis):**
- Data Collection Layer (99-01): tóm tắt config SerpApi, Apify, ScrapeCreators, APScheduler scheduler.
- Hybrid DB Schema (99-05): ChromaDB collection `trend_knowledge_chunks`, Neo4j graph schema (4 node types, 3 relationship types), Entity Resolution 4-step algorithm, HNSW index config.
- Redis + Neo4j Upsert Flow (99-06): ZSET key template, TTL 6h, concurrent `asyncio.gather` write flow, retry policy, Cache-Aside read pattern.
- GraphRAG Context Builder: vector search → graph traversal → context synthesis flow từ AI_Iteration_5 (DA-AI14).

**Thiết kế gap analysis & new sub-tasks:**

| Sub-task | Nội dung thiết kế | Module đề xuất |
|---|---|---|
| 99-04 Text Normalizer | Whisper STT pipeline (faster-whisper base, CUDA), text cleaner (Unicode NFC, emoji removal), language detection (lingua, vi+en), chunker (512 chars, 20% overlap) | `app/services/normalizer/` |
| 99-02 BM25 Scoring Engine | BM25 implementation với Vietnamese tokenizer (pyvi), moving Z-score anomaly detector (7-day baseline window, threshold 2σ) | `app/services/scoring/` |
| 99-03 Trend Prediction Engine | 4-factor composite score: anomaly (35%) + graph virality (30%) + engagement (25%) + source diversity (10%), sigmoid normalization, Neo4j graph density query | `app/services/prediction/` |

**Tài liệu bổ sung:**
- API contracts: 5 endpoints với request/response schema và latency targets.
- Docker service configs: Neo4j container mới, biến môi trường bổ sung cho ai-service.
- New dependencies list: `faster-whisper`, `rank-bm25`, `pyvi`, `lingua-language-detector`, `neo4j`, `redis`, `apscheduler`, `serpapi`, `apify-client`.
- Cost estimate: $0-55/tháng cho toàn bộ pipeline MVP.
- Acceptance criteria checklist: 12 items end-to-end.
- Quality gates: 7 metrics với threshold cụ thể.
- Known risks: 6 risks với probability/impact/mitigation.
- Phase 2 roadmap: 6 giai đoạn mở rộng với trigger condition.

**Kết quả đạt được:**
- Single source of truth: developer đọc 1 file (~580 dòng) hiểu toàn bộ pipeline crawl → trend → store → serve.
- 3 sub-task còn thiếu (99-02, 99-03, 99-04) đã được thiết kế đầy đủ — sẵn sàng assign cho team implement.
- Cross-reference map tới tất cả tài liệu liên quan trong epic.

**Ghi chú review:** Cần team review các tham số default (weights, thresholds) và quyết định có cần điều chỉnh trước khi implement. BM25 tokenizer cho tiếng Việt (pyvi) có thể cần benchmark thêm với underthesea trước khi chốt.

---

## 4. Tasks chưa hoàn thành / chưa chuyển review

Không có. Cả 2 task trong sprint đều đã hoàn thành và đang ở trạng thái In Review.

---

## 5. Đóng góp ngoài tasks chính

- Phân tích market comparison (Brandwatch, Meltwater, TikTok, Pinterest vs BrandHub) để định vị chiến lược: "Brandwatch/Meltwater thu nhỏ" cho SME Việt Nam.
- Pivot chiến lược từ custom-crawler-first sang API-first sau khi research cho thấy pytrends đã chết và TikTok anti-bot rate 14-22%.
- Thiết kế cấu trúc blueprint theo hướng single source of truth — giảm context-switching cho developer (1 file thay vì 6 file).
- Định nghĩa interface contract giữa các layer: `RawCrawlItem` → `IngestedItem` → `ScoredItem` → `TrendResult` → `GraphContext`.

---

## 6. Học được gì trong sprint này

1. **API-first là quyết định đúng cho MVP:** Tự code crawler TikTok/Facebook tốn hàng tuần debug anti-bot, trong khi Apify/ScrapeCreators đã giải quyết bài toán này. Chi phí API thấp hơn nhiều so với công sức dev + maintenance.
2. **pytrends không còn là dependency tin cậy:** Archived GitHub, Google thay đổi auth flow. Cần có fallback strategy (SerpApi hoặc DataForSEO) ngay từ đầu.
3. **Composite scoring cần tunable weights:** Không có bộ trọng số nào đúng cho mọi loại trend. Cần thiết kế hệ thống có thể điều chỉnh weights mà không cần deploy lại code.
4. **Single source of truth document giảm fragmentation:** Khi epic có 7 sub-task với 6 file tài liệu, blueprint tổng giúp developer mới onboard nhanh và team không bị lạc trong đống doc rời rạc.
5. **Entity Resolution là bài toán khó nhất trong GraphRAG:** Jaro-Winkler + embedding similarity là giải pháp tốt cho giai đoạn đầu, nhưng cần LLM-based resolution khi graph phình to.

---

## 7. Feedback & Đề xuất

### 7.1 Về quy trình làm việc

Sprint 5 tập trung vào research & design (không code). Điều này hợp lý cho epic AI-4.99 vì đây là epic phân tích kiến trúc. Các sprint sau (6+) sẽ là implementation dựa trên blueprint này.

### 7.2 Về tài liệu

- Nên có convention đặt tên file thống nhất cho AI_Models: `DA-AI04-99-XX_Ten_Task.md`.
- Các file database docs nên được link chéo từ AI_Models docs để tránh fragmentation.
- Cân nhắc tạo `docs/AI_Models/README.md` làm index cho toàn bộ AI model documents.

### 7.3 Đề xuất cho sprint tiếp theo

- Bắt đầu implement 99-04 (Text Normalizer) — đây là blocker cho toàn bộ pipeline downstream.
- Setup Neo4j Docker container và verify constraints/indexes từ 99-05.
- Benchmark Whisper base model trên sample video TikTok tiếng Việt để verify WER ≤15%.
- Nếu team quyết định dùng ScrapeCreators Freelance plan, tạo tài khoản và test các endpoint cần thiết.
- Cập nhật `requirements.txt` và `docker-compose.apps.yml` với các dependency và service mới từ blueprint.

---

## 8. Self-assessment

| Tiêu chí | Điểm (1-5) | Ghi chú |
|---|---|---:|
| Hoàn thành đúng deadline | 5/5 | Cả 2 task hoàn thành trong sprint, không có task spill-over |
| Chất lượng deliverable | 5/5 | 99-01 (1,186 dòng) + 99-07 (blueprint end-to-end) đều đầy đủ chi tiết, có code reference, contract rõ ràng |
| Giao tiếp với team | 4/5 | Document đã cross-reference đầy đủ, cần team review để chốt tham số trước khi implement |
| Chủ động xử lý blocker | 5/5 | Pivot từ custom-crawler sang API-first, phát hiện pytrends đã chết, thiết kế gap analysis cho 3 sub-task còn thiếu |
| **Tổng** | **19/20** | |

---

*Nộp: 2026-08-03 | Sprint 5 ends: 2026-08-03*
