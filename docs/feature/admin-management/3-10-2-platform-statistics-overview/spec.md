# UC — Platform Statistics Overview

| | |
|---|---|
| FR Code | 3.10.2 |
| Feature | Platform Statistics Overview |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Dashboard tổng quan hệ thống — chart về user, doanh thu, agency đang hoạt động.

## 2. User Story

Là một Admin,
tôi muốn xem thống kê tổng quan hệ thống,
để nắm tình hình vận hành BrandHub.

## 3. Acceptance Criteria

- Chart: tổng user, user mới theo thời gian, doanh thu theo tháng, số Agency đang hoạt động.

## 4. UI / UX

- Trang Admin `/admin/dashboard`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/statistics/overview
→ 200 { "success": true, "data": { "totalUsers", "revenueByMonth": [...], "activeAgencies" } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Dashboard hiển thị đúng số liệu tổng hợp toàn hệ thống.

## Out of Scope

- Không có.

## Tham chiếu BA

[09_Admin_Management.md](../../../BA/09_Admin_Management.md)
