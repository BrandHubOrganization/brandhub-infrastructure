# UC — Crawl Schedule Config

| | |
|---|---|
| FR Code | 3.7.9 |
| Feature | Crawl Schedule Config |
| Domain | AI Features (FR 3.7) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Cấu hình bộ cào data phục vụ tìm keyword trend: thời gian, page nào, số bài/lần. Duy nhất FR AI thuộc quyền ADMIN.

## 2. User Story

Là một Admin,
tôi muốn cấu hình lịch crawl trend,
để kiểm soát tài nguyên hệ thống và chất lượng dữ liệu trend.

## 3. Acceptance Criteria

- Form cấu hình: `schedule` (cron expression hoặc interval), `sourcePages` (danh sách page/nguồn crawl), `postsPerRun` (số bài crawl mỗi lần).
- **Chỉ ADMIN** cấu hình được — vì ảnh hưởng tài nguyên server toàn hệ thống (tần suất gọi API ngoài), không phải thao tác cấp Workspace.

## 4. UI / UX

- Trang Admin `/admin/ai/crawl-config`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/ai/crawl-config
→ 200 { "success": true, "data": { "schedule", "sourcePages", "postsPerRun" } }

PATCH /api/v1/admin/ai/crawl-config
{ "schedule"?, "sourcePages"?, "postsPerRun"? }
→ 200 { "success": true, "data": { ...updated config... } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.
- `schedule` không hợp lệ (cron sai format) → 400 `INVALID_SCHEDULE`.

## 7. Edge Cases

- Đổi cấu hình khi crawler đang chạy → áp dụng cho lần chạy tiếp theo, không dừng job đang chạy giữa đường.

## 8. Definition of Done

- Cấu hình lưu đúng, crawler chạy theo config mới ở lần kế tiếp.

## Out of Scope

- Không có.

## Tham chiếu BA

[06_AI_Features.md](../../../BA/06_AI_Features.md)
