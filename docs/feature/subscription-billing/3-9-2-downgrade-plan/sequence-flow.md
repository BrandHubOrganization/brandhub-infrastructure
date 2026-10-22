# Sequence Flow — Downgrade Plan

> Supplements `spec.md` (FR 3.9.2). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (own account)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Downgrade Plan Page`.
- **System** — `SubscriptionController` / `SubscriptionService`.

---

## Flow A — Luồng thực thi chính: Downgrade Plan

1. subscriptionservice -> subscriptionservice: `Validate account ownership, lower plan eligibility and workspace limit`
2. userownaccount -> webdashboard: `Select lower plan`
3. webdashboard --> userownaccount: `Show downgrade impact and date`
4. userownaccount -> webdashboard: `Confirm downgrade`
5. webdashboard -> subscriptioncontroll: `POST /api/v1/subscription/cancel`
6. subscriptioncontroll -> subscriptionservice: `cancel(user, command)`
7. subscriptionservice -> usersubscriptionrepo: `Load owned subscription and lower plan catalog`
8. usersubscriptionrepo --> subscriptionservice: `UserSubscription`
9. subscriptionservice --> subscriptioncontroll: `400 Bad Request / 403 Forbidden / 409 Conflict`
10. subscriptioncontroll --> webdashboard: `400 Bad Request / 403 Forbidden / 409 Conflict`
11. webdashboard --> userownaccount: `Display WORKSPACE_LIMIT_EXCEEDED or conflict error`
12. subscriptionservice -> usersubscriptionrepo: `Save downgraded plan / schedule change`
13. usersubscriptionrepo --> subscriptionservice: `writeOutcome`
14. subscriptionservice --> subscriptioncontroll: `200 OK`
15. subscriptioncontroll --> webdashboard: `200 OK`
16. webdashboard --> userownaccount: `Display downgrade confirmed`
17. subscriptionservice --> subscriptioncontroll: `409 Conflict / 500 Internal Server Error`
18. subscriptioncontroll --> webdashboard: `409 Conflict / 500 Internal Server Error`
19. webdashboard --> userownaccount: `Display save error; retain previous values`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
