# Sequence Flow — View Invoice History

> Supplements `spec.md` (FR 3.9.4). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (own account)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `View Invoice History Page`.
- **System** — `BillingController` / `BillingService`.

---

## Flow A — Luồng thực thi chính: View Invoice History

1. billingservice -> billingservice: `Check session, filters and dates`
2. userownaccount -> webdashboard: `Open transaction history / details`
3. webdashboard -> billingcontroller: `GET /api/v1/billing/transactions[/{transactionId}]`
4. billingcontroller -> billingservice: `listTransactions() / getTransaction()`
5. billingservice --> billingcontroller: `401 Unauthorized / 400 Bad Request`
6. billingcontroller --> webdashboard: `401 Unauthorized / 400 Bad Request`
7. webdashboard --> userownaccount: `Display authentication or validation error`
8. billingservice -> transactionrepositor: `Query owned page / detail`
9. transactionrepositor --> billingservice: `historyOutcome`
10. billingservice --> billingcontroller: `403 Forbidden / 500 Internal Server Error`
11. billingcontroller --> webdashboard: `403 Forbidden / 500 Internal Server Error`
12. webdashboard --> userownaccount: `Display load/access error; Retry where allowed`
13. billingservice --> billingcontroller: `200 OK`
14. billingcontroller --> webdashboard: `200 OK`
15. webdashboard --> userownaccount: `Display transaction details / empty history`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
