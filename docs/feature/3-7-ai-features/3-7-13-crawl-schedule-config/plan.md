# Plan — 3.7.9 Crawl Schedule Config

1. **AI service:** `models/crawl_config.py` (validate, `trigger()`), `services/crawl_config_store.py` (Redis, fallback env), `CrawlScheduler.start(trigger)/reschedule()/next_run_at`, tick áp `source_pages`/`posts_per_run` cho scraper có `configure()`, `ApifyFacebookGroupsScraper.configure()` điền `startUrls` (trước đây luôn rỗng). Endpoint nội bộ `GET/POST /api/v1/ai/trends/crawl-config`. `main.py` khởi động scheduler theo lịch đã lưu.
2. **Business:** `AdminCrawlConfigService` + `AdminCrawlConfigController` (`GET/PATCH /api/v1/admin/ai/crawl-config`), `ErrorCode.INVALID_SCHEDULE`, `SecurityConfig.accessDeniedHandler` (403 JSON).
3. **Web:** `services/adminCrawlConfigService.ts`, `AdminCrawlConfigPanel.tsx`, view `crawl` trong `pages/admin/index.tsx` và `AdminSidebar`.
4. **Locale:** `src/i18n/locales/{vi,en}/admin.json`.
5. Không có migration SQL (cấu hình ở Redis). Rủi ro: Redis bị xoá → quay về giá trị env; ghi chú `ponytail:` trong code.
