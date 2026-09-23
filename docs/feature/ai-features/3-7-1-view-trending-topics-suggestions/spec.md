# UC — View Trending Topics Suggestions

| | |
|---|---|
| FR Code | 3.7.1 |
| Feature | View Trending Topics Suggestions |
| Domain | AI Features (FR 3.7) |
| Role | CREATOR |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dashboard xem keyword trend hiện tại để Creator lấy cảm hứng nội dung.

## 2. User Story

Là một Creator,
tôi muốn xem các keyword trending hiện tại,
để tạo content bắt trend, tăng khả năng viral.

## 3. Acceptance Criteria

- Dashboard hiển thị list keyword trend, kèm volume/score, nguồn crawl (xem FR 3.7.9 Crawl Schedule Config).
- Filter theo ngành/lĩnh vực nếu có phân loại.

## 4. UI / UX

- Trang `/workspaces/:id/ai/trends`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/ai/trending-topics
→ 200 { "success": true, "data": [{ "keyword", "score", "category" }] }
```

## 6. Error Handling

- Không có dữ liệu trend (crawler chưa chạy) → empty state, không lỗi.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Hiển thị đúng list trend, cập nhật theo lịch crawl.

## Out of Scope

- Không có.

## Tham chiếu BA

[06-ai-features.md](../../../BA/06-ai-features.md)
