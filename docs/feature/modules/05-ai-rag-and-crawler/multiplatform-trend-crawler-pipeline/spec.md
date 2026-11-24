> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Multi-Platform Trend Crawler Pipeline, Proxy Rotation, S3 Cold Storage & Daily Replay

| Field | Value |
| :--- | :--- |
| **Module Slug** | `multiplatform-trend-crawler-pipeline` |
| **Category** | `05-ai-rag-and-crawler` — AI Trend Crawler, Neo4j Knowledge Graph & Brand RAG |
| **Canonical Actors / Roles** | `Admin` |
| **Consolidated Feature Scopes** | `admin-crawler-control`, `admin-multiplatform-trend-pipeline`, `admin-trend-data-view`, `admin-trend-pipeline-now`, `admin-trend-source-config`, `crawler-bounded-memory`, `crawler-proxy-readiness`, `internal-trends-fetch`, `update-trend-flow`, `trend-cold-storage`, `trend-s3-daily-replay`, `trend-review-cli`, `ai-service-ci` |
| **Aligned SRS Domains** | [FR 3.7.1 — View Trending Topics](../../../srs/06-ai-features/3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.13 — Crawl Schedule Config](../../../srs/06-ai-features/3-7-13-crawl-schedule-config/spec.md) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Orchestrate BrandHub's end-to-end **Multi-Platform Trend Ingestion & Labeling Pipeline (`T0 -> T7`)**: `Admin` crawler credential/proxy health probes & live run controls (`AdminCrawlerManagementController`, `AdminTrendPipelineController`), bounded-memory headless/API crawlers (`crawler-bounded-memory`, `crawler-proxy-readiness`), lean LLM trend clustering & naming (`update-trend-flow`, `trend-review-cli`), internal `/fetch` & `/dependencies` contracts, **S3 Daily Cold Storage & Deterministic Historical Replay** (`AdminTrendReplayController`), and `brandhub-ai-service` CI gates.

## 2. User Stories

- As an `Admin`, I want full visibility and manual/scheduled control over multi-platform trend crawlers, rotating proxy & cookie probes, immediate 'Run Pipeline Now' triggers, raw trend data inspection, and deterministic S3 daily historical replay without memory leaks or duplicate Neo4j/Redis ingestion.

## 3. Consolidated Acceptance Criteria

1. **Unified Admin Crawler & Source Control (`admin-crawler-control`, `admin-multiplatform-trend-pipeline`, `admin-trend-source-config`, `admin-trend-pipeline-now`, `admin-trend-data-view`):** `AdminCrawlerManagementController` (`/api/v1/admin/ai/trend-pipeline/management/{health|credentials|preview|start|runs}`) and `AdminTrendPipelineController` (`/config`, `/source-config`, `/runs`, `/recover`) let `Admin` configure source weights, probe/revoke encrypted cookies/proxies, trigger on-demand runs, recover stalled runs, and inspect normalized trend items (`AdminTrendController`).
2. **Bounded-Memory Execution & Proxy Rotation (`crawler-bounded-memory`, `crawler-proxy-readiness`):** `crawl_batch_consumer.py` enforces strict batch streaming, browser context recycling, and health-checked proxy rotation so long crawl batches stay within container memory limits.
3. **Lean `T0 -> T7` LLM Labeling & Internal Fetch Contract (`update-trend-flow`, `trend-review-cli`, `internal-trends-fetch`):** Raw scraped items deduplicate (`trend_dedup.py`), cluster, label via structured LLM/Claude CLI review prompts, publish to Redis ZSETs (`trends:vn:*`) + Neo4j (`knowledge_graph.py`), and expose `GET /api/v1/ai/internal/trends/fetch` & `/dependencies` (`X-Internal-Api-Key`).
4. **S3 Cold Storage & Daily Replay (`trend-cold-storage`, `trend-s3-daily-replay`):** Every crawl batch archives immutable compressed NDJSON/JSON envelopes to S3 (`trend_cold_storage.py`); `AdminTrendReplayController` (`/api/v1/admin/ai/trend-replays/preview`, `/{identity}/start|cancel|days/{day}`) replays archived S3 days idempotently to rebuild Redis/Neo4j state.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`admin.crawler.*`, `admin.trendPipeline.*`, `admin.trendReplay.*` in `src/i18n/locales/{vi,en}/admin.json`) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** `pages/admin/components/{AdminTrendPipelinePanel,AdminTrendPipelineControl,AdminTrendSourceConfig,CrawlerCredentialsPanel,CrawlerHealthPanel,CrawlerRunLauncher,AdminTrendReplayPanel,TrendReplayFlow}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/components/admin/AdminCrawlerHealthCard.tsx`, `src/screens/admin/AdminSystemHealthScreen.tsx`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `GET/PATCH/POST /api/v1/admin/ai/trend-pipeline/** & /management/**` | Bearer (`Admin`) | `AdminTrendPipelineController` & `AdminCrawlerManagementController` -> schedule, source config, credential probes & run lifecycle |
| `GET /api/v1/admin/ai/trends & /summary` | Bearer (`Admin`) | `AdminTrendController` -> inspect ingested multi-platform trend records |
| `POST/GET /api/v1/admin/ai/trend-replays/**` | Bearer (`Admin`) | `AdminTrendReplayController` -> `trend_replays.py` S3 cold-storage preview & daily replay |
| `GET /api/v1/ai/internal/trends/fetch & /dependencies` | `X-Internal-Api-Key` | `internal_trends.py` (`brandhub-ai-service`) -> internal snapshot & store readiness contract |

## 6. Error Handling, Security & Edge Cases

- **Proxy / Platform Cookie Expired Mid-Run:** Credential probe marks source degraded, isolates failure to that source (`trend_dlq.py`), and completes remaining sources without aborting the entire pipeline.
- **Cancelled or Concurrent Pipeline Run:** Distributed Redis run lock prevents overlapping `T0 -> T7` mutations; `/recover` cleans orphaned locks.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [FR 3.7.1 — View Trending Topics](../../../srs/06-ai-features/3-7-1-view-trending-topics-suggestions/spec.md) · [FR 3.7.13 — Crawl Schedule Config](../../../srs/06-ai-features/3-7-13-crawl-schedule-config/spec.md)
- **BA & Architecture References:** [BA 06 AI Features](../../../../ba/06-ai-features.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
