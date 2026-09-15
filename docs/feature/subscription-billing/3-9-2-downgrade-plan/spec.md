# UC — Downgrade Plan

| | |
|---|---|
| FR Code | 3.9.2 |
| Feature | Downgrade Plan |
| Domain | Subscription (FR 3.9) |
| Role | OWNER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

Hủy gói khi Owner không còn nhu cầu sử dụng nữa.

## 2. User Story

Là một Owner,
tôi muốn hủy gói Pro/Enterprise hiện tại,
khi tôi không còn cần các tính năng nâng cao.

## 3. Acceptance Criteria

- Downgrade về Basic (hoặc plan thấp hơn) — chỉ Owner thực hiện (khác Upgrade cho phép USER nói chung).
- Nếu Agency đang có nhiều Workspace hơn giới hạn Plan mới → cảnh báo rõ, có thể yêu cầu archive/xóa bớt Workspace trước khi downgrade thành công.

## 4. UI / UX

- Nút 'Hủy gói' trong `/settings/subscription`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
POST /api/v1/subscriptions/downgrade
{ "targetPlanId": "string" }
→ 200 { "success": true, "data": { ...updated subscription... } }
```

## 6. Error Handling

- Số Workspace hiện tại vượt giới hạn Plan mới → 409 `WORKSPACE_LIMIT_EXCEEDED`, phải xử lý trước khi downgrade.

## 7. Edge Cases

- Downgrade giữa kỳ thanh toán (đã trả tiền Pro tháng này) → áp dụng downgrade ngay hay chờ hết kỳ hiện tại? Cần xác nhận policy khi thiết kế (đề xuất: áp dụng từ kỳ thanh toán tiếp theo, không hoàn tiền phần đã dùng).

## 8. Definition of Done

- Downgrade thành công đúng điều kiện, chặn đúng khi vượt giới hạn Workspace.

## Out of Scope

- Hoàn tiền một phần (chưa xác nhận policy).

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
