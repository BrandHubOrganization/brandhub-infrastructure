# UC — Suggest hashtag trend

| | |
|---|---|
| FR Code | 3.7.10 |
| Feature | Suggest hashtag trend |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Gợi ý hashtag trend cho Content Creator.

## 2. User Story

Là một Creator,
tôi muốn AI gợi ý hashtag trending phù hợp với content của tôi,
để tăng khả năng lan tỏa bài đăng.

## 3. Acceptance Criteria

- Input: nội dung/topic bài đăng → AI trả về list hashtag trend liên quan.
- Có thể thêm trực tiếp vào Hashtag Collection (FR 3.6.19) từ kết quả gợi ý.

## 4. UI / UX

- Nút 'Gợi ý hashtag' trong Content Writing View hoặc Hashtag Collection.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai/suggest-hashtags
{ "content": "string" }
→ 200 { "success": true, "data": { "hashtags": ["string"] } }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Không tìm thấy hashtag trend liên quan → trả list rỗng, không lỗi.

## 8. Definition of Done

- Gợi ý đúng, thêm được vào Hashtag Collection.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)
