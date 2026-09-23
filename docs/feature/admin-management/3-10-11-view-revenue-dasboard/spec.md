# UC — View Revenue Dasboard

| | |
|---|---|
| FR Code | 3.10.11 |
| Feature | View Revenue Dasboard |
| Domain | Admin Management (FR 3.10) |
| Role | ADMIN |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem doanh thu của hệ thống đã thu được từ Plan và Credit.

## 2. User Story

Là một Admin,
tôi muốn xem dashboard doanh thu,
để theo dõi tình hình kinh doanh của BrandHub.

## 3. Acceptance Criteria

- Breakdown doanh thu theo: Plan subscription, Credit purchase.
- Filter theo khoảng thời gian.
- **Lưu ý số hiệu FR**: CSV gốc nhảy từ 3.10.9 sang 3.10.11 (không có 3.10.10) — giữ nguyên số hiệu như nguồn để tránh lệch tham chiếu.

## 4. UI / UX

- Trang Admin `/admin/revenue`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/admin/revenue?from=...&to=...
→ 200 { "success": true, "data": { "totalRevenue", "byPlan": {...}, "byCredit": {...} } }
```

## 6. Error Handling

- Không phải Admin → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt.

## 8. Definition of Done

- Dashboard hiển thị đúng doanh thu breakdown.

## Out of Scope

- Không có.

## Tham chiếu BA

[09-admin-management.md](../../../BA/09-admin-management.md)
