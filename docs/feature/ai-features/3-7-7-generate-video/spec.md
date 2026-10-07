# UC — Generate Video

| | |
|---|---|
| FR Code | 3.7.7 |
| Feature | Generate Video |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dùng LLM + prompt tạo Video, sử dụng API gen video bên thứ 3. Có thể mở rộng thành studio.

## 2. User Story

Là một Creator,
tôi muốn AI tạo video cho bài đăng,
để có nội dung video nhanh mà không cần quay/dựng thủ công.

## 3. Acceptance Criteria

- Input: prompt + Ambassador (nếu chọn) + style template (FR 3.7.6).
- Gọi API gen video bên thứ 3 (xử lý async — video generation thường mất thời gian dài hơn ảnh).
- Trừ credit AI (mức trừ có thể cao hơn Generate Image do chi phí xử lý).

## 4. UI / UX

- Trang Generate Video, hiển thị progress bar/polling trong lúc chờ xử lý.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-video
{ "prompt", "ambassadorId"?, "styleTemplateId"? }
→ 202 { "success": true, "data": { "jobId" } }

GET /api/v1/ai/generate-video/{jobId}/status
→ 200 { "success": true, "data": { "status": "processing|done|failed", "videoUrl"? } }
```

## 6. Error Handling

- Hết credit → 402 `INSUFFICIENT_AI_CREDIT`.
- Job xử lý thất bại → `status=failed`, có thể hoàn lại credit đã trừ (quyết định khi thiết kế kỹ thuật).

## 7. Edge Cases

- Video generation timeout (bên thứ 3 xử lý quá lâu) → set `status=failed` sau ngưỡng thời gian, thông báo Creator retry.

## 8. Definition of Done

- Generate video hoạt động qua luồng async, trả kết quả đúng qua polling.

## Out of Scope

- Studio mở rộng (edit video trực tiếp trên hệ thống) — chỉ là hướng mở rộng tương lai theo CSV, không thuộc scope hiện tại.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)

## Bổ sung khi thiết kế kỹ thuật (2026-10-08)

- API: `POST /api/v1/workspaces/{id}/ai/videos` `{prompt, styleKey?, ambassadorId?, aspectRatio}` → 202 `{job, creditsUsed, creditsRemaining}`;
  `GET /api/v1/workspaces/{id}/ai/videos/{jobId}` (chỉ workspace sở hữu đọc được); `GET /api/v1/workspaces/{id}/ai/videos` (12 gần nhất).
- Veo 3.1 (AI service, chạy nền, kết quả lên S3). Ambassador preset → ảnh tham chiếu (REFERENCE_TO_VIDEO).
- **Credit (đã chốt 2026-10-04):** trừ trước khi chạy (`ai.credits.video.base`, mặc định 10, chưa chốt giá); **hoàn đúng 1 lần** khi job FAILED, quá thời gian (`ai.video.timeout-seconds` 600) hoặc AI service mất job (restart). Job quét mỗi phút để hoàn cả khi không ai theo dõi.
- Lỗi provider/không có key → 502 `AI_SERVICE_UNAVAILABLE`, không trừ. Style/Ambassador sai → 400.
- UI: trang `/ai-studio/video` (menu "Video AI" trong workspace) + panel video của Trình soạn (Lộc) đi qua API này.
