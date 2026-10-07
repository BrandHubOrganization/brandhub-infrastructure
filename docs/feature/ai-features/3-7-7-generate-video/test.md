# Test — 3.7.7 Generate Video

- [x] Tạo video → 202 + job PENDING, trừ credit; polling tới COMPLETED → video phát được, giữ nguyên credit.
- [x] Job FAILED → hoàn credit đúng 1 lần (status + sweep không hoàn 2 lần).
- [x] AI service mất job, quá 600s → FAILED `VIDEO_GENERATION_TIMEOUT`, hoàn credit.
- [x] Workspace khác đọc job → 400.
- [x] Style sai → 400, provider lỗi → 502, cả hai không trừ credit.
- [x] Hết credit → 402 trước khi gọi AI.
- [x] UI: progress, "Đã hoàn lại credit", nút thử lại, lịch sử.

## Kết quả (2026-10-08)
- AI `test_video_styles.py` 3/3; business `AiVideoDatabaseTest` 3/3; e2e `video.spec.ts` 2/2.
- Live: style list 8/8, lịch sử, job lạ → 400, style sai → INVALID_REQUEST không trừ credit; trang Video Studio hiển thị với dữ liệu thật.
- Chưa chạy Veo thật: bucket S3 `brandhub-media` không tồn tại (404) và mỗi video Veo tính phí.
