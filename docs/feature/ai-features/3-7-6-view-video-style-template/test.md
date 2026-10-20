# Test — 3.7.6 View Video Style Template

- [x] Gallery hiện đủ style từ API (live: 8 style).
- [x] Chọn style → khung hình gợi ý; chọn lại → bỏ style.
- [x] Style không có trong catalog → 400 `INVALID_REQUEST`, không trừ credit.
- [x] Style được thêm vào prompt gửi Veo.
- [x] VI/EN, light/dark.

## Kết quả (2026-10-08)
- `test_video_styles.py` 3/3; e2e `video.spec.ts` 2/2; live: Creator mở "Video AI" thấy 8 style, chọn "Món ăn cận cảnh" đổi sang 9:16.
