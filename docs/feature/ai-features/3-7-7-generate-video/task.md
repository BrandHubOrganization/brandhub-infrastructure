# Task — 3.7.7 Generate Video

- [x] Migration `ai_video_jobs` (+ `s3_key`): 2 lần DB test, backup, 2 lần DB dev; gộp vào 2 init SQL.
- [x] AI service: Ambassador → ảnh tham chiếu, style → prompt.
- [x] Business: trừ credit, lưu job theo workspace, hoàn 1 lần khi lỗi/quá hạn/mất job, sweep định kỳ.
- [x] Web: Video Studio thật (progress, kết quả, tải về, thử lại, lịch sử), menu "Video AI", panel Trình soạn dùng API mới.
- [x] vi/en + light/dark.
- [x] Test: AI 3/3, business `AiVideoDatabaseTest` 3/3, e2e 2/2.
- [ ] Chạy thật 1 video (cần bucket S3 + đồng ý chi phí Veo).
