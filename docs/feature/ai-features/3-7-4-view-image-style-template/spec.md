# UC — View Image Style Template

| | |
|---|---|
| FR Code | 3.7.4 |
| Feature | View Image Style Template |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Gợi ý template mẫu phong cách (anime, mùa xuân, hồi ức...) để tạo Image theo style mà không cần mô tả nhiều.

## 2. User Story

Là một Creator,
tôi muốn chọn 1 style template có sẵn,
để tạo ảnh theo phong cách mong muốn nhanh hơn.

## 3. Acceptance Criteria

- List các style template có sẵn (thumbnail preview), chọn 1 → áp dụng làm base prompt cho Generate Image (FR 3.7.5).

## 4. UI / UX

- Gallery chọn style trong màn Generate Image.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai/image-style-templates
→ 200 { "success": true, "data": [{ "id", "name", "thumbnailUrl" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng danh sách style.

## Out of Scope

- Không có.

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
