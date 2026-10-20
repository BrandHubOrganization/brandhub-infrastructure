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

## Bổ sung 2026-10-05 — nhật ký crawl

- [x] Chia đều `postsPerRun` cho các page, dừng khi hết cursor; page lỗi/private ghi lỗi, page khác vẫn chạy (`test_crawl_config.py`, không gọi mạng thật).
- [x] Chỉ một lần crawl tại một thời điểm; nhật ký giữ kết quả (fakeredis).
- [x] Business `AdminCrawlConfigServiceTest` 5/5 (chạy ngay, audit, 409 khi đang chạy, map nhật ký).
- [x] E2E: nhật ký hiển thị trang/bài/lỗi/credit, nút dev bắt đầu crawl; Creator thấy menu "Xu hướng" trong workspace.
- [x] Smoke thật (key ScrapeCreators của người dùng): 2 page trong `crawler-social/data/current_batch.json` → `vietnamoi.vn` 2 bài, `diadiemanuong.vn` bị ScrapeCreators báo "Profile is private"; nhấn lần 2 khi đang chạy → `CRAWL_ALREADY_RUNNING`. Tốn khoảng 3 credit.
- Giới hạn: nguồn có sẵn `tiktok-trending` trả 0 bài (parser cũ không khớp định dạng ScrapeCreators) — chưa sửa vì không thuộc phạm vi và mỗi lần thử tốn credit.

## Bổ sung 2026-10-05 — card tiến độ

- [x] Card bên phải form: tổng bài đã cào + số bài từng page, cập nhật mỗi 3 giây khi đang crawl (page chưa tới lượt có vòng quay), hết crawl thì hiện lần gần nhất.
- [x] AI service ghi tiến độ sau mỗi page (`update_run`, chỉ ghi khi run còn chạy).
- [x] Trạng thái crawler liệt kê nguồn `facebook-pages` khi có key ScrapeCreators.
