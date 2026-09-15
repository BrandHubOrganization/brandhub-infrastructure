# UC — Upgrade Plan

| | |
|---|---|
| FR Code | 3.9.1 |
| Feature | Upgrade Plan |
| Domain | Subscription (FR 3.9) |
| Role | USER |
| Version | 2.0 (V2 — nghiệp vụ mới, 2026-09-14) |
| Trạng thái tài liệu | Draft — BA confirmed, chưa code |

## 1. Objective

User mới mặc định gói Basic; upgrade lên Pro/Enterprise để tạo nhiều Workspace, nhiều credit AI, và dùng tính năng nâng cao.

## 2. User Story

Là một User,
tôi muốn upgrade lên Pro/Enterprise,
để mở khóa thêm Workspace và credit AI cho Agency của tôi.

## 3. Acceptance Criteria

- Danh sách Plan (Basic/Pro/Enterprise) hiển thị rõ giới hạn: số Workspace tối đa, credit AI/tháng, tính năng nâng cao.
- Chọn Plan → chuyển sang Make Payment (FR 3.9.3) để thanh toán.
- Upgrade thành công → cập nhật ngay giới hạn Workspace/credit cho toàn bộ Agency của User (Plan gắn cấp User/Owner, xem [08-subscription-billing.md](../../../BA/08-subscription-billing.md)).

## 4. UI / UX

- Trang `/settings/subscription`.

## 5. API Contract (đề xuất, cần xác nhận khi thiết kế kỹ thuật)

```
GET /api/v1/subscriptions/plans
→ 200 { "success": true, "data": [{ "id", "name", "maxWorkspaces", "monthlyCredit", "price" }] }

POST /api/v1/subscriptions/upgrade
{ "planId": "string" }
→ 200 { "success": true, "data": { "paymentUrl" hoặc "transactionId" } }
```

## 6. Error Handling

- User đã ở Plan cao nhất (Enterprise) → 400 `ALREADY_AT_HIGHEST_PLAN`.

## 7. Edge Cases

- Upgrade thành công nhưng thanh toán chưa hoàn tất → Plan chỉ áp dụng SAU khi Make Payment xác nhận thành công (không active trước khi thanh toán xong).

## 8. Definition of Done

- Upgrade hoạt động, giới hạn mới áp dụng đúng ngay sau thanh toán thành công.

## Out of Scope

- Không có.

## Tham chiếu BA

[08-subscription-billing.md](../../../BA/08-subscription-billing.md)
