# Sequence Flow — View Trending Topics Suggestions

> Supplements `spec.md` (FR 3.7.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `TrendsPage (UI)`.
- **System** — `AiTrendController` / `AI Service (trends API)`.

---

## Flow A — Luồng thực thi chính: View Trending Topics Suggestions

1. aitrendcontroller -> aitrendcontroller: `Validate period and limit`
2. creatormanager -> trendspageui: `Open trends; choose period and topic`
3. trendspageui -> aitrendcontroller: `GET /api/v1/ai/trending-topics`
4. aitrendcontroller --> trendspageui: `400 — invalid filters`
5. trendspageui --> creatormanager: `Show error; keep filters`
6. aitrendcontroller -> aiservicetrendsapi: `GET /api/v1/ai/trends?period&limit=100`
7. aiservicetrendsapi -> redis: `ZREVRANGE trendKey 0 99 WITHSCORES HGET trendKey:data trendId`
8. redis --> aiservicetrendsapi: `Cached trends, possibly empty`
9. aiservicetrendsapi --> aitrendcontroller: `Trend data / upstream error`
10. aitrendcontroller --> trendspageui: `502 / 503 — trends unavailable`
11. trendspageui --> creatormanager: `Show error and retry`
12. aitrendcontroller -> aitrendcontroller: `Filter topics; rank and deduplicate trends`
13. aitrendcontroller -> aiservicetrendsapi: `GET /api/v1/ai/trends/crawl-config`
14. aiservicetrendsapi --> aitrendcontroller: `Crawl summary / null on failure`
15. aitrendcontroller --> trendspageui: `200 OK — ApiResponse<ObjectNode>`
16. trendspageui --> creatormanager: `Show trends, topic chart and crawl summary`
17. creatormanager -> trendspageui: `Hover or open a trend`
18. trendspageui --> creatormanager: `Show sample posts and growth chart`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
