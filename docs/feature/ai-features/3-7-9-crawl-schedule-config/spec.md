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

[06-ai-features.md](../../../BA/06-ai-features.md)

## Bổ sung khi thiết kế kỹ thuật (2026-10-05)

- Crawler được cấu hình: `CrawlScheduler` trong AI service (nguồn ScrapeCreators TikTok, Apify Facebook groups).
- `schedule` = `intervalMinutes` (15–10080) **hoặc** `cron` 5 trường theo giờ Việt Nam; chọn loại này thì xoá loại kia.
- `sourcePages`: tối đa 50 URL https (Apify `startUrls`); `postsPerRun`: 10–1000 (Apify `maxItems` + cắt batch mỗi nguồn).
- Lưu ở Redis key `trend:crawl-config` của AI service (AI service không có SQL); Business chỉ kiểm quyền, validate, audit `UPDATE AI_CRAWL_CONFIG` (before/after).
- Đổi lịch → `reschedule_job` cho lần chạy kế tiếp; trang/số bài đọc lại ở đầu mỗi tick → job đang chạy không bị dừng.
- Người dùng không phải ADMIN → 403 `FORBIDDEN` (JSON trả trực tiếp, không qua `/error`).
- UI thực tế: `/admin?view=crawl` (tab "Cấu hình crawl" trong Admin).
- **i18n:** `admin.navigation.crawl`, `admin.crawl.*` song song `vi/admin.json` và `en/admin.json`.
- **Light/Dark:** token theme và class `dark:` sẵn có.
