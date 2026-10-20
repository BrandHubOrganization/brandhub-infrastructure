# Plan — 3.7.1 View Trending Topics

1. **AI service (có sẵn):** `GET /api/v1/ai/trends` đọc Redis ZSET `trends:vn:*` (pipeline AI-05 của DA-744→753). Thêm `GET /api/v1/ai/trends/crawl-config` (FR 3.7.9) để lấy nguồn/lịch.
2. **Business:** `AiTrendController` `GET /api/v1/ai/trending-topics` — xác thực người dùng, validate `period`/`limit`, lấy top 100, lọc `topic`, cắt `limit`, chỉ trả trường dashboard cần (tối đa 3 sample post), gắn `crawl` (lỗi AI service khi lấy crawl → `null`, không chặn trend).
3. **Web:** `services/trendService.ts`; `pages/ai-studio/trends.tsx` thay mock bằng TanStack Query (provider riêng như `/admin`); xoá `KeywordConfigPanel`, `TrendingTopicGrid/Card`, `mockTrendsService` (cấu hình crawl chuyển sang Admin 3.7.9).
4. **Locale:** `src/i18n/locales/{vi,en}/aiStudio.json` (`trends.*`).
5. Rủi ro: cache trống khi crawler chưa chạy → empty state; `final_score` không chuẩn hoá → thanh điểm tương đối theo max trong danh sách.
