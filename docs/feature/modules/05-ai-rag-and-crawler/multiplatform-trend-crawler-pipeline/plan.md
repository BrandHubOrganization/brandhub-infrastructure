> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · [Spec](./spec.md) · **Plan** · [Task](./task.md) · [Test](./test.md)

# Technical Implementation Plan — Multi-Platform Trend Crawler Pipeline, Proxy Rotation, S3 Cold Storage & Daily Replay (`multiplatform-trend-crawler-pipeline`)

## 1. System Components & Touched Repositories

Consolidates the technical architecture for `admin-crawler-control`, `admin-multiplatform-trend-pipeline`, `admin-trend-data-view`, `admin-trend-pipeline-now`, `admin-trend-source-config`, `crawler-bounded-memory`, `crawler-proxy-readiness`, `internal-trends-fetch`, `update-trend-flow`, `trend-cold-storage`, `trend-s3-daily-replay`, `trend-review-cli`, `ai-service-ci` as specified in [spec.md](./spec.md):

| Layer / Repository | Key Classes, Services, Schemas & Components |
| :--- | :--- |
| **API Gateway (`brandhub-api-gateway`)** | `GatewayConfig.java` (`/api/v1/admin/ai/**` routes) |
| **Backend / Worker Services** | `AdminCrawlConfigController.java`, `AdminCrawlerManagementController.java`, `AdminTrendPipelineController.java`, `AdminTrendController.java`, `AdminTrendReplayController.java`; `brandhub-ai-service`: `trend_pipeline.py`, `trend_scheduler.py`, `trend_cold_storage.py`, `trend_replays.py`, `crawl_batch_consumer.py` |
| **Persistence, Cache & Brokers** | Redis (`trends:vn:*`, run locks), Neo4j Trend Graph, AWS S3 (`trends/cold-storage/{yyyy-mm-dd}/*`), MongoDB/Redis run history (`trend_run_store.py`) |
| **Web Frontend (`brandhub-web`)** | `pages/admin/components/{AdminTrendPipelinePanel,AdminTrendPipelineControl,AdminTrendSourceConfig,CrawlerCredentialsPanel,CrawlerHealthPanel,CrawlerRunLauncher,AdminTrendReplayPanel,TrendReplayFlow}.tsx` |
| **Mobile App (`brandhub-mobile-app`)** | `src/components/admin/AdminCrawlerHealthCard.tsx`, `src/screens/admin/AdminSystemHealthScreen.tsx` |
| **i18n & Theme Assets** | `admin.crawler.*`, `admin.trendPipeline.*`, `admin.trendReplay.*` in `src/i18n/locales/{vi,en}/admin.json`; Mobile `src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` & `src/theme/tokens.ts` |

## 2. Core Technical Design & Data Model Invariants

- **Stage-Gate Pipeline (`T0` Ingest -> `T7` Publish):** Decouples raw scraping (archived immediately to S3 cold storage) from deterministic deduplication, LLM naming, and Redis/Neo4j indexing.
- **CI Verification (`ai-service-ci`):** GitHub Actions runs `ruff` / `pytest` contract & security-path checks (`scripts/security/check_sensitive_paths.py`) on every `brandhub-ai-service` change.

## 3. End-to-End Data & Control Flow

1. **Ingress & Identity Propagation:** Requests pass through `brandhub-api-gateway` (`InboundSecurityWebFilter` -> `JwtAuthFilterGatewayFilterFactory` -> `RateLimitGatewayFilterFactory`), stripping external header spoofing and injecting verified `X-User-Id`, `X-Request-Id`, and role claims.
2. **Authorization & Invariant Validation:** Downstream controllers and services re-verify canonical role permissions (`Admin`) and Agency/Workspace tenant membership against authoritative database state before mutating data or dispatching async jobs.
3. **Atomic Persistence & Event Fan-Out:** State transitions commit atomically across Redis (`trends:vn:*`, run locks), Neo4j Trend Graph, AWS S3 (`trends/cold-storage/{yyyy-mm-dd}/*`), MongoDB/Redis run history (`trend_run_store.py`) using optimistic (`@Version` / `expectedRevision`) or pessimistic locks, emitting outbox/WebSocket/`pg_notify` events after commit.
4. **Client State Reconciliation:** `brandhub-web` and `brandhub-mobile-app` consume typed `ApiResponse<T>` envelopes, update user/tenant-scoped `TanStack Query` caches, and render localized UI states in Light and Dark themes.

## 4. Sequential Implementation & Rollout Order

1. **Phase 1 — Database / Storage / Config Baseline:** Apply additive migrations in `database/init/init-postgres-v2.sql` and `database/migrations/postgres/*.sql` (plus MongoDB/Neo4j/Redis indexes) with repeat-run idempotency.
2. **Phase 2 — Domain Services & Security Guards:** Implement core service logic, cryptographic/concurrency helpers, and internal service-to-service contracts.
3. **Phase 3 — Public REST / WebSocket / Worker Endpoints:** Wire controllers, consumers, and exception handlers returning standardized `ErrorCode` payloads.
4. **Phase 4 — Web & Mobile UI Surfaces:** Deliver responsive components, accessibility/keyboard navigation, and state transitions without mock data fallbacks.
5. **Phase 5 — Key-Parallel i18n (`vi`/`en`) & Light/Dark Theme Audit:** Synchronize translation namespaces and verify semantic color tokens across Light and Dark modes.
6. **Phase 6 — Multi-Layer Verification:** Execute unit, integration, contract, and browser/mobile E2E suites documented in [test.md](./test.md).

## 5. Localization (`vi.json` + `en.json`), Theme Tokens & Observability Plan

- **Key-Parallel Locale Synchronization:** Every new or updated label in `admin.crawler.*`, `admin.trendPipeline.*`, `admin.trendReplay.*` in `src/i18n/locales/{vi,en}/admin.json` is committed simultaneously in `vi` and `en` bundles on `brandhub-web` and mirrored in `brandhub-mobile-app/src/i18n/locales/en.json` + `src/i18n/locales/vi/common.json` (verified by `mobileI18nParity.test.ts` and `i18nCoverage.test.ts`).
- **Light & Dark Theme Architecture:** Web components rely exclusively on semantic CSS custom properties (`bg-background`, `bg-card`, `text-foreground`, `text-muted-foreground`, `border-border`) and paired `dark:` utility classes; Mobile components consume `useAppPreferences().palette` (`src/theme/tokens.ts`) verified by `tokens.test.ts`.
- **Structured Telemetry & Rollback Safety:** Every boundary logs `X-Request-Id`, latency, and classified `ErrorCode` while redacting tokens/PII. Additive schema migrations preserve backward-compatible rollback without dropping historical audit or ledger data.

## 6. Engineering Risks & Mitigations

- **Unbounded Chromium / Scraper RSS Growth:** Mitigated by per-batch page/context disposal and bounded item queues in `crawl_batch_consumer.py`.
