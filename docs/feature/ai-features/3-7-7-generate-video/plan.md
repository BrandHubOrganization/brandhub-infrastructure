# Plan — 3.7.7 Generate Video

1. DB: `2026-10-08-ai-video-jobs.sql` — `ai_video_jobs` (job theo workspace/user, usage_id credit, status, video_url, s3_key, error_code, refunded_at).
2. AI service: `VideoGenerateRequest` + `ambassador_id` (nạp ảnh preset), `template_key` → `styled_prompt`.
3. Business: `AiVideoService` (generate: kiểm credit → gọi AI → charge → lưu job; status: refresh khi còn chạy; `fail()` hoàn 1 lần; `@Scheduled sweep`), `AiVideoController`.
4. Web: `services/aiVideoService.ts`, viết lại `pages/ai-studio/video.tsx` (mô tả, style, Ambassador, khung hình, credit, progress, video + tải về, thử lại, lịch sử), menu "Video AI", `AIVideoAssistPanel` (Lộc) dùng API mới.

## Ghi chú tích hợp
- **Ambassador do người dùng tạo (FR 3.7.3, Tuấn):** hiện chỉ dùng preset của AI service (`model_presets.py`). Khi 3.7.3 lưu ambassador riêng, cho `VideoGenerateRequest.ambassador_id` tra thêm nguồn đó (hoặc business gửi `reference_image_base64`).
- **FR 3.9.5 (Tuấn):** dùng `ai_credit_usages.feature = 'VIDEO'`, hoàn tiền có `refunded_at`.
- **API cũ** `/api/v1/ai/video/generate` + `/video/{jobId}/status` (proxy của Lộc) không trừ credit và không kiểm chủ sở hữu job: nên bỏ khi không còn màn nào dùng.
- **Môi trường:** cần bucket S3 tồn tại (`S3_BUCKET_NAME`); hiện `brandhub-media` trả 404 nên job thật sẽ FAILED ở bước upload (và được hoàn credit).
