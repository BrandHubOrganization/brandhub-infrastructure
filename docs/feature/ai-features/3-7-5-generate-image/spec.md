# UC — Generate Image

| | |
|---|---|
| FR Code | 3.7.5 |
| Feature | Generate Image |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dùng LLM + prompt tạo Image cho bài post. Input = form + model (Ambassador) + materials khác → chuyển thành prompt. Có LoRA lai với model LLM.

## 2. User Story

Là một Creator,
tôi muốn AI tạo ảnh cho bài đăng,
để có visual content nhanh mà không cần chụp/thiết kế thủ công.

## 3. Acceptance Criteria

- Input: form (mô tả mong muốn) + model (Ambassador nếu chọn, FR 3.7.3) + materials tham khảo khác (từ Material Repository/Brand Collection) → hệ thống ghép thành 1 prompt hoàn chỉnh.
- Có sử dụng **LoRA** lai (fine-tune nhẹ) với model LLM gen Image — cho phép custom phong cách riêng theo brand.
- Trừ credit AI theo lượt generate.

## 4. UI / UX

- Trang Generate Image trong Task Detail (loại Post), hoặc trang riêng `/workspaces/:id/ai/generate-image`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-image
{ "prompt", "ambassadorId"?, "referenceAssetIds"?: [...], "styleTemplateId"? }
→ 200 { "success": true, "data": { "imageUrl", "creditsUsed" } }
```

## 6. Error Handling

- Hết credit → 402 `INSUFFICIENT_AI_CREDIT`.
- Prompt vi phạm content policy (nội dung nhạy cảm) → 400 `PROMPT_REJECTED`.

## 7. Edge Cases

- Generate ra ảnh không đạt yêu cầu, Creator generate lại nhiều lần → mỗi lần trừ credit riêng, không có cơ chế 'thử lại miễn phí'.

## 8. Definition of Done

- Generate thành công, prompt ghép đúng từ 3 nguồn input, LoRA áp dụng đúng nếu có.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)
