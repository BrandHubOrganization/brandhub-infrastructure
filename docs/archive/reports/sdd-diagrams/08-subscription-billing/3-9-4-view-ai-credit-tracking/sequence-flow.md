# Sequence Flow — View AI Credit Tracking

> Supplements `spec.md` (FR 3.9.5). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **USER (self) / OWNER (managed
Agency)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `View AI Credit Tracking Page`.
- **System** — `BillingController` / `BillingService`.

---

## Flow A — Luồng thực thi chính: View AI Credit Tracking

1. billingservice -> billingservice: `Check session, scope and self scope / Agency OWNER`
2. billingservice -> billingservice: `Validate period and permitted Workspace/Creator filters`
3. billingservice -> billingservice: `Resolve authenticated self scope`
4. billingservice -> billingservice: `Build usageOutcome`
5. userselfownermanaged -> webdashboard: `Select month and permitted usage scope`
6. webdashboard -> billingcontroller: `GET /api/v1/billing/credits/usage`
7. billingcontroller -> billingservice: `getCreditUsage(user, query)`
8. billingservice -> agencyrepository: `Load owned agency`
9. agencyrepository --> billingservice: `Agency`
10. billingservice -> workspacememberrepos: `Load scoped membership`
11. workspacememberrepos --> billingservice: `WorkspaceMember`
12. billingservice --> billingcontroller: `401 Unauthorized / 403 Forbidden / 404 Not Found`
13. billingcontroller --> webdashboard: `401 Unauthorized / 403 Forbidden / 404 Not Found`
14. webdashboard --> userselfownermanaged: `Display access or resource error`
15. billingservice --> billingcontroller: `400 Bad Request / 403 Forbidden`
16. billingcontroller --> webdashboard: `400 Bad Request / 403 Forbidden`
17. webdashboard --> userselfownermanaged: `Display validation or scope error`
18. billingservice -> aicreditentryreposit: `Aggregate committed usage`
19. aicreditentryreposit --> billingservice: `usage`
20. billingservice -> aicreditworkspacelim: `Load workspace limit`
21. aicreditworkspacelim --> billingservice: `limit`
22. billingservice -> aicreditaccountrepos: `Load balance and reservations`
23. aicreditaccountrepos --> billingservice: `balance / reserved`
24. billingservice --> billingcontroller: `500 Internal Server Error`
25. billingcontroller --> webdashboard: `500 Internal Server Error`
26. webdashboard --> userselfownermanaged: `Display load error; do not show zero usage`
27. billingservice --> billingcontroller: `200 OK`
28. billingcontroller --> webdashboard: `200 OK`
29. webdashboard --> userselfownermanaged: `Display usage, limit, balance and reserved`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
