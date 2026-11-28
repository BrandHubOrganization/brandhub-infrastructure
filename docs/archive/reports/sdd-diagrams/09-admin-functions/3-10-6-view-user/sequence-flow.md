# Sequence Flow — View User

> Supplements `spec.md` (FR 3.10.6). This file lists each step as actor → action → system, in enough detail to draw the sequence diagram directly — it does not restate business rules (see spec.md for those).

## Actors

- **User** — actor tương tác chính trong quy trình.
- **Client** — giao diện người dùng `AdminAccountsPanel / AdminStrikeDialog (UI)`.
- **System** — `AdminController` / `AdminAccountQueryService`.

---

## Flow A — Luồng thực thi chính: View User

1. adminaccountspanelad -> admincontroller: `GET /api/v1/admin/users OR /users/{id}/violations`
2. admincontroller -> adminaccountqueryser: `list(actor, filter) / history(actor, userId, page)`
3. adminaccountqueryser -> adminaccountqueryser: `Validate filters and pagination`
4. systemadministrator -> adminaccountspanelad: `Search accounts or view strike history`
5. adminaccountqueryser -> adminaccountservice: `requireAdmin(actor)`
6. adminaccountservice --> adminaccountqueryser: `ADMIN verified (void) / BusinessException(FORBIDDEN)`
7. adminaccountqueryser --> admincontroller: `BusinessException(errorCode)`
8. admincontroller --> adminaccountspanelad: `403 / 400 — request rejected`
9. adminaccountspanelad --> systemadministrator: `Show the error; keep filters`
10. adminaccountqueryser -> userrepository: `findAdminUsers(search, status, role, pageable)`
11. userrepository --> adminaccountqueryser: `Page<User>, including an empty page`
12. adminaccountqueryser -> userrepository: `findById(userId)`
13. userrepository --> adminaccountqueryser: `Optional<User>`
14. adminaccountqueryser --> admincontroller: `BusinessException(USER_NOT_FOUND)`
15. admincontroller --> adminaccountspanelad: `404 — account not found`
16. adminaccountspanelad --> systemadministrator: `Show the error; return to account list`
17. adminaccountqueryser -> userstrikerepository: `findByUserIdOrderByCreatedAtDescIdDesc(userId, pageable)`
18. userstrikerepository --> adminaccountqueryser: `Page<UserStrike>`
19. adminaccountqueryser -> useruserstrike: `Read account and strike fields`
20. useruserstrike --> adminaccountqueryser: `Account IDs/status and history fields`
21. adminaccountqueryser -> sanctionreviewreposi: `findByUserIdInAndStatus(userIds, "PENDING")`
22. sanctionreviewreposi --> adminaccountqueryser: `Pending sanction reviews`
23. adminaccountqueryser -> userstrikerepository: `findByUserIdInAndRemovedAtIsNullAndExpiresAtAfter (userIds, now)`
24. userstrikerepository --> adminaccountqueryser: `Live strikes for counters`
25. adminaccountqueryser --> admincontroller: `AdminPageResponse<AdminUserResponse> / AdminStrikeSummary`
26. admincontroller --> adminaccountspanelad: `200 OK — includes valid empty pages`
27. adminaccountspanelad --> systemadministrator: `Show accounts, counters, history and pagination`

---

## Error paths

| Step | Failure condition | HTTP | ErrorCode |
|---|---|---|---|
| Xác thực | Token thiếu, hết hạn hoặc không hợp lệ | 401 | `UNAUTHORIZED` |
| Phân quyền | Vai trò người dùng không có quyền truy cập tính năng | 403 | `FORBIDDEN` |
| Kiểm tra dữ liệu | Dữ liệu đầu vào không hợp lệ hoặc xung đột trạng thái | 400 | `BAD_REQUEST` |
| Truy vấn | Không tìm thấy bản ghi đối tượng tương ứng | 404 | `NOT_FOUND` |
