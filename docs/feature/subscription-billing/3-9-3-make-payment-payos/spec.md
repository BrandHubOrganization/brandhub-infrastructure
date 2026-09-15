# UC — Make Payment (PayOs)

| | |
|---|---|
| FR Code | 3.9.3 |
| Feature | Make Payment (PayOs) |
| Domain | Subscription (FR 3.9) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Tạo Transaction cho các tính năng nâng gói, mua thêm credit — tuân thủ ACID.

## 2. User Story

Là một User,
tôi muốn thanh toán qua PayOS,
để hoàn tất upgrade Plan hoặc mua thêm credit.

## 3. Acceptance Criteria

- Tạo `Transaction` với trạng thái `PENDING`, redirect sang PayOS checkout.
- Callback từ PayOS xác nhận thanh toán → cập nhật `Transaction.status = SUCCESS`, kích hoạt hiệu lực Plan/Credit tương ứng.
- **Toàn bộ quy trình phải tuân thủ ACID**: nếu callback xử lý giữa đường bị lỗi (ví dụ cập nhật Plan thành công nhưng ghi Transaction log thất bại), phải rollback toàn bộ — không để trạng thái nửa vời (đã tính tiền nhưng chưa cấp Plan, hoặc ngược lại).

## 4. UI / UX

- Redirect sang PayOS checkout page, quay lại `/settings/subscription/payment-result` sau khi thanh toán.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/payments/create
{ "type": "upgrade_plan|buy_credit", "refId": "string" }
→ 200 { "success": true, "data": { "paymentUrl", "transactionId" } }

POST /api/v1/payments/callback (webhook từ PayOS)
{ "transactionId", "status", "signature" }
→ 200 { "success": true }
```

## 6. Error Handling

- Signature webhook không khớp (giả mạo) → 400 `INVALID_WEBHOOK_SIGNATURE`, không xử lý.
- Thanh toán thất bại từ PayOS → `Transaction.status = FAILED`, không cấp Plan/Credit.

## 7. Edge Cases

- Webhook gọi lại nhiều lần cho cùng 1 transaction (PayOS retry) → idempotency check theo `transactionId`, không cấp Plan/Credit trùng lần 2.

## 8. Definition of Done

- Thanh toán + kích hoạt Plan/Credit hoạt động đúng ACID, idempotent với webhook retry.

## Out of Scope

- Không có.

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
