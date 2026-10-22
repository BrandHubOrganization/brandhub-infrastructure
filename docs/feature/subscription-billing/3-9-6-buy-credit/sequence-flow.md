# Sequence Flow — Buy Credit

> Supplements `spec.md` (FR 3.9.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (owned budget)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Buy Credit Page`.
- **System** — `BillingController` / `BillingService`.

---

## Flow A — Luồng thực thi chính: Buy Credit

1. userownedbudget -> webdashboard: `Select credit quantity and confirm quote`
2. billingservice -> billingservice: `Check budget owner and eligible plan`
3. billingservice -> billingservice: `Validate quantity; price purchase`
4. webdashboard -> billingcontroller: `POST /api/v1/billing/credits/buy`
5. billingcontroller -> billingservice: `buyCredit(user, request)`
6. billingservice -> aicreditaccountrepos: `Load owned budget`
7. aicreditaccountrepos --> billingservice: `AiCreditAccount`
8. billingservice -> usersubscriptionrepo: `Load owned subscription`
9. usersubscriptionrepo --> billingservice: `UserSubscription`
10. billingservice -> subscriptionplanrepo: `Load plan catalog`
11. subscriptionplanrepo --> billingservice: `SubscriptionPlan`
12. billingservice --> billingcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
13. billingcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
14. webdashboard --> userownedbudget: `Display access or resource error`
15. billingservice --> billingcontroller: `400 Bad Request / 409 Conflict`
16. billingcontroller --> webdashboard: `400 Bad Request / 409 Conflict`
17. webdashboard --> userownedbudget: `Display purchase validation error`
18. billingservice --> billingcontroller: `200 OK`
19. billingcontroller --> webdashboard: `200 OK`
20. webdashboard --> userownedbudget: `Display checkout / processing; reload balance and history after provisioning`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
