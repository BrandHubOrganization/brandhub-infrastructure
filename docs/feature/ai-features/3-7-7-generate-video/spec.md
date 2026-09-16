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
