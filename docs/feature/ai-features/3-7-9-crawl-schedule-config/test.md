# Test — 3.7.9 Crawl Schedule Config

- [x] ADMIN xem cấu hình + trạng thái crawler; USER gọi API → 403.
- [x] Cron sai (61 phút, thiếu trường) → 400 `INVALID_SCHEDULE`, không gọi AI service, không audit.
- [x] Interval < 15 hoặc > 10080 → `INVALID_SCHEDULE`.
- [x] Chọn cron xoá interval và ngược lại; trường không gửi giữ giá trị cũ.
- [x] Page phải https, bỏ trùng/khoảng trắng, tối đa 50; số bài 10–1000.
- [x] Lưu → tick kế tiếp dùng page/số bài mới; đổi lịch dời lần chạy kế tiếp, không dừng job đang chạy.
- [x] Mỗi lần lưu ghi audit `UPDATE AI_CRAWL_CONFIG` (before/after).
- [x] Đổi VI/EN, light/dark không vỡ UI.

## Kết quả (2026-10-05)

- AI service: `test_crawl_config.py` 4/4 + `test_scheduler.py` 10/10.
- Business: `AdminCrawlConfigServiceTest` 4/4.
- Playwright `tests/e2e/admin/crawl-config.spec.ts` 2/2.
- Smoke live (dev): GET 200, USER 403, cron sai 400 `INVALID_SCHEDULE`, PATCH cron + page + 150 bài → 200, trang trend nhận `crawl` mới, audit 2 dòng; đã khôi phục cấu hình cũ.
- Giới hạn: crawler local đang tắt (`TREND_CRAWLER_ENABLED=false`, chưa có API key scraper) nên chưa chạy tick thật; tick được kiểm bằng unit test.
