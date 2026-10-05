# Test — 3.7.1 View Trending Topics

- [x] Danh sách trend hiển thị keyword, điểm, độ lan tỏa, trạng thái, lĩnh vực, rủi ro thương hiệu, dư luận, siêu trend.
- [x] Đổi khoảng 6h/24h/7d gọi lại API với `period` tương ứng.
- [x] Lọc lĩnh vực trả đúng trend của lĩnh vực; danh sách lĩnh vực không mất khi đang lọc.
- [x] Cache rỗng → empty state, không hiện lỗi.
- [x] `period`/`limit` sai → 400 trước khi gọi AI service.
- [x] Hiển thị nguồn crawl + lịch (FR 3.7.9); AI service không trả được cấu hình → trend vẫn hiện.
- [x] Đổi VI/EN không vỡ UI; light/dark không vỡ màu; 390px không tràn ngang.

## Kết quả (2026-10-05)

- `AiTrendControllerTest` 3/3; Playwright `tests/e2e/ai/trends.spec.ts` 2/2.
- Smoke live: user dev gọi `/api/v1/ai/trending-topics` → 200, `items: []` (Redis chưa có trend vì crawler local tắt), `crawl` đúng cấu hình.
