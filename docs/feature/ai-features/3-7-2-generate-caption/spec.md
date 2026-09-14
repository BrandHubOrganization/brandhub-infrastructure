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
- Trừ credit AI theo lượt generate (xem [08_Subscription_Billing.md](../../../BA/08_Subscription_Billing.md)).

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

[06_AI_Features.md](../../../BA/06_AI_Features.md)
