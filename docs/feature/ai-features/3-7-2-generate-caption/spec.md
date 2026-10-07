# UC — Generate Caption

| | |
|---|---|
| FR Code | 3.7.2 |
| Feature | Generate Caption |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dùng LLM + prompt tạo caption cho bài post.

## 2. User Story

Là một Creator,
tôi muốn AI tạo caption cho bài đăng,
để tiết kiệm thời gian viết nội dung.

## 3. Acceptance Criteria

- Input: topic, tone, platform đích, độ dài mong muốn.
- AI trả về 1 hoặc nhiều phương án caption để Creator chọn/chỉnh sửa.
- Trừ credit AI theo lượt generate (xem [08-subscription-billing.md](../../../BA/08-subscription-billing.md)).

## 4. UI / UX

- Nút 'AI Generate Caption' trong Content Writing View (Task Detail, loại Post).

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/generate-caption
{ "topic", "tone", "platform", "length" }
→ 200 { "success": true, "data": { "captions": ["string"], "creditsUsed": number } }
```

## 6. Error Handling

- Hết credit AI → 402 `INSUFFICIENT_AI_CREDIT`.
- LLM service lỗi → 502 `AI_SERVICE_UNAVAILABLE`.

## 7. Edge Cases

- Generate nhiều lần liên tiếp cho cùng Task → mỗi lần trừ credit riêng (không cache/miễn phí lần sau, trừ trường hợp reuse content cũ theo FR 3.6.35).

## 8. Definition of Done

- Generate thành công, trừ credit đúng.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)

## Bổ sung khi thiết kế kỹ thuật (2026-10-08)

- API thực tế: `POST /api/v1/workspaces/{workspaceId}/ai/captions` (MANAGER/CREATOR, `@RequireRole` cần workspaceId trên path)
  `{ topic (10–1000), tone, platform, length, language }` → `{ captions: [{ type, title, caption, hashtags, characterCount, recommendedMaxChars }], creditsUsed, creditsRemaining }`.
  `GET /api/v1/workspaces/{workspaceId}/ai/credits` → số credit còn dùng được.
- 3 phương án cố định từ AI service: HOOK_DRIVEN, STORYTELLING, DIRECT_CTA; bối cảnh thương hiệu lấy từ tên/ngành/mô tả workspace.
- **Giá credit chưa chốt** (người dùng xác nhận 2026-10-08) → cấu hình: `ai.credits.caption.base` (mặc định 1) + `ai.credits.caption.per-1000-chars` (mặc định 0, tính trên prompt + output). Cả hai = 0 → miễn phí.
- Credit theo BR 3.9.x: credit tháng của agency = gói của Owner (không có gói → Basic); hạn mức Creator do Owner đặt là **cứng**. Chỉ trừ khi AI trả kết quả; AI lỗi → 502 `AI_SERVICE_UNAVAILABLE`, không trừ. Hết credit → 402 `INSUFFICIENT_AI_CREDIT` trước khi gọi AI.
- UI: nút "AI tạo caption" trong Content Writing View; mỗi phương án có "Chèn" (tại con trỏ) và "Thay toàn bộ" (qua Yjs để người cùng soạn thấy một thay đổi).
- **i18n:** `editor.aiCaption.*` song song vi/en. **Light/Dark:** token theme sẵn có.
