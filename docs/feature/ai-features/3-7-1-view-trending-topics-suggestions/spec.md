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

## Bổ sung khi thiết kế kỹ thuật (2026-10-05)

- API thực tế: `GET /api/v1/ai/trending-topics?period=6h|24h|7d&topic=&limit=1..100` →
  `{ items: [{ id, rank, keyword, score, virality, dailyCounts, topic, status, mood, emotion, brandRisk, crossTopic, keywords, sources, samplePosts }], topics: [..], crawl: { intervalMinutes, cron, pageCount, sources, nextRunAt } | null }`.
  Dữ liệu từ Redis ZSET do pipeline AI-05 (T0→T7) ghi; cache rỗng → `items: []` (empty state, không lỗi).
- Filter lĩnh vực = `topic` (T3) có trong dữ liệu; nguồn crawl hiển thị từ cấu hình FR 3.7.9 (`crawl`), vì T7 không điền `source_distribution`.
- Route thực tế: `/ai-studio/trends` (AI Studio cấp agency, quyền MANAGER/CREATOR theo `routes/access.ts`).
- **i18n:** namespace `aiStudio.trends.*` (period, topicFilter, allTopics, refresh, empty, emptyHint, score, virality, risk.*, mood.*, status.*, superTrend, dailyPosts, copyKeyword, copied, copyError, crawl.*) — thêm song song `vi/aiStudio.json` và `en/aiStudio.json`.
- **Light/Dark:** chỉ dùng token theme (`bg-card`, `text-muted-foreground`, `bg-brand-orange`) và màu trạng thái có biến thể `dark:`.
