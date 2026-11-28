# Sequence Flow — Set Credit

> Supplements `spec.md` (FR 3.9.7). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **OWNER (Workspace Agency)** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `Set Credit Page`.
- **System** — `BillingController` / `BillingService`.

---

## Flow A — Luồng thực thi chính: Set Credit

1. billingservice -> billingservice: `Validate OWNER role, nonnegative limit, period and expectedVersion`
2. ownerworkspaceagency -> webdashboard: `Confirm Workspace credit limit`
3. webdashboard -> billingcontroller: `PUT /api/v1/billing/credits/{agencyId}/limits`
4. billingcontroller -> billingservice: `setWorkspaceCreditLimit(user, command)`
5. billingservice -> workspacerepository: `Load workspace and agency OWNER access`
6. workspacerepository --> billingservice: `Workspace`
7. billingservice -> aicreditworkspacelim: `Load workspace credit limit and current usage`
8. aicreditworkspacelim --> billingservice: `AiCreditWorkspaceLimit`
9. billingservice --> billingcontroller: `400 Bad Request / 403 Forbidden / 409 Conflict`
10. billingcontroller --> webdashboard: `400 Bad Request / 403 Forbidden / 409 Conflict`
11. webdashboard --> ownerworkspaceagency: `Display validation or permission conflict error`
12. billingservice -> aicreditworkspacelim: `Save workspace limit with version check`
13. aicreditworkspacelim --> billingservice: `writeOutcome`
14. billingservice --> billingcontroller: `200 OK`
15. billingcontroller --> webdashboard: `200 OK`
16. webdashboard --> ownerworkspaceagency: `Display updated Workspace limit`
17. billingservice --> billingcontroller: `409 Conflict / 500 Internal Server Error`
18. billingcontroller --> webdashboard: `409 Conflict / 500 Internal Server Error`
19. webdashboard --> ownerworkspaceagency: `Display save error; retain previous values`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
