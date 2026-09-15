# UC — View Video Style Template

| | |
|---|---|
| FR Code | 3.7.6 |
| Feature | View Video Style Template |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tương tự FR 3.7.4 nhưng áp dụng cho LLM gen Video.

## 2. User Story

Là một Creator,
tôi muốn chọn 1 style template video có sẵn,
để tạo video theo phong cách mong muốn nhanh hơn.

## 3. Acceptance Criteria

- List style template cho video (thumbnail/preview clip ngắn), chọn 1 → áp dụng cho Generate Video (FR 3.7.7).

## 4. UI / UX

- Gallery chọn style trong màn Generate Video.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai/video-style-templates
→ 200 { "success": true, "data": [{ "id", "name", "previewUrl" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng danh sách style video.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)
