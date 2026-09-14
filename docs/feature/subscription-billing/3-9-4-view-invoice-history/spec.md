# UC — View Invoice History

| | |
|---|---|
| FR Code | 3.9.4 |
| Feature | View Invoice History |
| Domain | Subscription (FR 3.9) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Xem lịch sử giao dịch của tài khoản.

## 2. User Story

Là một Owner,
tôi muốn xem lịch sử giao dịch,
để theo dõi chi tiêu của Agency trên BrandHub.

## 3. Acceptance Criteria

- List `Transaction`: loại (upgrade/buy credit), số tiền, ngày, trạng thái.

## 4. UI / UX

- Trang `/settings/subscription/invoices`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/payments/history
→ 200 { "success": true, "data": [{ "id", "type", "amount", "status", "createdAt" }] }
```

## 6. Error Handling

- Không có lỗi đặc biệt.

## 7. Edge Cases

- Chưa từng thanh toán → empty state.

## 8. Definition of Done

- Hiển thị đúng lịch sử.

## Out of Scope

- Export PDF (xem FR 3.10.12, thuộc Admin Management, không phải FR này).

## Tham chiếu BA

[08_Subscription_Billing.md](../../../BA/08_Subscription_Billing.md)
