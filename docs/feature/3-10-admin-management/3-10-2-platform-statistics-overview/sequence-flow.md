# Sequence Flow — Platform Statistics Overview

> Supplements `spec.md` (FR 3.10.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **Admin** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminOverviewPanel (UI)`.
- **System** — `AdminStatisticsController` / `AdminStatisticsService`.

---

## Flow A — Luồng thực thi chính: Platform Statistics Overview

1. admin -> adminoverviewpanelui: `Open overview; choose period & timezone`
2. adminoverviewpanelui -> adminstatisticscontr: `GET /api/v1/admin/statistics(days, tz)`
3. adminstatisticscontr -> adminaccountservice: `requireAdmin(actorId)`
4. adminaccountservice --> adminstatisticscontr: `200 OK (ADMIN verified)`
5. adminstatisticscontr -> adminstatisticsservi: `getPlatformOverview(days, tz)`
6. adminstatisticsservi -> platformstatsreposit: `fetchPlatformMetrics(days)`
7. platformstatsreposit --> adminstatisticsservi: `return platformMetrics`
8. adminstatisticsservi -> adminstatisticsservi: `aggregatePlatformStatistics(platformMetrics)`
9. adminstatisticsservi --> adminstatisticscontr: `return PlatformStatsResponse`
10. adminstatisticscontr --> adminoverviewpanelui: `200 OK (PlatformStatsResponse)`
11. adminoverviewpanelui --> admin: `Render overview stats, user growth & activity`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
