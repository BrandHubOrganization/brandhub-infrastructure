# Sequence Flow — Upgrade Plan

> Supplements `spec.md` (FR 3.9.1). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (own account)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Upgrade Plan Page`.
- **System** — `SubscriptionController` / `SubscriptionService`.

---

## Flow A — Luồng thực thi chính: Upgrade Plan

1. subscriptionservice -> subscriptionservice: `Check session, scope and account ownership`
2. subscriptionservice -> subscriptionservice: `Check higher destination, current version and server quote`
3. userownaccount -> webdashboard: `Compare plans and confirm higher plan`
4. webdashboard -> subscriptioncontroll: `POST /api/v1/subscription`
5. subscriptioncontroll -> subscriptionservice: `subscribe(user, command)`
6. subscriptionservice -> usersubscriptionrepo: `Load owned subscription`
7. usersubscriptionrepo --> subscriptionservice: `UserSubscription`
8. subscriptionservice -> subscriptionplanrepo: `Load plan catalog`
9. subscriptionplanrepo --> subscriptionservice: `SubscriptionPlan`
10. subscriptionservice --> subscriptioncontroll: `401 Unauthorized / 403 Forbidden / 404 Not Found`
11. subscriptioncontroll --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
12. webdashboard --> userownaccount: `Display access or resource error`
13. subscriptionservice --> subscriptioncontroll: `400 Bad Request / 409 Conflict`
14. subscriptioncontroll --> webdashboard: `400 Bad Request / 409 Conflict`
15. webdashboard --> userownaccount: `Display ALREADY_AT_HIGHEST_PLAN or invalid upgrade`
16. subscriptionservice --> subscriptioncontroll: `200 OK`
17. subscriptioncontroll --> webdashboard: `200 OK`
18. webdashboard --> userownaccount: `Display checkout / payment processing; retain current plan until provisioned`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
