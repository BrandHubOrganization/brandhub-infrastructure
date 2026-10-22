# Sequence Flow — Make Payment (PayOs)

> Supplements `spec.md` (FR 3.9.3). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (own order)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Make Payment (PayOs) Page`.
- **System** — `MakePayment(PayOs)Controller` / `MakePayment(PayOs)Service`.

---

## Flow A — Luồng thực thi chính: Make Payment (PayOs)

1. billingwebhookprovis -> billingwebhookprovis: `Check ownership, priced terms and idempotent request`
2. userownorder -> webdashboard: `Confirm owned upgrade or credit purchase`
3. webdashboard -> billingcallbackcontr: `POST /api/v1/billing/transactions`
4. billingcallbackcontr -> billingwebhookprovis: `createPayment(user, request)`
5. billingwebhookprovis -> transactionrepositor: `Load owned active transactions`
6. transactionrepositor --> billingwebhookprovis: `Transaction`
7. billingwebhookprovis --> billingcallbackcontr: `400 Bad Request / 401 Unauthorized / 409 Conflict`
8. billingcallbackcontr --> webdashboard: `400 Bad Request / 401 Unauthorized / 409 Conflict`
9. webdashboard --> userownorder: `Display access or quote validation error`
10. billingwebhookprovis -> transactionrepositor: `Save PENDING order`
11. transactionrepositor --> billingwebhookprovis: `pendingOutcome`
12. billingwebhookprovis -> payos: `Create PayOS checkout`
13. payos --> billingwebhookprovis: `checkoutOutcome`
14. billingwebhookprovis --> billingcallbackcontr: `503 Service Unavailable`
15. billingcallbackcontr --> webdashboard: `503 Service Unavailable`
16. webdashboard --> userownorder: `Display payment gateway unavailable`
17. billingwebhookprovis -> transactionrepositor: `Update order with checkout link`
18. transactionrepositor --> billingwebhookprovis: `updateOutcome`
19. billingwebhookprovis --> billingcallbackcontr: `201 Created`
20. billingcallbackcontr --> webdashboard: `201 Created`
21. webdashboard --> userownorder: `Display PayOS checkout link`
22. userownorder -> payos: `Pay through PayOS checkout`
23. payos -> billingcallbackcontr: `Payment webhook callback`
24. billingwebhookprovis -> billingwebhookprovis: `Verify PayOS signature and payment data`
25. billingcallbackcontr -> billingwebhookprovis: `receiveWebhook(payload)`
26. billingwebhookprovis --> billingcallbackcontr: `401 Unauthorized`
27. billingcallbackcontr --> payos: `Reject webhook call`
28. billingwebhookprovis -> transactionrepositor: `Find order by verified transaction ID`
29. transactionrepositor --> billingwebhookprovis: `order`
30. billingwebhookprovis -> paymentreceiptreposi: `Save durable receipt`
31. paymentreceiptreposi --> billingwebhookprovis: `receiptOutcome`
32. billingwebhookprovis -> usersubscriptionrepo: `Apply purchased subscription / plan`
33. usersubscriptionrepo --> billingwebhookprovis: `planOutcome`
34. billingwebhookprovis -> aicreditaccountrepos: `Grant purchased credits`
35. aicreditaccountrepos --> billingwebhookprovis: `creditOutcome`
36. billingwebhookprovis -> transactionrepositor: `Mark order SUCCESS`
37. transactionrepositor --> billingwebhookprovis: `successOutcome`
38. billingwebhookprovis --> billingcallbackcontr: `200 OK`
39. billingcallbackcontr --> payos: `Acknowledge webhook 200 OK`
40. billingwebhookprovis -> transactionrepositor: `Mark order FAILED / CANCELLED`
41. transactionrepositor --> billingwebhookprovis: `failOutcome`
42. billingwebhookprovis --> billingcallbackcontr: `200 OK`
43. billingcallbackcontr --> payos: `Acknowledge webhook 200 OK`
44. billingwebhookprovis -> billingwebhookprovis: `Check session, scope and order ownership`
45. userownorder -> webdashboard: `Return from checkout / Check Status`
46. webdashboard -> billingcallbackcontr: `GET /api/v1/billing/transactions/{transactionId}`
47. billingcallbackcontr -> billingwebhookprovis: `getTransaction(user, transactionId)`
48. billingwebhookprovis -> transactionrepositor: `Load payment transaction status`
49. transactionrepositor --> billingwebhookprovis: `transaction`
50. billingwebhookprovis --> billingcallbackcontr: `401 Unauthorized / 403 Forbidden / 404 Not Found`
51. billingcallbackcontr --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
52. webdashboard --> userownorder: `Display access or resource error`
53. billingwebhookprovis --> billingcallbackcontr: `200 OK`
54. billingcallbackcontr --> webdashboard: `200 OK`
55. webdashboard --> userownorder: `Display committed payment status`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
