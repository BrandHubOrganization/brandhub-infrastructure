# UC — Buy Credit

| | |
|---|---|
| FR Code | 3.9.6 |
| Feature | Buy Credit |
| Domain | Subscription (FR 3.9) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Mua thêm credit khi hết credit trong gói Pro/Enterprise.

## 2. User Story

Là một Owner,
tôi muốn mua thêm credit AI,
khi Agency đã dùng hết credit trong gói hiện tại.

## 3. Acceptance Criteria

- Chọn số lượng credit muốn mua → Make Payment (FR 3.9.3) → credit được cộng thêm vào Agency sau khi thanh toán thành công.
- **Chỉ Owner** mua được — Creator không tự mua credit cho mình.

## 4. UI / UX

- Nút 'Mua thêm Credit' trong trang AI Credit Tracking.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/ai-credit/buy
{ "amount": number }
→ 200 { "success": true, "data": { "paymentUrl", "transactionId" } }
```

## 6. Error Handling

- Không phải Owner → 403 `FORBIDDEN`.

## 7. Edge Cases

- Không có edge case đặc biệt (xử lý ACID/idempotency giống FR 3.9.3).

## 8. Definition of Done

- Mua credit thành công, cộng đúng số lượng sau thanh toán.

## Out of Scope

- Không có.

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
