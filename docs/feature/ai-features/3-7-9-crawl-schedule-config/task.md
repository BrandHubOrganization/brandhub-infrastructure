# Task — 3.7.9 Crawl Schedule Config

- [x] AI service: model + store + scheduler reschedule + áp cấu hình mỗi tick + Apify `startUrls`.
- [x] AI service: endpoint nội bộ GET/POST `crawl-config`; khởi động theo lịch đã lưu.
- [x] AI service test `tests/unit/crawlers/test_crawl_config.py`.
- [x] Business service/controller, `INVALID_SCHEDULE`, audit, `AdminCrawlConfigServiceTest`.
- [x] Business: 403 JSON cho người dùng không đủ quyền.
- [x] Web: tab Admin "Cấu hình crawl" (lịch chu kỳ/cron, page nguồn, số bài, trạng thái crawler, lần chạy kế tiếp).
- [x] Cập nhật `vi/admin.json` + `en/admin.json`.
- [x] Kiểm tra light/dark mode.
- [x] E2E `tests/e2e/admin/crawl-config.spec.ts`; smoke live.
