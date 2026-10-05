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

## Bổ sung 2026-10-05 — dữ liệu thật, lĩnh vực theo topic, biểu đồ

- [x] Lĩnh vực = nhãn topic T2 (12 nhãn PhoBERT), hiển thị tên VI/EN (`aiStudio.trends.topicName.*`).
- [x] "Tất cả lĩnh vực" hiện biểu đồ cột ngang "Lĩnh vực đang nổi" (tổng điểm trend theo topic, tooltip số trend/đang lên, bảng ẩn cho trình đọc màn hình); bấm cột để lọc; chọn 1 lĩnh vực thì ẩn biểu đồ.
- [x] Business trả `topicStats` (`AiTrendControllerTest`).
- [x] Creator trong workspace thấy menu "Xu hướng".
- [x] Dữ liệu thật: `brandhub-ai-service/scripts/dev_seed_trends_from_local.py ../crawler-social/output 3000` chạy T0→T7 trên 3.000 bài crawl thật → 28 trend, 5 lĩnh vực (Thể thao 13, Thời sự 7, Công nghệ 4, Giải trí 3, Tài chính 1); kiểm tra bằng ảnh chụp đăng nhập Creator thật.

## Bổ sung 2026-10-05 — popup bài viết khi hover

- [x] T7 trả `post_items` (port từ bản demo `trend-pipeline`): tối đa 10 bài/trend, nhiều like trước, nội dung cắt 300 ký tự.
- [x] Hover (hoặc focus bàn phím) vào thẻ trend → popup danh sách bài: tác giả, giờ đăng, nội dung, like/bình luận/chia sẻ, link "Mở bài".
- [x] Business lọc trend trùng từ khóa (cache ngày giữ mỗi lần crawl một bản) — `AiTrendControllerTest`.
- [x] Sửa adapter Facebook: `timestamp` dạng chuỗi ISO của crawler-social trước đây bị đọc thành "bây giờ" → mọi bài coi là đăng hôm nay, T4 gắn mọi trend "Mới". Sau sửa: 14 trend với trạng thái đang lên/đang giảm theo ngày đăng thật (`test_facebook_adapter_dates.py`).
- [x] E2E hover popup; ảnh chụp đăng nhập Creator thật.
